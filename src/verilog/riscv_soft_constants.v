`define ALU_OP_ADD 4'h0
`define ALU_OP_SLT 4'h1
`define ALU_OP_SLTU 4'h2
`define ALU_OP_SEQ 4'h3
`define ALU_OP_SNE 4'h4
`define ALU_OP_SGE 4'h5
`define ALU_OP_SGEU 4'h6
`define ALU_OP_AND 4'h7
`define ALU_OP_OR 4'h8
`define ALU_OP_XOR 4'h9
`define ALU_OP_SLL 4'hA
`define ALU_OP_SRL 4'hB
`define ALU_OP_SUB 4'hC
`define ALU_OP_SRA 4'hD

`define OP_LUI 7'b0110111
`define OP_AUIPC 7'b0010111
`define OP_JAL 7'b1101111
`define OP_JALR 7'b1100111
`define OP_BRANCH 7'b1100011
`define OP_LOAD 7'b0000011
`define OP_STORE 7'b0100011
`define OP_IMM 7'b0010011
`define OP_OP 7'b0110011
`define OP_MISC_MEM 7'b0001111
`define OP_SYSTEM 7'b1110011


`define ALU_SRC_REG 2'h0
`define ALU_SRC_IMM 2'h1
`define ALU_SRC_ZERO 2'h2
`define ALU_SRC_PC 2'h3


`define PC_SRC_PLUS_4 2'h0
`define PC_SRC_BRANCH 2'h1
`define PC_SRC_JUMP 2'h2


`define IMM_I 3'h0
`define IMM_S 3'h1
`define IMM_B 3'h2
`define IMM_U 3'h3
`define IMM_J 3'h4


`define BRANCH_FUNCT3_BEQ 3'h0
`define BRANCH_FUNCT3_BNE 3'h1
`define BRANCH_FUNCT3_BLT 3'h4
`define BRANCH_FUNCT3_BGE 3'h5
`define BRANCH_FUNCT3_BLTU 3'h6
`define BRANCH_FUNCT3_BGEU 3'h7


`define REG_IMM_FUNCT3_ADDI 3'h0
`define REG_IMM_FUNCT3_SLLI 3'h1
`define REG_IMM_FUNCT3_SLTI 3'h2
`define REG_IMM_FUNCT3_SLTIU 3'h3
`define REG_IMM_FUNCT3_XORI 3'h4
`define REG_IMM_FUNCT3_SRLI_SRAI 3'h5
`define REG_IMM_FUNCT3_ORI 3'h6
`define REG_IMM_FUNCT3_ANDI 3'h7


`define FUNCT7_SRLI 7'h0
`define FUNCT7_SRAI 7'h20


`define REG_REG_FUNCT_ADD 10'h0
`define REG_REG_FUNCT_SLL 10'h1
`define REG_REG_FUNCT_SLT 10'h2
`define REG_REG_FUNCT_SLTU 10'h3
`define REG_REG_FUNCT_XOR 10'h4
`define REG_REG_FUNCT_SRL 3'h5
`define REG_REG_FUNCT_OR 3'h6
`define REG_REG_FUNCT_AND 3'h7
`define REG_REG_FUNCT_SUB 10'h100
`define REG_REG_FUNCT_SRA 10'h105


`define WB_SRC_ALU 2'h0
`define WB_SRC_MEM 2'h1
`define WB_SRC_PC_PLUS_4 2'h2


`define MEM_LOAD 2'h0
`define MEM_STORE 2'h1
`define MEM_FENCE 2'h2


`define MEM_TYPE_BYTE 3'h0
`define MEM_TYPE_HALF 3'h1
`define MEM_TYPE_WORD 3'h2
`define MEM_TYPE_BYTEU 3'h4
`define MEM_TYPE_HALFU 3'h5


`define AXI_LITE_BUS_WIDTH 32
`define AXI_LITE_ADDR_WIDTH 5