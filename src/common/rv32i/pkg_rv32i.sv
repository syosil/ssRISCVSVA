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

package pkg_rv32i;
  localparam OPCODE_OP     = 7'b0110011;
  localparam OPCODE_OP_IMM = 7'b0010011;
  localparam OPCODE_JALR   = 7'b1100111;
  localparam OPCODE_JAL    = 7'b1101111;
  localparam OPCODE_LUI    = 7'b0110111;
  localparam OPCODE_AUIPC  = 7'b0010111;
  localparam OPCODE_BRANCH = 7'b1100011;
  localparam OPCODE_STORE  = 7'b0100011;
  localparam OPCODE_LOAD   = 7'b0000011;

  localparam FUNCT3_JALR = 3'b000;

  localparam FUNCT3_ADD  = 3'b000;
  localparam FUNCT3_SLL  = 3'b001;
  localparam FUNCT3_SLT  = 3'b010;
  localparam FUNCT3_SLTU = 3'b011;
  localparam FUNCT3_XOR  = 3'b100;
  localparam FUNCT3_SRL  = 3'b101;
  localparam FUNCT3_SRA  = 3'b101;
  localparam FUNCT3_OR   = 3'b110;
  localparam FUNCT3_AND  = 3'b111;

  localparam FUNCT3_BEQ  = 3'b000;
  localparam FUNCT3_BNE  = 3'b001;
  localparam FUNCT3_BLT  = 3'b100;
  localparam FUNCT3_BGE  = 3'b101;
  localparam FUNCT3_BLTU = 3'b110;
  localparam FUNCT3_BGEU = 3'b111;

  localparam FUNCT3_SB  = 3'b000;
  localparam FUNCT3_SH  = 3'b001;
  localparam FUNCT3_SW  = 3'b010;

  localparam FUNCT3_LB  = 3'b000;
  localparam FUNCT3_LH  = 3'b001;
  localparam FUNCT3_LW  = 3'b010;
  localparam FUNCT3_LBU = 3'b100;
  localparam FUNCT3_LHU = 3'b101;

  localparam FUNCT7_ADD  = 7'b000_0000;
  localparam FUNCT7_SUB  = 7'b010_0000;
  localparam FUNCT7_SLL  = 7'b000_0000;
  localparam FUNCT7_SLT  = 7'b000_0000;
  localparam FUNCT7_SLTU = 7'b000_0000;
  localparam FUNCT7_XOR  = 7'b000_0000;
  localparam FUNCT7_SRL  = 7'b000_0000;
  localparam FUNCT7_SRA  = 7'b010_0000;
  localparam FUNCT7_OR   = 7'b000_0000;
  localparam FUNCT7_AND  = 7'b000_0000;

endpackage: pkg_rv32i
