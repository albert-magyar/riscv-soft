module riscv_soft_alu_src_mux(

			      );

   input [1:0] sel;
   input [XPR_LEN-1:0] imm;
   input [XPR_LEN-1:0] PC;
   input [XPR_LEN-1:0] reg_data;
   input 	       fwd;
   input [XPR_LEN-1:0] bypass_data;
   reg [XPR_LEN-1:0]   output_data_unbypassed;
   output [XPR_LEN-1:0] output_data;
   
   always @(*) begin
      case (sel)
	`ALU_SRC_IMM : output_data = imm;
	`ALU_SRC_PC : output_data = PC;
	`ALU_SRC_REG : output_data = reg_data;
	`ALU_SRC_ZERO : output_data = 0;
	default : output_data = 0;
      endcase // case (sel)
   end

   assign output_data = (fwd) ? bypass_data : output_data_unbypassed;

endmodule // riscv_soft_alu_src_mux
