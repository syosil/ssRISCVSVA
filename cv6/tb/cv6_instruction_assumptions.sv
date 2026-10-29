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

import pkg_rv32i::FUNCT7_ADD;
import pkg_rv32i::FUNCT7_SUB;

module cv6_instruction_assumptions #(
  parameter int FETCH_WIDTH     = 32,
  parameter type icache_drsp_t  = logic
) (
  input logic clk,
  input logic rst,
  input icache_drsp_t icache_dreq_o
);

  generate
    for (genvar i = 0; i < FETCH_WIDTH; i += 32) begin : gen_legal_instructions
      asm_valid_op : assume property (
        @(posedge clk) disable iff (rst)
        (icache_dreq_o.valid)
        |-> (icache_dreq_o.data[OPCODE_OFFSET+i +: OPCODE_WIDTH] inside {
          OPCODE_OP,
          OPCODE_OP_IMM,
          OPCODE_JAL,
          OPCODE_JALR,
          OPCODE_AUIPC,
          OPCODE_LUI,
          OPCODE_BRANCH,
          OPCODE_STORE,
          OPCODE_LOAD
        })
      );

      asm_valid_funct7 : assume property (
        @(posedge clk) disable iff (rst)
        (icache_dreq_o.data[OPCODE_OFFSET+i +: OPCODE_WIDTH] == OPCODE_OP)
        |-> (icache_dreq_o.data[FUNCT7_OFFSET+i +: FUNCT7_WIDTH] inside {FUNCT7_ADD, FUNCT7_SUB})
      );

      asm_valid_funct3_sub : assume property (
        @(posedge clk) disable iff (rst)
          (icache_dreq_o.data[OPCODE_OFFSET+i +: OPCODE_WIDTH] == OPCODE_OP && icache_dreq_o.data[FUNCT7_OFFSET+i +: FUNCT7_WIDTH] == FUNCT7_SUB)
          |-> (icache_dreq_o.data[FUNCT3_OFFSET+i +: FUNCT3_WIDTH] inside {FUNCT3_ADD, FUNCT3_SRL})
      );
      asm_valid_funct3_add : assume property (
        @(posedge clk) disable iff (rst)
          (icache_dreq_o.data[OPCODE_OFFSET+i +: OPCODE_WIDTH] == OPCODE_OP && icache_dreq_o.data[FUNCT7_OFFSET+i +: FUNCT7_WIDTH] == FUNCT7_ADD)
          |-> (icache_dreq_o.data[FUNCT3_OFFSET+i +: FUNCT3_WIDTH] inside {
              FUNCT3_ADD,
              FUNCT3_SLL,
              FUNCT3_SLT,
              FUNCT3_SLTU,
              FUNCT3_XOR,
              FUNCT3_SRL,
              FUNCT3_OR,
              FUNCT3_AND
          })
        );
      asm_valid_funct3_jalr : assume property (
        @(posedge clk) disable iff (rst)
        (icache_dreq_o.data[OPCODE_OFFSET+i +: OPCODE_WIDTH] == OPCODE_JALR)
        |-> (icache_dreq_o.data[FUNCT3_OFFSET+i +: FUNCT3_WIDTH] == FUNCT3_JALR)
      );
      asm_valid_funct3_branch : assume property (
        @(posedge clk) disable iff (rst)
        (icache_dreq_o.data[OPCODE_OFFSET+i +: OPCODE_WIDTH] == OPCODE_BRANCH)
        |-> (icache_dreq_o.data[FUNCT3_OFFSET+i +: FUNCT3_WIDTH] inside {
            FUNCT3_BEQ,
            FUNCT3_BNE,
            FUNCT3_BLT,
            FUNCT3_BGE,
            FUNCT3_BLTU,
            FUNCT3_BGEU
          })
        );
      asm_valid_load_funct3_sel : assume property (
        @(posedge clk) disable iff (rst)
        (icache_dreq_o.data[OPCODE_OFFSET+i +: OPCODE_WIDTH] == OPCODE_LOAD)
        |-> (icache_dreq_o.data[FUNCT3_OFFSET+i +: FUNCT3_WIDTH] inside {
          FUNCT3_LB,
          FUNCT3_LH,
          FUNCT3_LW,
          FUNCT3_LBU,
          FUNCT3_LHU})
      );
    end : gen_legal_instructions
  endgenerate

endmodule : cv6_instruction_assumptions
