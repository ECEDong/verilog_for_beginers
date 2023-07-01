`include "defines.vh"

module input_prio_arbiter(
    input [`N-1:0] req;
	input [`N-1:0] base;
	output reg [ `N-1:0] grant
)			
	wire [2*`N-1:0] double_req 
	wire [2*`N-1:0] double_gnt;
	assign double_req = {req,req};
	assign double_gnt = double_req&~(double_req-base);
	assign grant = double_gnt[`N-1:0] | double_gnt[2*`N-1:`N];

endmodule