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

module cv6_axi_assumptions #(
  parameter int unsigned ARLEN_WIDTH = 8,
  parameter int unsigned RSP_MAX_LATENCY = 1
) (
  input logic                     ACLK,
  input logic                     ARESETn,
  input logic                     ARVALID,
  input logic [ARLEN_WIDTH-1:0]   ARLEN,
  input logic                     RVALID,
  input logic                     RLAST,
  input logic [1:0]               RRESP,
  input logic                     AWREADY,
  input logic                     WREADY,
  input logic                     ARREADY
);

  asm_always_w_ready : assume property (
    @(posedge ACLK) disable iff (!ARESETn)
     (WREADY == 1)
  );

  asm_always_aw_ready : assume property (
    @(posedge ACLK) disable iff (!ARESETn)
     (AWREADY == 1)
  );

  asm_always_ar_ready : assume property (
    @(posedge ACLK) disable iff (!ARESETn)
     (ARREADY == 1)
  );

  asm_axi_small_burst : assume property (
    @(posedge ACLK) disable iff (!ARESETn)
    ARVALID |-> (ARLEN inside {[0:3]})
  );

  property prot_axi_read_burst_len (int unsigned LEN);
    @(posedge ACLK) disable iff (!ARESETn)
      (ARVALID && (ARLEN == LEN)) |->
        ##[1:RSP_MAX_LATENCY] (RVALID && !RLAST)[*(LEN)]
        ##1 (RVALID &&  RLAST);
  endproperty

  asm_axi_read_burst_len_0 : assume property (prot_axi_read_burst_len(0));
  asm_axi_read_burst_len_1 : assume property (prot_axi_read_burst_len(1));
  asm_axi_read_burst_len_2 : assume property (prot_axi_read_burst_len(2));
  asm_axi_read_burst_len_3 : assume property (prot_axi_read_burst_len(3));

  asm_always_okay : assume property (
    @(posedge ACLK) disable iff (!ARESETn)
    RVALID |-> (RRESP == 2'b0)
  );

  asm_no_extra_rvalid : assume property (
    @(posedge ACLK) disable iff (!ARESETn)
    (RVALID && RLAST) |-> ##1 (!RVALID)
  );

  asm_no_spurious_rvalid : assume property (
    @(posedge ACLK) disable iff (!ARESETn)
    (!ARVALID && !RVALID) |-> ##1 !RVALID
  );

endmodule : cv6_axi_assumptions
