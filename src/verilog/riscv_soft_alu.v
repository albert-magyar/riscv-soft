`include "riscv_soft_constants.v"

module riscv_soft_alu(
		      operation,
		      operand_1,
		      operand_2,
		      result,
		      cmp_true
		      );

   parameter XPR_LEN = 32;

   function integer log2;
      input integer i;
      begin
	 i = value - 1;
	 for (log2 = 0; value > 0; log2 = log2 + 1)
	   value = value >> 1;
      end
   endfunction

   localparam LOG2_XPR_LEN = log2(XPR_LEN);
   
   input [3:0] 		    operation;
   input [XPR_LEN-1:0] 	    operand_1;
   input [XPR_LEN-1:0] 	    operand_2;
   output reg [XPR_LEN-1:0] result;
   output 		    cmp_true;

   assign cmp_true = result[0];
   
   wire [LOG2_XPR_LEN-1:0]  shamt = operand_2[LOG2_XPR_LEN-1:0];
   
   always @(*) begin
      case (operation)
	`ALU_OP_ADD : result = operand_1 + operand_2;
	`ALU_OP_SLT : result = ($signed(operand_1) < $signed(operand_2));
	`ALU_OP_SLTU : result = operand_1 < operand_2;
	`ALU_OP_SEQ : result = operand_1 == operand_2;
	`ALU_OP_SNE : result = operand_1 != operand_2;
	`ALU_OP_SGE : result = ($signed(operand_1) > $signed(operand_2));
	`ALU_OP_SGEU : result = operand_1 > operand_2;
	`ALU_OP_AND : result = operand_1 & operand_2;
	`ALU_OP_OR : result = operand_1 | operand_2;
	`ALU_OP_XOR : result = operand_1 ^ operand_2;
	`ALU_OP_SLL : result = operand_1 << shamt;
	`ALU_OP_SRL : result = operand_1 >> shamt;
	`ALU_OP_SUB : result = operand_1 - operand_2;
	`ALU_OP_SRA : result = $signed(operand_1) >>> shamt;
	default : result = 0;
      endcase // case (operation)
   end

endmodule // riscv_soft_alu
