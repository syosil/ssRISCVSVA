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

module pico_formal_tb (
  input logic clk,
  input logic rst,

  input logic           mem_ready,
  input logic   [31:0]  mem_rdata,

  output logic  [31:0]  mem_addr,
  output logic  [31:0]  mem_wdata,
  output logic  [ 3:0]  mem_wstrb,
  output logic          mem_valid,
  output logic          mem_instr
);

  logic        rvfi_valid;
  logic [63:0] rvfi_order;
  logic [31:0] rvfi_insn;
  logic        rvfi_trap;
  logic        rvfi_halt;
  logic        rvfi_intr;
  logic [ 1:0] rvfi_mode;
  logic [ 1:0] rvfi_ixl;
  logic [ 4:0] rvfi_rs1_addr;
  logic [ 4:0] rvfi_rs2_addr;
  logic [ 4:0] rvfi_rd_addr;
  logic [31:0] rvfi_rs1_rdata;
  logic [31:0] rvfi_rs2_rdata;
  logic [31:0] rvfi_rd_wdata;
  logic [31:0] rvfi_pc_rdata;
  logic [31:0] rvfi_pc_wdata;
  logic [31:0] rvfi_mem_addr;
  logic [ 3:0] rvfi_mem_rmask;
  logic [ 3:0] rvfi_mem_wmask;
  logic [31:0] rvfi_mem_rdata;
  logic [31:0] rvfi_mem_wdata;

  // unused signals
  logic mem_la_read;
  logic mem_la_write;
  logic [31:0] mem_la_addr;
  logic [31:0] mem_la_wdata;
  logic [ 3:0] mem_la_wstrb;

  logic pcpi_valid;
  logic [31:0] pcpi_insn;
  logic [31:0] pcpi_rs1;
  logic [31:0] pcpi_rs2;

  logic [31:0] eoi;
  logic trap;
  logic [63:0] rvfi_csr_mcycle_rmask;
  logic [63:0] rvfi_csr_mcycle_wmask;
  logic [63:0] rvfi_csr_mcycle_rdata;
  logic [63:0] rvfi_csr_mcycle_wdata;
  logic [63:0] rvfi_csr_minstret_rmask;
  logic [63:0] rvfi_csr_minstret_wmask;
  logic [63:0] rvfi_csr_minstret_rdata;
  logic [63:0] rvfi_csr_minstret_wdata;
  logic trace_valid;
  logic [35:0] trace_data;

  picorv32 #(
    .ENABLE_COUNTERS(0),
    .ENABLE_COUNTERS64(0),
    .ENABLE_IRQ_QREGS(0),
    .ENABLE_IRQ_TIMER(0),
    .ENABLE_MUL(0),
    .ENABLE_DIV(0),
    .COMPRESSED_ISA(0)
    ) duv (
    .clk(clk),
    .resetn(!rst),
    .trap(trap),
    .mem_valid(mem_valid),
    .mem_instr(mem_instr),
    .mem_ready(mem_ready),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_wstrb(mem_wstrb),
    .mem_rdata(mem_rdata),
    .mem_la_read(mem_la_read),
    .mem_la_write(mem_la_write),
    .mem_la_addr(mem_la_addr),
    .mem_la_wdata(mem_la_wdata),
    .mem_la_wstrb(mem_la_wstrb),
    .pcpi_valid(pcpi_valid),
    .pcpi_insn(pcpi_insn),
    .pcpi_rs1(pcpi_rs1),
    .pcpi_rs2(pcpi_rs2),
    .pcpi_wr(1'b0),
    .pcpi_rd(32'b0),
    .pcpi_wait(1'b0),
    .pcpi_ready(1'b0),
    .irq(32'b0),
    .eoi(eoi),
    .rvfi_valid(rvfi_valid),
    .rvfi_order(rvfi_order),
    .rvfi_insn(rvfi_insn),
    .rvfi_trap(rvfi_trap),
    .rvfi_halt(rvfi_halt),
    .rvfi_intr(rvfi_intr),
    .rvfi_mode(rvfi_mode),
    .rvfi_ixl(rvfi_ixl),
    .rvfi_rs1_addr(rvfi_rs1_addr),
    .rvfi_rs2_addr(rvfi_rs2_addr),
    .rvfi_rs1_rdata(rvfi_rs1_rdata ),
    .rvfi_rs2_rdata(rvfi_rs2_rdata),
    .rvfi_rd_addr(rvfi_rd_addr),
    .rvfi_rd_wdata(rvfi_rd_wdata ),
    .rvfi_pc_rdata(rvfi_pc_rdata ),
    .rvfi_pc_wdata(rvfi_pc_wdata ),
    .rvfi_mem_addr(rvfi_mem_addr ),
    .rvfi_mem_rmask(rvfi_mem_rmask),
    .rvfi_mem_wmask(rvfi_mem_wmask),
    .rvfi_mem_rdata(rvfi_mem_rdata),
    .rvfi_mem_wdata(rvfi_mem_wdata),
    .rvfi_csr_mcycle_rmask(rvfi_csr_mcycle_rmask),
    .rvfi_csr_mcycle_wmask(rvfi_csr_mcycle_wmask),
    .rvfi_csr_mcycle_rdata(rvfi_csr_mcycle_rdata),
    .rvfi_csr_mcycle_wdata(rvfi_csr_mcycle_wdata),
    .rvfi_csr_minstret_rmask(rvfi_csr_minstret_rmask),
    .rvfi_csr_minstret_wmask(rvfi_csr_minstret_wmask),
    .rvfi_csr_minstret_rdata(rvfi_csr_minstret_rdata),
    .rvfi_csr_minstret_wdata(rvfi_csr_minstret_wdata),
    .trace_valid(trace_valid),
    .trace_data(trace_data)
  );

  rvfi_assertions_rv32i #(
    .ALIGNED_MEM(1'b1)
  ) rv32i_assertions (
    .clock(clk),
    .reset(rst),
    .rvfi_valid(rvfi_valid),
    .rvfi_trap(rvfi_trap),
    .rvfi_order(rvfi_order),
    .rvfi_insn(rvfi_insn),
    .rvfi_rd_addr(rvfi_rd_addr),
    .rvfi_rd_wdata(rvfi_rd_wdata),
    .rvfi_rs1_addr(rvfi_rs1_addr),
    .rvfi_rs1_rdata(rvfi_rs1_rdata),
    .rvfi_rs2_addr(rvfi_rs2_addr),
    .rvfi_rs2_rdata(rvfi_rs2_rdata),
    .rvfi_pc_rdata(rvfi_pc_rdata),
    .rvfi_pc_wdata(rvfi_pc_wdata),
    .rvfi_mem_addr(rvfi_mem_addr),
    .rvfi_mem_rmask(rvfi_mem_rmask),
    .rvfi_mem_wmask(rvfi_mem_wmask),
    .rvfi_mem_rdata(rvfi_mem_rdata),
    .rvfi_mem_wdata(rvfi_mem_wdata)
  );

  sanity_cover sanity_cover_i (
    .clk(clk),
    .rst(rst),
    .rvfi_valid(rvfi_valid),
    .rvfi_order(rvfi_order),
    .rvfi_insn(rvfi_insn),
    .rvfi_rd_addr(rvfi_rd_addr),
    .rvfi_rd_wdata(rvfi_rd_wdata),
    .rvfi_rs1_addr(rvfi_rs1_addr),
    .rvfi_rs1_rdata(rvfi_rs1_rdata),
    .rvfi_rs2_addr(rvfi_rs2_addr),
    .rvfi_rs2_rdata(rvfi_rs2_rdata),
    .rvfi_pc_rdata(rvfi_pc_rdata),
    .rvfi_pc_wdata(rvfi_pc_wdata),
    .rvfi_mem_addr(rvfi_mem_addr),
    .rvfi_mem_rmask(rvfi_mem_rmask),
    .rvfi_mem_wmask(rvfi_mem_wmask),
    .rvfi_mem_rdata(rvfi_mem_rdata),
    .rvfi_mem_wdata(rvfi_mem_wdata)
  );

  rvfi_pico_bindings bindings (
    .clk(clk),
    .rst(rst),
    .mem_valid(mem_valid),
    .mem_instr(mem_instr),
    .mem_ready(mem_ready),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    .mem_wstrb(mem_wstrb)
  );

endmodule: pico_formal_tb
