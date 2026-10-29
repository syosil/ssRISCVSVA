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

import pkg_rv32i::OPCODE_OP;
import pkg_rv32i::OPCODE_OP_IMM;
import pkg_rv32i::OPCODE_JALR;
import pkg_rv32i::OPCODE_JAL;
import pkg_rv32i::OPCODE_LUI;
import pkg_rv32i::OPCODE_AUIPC;
import pkg_rv32i::OPCODE_BRANCH;
import pkg_rv32i::OPCODE_STORE;
import pkg_rv32i::OPCODE_LOAD;

import pkg_rv32i::FUNCT3_ADD;
import pkg_rv32i::FUNCT3_SLL;
import pkg_rv32i::FUNCT3_SLT;
import pkg_rv32i::FUNCT3_SLTU;
import pkg_rv32i::FUNCT3_XOR;
import pkg_rv32i::FUNCT3_SRL;
import pkg_rv32i::FUNCT3_SRA;
import pkg_rv32i::FUNCT3_OR;
import pkg_rv32i::FUNCT3_JALR;
import pkg_rv32i::FUNCT3_AND;
import pkg_rv32i::FUNCT3_BEQ;
import pkg_rv32i::FUNCT3_BNE;
import pkg_rv32i::FUNCT3_BLT;
import pkg_rv32i::FUNCT3_BGE;
import pkg_rv32i::FUNCT3_BLTU;
import pkg_rv32i::FUNCT3_BGEU;
import pkg_rv32i::FUNCT3_SB;
import pkg_rv32i::FUNCT3_SH;
import pkg_rv32i::FUNCT3_SW;
import pkg_rv32i::FUNCT3_LB;
import pkg_rv32i::FUNCT3_LH;
import pkg_rv32i::FUNCT3_LW;
import pkg_rv32i::FUNCT3_LBU;
import pkg_rv32i::FUNCT3_LHU;

import pkg_rv32i::FUNCT7_ADD;
import pkg_rv32i::FUNCT7_SUB;
import pkg_rv32i::FUNCT7_SLL;
import pkg_rv32i::FUNCT7_SLT;
import pkg_rv32i::FUNCT7_SLTU;
import pkg_rv32i::FUNCT7_XOR;
import pkg_rv32i::FUNCT7_SRL;
import pkg_rv32i::FUNCT7_SRA;
import pkg_rv32i::FUNCT7_OR;
import pkg_rv32i::FUNCT7_AND;

import pkg_rv32_common::OPCODE_OFFSET;
import pkg_rv32_common::OPCODE_WIDTH;
import pkg_rv32_common::RD_OFFSET;
import pkg_rv32_common::RD_WIDTH;
import pkg_rv32_common::FUNCT3_OFFSET;
import pkg_rv32_common::FUNCT3_WIDTH;
import pkg_rv32_common::FUNCT7_OFFSET;
import pkg_rv32_common::FUNCT7_WIDTH;

import pkg_rv32_common::immediate_decoder;

