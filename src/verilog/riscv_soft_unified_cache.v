module riscv_soft_unified_cache(
				clk,
				reset,
				i_fetch_req_ready,
				i_fetch_req_valid,
				i_fetch_req_addr,
				i_fetch_resp_valid,
				i_fetch_resp_data
				data_req_ready,
				data_req_valid,
				data_req_op,
				data_req_op_type,
				data_req_addr,
				data_req_data,
				data_resp_valid,
				data_resp_data,
				host_req_ready,
				host_req_valid,
				host_req_op,
				host_req_op_type,
				host_req_addr,
				host_req_data,
				host_resp_valid,
				host_resp_data
				);

   parameter DEPTH = 512;
   parameter XPR_LEN = 32;

   input 		clk;
   input 		reset;

   output 		    i_fetch_req_ready;
   input 		    i_fetch_req_valid;
   input [XPR_LEN-1:0] 	    i_fetch_req_addr;
   
   output reg 		    i_fetch_resp_valid;
   output reg [XPR_LEN-1:0] i_fetch_resp_data;
   
   output 		    data_req_ready;
   input 		    data_req_valid;
   input [1:0] 		    data_req_op;
   input [2:0] 		    data_req_op_type;
   input [XPR_LEN-1:0] 	    data_req_addr;
   input [XPR_LEN-1:0] 	    data_req_data;
   
   output reg 		    data_resp_valid;
   output reg [XPR_LEN-1:0] data_resp_data;

   output 		    host_req_ready;
   input 		    host_req_valid;
   input [1:0] 		    host_req_op;
   input [2:0] 		    host_req_op_type;
   input [XPR_LEN-1:0] 	    host_req_addr;
   input [XPR_LEN-1:0] 	    host_req_data;
   
   output reg 		    host_resp_valid;
   output reg [XPR_LEN-1:0] host_resp_data;
   
   reg [31:0] 		    mem [DEPTH-1:0];
   
   wire 		    arb_rw_req_valid;
   wire [1:0] 		    arb_rw_req_op;
   wire [2:0] 		    arb_rw_req_op_type;
   wire [XPR_LEN-1:0] 	    arb_rw_req_addr;
   wire [XPR_LEN-1:0] 	    arb_rw_req_data;

   reg 			    arb_rw_resp_valid;
   reg [XPR_LEN-1:0] 	    arb_rw_resp_data;

   reg 			    was_host_req;
   
   assign host_req_ready = 1;
   assign i_fetch_req_ready = !host_req_valid;
   assign data_req_ready = !host_req_valid;

   assign arb_rw_req_valid = host_req_valid || data_req_valid;
   assign arb_rw_req_op = (host_req_valid) ?
			  host_req_op : data_req_op;
   assign arb_rw_req_op_type = (host_req_valid) ?
			       host_req_op_type : data_req_op_type;
   assign arb_rw_req_addr = (host_req_valid) ?
			    host_req_addr : data_req_addr;
   assign arb_rw_req_data = (host_req_valid) ?
			    host_req_data : data_req_data;

   
   
   always @(posedge clk) begin
      i_fetch_resp_valid <= i_fetch_req_valid && !host_req_valid;
      i_fetch_resp_data <= mem[i_fetch_req_addr];
      data_resp_valid <= data_req_valid;
      arb_rw_resp_data <= mem[arb_rw_req_addr];
      host_resp_valid <= host_req_valid;
      data_resp_valid <= data_req_valid && !host_req_valid;
      if (arb_rw_req_op == `MEM_STORE) mem[arb_rw_req_addr] <= arb_rw_req_data;
   end
   
   always @(*) begin
      host_resp_data = arb_rw_resp_data;
      data_resp_data = arb_rw_resp_data;
   end
   
// \   localparam BYTE_WIDTH = 8;
// \   localparam INT_ADDR_WIDTH = log2(DEPTH);
// \	  
// \   wire [(XPR_LEN/BYTE_WIDTH)-1:0] wr_en;
// \   wire [INT_ADDR_WIDTH-1:0] 	   wr_addr;
// \   wire [XPR_LEN-1:0] 		   wr_data;
// \   wire [INT_ADDR_WIDTH-1:0] 	   rd_addr;
// \   reg [XPR_LEN-1:0] 		   rd_data;
// \   reg [BYTE_WIDTH-1:0] 	   wr_data_0, wr_data_1, wr_data_2, wr_data_3;
// \   reg [XPR_LEN-1:0] 		   RAM [DEPTH-1:0];
// \
// \
// \
// \   always @(wr_en or wr_data) begin
// \      if (wr_en[3])
// \	wr_data_3 = wr_data[4*BYTE_WIDTH-1 -: BYTE_WIDTH];
// \      else
// \	wr_data_3 = RAM[addr]wr_data[4*BYTE_WIDTH-1 -: BYTE_WIDTH];
// \      if (wr_en[2])
// \	wr_data_2 = wr_data[3*BYTE_WIDTH-1 -: BYTE_WIDTH];
// \      else
// \	wr_data_2 = RAM[addr]wr_data[3*BYTE_WIDTH-1 -: BYTE_WIDTH];
// \      if (wr_en[1])
// \	wr_data_1 = wr_data[2*BYTE_WIDTH-1 -: BYTE_WIDTH];
// \      else
// \	wr_data_1 = RAM[addr]wr_data[2*BYTE_WIDTH-1 -: BYTE_WIDTH];
// \      if (wr_en[0])
// \	wr_data_0 = wr_data[1*BYTE_WIDTH-1 -: BYTE_WIDTH];
// \      else
// \	wr_data_0 = RAM[addr]wr_data[1*BYTE_WIDTH-1 -: BYTE_WIDTH];
// \   end // always @ (wr_en or wr_data)
// \   
// \   always @(posedge clk) begin
// \      RAM[wr_addr] <= {wr_data_3,wr_data_2,wr_data_1,wr_data_0};
// \      rd_data <= RAM[rd_addr];
// \   end
   
endmodule // riscv_soft_d_cache
