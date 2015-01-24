module riscv_soft_core(
		       clk,
		       reset,
		       i_cache_req_ready,
		       i_cache_req_valid,
		       i_cache_req_addr,
		       i_cache_resp_valid,
		       i_cache_resp_data,
		       d_cache_req_ready,
		       d_cache_req_valid,
		       d_cache_req_op,
		       d_cache_req_op_type,
		       d_cache_req_addr,
		       d_cache_req_data,
		       d_cache_resp_valid,
		       d_cache_resp_data
		       );


   parameter XPR_LEN = 32;
   localparam INST_LEN = 32;

   reg [XPR_LEN-1:0] PC_IF;

   reg [XPR_LEN-1:0] PC_EX;
   reg [31:0] 	     inst_EX;
   
   wire [4:0] 	      rs1_EX;
   wire [XPR_LEN-1:0] rs1_data_EX;
   wire [4:0] 	      rs2_EX;
   wire [XPR_LEN-1:0] rs2_data_EX;

   riscv_soft_regfile regfile(
			      .clk(clk),
			      .reset(reset),
			      .rd_addr_1(rs1_EX),
			      .rd_data_1(rs1_data_EX),
			      .rd_addr_2(rs2_EX),
			      .rd_data_2(rs2_data_EX),
			      .wr_en(wr_reg_WB),
			      .wr_addr(reg_wr_WB),
			      .wr_data(wb_data_WB)
			      )
   
   reg [XPR_LEN-1:0] PC_WB;
   
   
endmodule // riscv_soft_core
