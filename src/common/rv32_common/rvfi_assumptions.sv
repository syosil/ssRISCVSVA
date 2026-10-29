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
import pkg_rv32_common::FUNCT3_OFFSET;
import pkg_rv32_common::FUNCT3_WIDTH;

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

import pkg_rv32i::FUNCT3_ADD;
import pkg_rv32i::FUNCT3_SLL;
import pkg_rv32i::FUNCT3_SLT;
import pkg_rv32i::FUNCT3_SLTU;
import pkg_rv32i::FUNCT3_XOR;
import pkg_rv32i::FUNCT3_SRL;
import pkg_rv32i::FUNCT3_OR;
import pkg_rv32i::FUNCT3_AND;
import pkg_rv32i::FUNCT3_JALR;
import pkg_rv32i::FUNCT3_BEQ;
import pkg_rv32i::FUNCT3_BNE;
import pkg_rv32i::FUNCT3_BLT;
import pkg_rv32i::FUNCT3_BGE;
import pkg_rv32i::FUNCT3_BLTU;
import pkg_rv32i::FUNCT3_BGEU;
import pkg_rv32i::FUNCT3_LB;
import pkg_rv32i::FUNCT3_LH;
import pkg_rv32i::FUNCT3_LW;
import pkg_rv32i::FUNCT3_LBU;
import pkg_rv32i::FUNCT3_LHU;

module rvfi_assumptions (
  input logic        clk,
  input logic        rst,
  input logic        rvfi_valid,
  input logic [31:0] rvfi_insn
);

  asm_valid_op_sel : assume property (
    @(posedge clk) disable iff (rst)
    (rvfi_valid)
    |-> (rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH] inside {
      OPCODE_OP,
      OPCODE_OP_IMM,
      OPCODE_JALR,
      OPCODE_JAL,
      OPCODE_LUI,
      OPCODE_AUIPC,
      OPCODE_BRANCH,
      OPCODE_STORE,
      OPCODE_LOAD
      })
  );
  asm_valid_funct7_sel : assume property (
    @(posedge clk) disable iff (rst)
    (rvfi_valid && rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_OP)
    |-> (rvfi_insn[FUNCT7_OFFSET +: FUNCT7_WIDTH] inside {FUNCT7_ADD, FUNCT7_SUB})
  );
  asm_valid_jalr_funct3_sel : assume property (
    @(posedge clk) disable iff (rst)
    (rvfi_valid && rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_JALR)
    |-> (rvfi_insn[FUNCT3_OFFSET +: FUNCT3_WIDTH] == FUNCT3_JALR)
  );
  asm_valid_branch_funct3_sel : assume property (
    @(posedge clk) disable iff (rst)
    (rvfi_valid && rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_BRANCH)
    |-> (rvfi_insn[FUNCT3_OFFSET +: FUNCT3_WIDTH] inside {
      FUNCT3_BEQ,
      FUNCT3_BNE,
      FUNCT3_BLT,
      FUNCT3_BGE,
      FUNCT3_BLTU,
      FUNCT3_BGEU})
  );
  asm_valid_load_funct3_sel : assume property (
    @(posedge clk) disable iff (rst)
    (rvfi_valid && rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_LOAD)
    |-> (rvfi_insn[FUNCT3_OFFSET +: FUNCT3_WIDTH] inside {
      FUNCT3_LB,
      FUNCT3_LH,
      FUNCT3_LW,
      FUNCT3_LBU,
      FUNCT3_LHU})
  );

endmodule: rvfi_assumptions
