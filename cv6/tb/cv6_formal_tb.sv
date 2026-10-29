//----------------------------------------------------------------------
// Copyright 2005-2026 SyoSil ApS
// All Rights Reserved Worldwide
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
// implied. See the License for the specific language governing permissions and limitations under the
// License.
//----------------------------------------------------------------------

`include "rvfi_types.svh"
`include "cvxif_types.svh"

import ariane_pkg::*;

module cv6_formal_tb #(
  parameter config_pkg::cva6_cfg_t CVA6Cfg = build_config_pkg::build_config(
      cva6_config_pkg::cva6_cfg
  ),
  // AXI types
  parameter type axi_ar_chan_t = struct packed {
    logic [CVA6Cfg.AxiIdWidth-1:0]   id;
    logic [CVA6Cfg.AxiAddrWidth-1:0] addr;
    axi_pkg::len_t                   len;
    axi_pkg::size_t                  size;
    axi_pkg::burst_t                 burst;
    logic                            lock;
    axi_pkg::cache_t                 cache;
    axi_pkg::prot_t                  prot;
    axi_pkg::qos_t                   qos;
    axi_pkg::region_t                region;
    logic [CVA6Cfg.AxiUserWidth-1:0] user;
  },

  parameter type axi_aw_chan_t = struct packed {
    logic [CVA6Cfg.AxiIdWidth-1:0]   id;
    logic [CVA6Cfg.AxiAddrWidth-1:0] addr;
    axi_pkg::len_t                   len;
    axi_pkg::size_t                  size;
    axi_pkg::burst_t                 burst;
    logic                            lock;
    axi_pkg::cache_t                 cache;
    axi_pkg::prot_t                  prot;
    axi_pkg::qos_t                   qos;
    axi_pkg::region_t                region;
    axi_pkg::atop_t                  atop;
    logic [CVA6Cfg.AxiUserWidth-1:0] user;
  },

  parameter type axi_w_chan_t = struct packed {
    logic [CVA6Cfg.AxiDataWidth-1:0]     data;
    logic [(CVA6Cfg.AxiDataWidth/8)-1:0] strb;
    logic                                last;
    logic [CVA6Cfg.AxiUserWidth-1:0]     user;
  },

  parameter type b_chan_t = struct packed {
    logic [CVA6Cfg.AxiIdWidth-1:0]   id;
    axi_pkg::resp_t                  resp;
    logic [CVA6Cfg.AxiUserWidth-1:0] user;
  },

  parameter type r_chan_t = struct packed {
    logic [CVA6Cfg.AxiIdWidth-1:0]   id;
    logic [CVA6Cfg.AxiDataWidth-1:0] data;
    axi_pkg::resp_t                  resp;
    logic                            last;
    logic [CVA6Cfg.AxiUserWidth-1:0] user;
  },

  parameter type noc_req_t = struct packed {
    axi_aw_chan_t aw;
    logic         aw_valid;
    axi_w_chan_t  w;
    logic         w_valid;
    logic         b_ready;
    axi_ar_chan_t ar;
    logic         ar_valid;
    logic         r_ready;
  },

  parameter type noc_resp_t = struct packed {
    logic    aw_ready;
    logic    ar_ready;
    logic    w_ready;
    logic    b_valid;
    b_chan_t b;
    logic    r_valid;
    r_chan_t r;
  },
  parameter type exception_t = struct packed {
    logic [CVA6Cfg.XLEN-1:0]  cause;  // cause of exception
    logic [CVA6Cfg.XLEN-1:0]  tval;   // additional information of causing exception (e.g.: instruction causing it),
    logic [CVA6Cfg.GPLEN-1:0] tval2;  // additional information when the causing exception in a guest exception
    logic [31:0]              tinst;  // transformed instruction information
    logic                     gva;    // signals when a guest virtual address is written to tval
    logic                     valid;
  },
  parameter type icache_dreq_t = struct packed {
    logic                    req;      // we request a new word
    logic                    kill_s1;  // kill the current request
    logic                    kill_s2;  // kill the last request
    logic                    spec;     // request is speculative
    logic [CVA6Cfg.VLEN-1:0] vaddr;    // 1st cycle: 12 bit index is taken for lookup
  },
  parameter type icache_drsp_t = struct packed {
    logic                                ready;  // icache is ready
    logic                                valid;  // signals a valid read
    logic [CVA6Cfg.FETCH_WIDTH-1:0]      data;   // 2+ cycle out: tag
    logic [CVA6Cfg.FETCH_USER_WIDTH-1:0] user;   // User bits
    logic [CVA6Cfg.VLEN-1:0]             vaddr;  // virtual address out
    exception_t                          ex;     // we've encountered an exception
  },
  parameter int AXI_MAX_LATENCY = 1,    // Maximum response latency on an AXI Read request on NOC signals
  parameter int CACHE_MAX_LATENCY = 3   // Maximum response latency from caches. Must be > 2 if NOC should be activated upon cache misses
  ) (
  input logic clk,
  input logic rst,
  output noc_req_t noc_req_o,
  input noc_resp_t noc_resp_i
  );


  logic rst_n;
  assign rst_n = ~rst;


  // probes struct, returned from cva6 core
  // the rvfi_probes_* are defined in core/include/rvfi_types.svh
  localparam type rvfi_probes_instr_t = `RVFI_PROBES_INSTR_T(CVA6Cfg);
  localparam type rvfi_probes_csr_t = `RVFI_PROBES_CSR_T(CVA6Cfg);
  localparam type rvfi_probes_t = struct packed {
    rvfi_probes_csr_t   csr;
    rvfi_probes_instr_t instr;
  };

  localparam type rvfi_instr_t = `RVFI_INSTR_T(CVA6Cfg);
  localparam type rvfi_csr_elmt_t = `RVFI_CSR_ELMT_T(CVA6Cfg);
  localparam type rvfi_csr_t = `RVFI_CSR_T(CVA6Cfg, rvfi_csr_elmt_t);

  rvfi_instr_t[CVA6Cfg.NrCommitPorts-1:0] rvfi_instr;

  // probes from cva6 core
  rvfi_probes_t rvfi_probes;

  // rvfi signals
  rvfi_csr_t   rvfi_csr;

  localparam CVA6ConfigXlen_tb = CVA6Cfg.XLEN;

  cva6 #(
    .CVA6Cfg(CVA6Cfg)
    )
  duv (
    .clk_i(clk),
    .rst_ni(rst_n),
    .boot_addr_i('h80000000),
    .hart_id_i('0),
    .irq_i('0),
    .ipi_i('0),
    .time_irq_i('0),
    .debug_req_i('0),
    .rvfi_probes_o(rvfi_probes),
    .cvxif_req_o(),
    .cvxif_resp_i('0),
    .noc_req_o(noc_req_o),
    .noc_resp_i(noc_resp_i)
  );

  // rvfi_probes to rvfi module
  cva6_rvfi #(
    .CVA6Cfg(CVA6Cfg),
    .rvfi_instr_t(rvfi_instr_t),
    .rvfi_csr_t(rvfi_csr_t),
    .rvfi_probes_instr_t(rvfi_probes_instr_t),
    .rvfi_probes_csr_t(rvfi_probes_csr_t),
    .rvfi_probes_t(rvfi_probes_t)
  ) i_cva6_rvfi (
    .clk_i(clk),
    .rst_ni(rst_n),
    .rvfi_probes_i(rvfi_probes),
    .rvfi_instr_o(rvfi_instr),
    .rvfi_csr_o(rvfi_csr)
  );

  cv6_axi_assumptions #(
    .ARLEN_WIDTH($bits(axi_pkg::len_t)),
    .RSP_MAX_LATENCY(AXI_MAX_LATENCY)
  ) asm_axi (
    .ACLK(clk),
    .ARESETn(rst_n),
    .ARVALID(noc_req_o.ar_valid),
    .ARLEN(noc_req_o.ar.len),
    .RVALID(noc_resp_i.r_valid),
    .RLAST(duv.noc_resp_i.r.last),
    .RRESP(duv.noc_resp_i.r.resp),
    .AWREADY(noc_req_o.r_ready),
    .WREADY(noc_resp_i.w_ready),
    .ARREADY(noc_resp_i.ar_ready)
  );

  cv6_icache_assumptions #(
    .MAX_CACHE_DELAY(CACHE_MAX_LATENCY),
    .icache_dreq_t(icache_dreq_t),
    .icache_drsp_t(icache_drsp_t)
  ) asm_icache (
    .clk(clk),
    .rst(rst),
    .dreq_i(duv.gen_cache_hpd.i_cache_subsystem.icache_dreq_i),
    .dreq_o(duv.gen_cache_hpd.i_cache_subsystem.icache_dreq_o)
  );

  cv6_instruction_assumptions #(
    .FETCH_WIDTH(CVA6Cfg.FETCH_WIDTH),
    .icache_drsp_t(icache_drsp_t)
  ) asm_instr (
    .clk(clk),
    .rst(rst),
    .icache_dreq_o(duv.gen_cache_hpd.i_cache_subsystem.icache_dreq_o)
  );

  generate
    for (genvar i = 0; i < CVA6Cfg.NrCommitPorts; i++) begin : gen_SVA

      rvfi_assertions_rv32i #(
        .ALIGNED_MEM(1'b0)
      ) rvfi_rv32i_assertions (
        .clock(clk),
        .reset(rst),
        .rvfi_valid(rvfi_instr[i].valid),
        .rvfi_trap(rvfi_instr[i].trap),
        .rvfi_order(rvfi_instr[i].order),
        .rvfi_insn(rvfi_instr[i].insn),
        .rvfi_rd_addr(rvfi_instr[i].rd_addr),
        .rvfi_rd_wdata(rvfi_instr[i].rd_wdata),
        .rvfi_rs1_addr(rvfi_instr[i].rs1_addr),
        .rvfi_rs1_rdata(rvfi_instr[i].rs1_rdata),
        .rvfi_rs2_addr(rvfi_instr[i].rs2_addr),
        .rvfi_rs2_rdata(rvfi_instr[i].rs2_rdata),
        .rvfi_pc_rdata(rvfi_instr[i].pc_rdata),
        .rvfi_pc_wdata(rvfi_instr[i].pc_wdata),
        .rvfi_mem_addr(rvfi_instr[i].mem_addr),
        .rvfi_mem_rmask(rvfi_instr[i].mem_rmask),
        .rvfi_mem_wmask(rvfi_instr[i].mem_wmask),
        .rvfi_mem_rdata(rvfi_instr[i].mem_rdata),
        .rvfi_mem_wdata(rvfi_instr[i].mem_wdata)
      );

      sanity_cover #(.XLEN_COVER(CVA6ConfigXlen_tb)
        ) sanity_cover_i (
        .clk(clk),
        .rst(rst),
        .rvfi_valid(rvfi_instr[i].valid),
        .rvfi_order(rvfi_instr[i].order),
        .rvfi_insn(rvfi_instr[i].insn),
        .rvfi_rd_addr(rvfi_instr[i].rd_addr),
        .rvfi_rd_wdata(rvfi_instr[i].rd_wdata),
        .rvfi_rs1_addr(rvfi_instr[i].rs1_addr),
        .rvfi_rs1_rdata(rvfi_instr[i].rs1_rdata),
        .rvfi_rs2_addr(rvfi_instr[i].rs2_addr),
        .rvfi_rs2_rdata(rvfi_instr[i].rs2_rdata),
        .rvfi_pc_rdata(rvfi_instr[i].pc_rdata),
        .rvfi_pc_wdata(rvfi_instr[i].pc_wdata),
        .rvfi_mem_addr(rvfi_instr[i].mem_addr),
        .rvfi_mem_rmask(rvfi_instr[i].mem_rmask),
        .rvfi_mem_wmask(rvfi_instr[i].mem_wmask),
        .rvfi_mem_rdata(rvfi_instr[i].mem_rdata),
        .rvfi_mem_wdata(rvfi_instr[i].mem_wdata)
      );
    end
  endgenerate

endmodule : cv6_formal_tb
