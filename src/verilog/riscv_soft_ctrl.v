`include "riscv_soft_constants.v"

module riscv_soft_ctrl(
		       clk,
		       reset,
		       stall_IF,
		       stall_EX,
		       stall_WB,
		       fwd_alu_src_1_EX,
		       fwd_alu_src_2_EX,
		       fwd_d_cache_data_EX,
		       next_PC_src_PIF,
		       i_cache_req_ready,
		       i_cache_req_valid,
		       i_cache_resp_valid,
		       instruction_EX,
		       imm_sel_EX,
		       alu_src_1_sel_EX,
		       alu_src_2_sel_EX,
		       alu_op_EX,
		       d_cache_req_ready,
		       d_cache_req_valid,
		       d_cache_req_op,
		       d_cache_req_op_type,
		       d_cache_resp_valid,
		       wb_data_src_WB,
		       wr_reg_WB
		       );

   parameter XPR_LEN = 32;

   localparam INST_LEN = 32;

   function [6:0] funct7;
      input [INST_LEN-1:0] instruction;
      funct7 = instruction[31:25];
   endfunction // case

   function [2:0] funct3;
      input [INST_LEN-1:0] instruction;
      funct3 = instruction[14:12];
   endfunction // case

   function [9:0] cat_funct7_funct3;
      input [INST_LEN-1:0] instruction;
      cat_funct7_funct3 = {instruction[31:25],instruction[14:12]};
   endfunction
   
   input 	    clk;
   input 	    reset;
   input [31:0]     instruction_EX;

   // Hazard and bypass signals
   output 	    stall_IF;
   output 	    stall_EX;
   output 	    stall_WB;
   output 	    fwd_alu_src_1_EX;
   output 	    fwd_alu_src_2_EX;
   output 	    fwd_d_cache_data_EX;
   
   // Pre-instruction fetch signals
   output reg [1:0] next_PC_src_PIF;
   input 	    i_cache_req_ready;
   output 	    i_cache_req_valid;

   // Signals used in IF stage
   input 	    i_cache_resp_valid;
   
   
   // Signals used in EX stage
   output reg [2:0] imm_sel_EX;
   output reg [1:0] alu_src_1_sel_EX;
   output reg [1:0] alu_src_2_sel_EX;
   output reg [3:0] alu_op_EX;

   // Signals for d_cache request
   input 	    d_cache_req_ready;
   reg 		    d_cache_req_valid_unkilled;
   output reg 	    d_cache_req_valid;
   output reg [1:0] d_cache_req_op;
   output reg [2:0] d_cache_req_op_type;

   // Signals not used in EX stage
   reg 		    wr_reg_unkilled_EX;		    
   reg [1:0] 	    wb_data_src_EX;

   // Signals from d_cache response
   input 	    d_cache_resp_valid;
   
   // Control signals for WB stage
   reg 		    wr_reg_unkilled_WB;		    
   output reg 	    wr_reg_WB;
   output reg [1:0] wb_data_src_WB;
   
   
   always @(*) begin
      case (opcode(instruction_EX))
	`OP_IMM : begin
	   alu_src_1_sel_EX = `ALU_SRC_REG;
	   alu_src_2_sel_EX = `ALU_SRC_IMM;
	   next_PC_src_PIF  = `PC_SRC_PLUS_4;
	   d_cache_req_op = 2'bxx;
	   d_cache_req_op_type = 3'bxxx;
	   wb_data_src_EX = `WB_SRC_ALU;
	   imm_sel_EX = `IMM_S;
	   case (funct3(instruction_EX))
	     `REG_IMM_FUNCT3_ADDI : alu_op_EX = `ALU_OP_ADD;
	     `REG_IMM_FUNCT3_SLTI : alu_op_EX = `ALU_OP_SLT;
	     `REG_IMM_FUNCT3_ANDI : alu_op_EX = `ALU_OP_AND;
	     `REG_IMM_FUNCT3_ORI : alu_op_EX = `ALU_OP_OR;
	     `REG_IMM_FUNCT3_XORI : alu_op_EX = `ALU_OP_XOR;
	     `REG_IMM_FUNCT3_SLLI : alu_op_EX = `ALU_OP_SLL;
	     `REG_IMM_FUNCT3_SRLI_SRAI : begin
		case (funct7(instruction_EX))
		  `FUNCT7_SRLI : alu_op_EX = `ALU_OP_SRL;
		  `FUNCT7_SRAI : alu_op_EX = `ALU_OP_SRA;
		  default : alu_op_EX = 4'bxxxx;
		endcase // case (funct7(instruction_EX))
	     end
	     default : alu_op_EX = 4'bxxxx;
	   endcase // case (funct3(instruction_EX))
	end

	`OP_LUI : begin
	   alu_src_1_sel_EX = `ALU_SRC_ZERO;
	   alu_src_2_sel_EX = `ALU_SRC_IMM;
	   next_PC_src_PIF  = `PC_SRC_PLUS_4;
	   d_cache_req_op = 2'bxx;
	   d_cache_req_op_type = 3'bxxx;
	   wb_data_src_EX = `WB_SRC_ALU;
	   imm_sel_EX = `IMM_U;
	   alu_op_EX = `ALU_OP_ADD;
	end
	`OP_AUIPC : begin
	   alu_src_1_sel_EX = `ALU_SRC_PC;
	   alu_src_2_sel_EX = `ALU_SRC_IMM;
	   next_PC_src_PIF  = `PC_SRC_PLUS_4;
	   d_cache_req_op = 2'bxx;
	   d_cache_req_op_type = 3'bxxx;
	   wb_data_src_EX = `WB_SRC_ALU;
	   imm_sel_EX = `IMM_U;
	   alu_op_EX = `ALU_OP_ADD;
	end

	`OP_OP : begin
	   alu_src_1_sel_EX = `ALU_SRC_REG;
	   alu_src_2_sel_EX = `ALU_SRC_REG;
	   next_PC_src_PIF  = `PC_SRC_PLUS_4;
	   d_cache_req_op = 2'bxx;
	   d_cache_req_op_type = 3'bxxx;
	   wb_data_src_EX = `WB_SRC_ALU;
	   imm_sel_EX = 3'bxxx;
	   case(cat_funct7_funct3(instruction_EX))
	     `REG_REG_FUNCT_ADD : alu_op_EX = `ALU_OP_ADD;
	     `REG_REG_FUNCT_SLT : alu_op_EX = `ALU_OP_SLT;
	     `REG_REG_FUNCT_SLTU : alu_op_EX = `ALU_OP_SLTU;
	     `REG_REG_FUNCT_AND : alu_op_EX = `ALU_OP_AND;
	     `REG_REG_FUNCT_OR : alu_op_EX = `ALU_OP_OR;
	     `REG_REG_FUNCT_XOR : alu_op_EX = `ALU_OP_XOR;
	     `REG_REG_FUNCT_SLL : alu_op_EX = `ALU_OP_SLL;
	     `REG_REG_FUNCT_SRL : alu_op_EX = `ALU_OP_SRL;
	     `REG_REG_FUNCT_SUB : alu_op_EX = `ALU_OP_SUB;
	     `REG_REG_FUNCT_SRA : alu_op_EX = `ALU_OP_SRA;
	     default : alu_op_EX = 4'bxxxx;
	   endcase // case (cat_funct7_funct3(instruction_EX))
	end // case: `OP
	

	`OP_JAL : begin
	   alu_src_1_sel_EX = `ALU_SRC_PC;
	   alu_src_2_sel_EX = `ALU_SRC_IMM;
	   next_PC_src_PIF  = `PC_SRC_JUMP;
	   d_cache_req_op = 2'bxx;
	   d_cache_req_op_type = 3'bxxx;
	   wb_data_src_EX = `WB_SRC_PC_PLUS_4;
	   imm_sel_EX = `IMM_J;
	   alu_op_EX = `ALU_OP_ADD;
	end
	
	`OP_JALR : begin
	   alu_src_1_sel_EX = `ALU_SRC_REG;
	   alu_src_2_sel_EX = `ALU_SRC_IMM;
	   next_PC_src_PIF  = `PC_SRC_JUMP;
	   d_cache_req_op = 2'bxx;
	   d_cache_req_op_type = 3'bxxx;
	   wb_data_src_EX = `WB_SRC_PC_PLUS_4;
	   imm_sel_EX = `IMM_I;
	   alu_op_EX = `ALU_OP_ADD;
	end

	`OP_BRANCH : begin
	   alu_src_1_sel_EX = `ALU_SRC_REG;
	   alu_src_2_sel_EX = `ALU_SRC_REG;
	   next_PC_src_PIF  = `PC_SRC_BRANCH;
	   d_cache_req_op = 2'bxx;
	   d_cache_req_op_type = 3'bxxx;
	   wb_data_src_EX = 2'bxx;
	   imm_sel_EX = `IMM_B;
	   case (funct3(instruction_EX))
	     `BRANCH_FUNCT3_BEQ : alu_op_EX = `ALU_OP_SEQ;
	     `BRANCH_FUNCT3_BNE : alu_op_EX = `ALU_OP_SNE;
	     `BRANCH_FUNCT3_BLT : alu_op_EX = `ALU_OP_SLT;
	     `BRANCH_FUNCT3_BLTU : alu_op_EX = `ALU_OP_SLTU;
	     `BRANCH_FUNCT3_BGE : alu_op_EX = `ALU_OP_SGE;
	     `BRANCH_FUNCT3_BGEU : alu_op_EX = `ALU_OP_SGEU;
	     default : alu_op_EX = 4'bxxxx;
	   endcase // case (funct3(instruction_EX))
	end // case: `BRANCH
	
	`OP_LOAD : begin
	   alu_src_1_sel_EX = `ALU_SRC_REG;
	   alu_src_2_sel_EX = `ALU_SRC_IMM;
	   next_PC_src_PIF  = `PC_SRC_PLUS_4;
	   d_cache_req_op = `MEM_LOAD;
	   d_cache_req_op_type = funct3(instruction_EX);
	   wb_data_src_EX = `WB_SRC_MEM;
	   imm_sel_EX = `IMM_I;
	   alu_op_EX = `ALU_OP_ADD;
	end
	`OP_STORE : begin
	   alu_src_1_sel_EX = `ALU_SRC_REG;
	   alu_src_2_sel_EX = `ALU_SRC_IMM;
	   next_PC_src_PIF  = `PC_SRC_PLUS_4;
	   d_cache_req_op = `MEM_STORE;
	   d_cache_req_op_type = funct3(instruction_EX);
	   wb_data_src_EX = 2'bxx;
	   imm_sel_EX = `IMM_S;
	   alu_op_EX = `ALU_OP_ADD;
	end

	`OP_MISC_MEM : begin
	   alu_src_1_sel_EX = 2'bxx;
	   alu_src_2_sel_EX = 2'bxx;
	   next_PC_src_PIF  = `PC_SRC_PLUS_4;
	   d_cache_req_op = `MEM_FENCE;
	   d_cache_req_op_type = 3'bxxx;
	   wb_data_src_EX = 2'bxx;
	   imm_sel_EX = 3'bxxx;	   
	   alu_op_EX = 4'bxxxx;
	end
	
	default : begin
	   alu_src_1_sel_EX = 2'bxx;
	   alu_src_2_sel_EX = 2'bxx;
	   next_PC_src_PIF = 1'bx;
	   d_cache_req_op = 2'bxx;
	   d_cache_req_op_type = 3'bxxx;
	   wb_data_src_EX = 2'bxx;
	   imm_sel_EX = 3'bxxx;
	   alu_op_EX = 4'bxxxx;
	end
      endcase // case (opcode(instruction_EX))
   end // always @ (*)

   wire is_load_EX;
   assign is_load_EX = opcode(instruction_EX) = `OP_LOAD;

   
   // Pipelined control signals
   always @(posedge clk) begin
      if (!stall_EX) begin
	 inherited_kill_EX <= kill_IF;
      end
      if (!stall_WB) begin
	 is_load_WB <= is_load_EX;
	 inherited_kill_WB <= kill_EX;
	 wr_reg_unkilled_WB <= wr_reg_unkilled_EX;
	 wb_data_src_WB <= wb_data_src_EX;
      end
   end
   
   
   // Hazard logic

   wire [4:0] rs1_EX;
   wire [4:0] rs2_EX;
   wire [4:0] rd_EX;
   reg [4:0]  rd_WB;
   wire       raw_alu_src_1;
   wire       raw_alu_src_2;
   wire       not_r0_WB;
   wire       load_use_ALU;
   wire       store_after_load;
   wire       branch_stall;
   
   assign rs1_EX = instruction_EX[19:15];
   assign rs2_EX = instruction_EX[24:20];
   assign rd_EX = instruction_EX[11:7];
   assign not_r0_WB = rd_WB != 0;

   // Forward result of ALU op to ALU ports
   assign raw_alu_src_1_EX = (alu_src_1_sel_EX == `ALU_SRC_REG)
     && (rs1_EX == rd_WB) && wr_reg_WB && not_r0_WB;
   assign raw_alu_src_2_EX = (alu_src_2_sel_EX == `ALU_SRC_REG)
     && (rs2_EX == rd_WB) && wr_reg_WB && not_r0_WB;
   assign fwd_alu_src_1_EX = raw_alu_src_1 && !is_load_WB;
   assign fwd_alu_src_2_EX = raw_alu_src_2 && !is_load_WB;

   // RAW dependencies on loads
   assign load_use_ALU = !kill_WB && is_load_WB && (raw_alu_src_1 || raw_alu_src_2);
   assign store_after_load = is_load_WB && (opcode(instruction_EX) == `OP_STORE)
     && (rs2_EX == rd_WB) && not_r0_WB;
   assign fwd_d_cache_data_EX = store_after_load && d_cache_resp_valid;

   // Branches that can't graduate while i_cache is busy
   assign branch_stall = branch_taken && !i_cache_req_ready;

   assign stall_WB = !d_cache_resp_valid;
   assign stall_EX = stall_WB || !d_cache_req_ready
		     || load_use_ALU || branch_stall;
   assign stall_IF = stall_EX;
   
   assign kill_WB = inherited_kill_WB || stall_WB;
   assign kill_EX = inherited_kill_EX || stall_EX;
   assign kill_IF = !d_cache_resp_valid;
      
   always @(posedge clk) begin
      if (!stall_WB) begin
	 rd_WB <= rd_EX;
	 is_load_WB <= (opcode(instruction_EX) == `OP_LOAD);
	 inherited_kill_WB <= kill_EX;
      end
      if (!stall_EX) begin
	 inherited_kill_EX <= kill_IF;
      end
   end
   
   
   
endmodule // ctrl_int

	
   