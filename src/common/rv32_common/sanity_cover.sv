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

module  sanity_cover #(
  parameter int XLEN_COVER = 32
)(
  input logic clk,
  input logic rst,
  //RVFI signals
  input logic        rvfi_valid,
  input logic [31:0] rvfi_insn,
  input logic [63:0] rvfi_order,
  //register signals
  input logic [ 4:0] rvfi_rs1_addr,
  input logic [ 4:0] rvfi_rs2_addr,
  input logic [31:0] rvfi_rs1_rdata,
  input logic [31:0] rvfi_rs2_rdata,
  input logic [ 4:0] rvfi_rd_addr,
  input logic [31:0] rvfi_rd_wdata,
  //pc signals
  input logic [31:0] rvfi_pc_rdata,
  input logic [31:0] rvfi_pc_wdata,
  //memory bus
  input logic [31:0] rvfi_mem_addr,
  input logic [ 3:0] rvfi_mem_rmask,
  input logic [ 3:0] rvfi_mem_wmask,
  input logic [31:0] rvfi_mem_rdata,
  input logic [31:0] rvfi_mem_wdata
  );


  import pkg_rv32_common::OPCODE_OFFSET;
  import pkg_rv32_common::OPCODE_WIDTH;
  import pkg_rv32_common::FUNCT7_OFFSET;
  import pkg_rv32_common::FUNCT7_WIDTH;
  import pkg_rv32i::OPCODE_OP;
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
  import pkg_rv32_common::immediate_decoder;


  localparam logic [XLEN_COVER-1:0] MIN32     =32'h00000000;
  localparam logic [XLEN_COVER-1:0] MAX32     =32'hFFFFFFFF;
  localparam logic [XLEN_COVER-1:0] DEMORS1   =32'h00000010;
  localparam logic [XLEN_COVER-1:0] DEMORS2   =32'h00000001;
  localparam logic [XLEN_COVER-1:0] RANDOMRS1 =32'h00000111;
  localparam logic [XLEN_COVER-1:0] RANDOMRS2 =32'hFFFF0001;
  localparam logic [XLEN_COVER-1:0] UNKNOWN32 =32'hXXXXXXXX;


  // Helper macro
  `define RVFI_COVER(_name, _expr) \
    _name: cover property (@(posedge clk) disable iff (rst) _expr);

  `define RVFI_VALID_INSN(_op) \
    (rvfi_valid && fc_is_valid_``_op(rvfi_valid, rvfi_insn))

  //Assumption cover checks
  `RVFI_COVER(cv_opcode,
    rvfi_valid && rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH] inside {OPCODE_OP}
  )

  `RVFI_COVER(cv_func7,
    rvfi_valid && (rvfi_insn[FUNCT7_OFFSET +: FUNCT7_WIDTH] inside {FUNCT7_ADD, FUNCT7_SUB})
  )



  //signal validity checks
  `RVFI_COVER(cv_valid_rs1,
    (rvfi_valid && rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH] inside {OPCODE_OP} && (rvfi_rs1_rdata!==UNKNOWN32))
  )

  `RVFI_COVER(cv_valid_rs2,
    (rvfi_valid && rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH] inside {OPCODE_OP} && (rvfi_rs2_rdata!==UNKNOWN32))
  )

  `RVFI_COVER(cv_valid_rs1_rs2,
    (rvfi_valid && rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH]inside {OPCODE_OP} && (rvfi_rs1_rdata!==UNKNOWN32) && (rvfi_rs2_rdata!==UNKNOWN32))
  )

  `RVFI_COVER(cv_valid_rd_rdata,
    (rvfi_valid && rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH] inside {OPCODE_OP} && (rvfi_rs1_rdata!==UNKNOWN32) && (rvfi_rs2_rdata!==UNKNOWN32))
  )



  //address match
  `RVFI_COVER(cv_addrs_match,
    (rvfi_valid && rvfi_insn[OPCODE_OFFSET +: OPCODE_WIDTH] inside {OPCODE_OP} && rvfi_rs1_addr == rvfi_insn[19:15] && (rvfi_rs2_addr == rvfi_insn[24:20]) && (rvfi_rd_addr  == rvfi_insn[11:7]))
  )



  // add cover points
  `RVFI_COVER(cv_common_antecedent_add,
    (rvfi_valid && fc_is_valid_add(rvfi_valid, rvfi_insn))
  )

  `RVFI_COVER(cv_min_add,
    (rvfi_valid && fc_is_valid_add(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32) && (rvfi_rs2_rdata==MIN32))
  )

  `RVFI_COVER(cv_toggle_add,
    (rvfi_valid && fc_is_valid_add(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32+1) && (rvfi_rs2_rdata==MIN32+1))
  )

  `RVFI_COVER(cv_random_point_add,
    (rvfi_valid && fc_is_valid_add(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==RANDOMRS1) && (rvfi_rs2_rdata==RANDOMRS2))
  )

  `RVFI_COVER(cv_max_point_add,
    (rvfi_valid && fc_is_valid_add(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MAX32) && (rvfi_rs2_rdata==MAX32))
  )



  // sub cover points
  `RVFI_COVER(cv_common_antecedent_sub,
    (rvfi_valid && fc_is_valid_sub(rvfi_valid, rvfi_insn))
  )

  `RVFI_COVER(cv_min_sub,
    (rvfi_valid && fc_is_valid_sub(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32) && (rvfi_rs2_rdata==MIN32))
  )

  `RVFI_COVER(cv_toggle_sub,
    (rvfi_valid && fc_is_valid_sub(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32+1) && (rvfi_rs2_rdata==MIN32+1))
  )

  `RVFI_COVER(cv_random_point_sub,
    (rvfi_valid && fc_is_valid_sub(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==RANDOMRS1) && (rvfi_rs2_rdata==RANDOMRS2))
  )

  `RVFI_COVER(cv_max_point_sub,
    (rvfi_valid && fc_is_valid_sub(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MAX32) && (rvfi_rs2_rdata==MAX32))
  )



  // and cover points
  `RVFI_COVER(cv_common_antecedent_and,
    (rvfi_valid && fc_is_valid_and(rvfi_valid, rvfi_insn))
  )

  `RVFI_COVER(cv_min_and,
    (rvfi_valid && fc_is_valid_and(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32) && (rvfi_rs2_rdata==MIN32))
  )

  `RVFI_COVER(cv_toggle_and,
    (rvfi_valid && fc_is_valid_and(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32+1) && (rvfi_rs2_rdata==MIN32+1))
  )

  `RVFI_COVER(cv_random_point_and,
    (rvfi_valid && fc_is_valid_and(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==RANDOMRS1) && (rvfi_rs2_rdata==RANDOMRS2))
  )

  `RVFI_COVER(cv_max_point_and,
    (rvfi_valid && fc_is_valid_and(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MAX32) && (rvfi_rs2_rdata==MAX32))
  )



  // or cover points
  `RVFI_COVER(cv_common_antecedent_or,
    (rvfi_valid && fc_is_valid_or(rvfi_valid, rvfi_insn))
  )

  `RVFI_COVER(cv_min_or,
    (rvfi_valid && fc_is_valid_or(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32) && (rvfi_rs2_rdata==MIN32))
  )

  `RVFI_COVER(cv_toggle_or,
    (rvfi_valid && fc_is_valid_or(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32+1) && (rvfi_rs2_rdata==MIN32+1))
  )

  `RVFI_COVER(cv_random_point_or,
    (rvfi_valid && fc_is_valid_or(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==RANDOMRS1) && (rvfi_rs2_rdata==RANDOMRS2))
  )

  `RVFI_COVER(cv_max_point_or,
    (rvfi_valid && fc_is_valid_or(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MAX32) && (rvfi_rs2_rdata==MAX32))
  )



  // slt cover points
  `RVFI_COVER(cv_common_antecedent_slt,
    (rvfi_valid && fc_is_valid_slt(rvfi_valid, rvfi_insn))
  )

  `RVFI_COVER(cv_min_slt,
    (rvfi_valid && fc_is_valid_slt(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32) && (rvfi_rs2_rdata==MIN32))
  )

  `RVFI_COVER(cv_toggle_slt,
    (rvfi_valid && fc_is_valid_slt(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32+1) && (rvfi_rs2_rdata==MIN32+1))
  )

  `RVFI_COVER(cv_random_point_slt,
    (rvfi_valid && fc_is_valid_slt(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==RANDOMRS1) && (rvfi_rs2_rdata==RANDOMRS2))
  )

  `RVFI_COVER(cv_max_point_slt,
    (rvfi_valid && fc_is_valid_slt(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MAX32) && (rvfi_rs2_rdata==MAX32))
  )



  // sltu cover points
  `RVFI_COVER(cv_common_antecedent_sltu,
    (rvfi_valid && fc_is_valid_sltu(rvfi_valid, rvfi_insn))
  )

  `RVFI_COVER(cv_min_sltu,
    (rvfi_valid && fc_is_valid_sltu(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32) && (rvfi_rs2_rdata==MIN32))
  )

  `RVFI_COVER(cv_toggle_sltu,
    (rvfi_valid && fc_is_valid_sltu(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32+1) && (rvfi_rs2_rdata==MIN32+1))
  )

  `RVFI_COVER(cv_random_point_sltu,
    (rvfi_valid && fc_is_valid_sltu(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==RANDOMRS1) && (rvfi_rs2_rdata==RANDOMRS2))
  )

  `RVFI_COVER(cv_max_point_sltu,
    (rvfi_valid && fc_is_valid_sltu(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MAX32) && (rvfi_rs2_rdata==MAX32))
  )



  // sll cover points
  `RVFI_COVER(cv_common_antecedent_sll,
    (rvfi_valid && fc_is_valid_sll(rvfi_valid, rvfi_insn))
  )

  `RVFI_COVER(cv_min_sll,
    (rvfi_valid && fc_is_valid_sll(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32) && (rvfi_rs2_rdata==MIN32))
  )

  `RVFI_COVER(cv_toggle_sll,
    (rvfi_valid && fc_is_valid_sll(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32+1) && (rvfi_rs2_rdata==MIN32+1))
  )

  `RVFI_COVER(cv_random_point_sll,
    (rvfi_valid && fc_is_valid_sll(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==RANDOMRS1) && (rvfi_rs2_rdata==RANDOMRS2))
  )

  `RVFI_COVER(cv_max_point_sll,
    (rvfi_valid && fc_is_valid_sll(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MAX32) && (rvfi_rs2_rdata==MAX32))
  )



    // srl cover points
  `RVFI_COVER(cv_common_antecedent_srl,
    (rvfi_valid && fc_is_valid_srl(rvfi_valid, rvfi_insn))
  )

  `RVFI_COVER(cv_min_srl,
    (rvfi_valid && fc_is_valid_srl(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32) && (rvfi_rs2_rdata==MIN32))
  )

  `RVFI_COVER(cv_toggle_srl,
    (rvfi_valid && fc_is_valid_srl(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32+1) && (rvfi_rs2_rdata==MIN32+1))
  )

  `RVFI_COVER(cv_random_point_srl,
    (rvfi_valid && fc_is_valid_srl(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==RANDOMRS1) && (rvfi_rs2_rdata==RANDOMRS2))
  )

  `RVFI_COVER(cv_max_point_srl,
    (rvfi_valid && fc_is_valid_srl(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MAX32) && (rvfi_rs2_rdata==MAX32))
  )



    // sra cover points
  `RVFI_COVER(cv_common_antecedent_sra,
    (rvfi_valid && fc_is_valid_sra(rvfi_valid, rvfi_insn))
  )

  `RVFI_COVER(cv_min_sra,
    (rvfi_valid && fc_is_valid_sra(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32) && (rvfi_rs2_rdata==MIN32))
  )

  `RVFI_COVER(cv_toggle_sra,
    (rvfi_valid && fc_is_valid_sra(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MIN32+1) && (rvfi_rs2_rdata==MIN32+1))
  )

  `RVFI_COVER(cv_random_point_sra,
    (rvfi_valid && fc_is_valid_sra(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==RANDOMRS1) && (rvfi_rs2_rdata==RANDOMRS2))
  )

  `RVFI_COVER(cv_max_point_sra,
    (rvfi_valid && fc_is_valid_sra(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==MAX32) && (rvfi_rs2_rdata==MAX32))
  )


  // xor cover points
  `RVFI_COVER(cv_common_antecedent_xor,
    `RVFI_VALID_INSN(xor)
  )

  `RVFI_COVER(cv_min_xor,
    (`RVFI_VALID_INSN(xor) && (rvfi_rs1_rdata == MIN32) && (rvfi_rs2_rdata == MIN32))
  )

  `RVFI_COVER(cv_toggle_xor,
    (`RVFI_VALID_INSN(xor) && (rvfi_rs1_rdata == MIN32+1) && (rvfi_rs2_rdata == MIN32+1))
  )

  `RVFI_COVER(cv_random_point_xor,
    (`RVFI_VALID_INSN(xor) && (rvfi_rs1_rdata == RANDOMRS1) && (rvfi_rs2_rdata == RANDOMRS2))
  )

  `RVFI_COVER(cv_max_point_xor,
    (`RVFI_VALID_INSN(xor) && (rvfi_rs1_rdata == MAX32) && (rvfi_rs2_rdata == MAX32))
  )

  `RVFI_COVER(cv_fast_convergible_demo_xor,
    (`RVFI_VALID_INSN(xor) && (rvfi_rs1_rdata == DEMORS1) && (rvfi_rs2_rdata == DEMORS2))
  )


  // Register-immediate arithmetic and logical cover points
  `RVFI_COVER(cv_common_antecedent_addi, `RVFI_VALID_INSN(addi))
  `RVFI_COVER(cv_zero_imm_addi,
    (`RVFI_VALID_INSN(addi) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_imm_addi,
    (`RVFI_VALID_INSN(addi) && (immediate_decoder(rvfi_insn) == 32'h00000001))
  )
  `RVFI_COVER(cv_negative_imm_addi,
    (`RVFI_VALID_INSN(addi) && (immediate_decoder(rvfi_insn) == 32'hFFFFFFFF))
  )
  `RVFI_COVER(cv_min_imm_addi,
    (`RVFI_VALID_INSN(addi) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_max_imm_addi,
    (`RVFI_VALID_INSN(addi) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )

  `RVFI_COVER(cv_common_antecedent_andi, `RVFI_VALID_INSN(andi))
  `RVFI_COVER(cv_zero_imm_andi,
    (`RVFI_VALID_INSN(andi) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_imm_andi,
    (`RVFI_VALID_INSN(andi) && (immediate_decoder(rvfi_insn) == 32'h00000001))
  )
  `RVFI_COVER(cv_negative_imm_andi,
    (`RVFI_VALID_INSN(andi) && (immediate_decoder(rvfi_insn) == 32'hFFFFFFFF))
  )
  `RVFI_COVER(cv_min_imm_andi,
    (`RVFI_VALID_INSN(andi) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_max_imm_andi,
    (`RVFI_VALID_INSN(andi) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )

  `RVFI_COVER(cv_common_antecedent_ori, `RVFI_VALID_INSN(ori))
  `RVFI_COVER(cv_zero_imm_ori,
    (`RVFI_VALID_INSN(ori) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_imm_ori,
    (`RVFI_VALID_INSN(ori) && (immediate_decoder(rvfi_insn) == 32'h00000001))
  )
  `RVFI_COVER(cv_negative_imm_ori,
    (`RVFI_VALID_INSN(ori) && (immediate_decoder(rvfi_insn) == 32'hFFFFFFFF))
  )
  `RVFI_COVER(cv_min_imm_ori,
    (`RVFI_VALID_INSN(ori) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_max_imm_ori,
    (`RVFI_VALID_INSN(ori) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )

  `RVFI_COVER(cv_common_antecedent_xori, `RVFI_VALID_INSN(xori))
  `RVFI_COVER(cv_zero_imm_xori,
    (`RVFI_VALID_INSN(xori) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_imm_xori,
    (`RVFI_VALID_INSN(xori) && (immediate_decoder(rvfi_insn) == 32'h00000001))
  )
  `RVFI_COVER(cv_negative_imm_xori,
    (`RVFI_VALID_INSN(xori) && (immediate_decoder(rvfi_insn) == 32'hFFFFFFFF))
  )
  `RVFI_COVER(cv_min_imm_xori,
    (`RVFI_VALID_INSN(xori) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_max_imm_xori,
    (`RVFI_VALID_INSN(xori) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )

  `RVFI_COVER(cv_common_antecedent_slti, `RVFI_VALID_INSN(slti))
  `RVFI_COVER(cv_zero_imm_slti,
    (`RVFI_VALID_INSN(slti) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_imm_slti,
    (`RVFI_VALID_INSN(slti) && (immediate_decoder(rvfi_insn) == 32'h00000001))
  )
  `RVFI_COVER(cv_negative_imm_slti,
    (`RVFI_VALID_INSN(slti) && (immediate_decoder(rvfi_insn) == 32'hFFFFFFFF))
  )
  `RVFI_COVER(cv_min_imm_slti,
    (`RVFI_VALID_INSN(slti) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_max_imm_slti,
    (`RVFI_VALID_INSN(slti) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )
  `RVFI_COVER(cv_true_slti,
    (`RVFI_VALID_INSN(slti) && ($signed(rvfi_rs1_rdata) < $signed(immediate_decoder(rvfi_insn))))
  )
  `RVFI_COVER(cv_false_slti,
    (`RVFI_VALID_INSN(slti) && ($signed(rvfi_rs1_rdata) > $signed(immediate_decoder(rvfi_insn))))
  )
  `RVFI_COVER(cv_equal_slti,
    (`RVFI_VALID_INSN(slti) && (rvfi_rs1_rdata == immediate_decoder(rvfi_insn)))
  )

  `RVFI_COVER(cv_common_antecedent_sltiu, `RVFI_VALID_INSN(sltiu))
  `RVFI_COVER(cv_zero_imm_sltiu,
    (`RVFI_VALID_INSN(sltiu) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_imm_sltiu,
    (`RVFI_VALID_INSN(sltiu) && (immediate_decoder(rvfi_insn) == 32'h00000001))
  )
  `RVFI_COVER(cv_negative_imm_sltiu,
    (`RVFI_VALID_INSN(sltiu) && (immediate_decoder(rvfi_insn) == 32'hFFFFFFFF))
  )
  `RVFI_COVER(cv_min_imm_sltiu,
    (`RVFI_VALID_INSN(sltiu) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_max_imm_sltiu,
    (`RVFI_VALID_INSN(sltiu) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )
  `RVFI_COVER(cv_true_sltiu,
    (`RVFI_VALID_INSN(sltiu) && ($unsigned(rvfi_rs1_rdata) < $unsigned(immediate_decoder(rvfi_insn))))
  )
  `RVFI_COVER(cv_false_sltiu,
    (`RVFI_VALID_INSN(sltiu) && ($unsigned(rvfi_rs1_rdata) > $unsigned(immediate_decoder(rvfi_insn))))
  )
  `RVFI_COVER(cv_equal_sltiu,
    (`RVFI_VALID_INSN(sltiu) && (rvfi_rs1_rdata == immediate_decoder(rvfi_insn)))
  )


  // Register-immediate shift cover points
  `RVFI_COVER(cv_common_antecedent_slli, `RVFI_VALID_INSN(slli))
  `RVFI_COVER(cv_shift_zero_slli,
    (`RVFI_VALID_INSN(slli) && (rvfi_insn[24:20] == 5'd0))
  )
  `RVFI_COVER(cv_shift_one_slli,
    (`RVFI_VALID_INSN(slli) && (rvfi_insn[24:20] == 5'd1))
  )
  `RVFI_COVER(cv_shift_max_slli,
    (`RVFI_VALID_INSN(slli) && (rvfi_insn[24:20] == 5'd31))
  )

  `RVFI_COVER(cv_common_antecedent_srli, `RVFI_VALID_INSN(srli))
  `RVFI_COVER(cv_shift_zero_srli,
    (`RVFI_VALID_INSN(srli) && (rvfi_insn[24:20] == 5'd0))
  )
  `RVFI_COVER(cv_shift_one_srli,
    (`RVFI_VALID_INSN(srli) && (rvfi_insn[24:20] == 5'd1))
  )
  `RVFI_COVER(cv_shift_max_srli,
    (`RVFI_VALID_INSN(srli) && (rvfi_insn[24:20] == 5'd31))
  )

  `RVFI_COVER(cv_common_antecedent_srai, `RVFI_VALID_INSN(srai))
  `RVFI_COVER(cv_shift_zero_srai,
    (`RVFI_VALID_INSN(srai) && (rvfi_insn[24:20] == 5'd0))
  )
  `RVFI_COVER(cv_shift_one_srai,
    (`RVFI_VALID_INSN(srai) && (rvfi_insn[24:20] == 5'd1))
  )
  `RVFI_COVER(cv_shift_max_srai,
    (`RVFI_VALID_INSN(srai) && (rvfi_insn[24:20] == 5'd31))
  )
  `RVFI_COVER(cv_negative_operand_srai,
    (`RVFI_VALID_INSN(srai) && rvfi_rs1_rdata[31])
  )


  // Jump cover points
  `RVFI_COVER(cv_common_antecedent_jalr, `RVFI_VALID_INSN(jalr))
  `RVFI_COVER(cv_rd_zero_jalr,
    (`RVFI_VALID_INSN(jalr) && (rvfi_rd_addr == 5'd0))
  )
  `RVFI_COVER(cv_rd_nonzero_jalr,
    (`RVFI_VALID_INSN(jalr) && (rvfi_rd_addr != 5'd0))
  )
  `RVFI_COVER(cv_zero_offset_jalr,
    (`RVFI_VALID_INSN(jalr) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_forward_offset_jalr,
    (`RVFI_VALID_INSN(jalr) && ($signed(immediate_decoder(rvfi_insn)) > 0))
  )
  `RVFI_COVER(cv_backward_offset_jalr,
    (`RVFI_VALID_INSN(jalr) && ($signed(immediate_decoder(rvfi_insn)) < 0))
  )

  `RVFI_COVER(cv_common_antecedent_jal, `RVFI_VALID_INSN(jal))
  `RVFI_COVER(cv_rd_zero_jal,
    (`RVFI_VALID_INSN(jal) && (rvfi_rd_addr == 5'd0))
  )
  `RVFI_COVER(cv_rd_nonzero_jal,
    (`RVFI_VALID_INSN(jal) && (rvfi_rd_addr != 5'd0))
  )
  `RVFI_COVER(cv_zero_offset_jal,
    (`RVFI_VALID_INSN(jal) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_forward_offset_jal,
    (`RVFI_VALID_INSN(jal) && ($signed(immediate_decoder(rvfi_insn)) > 0))
  )
  `RVFI_COVER(cv_backward_offset_jal,
    (`RVFI_VALID_INSN(jal) && ($signed(immediate_decoder(rvfi_insn)) < 0))
  )


  // Upper-immediate cover points
  `RVFI_COVER(cv_common_antecedent_lui, `RVFI_VALID_INSN(lui))
  `RVFI_COVER(cv_zero_imm_lui,
    (`RVFI_VALID_INSN(lui) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_imm_lui,
    (`RVFI_VALID_INSN(lui) && (immediate_decoder(rvfi_insn) == 32'h00001000))
  )
  `RVFI_COVER(cv_sign_boundary_imm_lui,
    (`RVFI_VALID_INSN(lui) && (immediate_decoder(rvfi_insn) == 32'h80000000))
  )
  `RVFI_COVER(cv_max_imm_lui,
    (`RVFI_VALID_INSN(lui) && (immediate_decoder(rvfi_insn) == 32'hFFFFF000))
  )

  `RVFI_COVER(cv_common_antecedent_auipc, `RVFI_VALID_INSN(auipc))
  `RVFI_COVER(cv_zero_imm_auipc,
    (`RVFI_VALID_INSN(auipc) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_imm_auipc,
    (`RVFI_VALID_INSN(auipc) && (immediate_decoder(rvfi_insn) == 32'h00001000))
  )
  `RVFI_COVER(cv_sign_boundary_imm_auipc,
    (`RVFI_VALID_INSN(auipc) && (immediate_decoder(rvfi_insn) == 32'h80000000))
  )
  `RVFI_COVER(cv_max_imm_auipc,
    (`RVFI_VALID_INSN(auipc) && (immediate_decoder(rvfi_insn) == 32'hFFFFF000))
  )


  // Branch outcome cover points
  `RVFI_COVER(cv_common_antecedent_beq, `RVFI_VALID_INSN(beq))
  `RVFI_COVER(cv_taken_beq,
    (`RVFI_VALID_INSN(beq) && (rvfi_rs1_rdata == rvfi_rs2_rdata))
  )
  `RVFI_COVER(cv_not_taken_beq,
    (`RVFI_VALID_INSN(beq) && (rvfi_rs1_rdata != rvfi_rs2_rdata))
  )

  `RVFI_COVER(cv_common_antecedent_bne, `RVFI_VALID_INSN(bne))
  `RVFI_COVER(cv_taken_bne,
    (`RVFI_VALID_INSN(bne) && (rvfi_rs1_rdata != rvfi_rs2_rdata))
  )
  `RVFI_COVER(cv_not_taken_bne,
    (`RVFI_VALID_INSN(bne) && (rvfi_rs1_rdata == rvfi_rs2_rdata))
  )

  `RVFI_COVER(cv_common_antecedent_blt, `RVFI_VALID_INSN(blt))
  `RVFI_COVER(cv_taken_blt,
    (`RVFI_VALID_INSN(blt) && ($signed(rvfi_rs1_rdata) < $signed(rvfi_rs2_rdata)))
  )
  `RVFI_COVER(cv_not_taken_blt,
    (`RVFI_VALID_INSN(blt) && ($signed(rvfi_rs1_rdata) >= $signed(rvfi_rs2_rdata)))
  )

  `RVFI_COVER(cv_common_antecedent_bge, `RVFI_VALID_INSN(bge))
  `RVFI_COVER(cv_taken_bge,
    (`RVFI_VALID_INSN(bge) && ($signed(rvfi_rs1_rdata) >= $signed(rvfi_rs2_rdata)))
  )
  `RVFI_COVER(cv_not_taken_bge,
    (`RVFI_VALID_INSN(bge) && ($signed(rvfi_rs1_rdata) < $signed(rvfi_rs2_rdata)))
  )

  `RVFI_COVER(cv_common_antecedent_bltu, `RVFI_VALID_INSN(bltu))
  `RVFI_COVER(cv_taken_bltu,
    (`RVFI_VALID_INSN(bltu) && ($unsigned(rvfi_rs1_rdata) < $unsigned(rvfi_rs2_rdata)))
  )
  `RVFI_COVER(cv_not_taken_bltu,
    (`RVFI_VALID_INSN(bltu) && ($unsigned(rvfi_rs1_rdata) >= $unsigned(rvfi_rs2_rdata)))
  )

  `RVFI_COVER(cv_common_antecedent_bgeu, `RVFI_VALID_INSN(bgeu))
  `RVFI_COVER(cv_taken_bgeu,
    (`RVFI_VALID_INSN(bgeu) && ($unsigned(rvfi_rs1_rdata) >= $unsigned(rvfi_rs2_rdata)))
  )
  `RVFI_COVER(cv_not_taken_bgeu,
    (`RVFI_VALID_INSN(bgeu) && ($unsigned(rvfi_rs1_rdata) < $unsigned(rvfi_rs2_rdata)))
  )


  // Store address and byte-lane cover points
  `RVFI_COVER(cv_common_antecedent_sb, `RVFI_VALID_INSN(sb))
  `RVFI_COVER(cv_zero_offset_sb,
    (`RVFI_VALID_INSN(sb) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_offset_sb,
    (`RVFI_VALID_INSN(sb) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )
  `RVFI_COVER(cv_negative_offset_sb,
    (`RVFI_VALID_INSN(sb) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_mask_0001_sb, (`RVFI_VALID_INSN(sb) && (rvfi_mem_wmask == 4'b0001)))
  `RVFI_COVER(cv_mask_0010_sb, (`RVFI_VALID_INSN(sb) && (rvfi_mem_wmask == 4'b0010)))
  `RVFI_COVER(cv_mask_0100_sb, (`RVFI_VALID_INSN(sb) && (rvfi_mem_wmask == 4'b0100)))
  `RVFI_COVER(cv_mask_1000_sb, (`RVFI_VALID_INSN(sb) && (rvfi_mem_wmask == 4'b1000)))

  `RVFI_COVER(cv_common_antecedent_sh, `RVFI_VALID_INSN(sh))
  `RVFI_COVER(cv_zero_offset_sh,
    (`RVFI_VALID_INSN(sh) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_offset_sh,
    (`RVFI_VALID_INSN(sh) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )
  `RVFI_COVER(cv_negative_offset_sh,
    (`RVFI_VALID_INSN(sh) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_mask_0011_sh, (`RVFI_VALID_INSN(sh) && (rvfi_mem_wmask == 4'b0011)))
  `RVFI_COVER(cv_mask_0110_sh, (`RVFI_VALID_INSN(sh) && (rvfi_mem_wmask == 4'b0110)))
  `RVFI_COVER(cv_mask_1100_sh, (`RVFI_VALID_INSN(sh) && (rvfi_mem_wmask == 4'b1100)))

  `RVFI_COVER(cv_common_antecedent_sw, `RVFI_VALID_INSN(sw))
  `RVFI_COVER(cv_zero_offset_sw,
    (`RVFI_VALID_INSN(sw) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_offset_sw,
    (`RVFI_VALID_INSN(sw) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )
  `RVFI_COVER(cv_negative_offset_sw,
    (`RVFI_VALID_INSN(sw) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_mask_1111_sw, (`RVFI_VALID_INSN(sw) && (rvfi_mem_wmask == 4'b1111)))


  // Load address and byte-lane cover points
  `RVFI_COVER(cv_common_antecedent_lb, `RVFI_VALID_INSN(lb))
  `RVFI_COVER(cv_zero_offset_lb,
    (`RVFI_VALID_INSN(lb) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_offset_lb,
    (`RVFI_VALID_INSN(lb) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )
  `RVFI_COVER(cv_negative_offset_lb,
    (`RVFI_VALID_INSN(lb) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_mask_0001_lb, (`RVFI_VALID_INSN(lb) && (rvfi_mem_rmask == 4'b0001)))
  `RVFI_COVER(cv_mask_0010_lb, (`RVFI_VALID_INSN(lb) && (rvfi_mem_rmask == 4'b0010)))
  `RVFI_COVER(cv_mask_0100_lb, (`RVFI_VALID_INSN(lb) && (rvfi_mem_rmask == 4'b0100)))
  `RVFI_COVER(cv_mask_1000_lb, (`RVFI_VALID_INSN(lb) && (rvfi_mem_rmask == 4'b1000)))

  `RVFI_COVER(cv_common_antecedent_lbu, `RVFI_VALID_INSN(lbu))
  `RVFI_COVER(cv_zero_offset_lbu,
    (`RVFI_VALID_INSN(lbu) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_offset_lbu,
    (`RVFI_VALID_INSN(lbu) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )
  `RVFI_COVER(cv_negative_offset_lbu,
    (`RVFI_VALID_INSN(lbu) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_mask_0001_lbu, (`RVFI_VALID_INSN(lbu) && (rvfi_mem_rmask == 4'b0001)))
  `RVFI_COVER(cv_mask_0010_lbu, (`RVFI_VALID_INSN(lbu) && (rvfi_mem_rmask == 4'b0010)))
  `RVFI_COVER(cv_mask_0100_lbu, (`RVFI_VALID_INSN(lbu) && (rvfi_mem_rmask == 4'b0100)))
  `RVFI_COVER(cv_mask_1000_lbu, (`RVFI_VALID_INSN(lbu) && (rvfi_mem_rmask == 4'b1000)))

  `RVFI_COVER(cv_common_antecedent_lh, `RVFI_VALID_INSN(lh))
  `RVFI_COVER(cv_zero_offset_lh,
    (`RVFI_VALID_INSN(lh) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_offset_lh,
    (`RVFI_VALID_INSN(lh) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )
  `RVFI_COVER(cv_negative_offset_lh,
    (`RVFI_VALID_INSN(lh) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_mask_0011_lh, (`RVFI_VALID_INSN(lh) && (rvfi_mem_rmask == 4'b0011)))
  `RVFI_COVER(cv_mask_0110_lh, (`RVFI_VALID_INSN(lh) && (rvfi_mem_rmask == 4'b0110)))
  `RVFI_COVER(cv_mask_1100_lh, (`RVFI_VALID_INSN(lh) && (rvfi_mem_rmask == 4'b1100)))

  `RVFI_COVER(cv_common_antecedent_lhu, `RVFI_VALID_INSN(lhu))
  `RVFI_COVER(cv_zero_offset_lhu,
    (`RVFI_VALID_INSN(lhu) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_offset_lhu,
    (`RVFI_VALID_INSN(lhu) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )
  `RVFI_COVER(cv_negative_offset_lhu,
    (`RVFI_VALID_INSN(lhu) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_mask_0011_lhu, (`RVFI_VALID_INSN(lhu) && (rvfi_mem_rmask == 4'b0011)))
  `RVFI_COVER(cv_mask_0110_lhu, (`RVFI_VALID_INSN(lhu) && (rvfi_mem_rmask == 4'b0110)))
  `RVFI_COVER(cv_mask_1100_lhu, (`RVFI_VALID_INSN(lhu) && (rvfi_mem_rmask == 4'b1100)))

  `RVFI_COVER(cv_common_antecedent_lw, `RVFI_VALID_INSN(lw))
  `RVFI_COVER(cv_zero_offset_lw,
    (`RVFI_VALID_INSN(lw) && (immediate_decoder(rvfi_insn) == 32'h00000000))
  )
  `RVFI_COVER(cv_positive_offset_lw,
    (`RVFI_VALID_INSN(lw) && (immediate_decoder(rvfi_insn) == 32'h000007FF))
  )
  `RVFI_COVER(cv_negative_offset_lw,
    (`RVFI_VALID_INSN(lw) && (immediate_decoder(rvfi_insn) == 32'hFFFFF800))
  )
  `RVFI_COVER(cv_mask_1111_lw, (`RVFI_VALID_INSN(lw) && (rvfi_mem_rmask == 4'b1111)))



  //Fast convergible demo
  `RVFI_COVER(cv_fast_convergible_demo_add,
    (rvfi_valid && fc_is_valid_add(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==DEMORS1) && (rvfi_rs2_rdata==DEMORS2))
  )

  `RVFI_COVER(cv_fast_convergible_demo_sub,
    (rvfi_valid && fc_is_valid_sub(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==DEMORS1) && (rvfi_rs2_rdata==DEMORS2))
  )

  `RVFI_COVER(cv_fast_convergible_demo_and,
    (rvfi_valid && fc_is_valid_and(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==DEMORS1) && (rvfi_rs2_rdata==DEMORS2))
  )

  `RVFI_COVER(cv_fast_convergible_demo_or,
    (rvfi_valid && fc_is_valid_or(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==DEMORS1) && (rvfi_rs2_rdata==DEMORS2))
  )

  `RVFI_COVER(cv_fast_convergible_demo_slt,
    (rvfi_valid && fc_is_valid_slt(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==DEMORS1) && (rvfi_rs2_rdata==DEMORS2))
  )

  `RVFI_COVER(cv_fast_convergible_demo_sltu,
    (rvfi_valid && fc_is_valid_sltu(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==DEMORS1) && (rvfi_rs2_rdata==DEMORS2))
  )

  `RVFI_COVER(cv_fast_convergible_demo_sll,
    (rvfi_valid && fc_is_valid_sll(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==DEMORS1) && (rvfi_rs2_rdata==DEMORS2))
  )

  `RVFI_COVER(cv_fast_convergible_demo_srl,
    (rvfi_valid && fc_is_valid_srl(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==DEMORS1) && (rvfi_rs2_rdata==DEMORS2))
  )

  `RVFI_COVER(cv_fast_convergible_demo_sra,
    (rvfi_valid && fc_is_valid_sra(rvfi_valid, rvfi_insn) && (rvfi_rs1_rdata==DEMORS1) && (rvfi_rs2_rdata==DEMORS2))
  )



  // ranges
  `RVFI_COVER(cv_rs1_range,
    (rvfi_valid && rvfi_rs1_rdata inside {[MIN32 : MAX32]})
  )

  `RVFI_COVER(cv_rs2_range,
    (rvfi_valid && rvfi_rs2_rdata inside {[MIN32 : MAX32]})
  )

  `RVFI_COVER(cv_rd_wdata_range,
    (rvfi_valid && rvfi_rd_wdata inside {[MIN32: MAX32]})
  )

  `RVFI_COVER(cv_rd_wdata_random_range,
    (rvfi_valid && rvfi_rd_wdata inside {[32'h0000FFFF : 32'hFFFF0000]})
  )

  `undef RVFI_VALID_INSN
  `undef RVFI_COVER

endmodule
