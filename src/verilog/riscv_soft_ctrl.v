module ctrl_int(
		clk,
		reset,
		instruction,
		imm_sel,
		alu_src_1_sel,
		alu_src_2_sel,
		alu_op,
		next_pc_src,
		mem_op,
		mem_op_type,
		wb_data_src
		);

   parameter XPR_LEN = 32;

   localparam INST_LEN = 32;
   
   input 	    clk;
   input 	    reset;
   input [31:0]     instruction;

   output reg [2:0] imm_sel;
   output reg [1:0] alu_src_1_sel;
   output reg [1:0] alu_src_2_sel;
   output reg [3:0] alu_op;
   output reg 	    next_pc_src;
   output reg [1:0] mem_op;
   output reg [2:0] mem_op_type;
   output reg [1:0] wb_data_src;

   always @(*) begin
      case (opcode(instruction))
	`OP_IMM : begin
	   alu_src_1_sel = `ALU_SRC_RS1;
	   alu_src_2_sel = `ALU_SRC_IMM;
	   next_pc_src  = `PC_PLUS_4;
	   mem_op = `MEM_NOP;
	   mem_op_type = 3'bxxx;
	   wb_data_src = `WB_SRC_ALU;
	   imm_sel = `IMM_S
	   case (funct3(instruction))
	     `ADDI : alu_op = `ALU_OP_ADD;
	     `SLTI : alu_op = `ALU_OP_SLT;
	     `ANDI : alu_op = `ALU_OP_AND;
	     `ORI : alu_op = `ALU_OP_OR;
	     `XORI : alu_op = `ALU_OP_XOR;
	     `SLLI : alu_op = `ALU_OP_SLL;
	     `SRLI : alu_op = `ALU_OP_SRL;
	     `SRAI : alu_op = `ALU_OP_SRA;
	     default : alu_op = 4'bxxxx;
	   endcase // case (funct3(instruction))
	end

	`LUI : begin
	   alu_src_1_sel = `ALU_SRC_ZERO;
	   alu_src_2_sel = `ALU_SRC_IMM;
	   next_pc_src  = `PC_PLUS_4;
	   mem_op = `MEM_NOP;
	   mem_op_type = 3'bxxx;
	   wb_data_src = `WB_SRC_ALU;
	   imm_sel = `IMM_U;
	   alu_op = `ALU_OP_ADD;
	end
	`AUIPC : begin
	   alu_src_1_sel = `ALU_SRC_PC;
	   alu_src_2_sel = `ALU_SRC_IMM;
	   next_pc_src  = `PC_PLUS_4;
	   mem_op = `MEM_NOP;
	   mem_op_type = 3'bxxx;
	   wb_data_src = `WB_SRC_ALU;
	   imm_sel = `IMM_U;
	   alu_op = `ALU_OP_ADD;
	end

	`OP : begin
	   alu_src_1_sel = `ALU_SRC_RS1;
	   alu_src_2_sel = `ALU_SRC_RS2;
	   next_pc_src  = `PC_PLUS_4;
	   mem_op = `MEM_NOP;
	   mem_op_type = 3'bxxx;
	   wb_data_src = `WB_SRC_ALU;
	   imm_sel = 3'bxxx;
	   case(cat_funct7_funct3(instruction))
	     `ADD : alu_op = `ALU_OP_ADD;
	     `SLT : alu_op = `ALU_OP_SLT;
	     `SLTU : alu_op = `ALU_OP_SLTU;
	     `AND : alu_op = `ALU_OP_AND;
	     `OR : alu_op = `ALU_OP_OR;
	     `XOR : alu_op = `ALU_OP_XOR;
	     `SLL : alu_op = `ALU_OP_SLL;
	     `SRL : alu_op = `ALU_OP_SRL;
	     `SUB : alu_op = `ALU_OP_SUB;
	     `SRA : alu_op = `ALU_OP_SRA;
	     default : alu_op = 4'bxxxx;
	   endcase // case (cat_funct7_funct3(instruction))
	end // case: `OP
	

	`JAL : begin
	   alu_src_1_sel = `ALU_SRC_PC;
	   alu_src_2_sel = `ALU_SRC_IMM;
	   next_pc_src  = `PC_JUMP;
	   mem_op = `MEM_NOP;
	   mem_op_type = 3'bxxx;
	   wb_data_src = `WB_SRC_PC_PLUS_4;
	   imm_sel = `IMM_J;
	   alu_op = `ALU_OP_ADD;
	end
	
	`JALR : begin
	   alu_src_1_sel = `ALU_SRC_RS1;
	   alu_src_2_sel = `ALU_SRC_IMM;
	   next_pc_src  = `PC_JUMP;
	   mem_op = `MEM_NOP;
	   mem_op_type = 3'bxxx;
	   wb_data_src = `WB_SRC_PC_PLUS_4;
	   imm_sel = `IMM_I;
	   alu_op = `ALU_OP_ADD;
	end

	`BRANCH : begin
	   alu_src_1_sel = `ALU_SRC_RS1;
	   alu_src_2_sel = `ALU_SRC_RS2;
	   next_pc_src  = `PC_BRANCH;
	   mem_op = `MEM_NOP;
	   mem_op_type = 3'bxxx;
	   wb_data_src = `WB_SRC_NONE;
	   imm_sel = `IMM_B;
	   case (funct3(instruction))
	     `BEQ : alu_op = `ALU_OP_SEQ;
	     `BNE : alu_op = `ALU_OP_SNE;
	     `BLT : alu_op = `ALU_OP_SLT;
	     `BLTU : alu_op = `ALU_OP_SLTU;
	     `BGE : alu_op = `ALU_OP_SGE;
	     `BGEU : alu_op = `ALU_OP_SGEU;
	     default : alu_op = 4'bxxxx;
	   endcase // case (funct3(instruction))
	end // case: `BRANCH
	
	`LOAD : begin
	   alu_src_1_sel = `ALU_SRC_RS1;
	   alu_src_2_sel = `ALU_SRC_IMM;
	   next_pc_src  = `PC_PLUS_4;
	   mem_op = `MEM_LOAD;
	   mem_op_type = funct3(instruction);
	   wb_data_src = `WB_SRC_MEM;
	   imm_sel = `IMM_I;
	   alu_op = `ALU_OP_ADD;
	end
	`STORE : begin
	   alu_src_1_sel = `ALU_SRC_RS1;
	   alu_src_2_sel = `ALU_SRC_IMM;
	   next_pc_src  = `PC_PLUS_4;
	   mem_op = `MEM_STORE;
	   mem_op_type = funct3(instruction);
	   wb_data_src = `WB_SRC_NONE;
	   imm_sel = `IMM_S;
	   alu_op = `ALU_OP_ADD;
	end

	`MISC_MEM : begin
	   alu_src_1_sel = 2'bxx;
	   alu_src_2_sel = 2'bxx;
	   next_pc_src  = `PC_PLUS_4;
	   mem_op = `MEM_FENCE;
	   mem_op_type = 3'bxxx;
	   wb_data_src = `WB_SRC_NONE;
	   imm_sel = 3'bxxx;	   
	   alu_op = 4'bxxxx;
	end
	
	default : begin
	   alu_src_1_sel = 2'bxx;
	   alu_src_2_sel = 2'bxx;
	   next_pc_src = 1'bx;
	   mem_op = 2'bxx;
	   mem_op_type = 3'bxxx;
	   wb_data_src = 2'bxx;
	   imm_sel = 3'bxxx;
	   alu_op = 4'bxxxx;
	end
      endcase // case (opcode(instruction))
   end // always @ (*)

endmodule // ctrl_int

	
   