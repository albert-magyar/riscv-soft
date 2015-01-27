module riscv_soft_regfile(
			  clk,
			  reset,
			  rd_addr_1,
			  rd_data_1,
			  rd_addr_2,
			  rd_data_2,
			  wr_en,
			  wr_addr,
			  wr_data
			  );

   parameter XPR_LEN = 32;
   localparam NUM_REGS = 32;
   
   input clk;
   input reset;
   input [4:0] rd_addr_1;
   output [XPR_LEN-1:0] rd_data_1;
   input [4:0] rd_addr_2;
   output [XPR_LEN-1:0] rd_data_2;
   input 		wr_en;
   input [4:0] 		wr_addr;
   input [XPR_LEN-1:0] 	wr_data;
   
   reg [XPR_LEN-1:0] 	mem [0:NUM_REGS-1];
   
   assign rd_data_1 = (rd_addr_1 == 0) ? 0 : mem[rd_addr_1];
   assign rd_data_2 = (rd_addr_2 == 0) ? 0 : mem[rd_addr_2];   

   always @(posedge clk) begin
      if (wr_en) mem[wr_addr] <= wr_data;
   end
   
endmodule // riscv_soft_regfile

			  