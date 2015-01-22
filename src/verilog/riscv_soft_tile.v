module riscv_soft_tile(
		       clk,
		       reset,
		       htif_in_ready,
		       htif_in_valid,
		       htif_in_data,
		       htif_out_ready,
		       htif_out_valid,
		       htif_out_data,
		       htif_clk,
		       htif_clk_edge,
		       htif_debug_stats_pcr
		       );

   parameter HTIF_WIDTH = 16;

   input 		   clk;
   input 		   reset;
   
   output 		   htif_in_ready;
   input 		   htif_in_valid;
   input [HTIF_WIDTH-1:0]  htif_in_data;
   
   input 		   htif_out_ready;
   output 		   htif_out_valid;
   output [HTIF_WIDTH-1:0] htif_out_data;
   
   output 		   htif_clk;
   output 		   htif_clk_edge;
   output 		   htif_debug_stats_pcr;

   riscv_soft_core core(
			.clk(clk),
			.reset(reset)
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

   
   riscv_soft_i_cache i_cache(
			      .clk(clk),
			      .reset(reset),
    			      .req_ready(i_cache_req_ready),
			      .req_valid(i_cache_req_valid),
			      .req_addr(i_cache_req_addr),
			      .resp_valid(i_cache_resp_valid),
			      .resp_data(i_cache_resp_data)
			      );
   
   
   riscv_soft_d_cache d_cache(
			      .clk(clk),
			      .reset(reset),
   			      .req_ready(d_cache_req_ready),
			      .req_valid(d_cache_req_valid),
			      .req_op(d_cache_req_op),	
			      .req_op_type(d_cache_req_op_type),
			      .req_addr(d_cache_req_addr),
			      .req_data(d_cache_req_data),
			      .resp_valid(d_cache_resp_valid),
			      .resp_data(d_cache_resp_data)
			      );
   
endmodule // riscv_soft_tile
