`define AXI_LITE_BUS_WIDTH 32
`define AXI_LITE_ADDR_WIDTH 5

module riscv_soft_axi_lite_slave (
				  input wire S_AXI_ACLK,
				  input wire S_AXI_ARESETN,
				  input  wire [`AXI_LITE_ADDR_WIDTH - 1:0] S_AXI_AWADDR,
				  input  wire                          S_AXI_AWVALID,
				  output wire                          S_AXI_AWREADY,
				  input  wire [`AXI_LITE_BUS_WIDTH-1:0] S_AXI_WDATA,
				  input  wire [`AXI_LITE_BUS_WIDTH/8-1:0] S_AXI_WSTRB,
				  input  wire                          S_AXI_WVALID,
				  output wire                          S_AXI_WREADY,
				  output wire [1:0]                    S_AXI_BRESP,
				  output wire                          S_AXI_BVALID,
				  input  wire                          S_AXI_BREADY,
				  input  wire [`AXI_LITE_ADDR_WIDTH - 1:0] S_AXI_ARADDR,
				  input  wire                          S_AXI_ARVALID,
				  output wire                          S_AXI_ARREADY,
				  output wire [`AXI_LITE_BUS_WIDTH-1:0] S_AXI_RDATA,
				  output wire [1:0]                    S_AXI_RRESP,
				  output wire                          S_AXI_RVALID,
				  input  wire                          S_AXI_RREADY
				  );
   
   
endmodule
