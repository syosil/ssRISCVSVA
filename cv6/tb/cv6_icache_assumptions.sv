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

module cv6_icache_assumptions #(
  parameter int MAX_CACHE_DELAY = 1,
  parameter type icache_dreq_t  = logic,
  parameter type icache_drsp_t  = logic
) (
  input logic clk,
  input logic rst,
  icache_dreq_t dreq_i,
  icache_drsp_t dreq_o
);

  asm_ic_rsp_in_1cy : assume property (
    @(posedge clk) disable iff (rst)
    (dreq_i.req &&
     dreq_o.ready)
    |-> ##[1:MAX_CACHE_DELAY] dreq_o.valid
  );

  asm_ic_rsp_no_kill_s1 : assume property (
    @(posedge clk) disable iff (rst)
    (!dreq_i.kill_s1)
  );

  asm_ic_rsp_no_kill_s2 : assume property (
    @(posedge clk) disable iff (rst)
    (!dreq_i.kill_s2)
  );

endmodule : cv6_icache_assumptions
