module riscv_soft_imm_logic(
			    inst,
			    imm_type_sel,
			    imm
			    );

   parameter XPR_LEN = 32;

   input [31:0] 	    inst;
   input [2:0] 		    imm_sel;
   output reg [XPR_LEN-1:0] imm;

   always @(*) begin
      case (imm_sel)
	`IMM_I : imm = $signed({inst[31:20]});
	`IMM_S : imm = $signed({inst[31:25],inst[11:7]});
	`IMM_B : imm = $signed({inst[31],inst[7],inst[30:25],inst[11:8],1'b0});
	`IMM_U : imm = {inst[31:12],12'b0};
	`IMM_J : imm = $signed({inst[31],inst[19:12],inst[20],inst[30:21],1'b0});
	default : imm = 0;
   end

endmodule // riscv_soft_imm_logic
