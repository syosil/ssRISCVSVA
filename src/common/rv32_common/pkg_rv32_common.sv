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

package pkg_rv32_common;
  localparam OPCODE_OFFSET = 0;
  localparam OPCODE_WIDTH  = 7;
  localparam RD_OFFSET     = 7;
  localparam RD_WIDTH      = 5;
  localparam FUNCT3_OFFSET = 12;
  localparam FUNCT3_WIDTH  = 3;
  localparam FUNCT7_OFFSET = 25;
  localparam FUNCT7_WIDTH  = 7;

  import pkg_rv32i::OPCODE_OP_IMM;
  import pkg_rv32i::OPCODE_JALR;
  import pkg_rv32i::OPCODE_JAL;
  import pkg_rv32i::OPCODE_LUI;
  import pkg_rv32i::OPCODE_AUIPC;
  import pkg_rv32i::OPCODE_BRANCH;
  import pkg_rv32i::OPCODE_STORE;
  import pkg_rv32i::OPCODE_LOAD;

  function bit fc_is_valid_rd(logic [31:0] instr);
    return (instr[RD_OFFSET +: RD_WIDTH] != 0);
  endfunction : fc_is_valid_rd

  function automatic logic fc_is_valid_retire(
    logic valid,
    logic trap
  );
    return valid && !trap;
  endfunction : fc_is_valid_retire

  function automatic logic fc_is_valid_retire_rd(
    logic                  valid,
    logic                  trap,
    logic [RD_WIDTH-1:0]   rd
  );
    return fc_is_valid_retire(valid, trap) && rd != '0;
  endfunction : fc_is_valid_retire_rd

  function bit fc_itype_insn_check(logic [31:0] insn);
    if (insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_OP_IMM) return 1'b1;
    if (insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_JALR)   return 1'b1;
    if (insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_LOAD)   return 1'b1;
    return 1'b0;
  endfunction : fc_itype_insn_check

  function bit fc_jtype_insn_check(logic [31:0] insn);
    return insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_JAL ? 1'b1 : 1'b0;
  endfunction : fc_jtype_insn_check

  function bit fc_utype_insn_check(logic [31:0] insn);
    if (insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_LUI)   return 1'b1;
    if (insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_AUIPC) return 1'b1;
    return 1'b0;
  endfunction : fc_utype_insn_check

  function bit fc_btype_insn_check(logic [31:0] insn);
    return insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_BRANCH ? 1'b1 : 1'b0;
  endfunction : fc_btype_insn_check

  function bit fc_stype_insn_check(logic [31:0] insn);
    return insn[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_STORE ? 1'b1 : 1'b0;
  endfunction : fc_stype_insn_check

  function logic[31:0] fc_itype_imm(logic[31:0] insn);
    return {{20{insn[31]}}, insn[31:20]};
  endfunction : fc_itype_imm

  function logic[31:0] fc_jtype_imm(logic[31:0] insn);
    return {{12{insn[31]}},insn[19:12],insn[20],insn[30:21],1'b0};
  endfunction : fc_jtype_imm

  function logic[31:0] fc_utype_imm(logic[31:0] insn);
    return {insn[31:12], 12'b0};
  endfunction : fc_utype_imm

  function logic[31:0] fc_btype_imm(logic[31:0] insn);
    return {{19{insn[31]}}, insn[31], insn[7], insn[30:25], insn[11:8], 1'b0};
  endfunction : fc_btype_imm

  function logic[31:0] fc_stype_imm(logic[31:0] insn);
    return {{20{insn[31]}}, insn[31:25], insn[11:7]};
  endfunction : fc_stype_imm

  function logic[31:0] immediate_decoder(logic [31:0] insn);
    if (fc_itype_insn_check(insn)) return fc_itype_imm(insn);
    if (fc_jtype_insn_check(insn)) return fc_jtype_imm(insn);
    if (fc_utype_insn_check(insn)) return fc_utype_imm(insn);
    if (fc_btype_insn_check(insn)) return fc_btype_imm(insn);
    if (fc_stype_insn_check(insn)) return fc_stype_imm(insn);
    return 32'b0;
  endfunction : immediate_decoder

endpackage : pkg_rv32_common
