module riscv_soft_alu_src_mux(
			      sel,
			      imm,
			      PC,
			      reg_data,
			      fwd,
			      bypass_data,
			      output_data
			      );

   parameter XPR_LEN = 32;
   
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
	`ALU_SRC_IMM : output_data_unbypassed = imm;
	`ALU_SRC_PC : output_data_unbypassed = PC;
	`ALU_SRC_REG : output_data_unbypassed = reg_data;
	`ALU_SRC_ZERO : output_data_unbypassed = 0;
	default : output_data_unbypassed = 0;
      endcase // case (sel)
   end

   assign output_data = (fwd) ? bypass_data : output_data_unbypassed;

endmodule // riscv_soft_alu_src_mux
