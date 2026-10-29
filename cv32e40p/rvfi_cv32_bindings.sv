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

import pkg_rv32_common::OPCODE_OFFSET;
import pkg_rv32_common::OPCODE_WIDTH;
import pkg_rv32_common::FUNCT7_OFFSET;
import pkg_rv32_common::FUNCT7_WIDTH;

import pkg_rv32i::OPCODE_OP;
import pkg_rv32i::OPCODE_OP_IMM;
import pkg_rv32i::OPCODE_JAL;
import pkg_rv32i::OPCODE_JALR;
import pkg_rv32i::OPCODE_AUIPC;
import pkg_rv32i::OPCODE_LUI;
import pkg_rv32i::OPCODE_BRANCH;
import pkg_rv32i::OPCODE_STORE;
import pkg_rv32i::OPCODE_LOAD;

module rvfi_cv32_bindings (
  // Clock and Reset
  input logic clk_i,
  input logic rst_ni,

  // Instruction memory interface
  input logic        instr_req_o,
  input logic        instr_gnt_i,
  input logic        instr_rvalid_i,
  input logic [31:0] instr_addr_o,
  input logic [31:0] instr_rdata_i,

  // Data memory interface
  input logic        data_req_o,
  input logic        data_gnt_i,
  input logic        data_rvalid_i,
  input logic        data_we_o,
  input logic [ 3:0] data_be_o,
  input logic [31:0] data_addr_o,
  input logic [31:0] data_wdata_o,
  input logic [31:0] data_rdata_i
);

  //instr_gnt_i should go high 1 clk_i cycles after instr_req_o goes high
  //Should be low on the very first clk_i cycle coming out of rst_ni
  asm_imem_delayed_ack_after_req: assume property (
    @(posedge clk_i) disable iff (~rst_ni)
    (instr_req_o |-> ##[1:1] (instr_rvalid_i) ) and
    ($past(~rst_ni) |-> !instr_rvalid_i)
  );

  //instr_rdata_i should be stable for any given value of instr_addr_o
  asm_imem_stable_data: assume property (
    @(posedge clk_i) disable iff (~rst_ni)
    $past(instr_addr_o,2) == $past(instr_addr_o) |-> instr_rdata_i == $past(instr_rdata_i)
  );

  //data_gnt_i should go high 1 clk_i cycles after data_req_o goes high
  // Once it has gone high, if req is not high, it should go low on the next cc
  asm_dmem_delayed_ack_after_req: assume property (
    @(posedge clk_i) disable iff (~rst_ni)
    (data_req_o |-> ##[1:1] (data_rvalid_i))
  );

  //Only some opcodes should be generated
  asm_only_select_opcodes: assume property (
    @(posedge clk_i) disable iff (~rst_ni)
    instr_rdata_i[OPCODE_OFFSET +: OPCODE_WIDTH] inside {
      OPCODE_OP,
      OPCODE_OP_IMM,
      OPCODE_JAL,
      OPCODE_JALR,
      OPCODE_AUIPC,
      OPCODE_LUI,
      OPCODE_BRANCH,
      OPCODE_STORE,
      OPCODE_LOAD
    }
  );

  asm_always_rdy : assume property (
    @(posedge clk_i) disable iff (~rst_ni)
    (glue.core.core_i.id_stage_i.id_ready_o == 1'b1) and
    (glue.core.core_i.ex_stage_i.ex_ready_o == 1'b1) and
    (glue.core.core_i.load_store_unit_i.lsu_ready_ex_o == 1'b1) and
    (glue.core.core_i.load_store_unit_i.lsu_ready_wb_o == 1'b1)
  );

endmodule: rvfi_cv32_bindings
