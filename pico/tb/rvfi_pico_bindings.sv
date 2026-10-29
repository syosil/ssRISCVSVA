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
import pkg_rv32i::OPCODE_LUI;
import pkg_rv32i::OPCODE_AUIPC;
import pkg_rv32i::OPCODE_BRANCH;
import pkg_rv32i::OPCODE_STORE;
import pkg_rv32i::OPCODE_LOAD;

import pkg_rv32i::FUNCT7_ADD;
import pkg_rv32i::FUNCT7_SUB;

module rvfi_pico_bindings (
  //clk and rst
  input             clk,
  input             rst,

  input mem_valid,
  input mem_instr,
  input mem_ready,

  input [31:0] mem_addr,
  input [31:0] mem_wdata,
  input [31:0] mem_rdata,
  input [ 3:0] mem_wstrb

);

// Keep mem_ready && mem_rdata stable
asm_mem_ready_stb : assume property (
  @(posedge clk) disable iff (rst)
  (mem_valid |-> ##[1:1] mem_ready)
);

asm_mem_stable_data: assume property (
  @(posedge clk) disable iff (rst)
  $past(mem_addr,2) == $past(mem_addr) |-> mem_rdata == $past(mem_rdata)
);

//assumption for normal 32-bit instructins
asm_only_select_opcodes: assume property (
  @(posedge clk) disable iff (rst)
  (mem_valid && mem_instr)
  |-> (mem_rdata[OPCODE_OFFSET +: OPCODE_WIDTH] inside {
    OPCODE_OP,
    OPCODE_OP_IMM,
    OPCODE_JAL,
    OPCODE_JALR,
    OPCODE_LUI,
    OPCODE_AUIPC,
    OPCODE_BRANCH,
    OPCODE_STORE,
    OPCODE_LOAD
  })
);


//Valid OP instructions
asm_valid_rtype: assume property (
  @(posedge clk) disable iff (rst)
  (mem_rdata[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_OP)
  |-> (mem_rdata[FUNCT7_OFFSET +: FUNCT7_WIDTH] inside {FUNCT7_ADD, FUNCT7_SUB})
);

endmodule: rvfi_pico_bindings
