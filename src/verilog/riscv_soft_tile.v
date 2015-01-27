`include "riscv_soft_constants.v"
`include "riscv_soft_core.v"
`include "riscv_soft_unified_cache.v"

module riscv_soft_tile(
		       clk,
		       reset,
		       host_req_ready,
		       host_req_valid,
		       host_req_op,
		       host_req_op_type,
		       host_req_addr,
		       host_req_data,
		       host_resp_valid,
		       host_resp_data
		       );

   parameter XPR_LEN = 32;
   
   input 		   clk;
   input 		   reset;

   output 		   host_req_ready;
   input 		   host_req_valid;
   input [1:0] 		   host_req_op;
   input [2:0] 		   host_req_op_type;
   input [XPR_LEN-1:0] 	   host_req_addr;
   input [XPR_LEN-1:0] 	   host_req_data;
   output 		   host_resp_valid;
   output [XPR_LEN-1:0]    host_resp_data;   

   wire 		   i_cache_req_ready;
   wire 		   i_cache_req_valid;
   wire [XPR_LEN-1:0] 	   i_cache_req_addr;
   wire 		   i_cache_resp_valid;
   wire [XPR_LEN-1:0] 	   i_cache_resp_data;

   wire 		   d_cache_req_ready;
   wire 		   d_cache_req_valid;
   wire [1:0] 		   d_cache_req_op;
   wire [2:0] 		   d_cache_req_op_type;
   wire [XPR_LEN-1:0] 	   d_cache_req_addr;
   wire [XPR_LEN-1:0] 	   d_cache_req_data;
   wire 		   d_cache_resp_valid;
   wire [XPR_LEN-1:0] 	   d_cache_resp_data;
   

   
   riscv_soft_core core(
			.clk(clk),
			.reset(reset),
			.i_cache_req_ready(i_cache_req_ready),
			.i_cache_req_valid(i_cache_req_valid),
			.i_cache_req_addr(i_cache_req_addr),
			.i_cache_resp_valid(i_cache_resp_valid),
			.i_cache_resp_data(i_cache_resp_data),
			.d_cache_req_ready(d_cache_req_ready),
			.d_cache_req_valid(d_cache_req_valid),
			.d_cache_req_op(d_cache_req_op),	
			.d_cache_req_op_type(d_cache_req_op_type),
			.d_cache_req_addr(d_cache_req_addr),
			.d_cache_req_data(d_cache_req_data),
			.d_cache_resp_valid(d_cache_resp_valid),
			.d_cache_resp_data(d_cache_resp_data)
			);

   
   riscv_soft_unified_cache cache(
				  .clk(clk),
				  .reset(reset),
				  .i_fetch_req_ready(i_cache_req_ready),
				  .i_fetch_req_valid(i_cache_req_valid),
				  .i_fetch_req_addr(i_cache_req_addr),
				  .i_fetch_resp_valid(i_cache_resp_valid),
				  .i_fetch_resp_data(i_cache_resp_data),
				  .data_req_ready(d_cache_req_ready),
				  .data_req_valid(d_cache_req_valid),
				  .data_req_op(d_cache_req_op),
				  .data_req_op_type(d_cache_req_op_type),
				  .data_req_addr(d_cache_req_addr),
				  .data_req_data(d_cache_req_data),
				  .data_resp_valid(d_cache_resp_valid),
				  .data_resp_data(d_cache_resp_data),
				  .host_req_ready(host_req_ready),
				  .host_req_valid(host_req_valid),
				  .host_req_op(host_req_op),
				  .host_req_op_type(host_req_op_type),
				  .host_req_addr(host_req_addr),
				  .host_req_data(host_req_data),
				  .host_resp_valid(host_resp_valid),
				  .host_resp_data(host_resp_data)
				  );
   
endmodule // riscv_soft_tile