function bit fc_is_valid_op(
  logic[2:0] funct3,
  logic[6:0] funct7,
  logic valid,
  logic[31:0] instr
);
  return (valid &&
    instr[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_OP &&
    instr[FUNCT3_OFFSET +: FUNCT3_WIDTH] == funct3 &&
    instr[FUNCT7_OFFSET +: FUNCT7_WIDTH] == funct7);
endfunction : fc_is_valid_op

function bit fc_is_valid_add(logic valid, logic[31:0] instr);
  return fc_is_valid_op(FUNCT3_ADD, FUNCT7_ADD, valid, instr);
endfunction : fc_is_valid_add

function bit fc_is_valid_sub(logic valid, logic[31:0] instr);
  return fc_is_valid_op(FUNCT3_ADD, FUNCT7_SUB, valid, instr);
endfunction : fc_is_valid_sub

function bit fc_is_valid_and(logic valid, logic[31:0] instr);
  return fc_is_valid_op(FUNCT3_AND, FUNCT7_AND, valid, instr);
endfunction : fc_is_valid_and

function bit fc_is_valid_or(logic valid, logic[31:0] instr);
  return fc_is_valid_op(FUNCT3_OR, FUNCT7_OR, valid, instr);
endfunction : fc_is_valid_or

function bit fc_is_valid_xor(logic valid, logic[31:0] instr);
  return fc_is_valid_op(FUNCT3_XOR, FUNCT7_XOR, valid, instr);
endfunction : fc_is_valid_xor

function bit fc_is_valid_sll(logic valid, logic[31:0] instr);
  return fc_is_valid_op(FUNCT3_SLL, FUNCT7_SLL, valid, instr);
endfunction : fc_is_valid_sll

function bit fc_is_valid_srl(logic valid, logic[31:0] instr);
  return fc_is_valid_op(FUNCT3_SRL, FUNCT7_SRL, valid, instr);
endfunction : fc_is_valid_srl

function bit fc_is_valid_sra(logic valid, logic[31:0] instr);
  return fc_is_valid_op(FUNCT3_SRA, FUNCT7_SRA, valid, instr);
endfunction : fc_is_valid_sra

function bit fc_is_valid_slt(logic valid, logic[31:0] instr);
  return fc_is_valid_op(FUNCT3_SLT, FUNCT7_SLT, valid, instr);
endfunction : fc_is_valid_slt

function bit fc_is_valid_sltu(logic valid, logic[31:0] instr);
  return fc_is_valid_op(FUNCT3_SLTU, FUNCT7_SLTU, valid, instr);
endfunction : fc_is_valid_sltu

function bit fc_is_valid_op_imm(
  logic[2:0] funct3,
  logic valid,
  logic[31:0] instr
);
  return (valid &&
    instr[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_OP_IMM &&
    instr[FUNCT3_OFFSET +: FUNCT3_WIDTH] == funct3);
endfunction : fc_is_valid_op_imm

function bit fc_is_valid_addi(logic valid, logic[31:0] instr);
  return fc_is_valid_op_imm(FUNCT3_ADD, valid, instr);
endfunction : fc_is_valid_addi

function bit fc_is_valid_andi(logic valid, logic[31:0] instr);
  return fc_is_valid_op_imm(FUNCT3_AND, valid, instr);
endfunction : fc_is_valid_andi

function bit fc_is_valid_ori(logic valid, logic[31:0] instr);
  return fc_is_valid_op_imm(FUNCT3_OR, valid, instr);
endfunction : fc_is_valid_ori

function bit fc_is_valid_xori(logic valid, logic[31:0] instr);
  return fc_is_valid_op_imm(FUNCT3_XOR, valid, instr);
endfunction : fc_is_valid_xori

function bit fc_is_valid_slli(logic valid, logic[31:0] instr);
  return fc_is_valid_op_imm(FUNCT3_SLL, valid, instr);
endfunction : fc_is_valid_slli

function bit fc_is_valid_srli(logic valid, logic[31:0] instr);
  return (fc_is_valid_op_imm(FUNCT3_SRL, valid, instr) &&
    instr[FUNCT7_OFFSET +: FUNCT7_WIDTH] == FUNCT7_SRL);
endfunction : fc_is_valid_srli

function bit fc_is_valid_srai(logic valid, logic[31:0] instr);
  return (fc_is_valid_op_imm(FUNCT3_SRA, valid, instr) &&
    instr[FUNCT7_OFFSET +: FUNCT7_WIDTH] == FUNCT7_SRA);
endfunction : fc_is_valid_srai

function bit fc_is_valid_slti(logic valid, logic[31:0] instr);
  return fc_is_valid_op_imm(FUNCT3_SLT, valid, instr);
endfunction : fc_is_valid_slti

function bit fc_is_valid_sltiu(logic valid, logic[31:0] instr);
  return fc_is_valid_op_imm(FUNCT3_SLTU, valid, instr);
endfunction : fc_is_valid_sltiu

function bit fc_is_valid_jump(
  logic[6:0] opcode,
  logic valid,
  logic[31:0] instr
);
  return (valid &&
    instr[OPCODE_OFFSET +: OPCODE_WIDTH] == opcode);
endfunction : fc_is_valid_jump

function bit fc_is_valid_jalr(logic valid, logic[31:0] instr);
  return (fc_is_valid_jump(OPCODE_JALR, valid, instr) &&
    instr[FUNCT3_OFFSET +: FUNCT3_WIDTH] == FUNCT3_JALR);
endfunction : fc_is_valid_jalr

function bit fc_is_valid_jal(logic valid, logic[31:0] instr);
  return fc_is_valid_jump(OPCODE_JAL, valid, instr);
endfunction : fc_is_valid_jal

function bit fc_is_valid_upper_imm(
  logic[6:0] opcode,
  logic valid,
  logic[31:0] instr
);
  return (valid &&
    instr[OPCODE_OFFSET +: OPCODE_WIDTH] == opcode);
endfunction : fc_is_valid_upper_imm

function bit fc_is_valid_lui(logic valid, logic[31:0] instr);
  return fc_is_valid_upper_imm(OPCODE_LUI, valid, instr);
endfunction : fc_is_valid_lui

function bit fc_is_valid_auipc(logic valid, logic[31:0] instr);
  return fc_is_valid_upper_imm(OPCODE_AUIPC, valid, instr);
endfunction : fc_is_valid_auipc

function bit fc_is_valid_branch(
  logic[2:0] funct3,
  logic valid,
  logic[31:0] instr
);
  return (valid &&
    instr[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_BRANCH &&
    instr[FUNCT3_OFFSET +: FUNCT3_WIDTH] == funct3);
endfunction : fc_is_valid_branch

function bit fc_is_valid_beq(logic valid, logic[31:0] instr);
  return fc_is_valid_branch(FUNCT3_BEQ, valid, instr);
endfunction : fc_is_valid_beq

function bit fc_is_valid_bne(logic valid, logic[31:0] instr);
  return fc_is_valid_branch(FUNCT3_BNE, valid, instr);
endfunction : fc_is_valid_bne

function bit fc_is_valid_blt(logic valid, logic[31:0] instr);
  return fc_is_valid_branch(FUNCT3_BLT, valid, instr);
endfunction : fc_is_valid_blt

function bit fc_is_valid_bge(logic valid, logic[31:0] instr);
  return fc_is_valid_branch(FUNCT3_BGE, valid, instr);
endfunction : fc_is_valid_bge

function bit fc_is_valid_bltu(logic valid, logic[31:0] instr);
  return fc_is_valid_branch(FUNCT3_BLTU, valid, instr);
endfunction : fc_is_valid_bltu

function bit fc_is_valid_bgeu(logic valid, logic[31:0] instr);
  return fc_is_valid_branch(FUNCT3_BGEU, valid, instr);
endfunction : fc_is_valid_bgeu

function bit fc_is_valid_store(
  logic[2:0] funct3,
  logic valid,
  logic[31:0] instr,
  logic[31:0] mem_addr = '0,
  bit aligned_mem = 1'b1
);
  return (valid &&
    instr[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_STORE &&
    instr[FUNCT3_OFFSET +: FUNCT3_WIDTH] == funct3 &&
    (!aligned_mem || mem_addr[1:0] == 2'b00));
endfunction : fc_is_valid_store

function bit fc_is_valid_sw(
  logic valid,
  logic[31:0] instr,
  logic[31:0] mem_addr = '0,
  bit aligned_mem = 1'b1
);
  return fc_is_valid_store(FUNCT3_SW, valid, instr, mem_addr, aligned_mem);
endfunction : fc_is_valid_sw

function bit fc_is_valid_sh(
  logic valid,
  logic[31:0] instr,
  logic[31:0] mem_addr = '0,
  bit aligned_mem = 1'b1
);
  return fc_is_valid_store(FUNCT3_SH, valid, instr, mem_addr, aligned_mem);
endfunction : fc_is_valid_sh

function bit fc_is_valid_sb(
  logic valid,
  logic[31:0] instr,
  logic[31:0] mem_addr = '0,
  bit aligned_mem = 1'b1
);
  return fc_is_valid_store(FUNCT3_SB, valid, instr, mem_addr, aligned_mem);
endfunction : fc_is_valid_sb

function bit fc_is_valid_load(
  logic[2:0] funct3,
  logic valid,
  logic[31:0] instr,
  logic[31:0] mem_addr = '0,
  bit aligned_mem = 1'b1
);
  return (valid &&
    instr[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_LOAD &&
    instr[FUNCT3_OFFSET +: FUNCT3_WIDTH] == funct3 &&
    (!aligned_mem || mem_addr[1:0] == 2'b00));
endfunction : fc_is_valid_load

function bit fc_is_valid_lb(
  logic valid,
  logic[31:0] instr,
  logic[31:0] mem_addr = '0,
  bit aligned_mem = 1'b1
);
  return fc_is_valid_load(FUNCT3_LB, valid, instr, mem_addr, aligned_mem);
endfunction : fc_is_valid_lb

function bit fc_is_valid_lh(
  logic valid,
  logic[31:0] instr,
  logic[31:0] mem_addr = '0,
  bit aligned_mem = 1'b1
);
  return fc_is_valid_load(FUNCT3_LH, valid, instr, mem_addr, aligned_mem);
endfunction : fc_is_valid_lh

function bit fc_is_valid_lw(
  logic valid,
  logic[31:0] instr,
  logic[31:0] mem_addr = '0,
  bit aligned_mem = 1'b1
);
  return fc_is_valid_load(FUNCT3_LW, valid, instr, mem_addr, aligned_mem);
endfunction : fc_is_valid_lw

function bit fc_is_valid_lbu(
  logic valid,
  logic[31:0] instr,
  logic[31:0] mem_addr = '0,
  bit aligned_mem = 1'b1
);
  return fc_is_valid_load(FUNCT3_LBU, valid, instr, mem_addr, aligned_mem);
endfunction : fc_is_valid_lbu

function bit fc_is_valid_lhu(
  logic valid,
  logic[31:0] instr,
  logic[31:0] mem_addr = '0,
  bit aligned_mem = 1'b1
);
  return fc_is_valid_load(FUNCT3_LHU, valid, instr, mem_addr, aligned_mem);
endfunction : fc_is_valid_lhu

function logic[31:0] fc_add(logic[31:0] rs1, logic[31:0] rs2);
  return (rs1+rs2);
endfunction : fc_add

function logic[31:0] fc_sub(logic[31:0] rs1, logic[31:0] rs2);
  return (rs1-rs2);
endfunction : fc_sub

function logic[31:0] fc_and(logic[31:0] rs1, logic[31:0] rs2);
  return (rs1&rs2);
endfunction : fc_and

function logic[31:0] fc_or(logic[31:0] rs1, logic[31:0] rs2);
  return (rs1|rs2);
endfunction : fc_or

function logic[31:0] fc_xor(logic[31:0] rs1, logic[31:0] rs2);
  return (rs1^rs2);
endfunction : fc_xor

function logic[31:0] fc_sll(logic[31:0] rs1, logic[31:0] rs2);
  return (rs1 << rs2[4:0]);
endfunction : fc_sll

function logic[31:0] fc_srl(logic[31:0] rs1, logic[31:0] rs2);
  return (rs1 >> rs2[4:0]);
endfunction : fc_srl

function logic[31:0] fc_sra(logic[31:0] rs1, logic[31:0] rs2);
  return (signed'(rs1) >>> rs2[4:0]);
endfunction : fc_sra

function logic[31:0] fc_slt(logic[31:0] rs1, logic[31:0] rs2);
  return (signed'(rs1) < signed'(rs2) ? 32'b1 : 32'b0);
endfunction : fc_slt

function logic[31:0] fc_sltu(logic[31:0] rs1, logic[31:0] rs2);
  return (unsigned'(rs1) < unsigned'(rs2) ? 32'b1 : 32'b0);
endfunction : fc_sltu

function logic[31:0] fc_addi(logic[31:0] rs1, logic[31:0] insn);
  return (rs1+immediate_decoder(insn));
endfunction : fc_addi

function logic[31:0] fc_andi(logic[31:0] rs1, logic[31:0] insn);
  return (rs1&immediate_decoder(insn));
endfunction : fc_andi

function logic[31:0] fc_ori(logic[31:0] rs1, logic[31:0] insn);
  return (rs1|immediate_decoder(insn));
endfunction : fc_ori

function logic[31:0] fc_xori(logic[31:0] rs1, logic[31:0] insn);
  return (rs1^immediate_decoder(insn));
endfunction : fc_xori

function logic[31:0] fc_slli(logic[31:0] rs1, logic[31:0] insn);
  return (rs1 << (immediate_decoder(insn) & 5'h1f));
endfunction : fc_slli

function logic[31:0] fc_srli(logic[31:0] rs1, logic[31:0] insn);
  return (rs1 >> (immediate_decoder(insn) & 5'h1f));
endfunction : fc_srli

function logic[31:0] fc_srai(logic[31:0] rs1, logic[31:0] insn);
  return (signed'(rs1) >>> (immediate_decoder(insn) & 5'h1f));
endfunction : fc_srai

function logic[31:0] fc_slti(logic[31:0] rs1, logic[31:0] insn);
  return (signed'(rs1) < signed'(immediate_decoder(insn)) ? 32'b1 : 32'b0);
endfunction : fc_slti

function logic[31:0] fc_sltui(logic[31:0] rs1, logic[31:0] insn);
  return (unsigned'(rs1) < unsigned'(immediate_decoder(insn)) ? 32'b1 : 32'b0);
endfunction : fc_sltui

function logic[31:0] fc_jalr_pc(logic[31:0] rs1, logic[31:0] insn);
  return ((rs1 + immediate_decoder(insn)) & ~1);
endfunction : fc_jalr_pc

function logic[31:0] fc_jalr_rd(logic[31:0] pc_rdata);
  return (pc_rdata + 4);
endfunction : fc_jalr_rd

function logic[31:0] fc_jal_pc(logic[31:0] pc_rdata, logic[31:0] insn);
  return ((pc_rdata + immediate_decoder(insn)) & ~1);
endfunction : fc_jal_pc

function logic[31:0] fc_jal_rd(logic[31:0] pc_rdata);
  return (pc_rdata + 4);
endfunction : fc_jal_rd

function logic[31:0] fc_lui(logic[31:0] insn);
  return immediate_decoder(insn);
endfunction : fc_lui

function logic[31:0] fc_auipc(logic[31:0] pc_rdata, logic[31:0] insn);
  return (pc_rdata + immediate_decoder(insn));
endfunction : fc_auipc

function logic[31:0] fc_beq(logic[31:0] rs1, logic[31:0] rs2, logic[31:0] pc_rdata, logic[31:0] insn);
  return (rs1 == rs2) ? pc_rdata + immediate_decoder(insn) : pc_rdata + 4;
endfunction : fc_beq

function logic[31:0] fc_bne(logic[31:0] rs1, logic[31:0] rs2, logic[31:0] pc_rdata, logic[31:0] insn);
  return (rs1 != rs2) ? pc_rdata + immediate_decoder(insn) : pc_rdata + 4;
endfunction : fc_bne

function logic[31:0] fc_blt(logic[31:0] rs1, logic[31:0] rs2, logic[31:0] pc_rdata, logic[31:0] insn);
  return (signed'(rs1) < signed'(rs2)) ? pc_rdata + immediate_decoder(insn) : pc_rdata + 4;
endfunction : fc_blt

function logic[31:0] fc_bge(logic[31:0] rs1, logic[31:0] rs2, logic[31:0] pc_rdata, logic[31:0] insn);
  return (signed'(rs1) >= signed'(rs2)) ? pc_rdata + immediate_decoder(insn) : pc_rdata + 4;
endfunction : fc_bge

function logic[31:0] fc_bltu(logic[31:0] rs1, logic[31:0] rs2, logic[31:0] pc_rdata, logic[31:0] insn);
  return (unsigned'(rs1) < unsigned'(rs2)) ? pc_rdata + immediate_decoder(insn) : pc_rdata + 4;
endfunction : fc_bltu

function logic[31:0] fc_bgeu(logic[31:0] rs1, logic[31:0] rs2, logic[31:0] pc_rdata, logic[31:0] insn);
  return (unsigned'(rs1) >= unsigned'(rs2)) ? pc_rdata + immediate_decoder(insn) : pc_rdata + 4;
endfunction : fc_bgeu

function logic[31:0] fc_sw_wdata(logic[31:0] mem_wdata);
  return mem_wdata;
endfunction : fc_sw_wdata

function logic[15:0] fc_sh_wdata(logic[31:0] mem_wdata, logic[3:0] wmask);
  if (wmask == 4'b1100) return mem_wdata[31:16];
  if (wmask == 4'b0110) return mem_wdata[23:8 ];
  if (wmask == 4'b0011) return mem_wdata[15:0 ];
  return 16'b0;
endfunction : fc_sh_wdata

function logic[7:0] fc_sb_wdata(logic[31:0] mem_wdata, logic[3:0] wmask);
  if (wmask == 4'b1000) return mem_wdata[31:24];
  if (wmask == 4'b0100) return mem_wdata[23:16];
  if (wmask == 4'b0010) return mem_wdata[15:8 ];
  if (wmask == 4'b0001) return mem_wdata[ 7:0 ];
  return 8'b0;
endfunction : fc_sb_wdata

function bit fc_is_valid_lb_rmask(logic[3:0] rmask);
  return rmask inside {4'b0001, 4'b0010, 4'b0100, 4'b1000};
endfunction : fc_is_valid_lb_rmask

function bit fc_is_valid_lh_rmask(logic[3:0] rmask);
  return rmask inside {4'b0011, 4'b0110, 4'b1100};
endfunction : fc_is_valid_lh_rmask

function bit fc_is_valid_lw_rmask(logic[3:0] rmask);
  return rmask == 4'b1111;
endfunction : fc_is_valid_lw_rmask

function logic[31:0] fc_lb_rdata(logic[31:0] mem_rdata, logic[3:0] rmask);
  case (rmask)
    4'b1000: return {{24{mem_rdata[31]}}, mem_rdata[31:24]};
    4'b0100: return {{24{mem_rdata[23]}}, mem_rdata[23:16]};
    4'b0010: return {{24{mem_rdata[15]}}, mem_rdata[15:8 ]};
    4'b0001: return {{24{mem_rdata[ 7]}}, mem_rdata[ 7:0 ]};
    default: return 32'b0;
  endcase
endfunction : fc_lb_rdata

function logic[31:0] fc_lbu_rdata(logic[31:0] mem_rdata, logic[3:0] rmask);
  case (rmask)
    4'b1000: return {24'b0, mem_rdata[31:24]};
    4'b0100: return {24'b0, mem_rdata[23:16]};
    4'b0010: return {24'b0, mem_rdata[15:8 ]};
    4'b0001: return {24'b0, mem_rdata[ 7:0 ]};
    default: return 32'b0;
  endcase
endfunction : fc_lbu_rdata

function logic[31:0] fc_lh_rdata(logic[31:0] mem_rdata, logic[3:0] rmask);
  case (rmask)
    4'b1100: return {{16{mem_rdata[31]}}, mem_rdata[31:16]};
    4'b0110: return {{16{mem_rdata[23]}}, mem_rdata[23:8 ]};
    4'b0011: return {{16{mem_rdata[15]}}, mem_rdata[15:0 ]};
    default: return 32'b0;
  endcase
endfunction : fc_lh_rdata

function logic[31:0] fc_lhu_rdata(logic[31:0] mem_rdata, logic[3:0] rmask);
  case (rmask)
    4'b1100: return {16'b0, mem_rdata[31:16]};
    4'b0110: return {16'b0, mem_rdata[23:8 ]};
    4'b0011: return {16'b0, mem_rdata[15:0 ]};
    default: return 32'b0;
  endcase
endfunction : fc_lhu_rdata

function logic[31:0] fc_lw_rdata(logic[31:0] mem_rdata);
  return mem_rdata;
endfunction : fc_lw_rdata

function logic[31:0] fc_effective_mem_addr(
  logic[31:0] rs1,
  logic[31:0] insn
);
  return rs1 + immediate_decoder(insn);
endfunction : fc_effective_mem_addr

function logic[31:0] fc_mem_addr(
  logic[31:0] rs1,
  logic[31:0] insn,
  bit aligned_mem = 1'b1
);
  logic[31:0] effective_addr;
  effective_addr = fc_effective_mem_addr(rs1, insn);
  return aligned_mem ? {effective_addr[31:2], 2'b00} : effective_addr;
endfunction : fc_mem_addr
