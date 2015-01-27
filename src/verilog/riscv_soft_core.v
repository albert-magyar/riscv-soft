`include "riscv_soft_constants.v"
`include "riscv_soft_ctrl.v"
`include "riscv_soft_alu.v"
`include "riscv_soft_alu_src_mux.v"
`include "riscv_soft_imm_logic.v"
`include "riscv_soft_regfile.v"

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
   
   input		       clk;
   input		       reset;
   input		       i_cache_req_ready;
   output		       i_cache_req_valid;
   output [XPR_LEN-1:0]        i_cache_req_addr;
   input 		       i_cache_resp_valid;
   input [XPR_LEN-1:0] 	       i_cache_resp_data;
   input 		       d_cache_req_ready;
   output		       d_cache_req_valid;
   output [1:0] 	       d_cache_req_op;
   output [2:0] 	       d_cache_req_op_type;
   output [XPR_LEN-1:0]        d_cache_req_addr;
   output [XPR_LEN-1:0]        d_cache_req_data;
   input 		       d_cache_resp_valid;
   input [XPR_LEN-1:0] 	       d_cache_resp_data;

   
   /*********************
    HAZARD/BYPASS SIGNALS
    *********************/

   // Stalls
   wire stall_IF;
   wire stall_EX;
   wire stall_WB;

   // Forwarding signals
   wire fwd_alu_src_1_EX;
   wire fwd_alu_src_2_EX;
   wire fwd_d_cache_data_EX;
   

   /*****************************
    PRE-INSTRUCTION FETCH SIGNALS
    *****************************/
   wire [1:0] next_PC_src_PIF;
   wire       i_cache_req_ready;
   wire       i_cache_req_valid;
   wire [XPR_LEN-1:0] i_cache_req_addr;
   wire 	      i_cache_resp_valid;
   wire [XPR_LEN-1:0] i_cache_resp_data;
   
   
   
   /***********************
    INSTRUCTION FETCH STAGE
    ***********************/
   
   // Pipeline registers
   reg [XPR_LEN-1:0]  PC_IF;
   wire [XPR_LEN-1:0] PC_plus_4_IF;
   
   
   /*************
    EXECUTE STAGE
    *************/

   // Pipeline registers
   reg [XPR_LEN-1:0] PC_EX;
   reg [XPR_LEN-1:0] PC_plus_4_EX;
   reg [31:0] 	     instruction_EX;
   
   // Register fetch signals
   wire [4:0] 	     rs1_EX;
   wire [XPR_LEN-1:0] rs1_data_EX;
   wire [4:0] 	      rs2_EX;
   wire [XPR_LEN-1:0] rs2_data_EX;
   
   // Immediate format selection
   wire [2:0] 	      imm_sel_EX;
   wire [XPR_LEN-1:0] imm_EX;
   
   // ALU operation signals
   wire [1:0] 	      alu_src_1_sel_EX;
   wire [1:0] 	      alu_src_2_sel_EX;
   wire [XPR_LEN-1:0] alu_src_1_EX;
   wire [XPR_LEN-1:0] alu_src_2_EX;
   wire [3:0] 	      alu_op_EX;
   wire [XPR_LEN-1:0] alu_result_EX;
   wire 	      cmp_true_EX;
   
   // Memory operation setup
   wire 	      d_cache_req_ready;
   wire 	      d_cache_req_valid;
   wire [1:0] 	      d_cache_req_op;
   wire [2:0] 	      d_cache_req_op_type;
   wire [XPR_LEN-1:0] d_cache_req_addr;
   wire [XPR_LEN-1:0] d_cache_req_data;

   // PC calculation
   wire [XPR_LEN-1:0] branch_PC_EX;
   wire [XPR_LEN-1:0] jump_PC_EX;
   
   
   /***************
    WRITEBACK STAGE
    ***************/
   
   // Pipeline registers
   reg [XPR_LEN-1:0]  PC_WB;
   reg [XPR_LEN-1:0]  PC_plus_4_WB;
   reg [XPR_LEN-1:0]  alu_result_WB;
   reg [4:0] 	      reg_dest_WB;
   
   // Data cache response
   wire 	      d_cache_resp_valid;
   wire [XPR_LEN-1:0] d_cache_resp_data;
   
   // Writeback
   wire 	      wr_reg_WB;
   wire [1:0] 	      wb_data_src_WB;
   wire [XPR_LEN-1:0] wb_data_WB;
   
   
   riscv_soft_ctrl ctrl(
			.clk(clk),
			.reset(reset),
			.stall_IF(stall_IF),
			.stall_EX(stall_EX),
			.stall_WB(stall_WB),
			.fwd_alu_src_1_EX(fwd_alu_src_1_EX),
			.fwd_alu_src_2_EX(fwd_alu_src_2_EX),
			.fwd_d_cache_data_EX(fwd_d_cache_data_EX),
			.next_PC_src_PIF(next_PC_src_PIF),
			.i_cache_req_ready(i_cache_req_ready),
			.i_cache_req_valid(i_cache_req_valid),
			.i_cache_resp_valid(i_cache_resp_valid),
			.instruction_EX(instruction_EX),
			.imm_sel_EX(imm_sel_EX),
			.alu_src_1_sel_EX(alu_src_1_sel_EX),
			.alu_src_2_sel_EX(alu_src_2_sel_EX),
			.alu_op_EX(alu_op_EX),
			.d_cache_req_ready(d_cache_req_ready),
			.d_cache_req_valid(d_cache_req_valid),
			.d_cache_req_op(d_cache_req_op),
			.d_cache_req_op_type(d_cache_req_op_type),
			.d_cache_resp_valid(d_cache_resp_valid),
			.wb_data_src_WB(wb_data_src_WB),
			.wr_reg_WB(wr_reg_WB)
			);
			
   
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
			      );

   riscv_soft_imm_logic imm_sel(
				.inst(instruction_EX),
				.imm_sel(imm_sel_EX),
				.imm(imm_EX)
				);
   

   riscv_soft_alu_src_mux src1_mux(
				   .sel(alu_src_1_sel_EX),
				   .imm(imm_EX),
				   .PC(PC_EX),
				   .reg_data(rs1_data_EX),
				   .fwd(fwd_alu_src_1_EX),
				   .bypass_data(alu_result_WB),
				   .output_data(alu_src_1_EX)
				   );
   
   riscv_soft_alu_src_mux src2_mux(
				   .sel(alu_src_2_sel_EX),
				   .imm(imm_EX),
				   .PC(PC_EX),
				   .reg_data(rs2_data_EX),
				   .fwd(fwd_alu_src_2_EX),
				   .bypass_data(alu_result_WB),
				   .output_data(alu_src_2_EX)
				   );
   
   
   riscv_soft_alu alu(
		      .operation(alu_op_EX),
		      .operand_1(alu_src_1_EX),
		      .operand_2(alu_src_2_EX),
		      .result(alu_result_EX),
		      .cmp_true(cmp_true_EX)
		      );
   
   
   
endmodule // riscv_soft_core
