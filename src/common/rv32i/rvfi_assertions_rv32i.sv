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

import pkg_rv32_common::fc_is_valid_retire;
import pkg_rv32_common::fc_is_valid_retire_rd;
import pkg_rv32_common::RD_OFFSET;
import pkg_rv32_common::RD_WIDTH;
module rvfi_assertions_rv32i #(
  parameter bit ALIGNED_MEM
) (
  input logic clock,
  input logic reset,
  //RVFI signals
  input logic        rvfi_valid,
  input logic        rvfi_trap,
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
  logic        valid_retire;
  logic        valid_retire_rd;

  assign valid_retire = fc_is_valid_retire(rvfi_valid, rvfi_trap);
  assign valid_retire_rd = fc_is_valid_retire_rd(rvfi_valid, rvfi_trap, rvfi_insn[RD_OFFSET +: RD_WIDTH]);

  property pt_add;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_add(valid_retire_rd, rvfi_insn))
    |-> (fc_add(rvfi_rs1_rdata, rvfi_rs2_rdata) == rvfi_rd_wdata);
  endproperty : pt_add

  property pt_sub;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sub(valid_retire_rd, rvfi_insn))
    |-> (fc_sub(rvfi_rs1_rdata, rvfi_rs2_rdata) == rvfi_rd_wdata);
  endproperty : pt_sub

  property pt_and;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_and(valid_retire_rd, rvfi_insn))
    |-> (fc_and(rvfi_rs1_rdata, rvfi_rs2_rdata) == rvfi_rd_wdata);
  endproperty : pt_and

  property pt_or;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_or(valid_retire_rd, rvfi_insn))
    |-> (fc_or(rvfi_rs1_rdata, rvfi_rs2_rdata) == rvfi_rd_wdata);
  endproperty : pt_or

  property pt_xor;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_xor(valid_retire_rd, rvfi_insn))
    |-> (fc_xor(rvfi_rs1_rdata, rvfi_rs2_rdata) == rvfi_rd_wdata);
  endproperty : pt_xor

  property pt_sll;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sll(valid_retire_rd, rvfi_insn))
    |-> (fc_sll(rvfi_rs1_rdata, rvfi_rs2_rdata) == rvfi_rd_wdata);
  endproperty : pt_sll

  property pt_srl;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_srl(valid_retire_rd, rvfi_insn))
    |-> (fc_srl(rvfi_rs1_rdata, rvfi_rs2_rdata) == rvfi_rd_wdata);
  endproperty : pt_srl

  property pt_sra;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sra(valid_retire_rd, rvfi_insn))
    |-> (fc_sra(rvfi_rs1_rdata, rvfi_rs2_rdata) == rvfi_rd_wdata);
  endproperty : pt_sra

  property pt_slt;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_slt(valid_retire_rd, rvfi_insn))
    |-> (fc_slt(rvfi_rs1_rdata, rvfi_rs2_rdata) == rvfi_rd_wdata);
  endproperty : pt_slt

  property pt_sltu;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sltu(valid_retire_rd, rvfi_insn))
    |-> (fc_sltu(rvfi_rs1_rdata, rvfi_rs2_rdata) == rvfi_rd_wdata);
  endproperty : pt_sltu

  property pt_addi;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_addi(valid_retire_rd, rvfi_insn))
    |-> (fc_addi(rvfi_rs1_rdata, rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_addi

  property pt_andi;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_andi(valid_retire_rd, rvfi_insn))
    |-> (fc_andi(rvfi_rs1_rdata, rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_andi

  property pt_ori;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_ori(valid_retire_rd, rvfi_insn))
    |-> (fc_ori(rvfi_rs1_rdata, rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_ori

  property pt_xori;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_xori(valid_retire_rd, rvfi_insn))
    |-> (fc_xori(rvfi_rs1_rdata, rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_xori

  property pt_slli;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_slli(valid_retire_rd, rvfi_insn))
    |-> (fc_slli(rvfi_rs1_rdata, rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_slli

  property pt_srli;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_srli(valid_retire_rd, rvfi_insn))
    |-> (fc_srli(rvfi_rs1_rdata, rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_srli

  property pt_srai;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_srai(valid_retire_rd, rvfi_insn))
    |-> (fc_srai(rvfi_rs1_rdata, rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_srai

  property pt_slti;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_slti(valid_retire_rd, rvfi_insn))
    |-> (fc_slti(rvfi_rs1_rdata, rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_slti

  property pt_sltiu;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sltiu(valid_retire_rd, rvfi_insn))
    |-> (fc_sltui(rvfi_rs1_rdata, rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_sltiu

  property pt_jalr_pc;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_jalr(valid_retire, rvfi_insn))
    |-> (fc_jalr_pc(rvfi_rs1_rdata, rvfi_insn) == rvfi_pc_wdata);
  endproperty : pt_jalr_pc;

  property pt_jalr_rd;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_jalr(valid_retire_rd, rvfi_insn))
    |-> (fc_jalr_rd(rvfi_pc_rdata) == rvfi_rd_wdata);
  endproperty : pt_jalr_rd;

  property pt_jal_pc;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_jal(valid_retire, rvfi_insn))
    |-> (fc_jal_pc(rvfi_pc_rdata, rvfi_insn) == rvfi_pc_wdata);
  endproperty : pt_jal_pc;

  property pt_jal_rd;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_jal(valid_retire_rd, rvfi_insn))
    |-> (fc_jal_rd(rvfi_pc_rdata) == rvfi_rd_wdata);
  endproperty : pt_jal_rd;

  property pt_lui;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lui(valid_retire_rd, rvfi_insn))
    |-> (fc_lui(rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_lui

  property pt_auipc;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_auipc(valid_retire_rd, rvfi_insn))
    |-> (fc_auipc(rvfi_pc_rdata, rvfi_insn) == rvfi_rd_wdata);
  endproperty : pt_auipc

  property pt_beq;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_beq(valid_retire, rvfi_insn))
    |-> (fc_beq(rvfi_rs1_rdata, rvfi_rs2_rdata, rvfi_pc_rdata, rvfi_insn) == rvfi_pc_wdata);
  endproperty : pt_beq

  property pt_bne;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_bne(valid_retire, rvfi_insn))
    |-> (fc_bne(rvfi_rs1_rdata, rvfi_rs2_rdata, rvfi_pc_rdata, rvfi_insn) == rvfi_pc_wdata);
  endproperty : pt_bne

  property pt_blt;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_blt(valid_retire, rvfi_insn))
    |-> (fc_blt(rvfi_rs1_rdata, rvfi_rs2_rdata, rvfi_pc_rdata, rvfi_insn) == rvfi_pc_wdata);
  endproperty : pt_blt

  property pt_bge;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_bge(valid_retire, rvfi_insn))
    |-> (fc_bge(rvfi_rs1_rdata, rvfi_rs2_rdata, rvfi_pc_rdata, rvfi_insn) == rvfi_pc_wdata);
  endproperty : pt_bge

  property pt_bltu;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_bltu(valid_retire, rvfi_insn))
    |-> (fc_bltu(rvfi_rs1_rdata, rvfi_rs2_rdata, rvfi_pc_rdata, rvfi_insn) == rvfi_pc_wdata);
  endproperty : pt_bltu

  property pt_bgeu;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_bgeu(valid_retire, rvfi_insn))
    |-> (fc_bgeu(rvfi_rs1_rdata, rvfi_rs2_rdata, rvfi_pc_rdata, rvfi_insn) == rvfi_pc_wdata);
  endproperty : pt_bgeu

  property pt_sw_addr;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sw(valid_retire, rvfi_insn, rvfi_mem_addr, ALIGNED_MEM))
    |-> (rvfi_mem_addr == fc_mem_addr(rvfi_rs1_rdata, rvfi_insn, ALIGNED_MEM));
  endproperty : pt_sw_addr

  property pt_sw_wdata;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sw(valid_retire, rvfi_insn))
    |-> (fc_sw_wdata(rvfi_mem_wdata) == rvfi_rs2_rdata);
  endproperty : pt_sw_wdata

  property pt_sh_addr;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sh(valid_retire, rvfi_insn, rvfi_mem_addr, ALIGNED_MEM))
    |-> (rvfi_mem_addr == fc_mem_addr(rvfi_rs1_rdata, rvfi_insn, ALIGNED_MEM));
  endproperty : pt_sh_addr

  property pt_sh_wdata;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sh(valid_retire, rvfi_insn))
    |-> (fc_sh_wdata(rvfi_mem_wdata, rvfi_mem_wmask) == rvfi_rs2_rdata[15:0]);
  endproperty : pt_sh_wdata

  property pt_sb_addr;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sb(valid_retire, rvfi_insn, rvfi_mem_addr, ALIGNED_MEM))
    |-> (rvfi_mem_addr == fc_mem_addr(rvfi_rs1_rdata, rvfi_insn, ALIGNED_MEM));
  endproperty : pt_sb_addr

  property pt_sb_wdata;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_sb(valid_retire, rvfi_insn))
    |-> (fc_sb_wdata(rvfi_mem_wdata, rvfi_mem_wmask) == rvfi_rs2_rdata[7:0]);
  endproperty : pt_sb_wdata

  property pt_lb_addr;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lb(valid_retire, rvfi_insn, rvfi_mem_addr, ALIGNED_MEM))
    |-> (rvfi_mem_addr == fc_mem_addr(rvfi_rs1_rdata, rvfi_insn, ALIGNED_MEM));
  endproperty : pt_lb_addr

  property pt_lb_rdata;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lb(valid_retire_rd, rvfi_insn))
    |-> (fc_lb_rdata(rvfi_mem_rdata, rvfi_mem_rmask) == rvfi_rd_wdata);
  endproperty : pt_lb_rdata

  property pt_lbu_addr;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lbu(valid_retire, rvfi_insn, rvfi_mem_addr, ALIGNED_MEM))
    |-> (rvfi_mem_addr == fc_mem_addr(rvfi_rs1_rdata, rvfi_insn, ALIGNED_MEM));
  endproperty : pt_lbu_addr

  property pt_lbu_rdata;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lbu(valid_retire_rd, rvfi_insn))
    |-> (fc_lbu_rdata(rvfi_mem_rdata, rvfi_mem_rmask) == rvfi_rd_wdata);
  endproperty : pt_lbu_rdata

  property pt_lh_addr;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lh(valid_retire, rvfi_insn, rvfi_mem_addr, ALIGNED_MEM))
    |-> (rvfi_mem_addr == fc_mem_addr(rvfi_rs1_rdata, rvfi_insn, ALIGNED_MEM));
  endproperty : pt_lh_addr

  property pt_lh_rdata;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lh(valid_retire_rd, rvfi_insn))
    |-> (fc_lh_rdata(rvfi_mem_rdata, rvfi_mem_rmask) == rvfi_rd_wdata);
  endproperty : pt_lh_rdata

  property pt_lhu_addr;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lhu(valid_retire, rvfi_insn, rvfi_mem_addr, ALIGNED_MEM))
    |-> (rvfi_mem_addr == fc_mem_addr(rvfi_rs1_rdata, rvfi_insn, ALIGNED_MEM));
  endproperty : pt_lhu_addr

  property pt_lhu_rdata;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lhu(valid_retire_rd, rvfi_insn))
    |-> (fc_lhu_rdata(rvfi_mem_rdata, rvfi_mem_rmask) == rvfi_rd_wdata);
  endproperty : pt_lhu_rdata

  property pt_lw_addr;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lw(valid_retire, rvfi_insn, rvfi_mem_addr, ALIGNED_MEM))
    |-> (rvfi_mem_addr == fc_mem_addr(rvfi_rs1_rdata, rvfi_insn, ALIGNED_MEM));
  endproperty : pt_lw_addr

  property pt_lw_rdata;
    @(posedge clock) disable iff (reset)
    (fc_is_valid_lw(valid_retire_rd, rvfi_insn))
    |-> (fc_lw_rdata(rvfi_mem_rdata) == rvfi_rd_wdata);
  endproperty : pt_lw_rdata

  // Reg-Reg
  ast_add   : assert property(pt_add);
  ast_sub   : assert property(pt_sub);
  ast_and   : assert property(pt_and);
  ast_or    : assert property(pt_or);
  ast_xor   : assert property(pt_xor);
  ast_sll   : assert property(pt_sll);
  ast_srl   : assert property(pt_srl);
  ast_sra   : assert property(pt_sra);
  ast_slt   : assert property(pt_slt);
  ast_sltu  : assert property(pt_sltu);

  // Reg-Imm
  ast_addi   : assert property(pt_addi);
  ast_andi   : assert property(pt_andi);
  ast_ori    : assert property(pt_ori);
  ast_xori   : assert property(pt_xori);
  ast_slli   : assert property(pt_slli);
  ast_srli   : assert property(pt_srli);
  ast_srai   : assert property(pt_srai);
  ast_slti   : assert property(pt_slti);
  ast_sltiu  : assert property(pt_sltiu);

  // Jumps
  ast_jalr_pc : assert property(pt_jalr_pc);
  ast_jalr_rd : assert property(pt_jalr_rd);
  ast_jal_pc  : assert property(pt_jal_pc);
  ast_jal_rd  : assert property(pt_jal_rd);

  // Register loads
  ast_lui   : assert property(pt_lui);
  ast_auipc : assert property(pt_auipc);

  // Branches
  ast_beq  : assert property(pt_beq);
  ast_bne  : assert property(pt_bne);
  ast_blt  : assert property(pt_blt);
  ast_bge  : assert property(pt_bge);
  ast_bltu : assert property(pt_bltu);
  ast_bgeu : assert property(pt_bgeu);

  // Store
  ast_sw_addr   : assert property(pt_sw_addr);
  ast_sw_data   : assert property(pt_sw_wdata);
  ast_sh_addr   : assert property(pt_sh_addr);
  ast_sh_data   : assert property(pt_sh_wdata);
  ast_sb_addr   : assert property(pt_sb_addr);
  ast_sb_data   : assert property(pt_sb_wdata);

  // Load
  ast_lb_addr   : assert property(pt_lb_addr);
  ast_lb_data   : assert property(pt_lb_rdata);
  ast_lbu_addr  : assert property(pt_lbu_addr);
  ast_lbu_data  : assert property(pt_lbu_rdata);
  ast_lh_addr   : assert property(pt_lh_addr);
  ast_lh_data   : assert property(pt_lh_rdata);
  ast_lhu_addr  : assert property(pt_lhu_addr);
  ast_lhu_data  : assert property(pt_lhu_rdata);
  ast_lw_addr   : assert property(pt_lw_addr);
  ast_lw_data   : assert property(pt_lw_rdata);

endmodule : rvfi_assertions_rv32i
