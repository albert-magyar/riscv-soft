`include "riscv_soft_constants.v"
`include "riscv_soft_tile.v"

module riscv_soft_tile_testbench;

   reg clk;
   reg reset;
   wire host_req_ready;
   reg 	host_req_valid;
   reg [1:0] host_req_op;
   reg [2:0] host_req_op_type;
   reg [31:0] host_req_addr;
   reg [31:0] host_req_data;
   wire       host_resp_valid;
   wire [31:0] host_resp_data;

   riscv_soft_tile DUT(
		       .clk(clk),
		       .reset(reset),
		       .host_req_ready(host_req_ready),
		       .host_req_valid(host_req_valid),
		       .host_req_op(host_req_op),
		       .host_req_op_type(host_req_op_type),
		       .host_req_addr(host_req_addr),
		       .host_req_data(host_req_data),
		       .host_resp_valid(host_resp_valid),
		       .host_resp_data(host_resp_data)
		     );

   initial begin
      clk = 0;
      reset = 0;
      host_req_valid = 0;
      host_req_op = 0;
      host_req_op_type = `MEM_TYPE_WORD;
      host_req_addr = 0;
      host_req_data = 0;
   end

   always
     #10 clk = !clk;

   initial begin
      @(posedge clk) begin
	 host_req_op = 
   