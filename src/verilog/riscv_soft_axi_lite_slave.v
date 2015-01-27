`include "riscv_soft_constants.v"
`include "riscv_soft_tile.v"

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

    parameter XPR_LEN = 32;

   localparam S_IDLE = 3'd0,
     S_WRITE_GET_DATA = 3'd1,
     S_WRITE_SETUP = 3'd2,
     S_WRITE_RESP = 3'd3,
     S_READ_SETUP = 3'd4,
     S_READ_RESP = 3'd5,
     S_WRITE_INIT = 3'd6,
     S_ERROR = 3'd7;
   
   wire 		   host_req_ready;
   wire 		   host_req_valid;
   wire [1:0] 		   host_req_op;
   wire [2:0] 		   host_req_op_type;
   wire [XPR_LEN-1:0] 	   host_req_addr;
   wire [XPR_LEN-1:0] 	   host_req_data;
   wire 		   host_resp_valid;
   wire [XPR_LEN-1:0] 	   host_resp_data;   

   wire 		   reset;

   reg [1:0] 		   current_state;
   reg [1:0] 		   next_state;

   reg [XPR_LEN-1:0] 	   stored_addr;
   reg [XPR_LEN-1:0] 	   stored_wdata;
   
   assign S_AXI_AWREADY = host_req_ready && (current_state == S_IDLE);
   assign S_AXI_WREADY = host_req_ready && (current_state == S_WRITE_GET_DATA);
   assign S_AXI_BRESP = 0;
   assign S_AXI_BVALID = host_resp_valid && (current_state == S_WRITE_RESP);

   assign S_AXI_ARREADY = host_req_ready && (current_state == S_IDLE);
   assign S_AXI_RDATA = host_resp_data;
   assign S_AXI_RRESP = 0;
   assign S_AXI_RVALID = host_resp_valid && (current_state == S_READ_RESP);

   assign host_req_valid = (current_state == S_WRITE_SETUP)
     || (current_state == S_READ_SETUP);
   
   assign host_req_op = (current_state == S_WRITE_SETUP) ? `MEM_STORE : `MEM_LOAD;
   assign host_req_op_type = `MEM_TYPE_WORD;
   assign host_req_addr = stored_addr ^ 2'b11;
   assign host_req_data = stored_wdata;

   assign reset = ~S_AXI_ARESETN;
   
   riscv_soft_tile tile(
			.clk(S_AXI_ACLK),
			.reset(reset),
			.host_req_ready(host_req_ready),
			.host_req_valid(host_req_valid),
			.host_req_op(host_req_op),
			.host_req_op_type(host_req_op_type),
			.host_req_addr(host_req_addr),
			.host_req_data(host_req_data),
			.host_resp_valid(host_resp_valid),
			.host_resp_data(host_resp_data)
			);


   always @(posedge S_AXI_ACLK) begin
      if (reset) current_state <= S_IDLE;
      else current_state <= next_state;
   end

   always @(posedge S_AXI_ACLK) begin
      if (current_state == S_IDLE) stored_addr <= (S_AXI_AWVALID) ? 
						  S_AXI_AWADDR : S_AXI_ARADDR;
   end

   always @(posedge S_AXI_ACLK) begin
      if (current_state == S_WRITE_GET_DATA) stored_wdata <= S_AXI_WDATA;
   end

   always @(*) begin
      next_state = current_state;
      case (current_state)
	S_IDLE : begin
	   if (S_AXI_AWVALID) next_state = S_WRITE_GET_DATA;
	   if (S_AXI_ARVALID) next_state = S_READ_SETUP;
	end
	S_WRITE_GET_DATA : begin
	   if (S_AXI_WVALID) next_state = S_WRITE_SETUP;
	end
	S_WRITE_SETUP : begin
	   if (host_req_ready) next_state = S_WRITE_RESP;
	end
	S_WRITE_RESP : begin
	   if (S_AXI_BREADY) next_state = S_IDLE;
	end
	S_READ_SETUP : begin
	   if (host_req_ready) next_state = S_READ_RESP;
	end
	S_READ_RESP : begin
	   if (S_AXI_RREADY) next_state = S_IDLE;
	end
	S_ERROR : begin
	end
	default : begin
	   next_state = S_ERROR;
	end
	endcase // case (current_state)
   end // always @ (*)
   
   
   
endmodule
