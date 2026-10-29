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

module rvfi_5stage_bindings (
  //clock and reset
  input             clock,
  input             reset,

  input  [31:0] io_imem_resp_rdata,
  input         io_imem_resp_ack,
  input         io_imem_req_req,
  input  [31:0] io_dmem_resp_rdata,
  input         io_dmem_resp_ack,
  input [31:0] io_imem_req_addr,
  input        io_dmem_req_req,
  input [31:0] io_dmem_req_addr,
  input [31:0] io_dmem_req_wdata,
  input        io_dmem_req_we
);

  // io_imem_resp_ack should go high one clock cycle after io_imem_req_req goes high
  asm_imem_delayed_ack_after_req: assume property (
    @(posedge clock) disable iff (reset)
    io_imem_req_req |-> ##1 io_imem_resp_ack
  );

  // io_imem_resp_ack should be low on the first clock cycle after reset
  asm_imem_ack_low_after_reset: assume property (
    @(posedge clock) disable iff (reset)
    $past(reset) |-> !io_imem_resp_ack
  );

  // io_imem_resp_rdata should be stable for valid requests to the same address
  asm_imem_stable_data: assume property (
    @(posedge clock) disable iff (reset)
    ($past(io_imem_req_req, 2) && $past(io_imem_req_req) &&
     $past(io_imem_resp_ack) && io_imem_resp_ack &&
     $past(io_imem_req_addr, 2) == $past(io_imem_req_addr))
    |-> io_imem_resp_rdata == $past(io_imem_resp_rdata)
  );

  // io_dmem_resp_ack should go high one clock cycle after io_dmem_req_req goes high
  asm_dmem_delayed_ack_after_req: assume property (
    @(posedge clock) disable iff (reset)
    io_dmem_req_req |-> ##1 io_dmem_resp_ack
  );

  // If io_dmem_req_req is low, io_dmem_resp_ack should be low on the next clock cycle
  asm_dmem_ack_low_after_req: assume property (
    @(posedge clock) disable iff (reset)
    !io_dmem_req_req |-> ##1 !io_dmem_resp_ack
  );

  //Only some opcodes should be generated
  asm_only_select_opcodes: assume property (
    @(posedge clock) disable iff (reset)
    io_imem_resp_rdata[OPCODE_OFFSET +: OPCODE_WIDTH] inside {
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

  //Valid OP instructions
  asm_valid_rtype: assume property (
    @(posedge clock) disable iff (reset)
    (io_imem_resp_rdata[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_OP && io_imem_resp_rdata[14:12] inside {3'b000, 3'b101} |-> io_imem_resp_rdata[31:25] inside {7'h20, 7'h00}) and
    (io_imem_resp_rdata[OPCODE_OFFSET +: OPCODE_WIDTH] == OPCODE_OP && !(io_imem_resp_rdata[14:12] inside {3'b000, 3'b101}) |-> io_imem_resp_rdata[31:25] == '0)
  );

endmodule: rvfi_5stage_bindings
