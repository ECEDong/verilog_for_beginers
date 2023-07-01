
`include "defines.vh"
module weight_round_arb
(
input			clk,
input			reset_n,
input 	[`N-1:0]	req,
input	[`N-1:0]  WEIGHT,
output 	[`N-1:0]	grant
);

 
reg    	[`N-1:0] 	round_priority;
reg		[`N-1:0]	count		[`N-1:0];// two dimension
wire	[`N-1:0]	round_cell_en;
wire				round_en;
 
genvar i;
generate
	for(i=0;i<`N;i++)	begin: counter
		always @(posedge clk or negedge reset_n)	begin
			if(!reset_n)
				count[i] <= {`N{1'b0}};
			else if(|grant)	begin
				if(grant[i])
					count[i] <= count[i] + 1'b1;
				else
					count[i] <= {`N{1'b0}};
			end
		end	
	end
 
	assign round_cell_en[i] = (count[i] ==WEIGHT[i]) | ((count[i]!=0) & (~req[i]));
endgenerate
 
assign round_en = (| round_cell_en[`N-1:0] ) & (| req);
 
always @(posedge clk or negedge reset_n)
begin
  if(!reset_n)
    round_priority <= {`N{1'b0}};
  else if(round_en)
    round_priority <= {grant[`N-2:0],grant[`N-1]};
end
wire	[`N*2-1:0]	double_req = {req,req};
wire	[`N*2-1:0]	req_sub_round_priority = double_req - round_priority;
wire	[`N*2-1:0]	double_grant = double_req & (~req_sub_round_priority);
 
assign	grant = double_grant[`N-1:0] | double_grant[`N*2-1:`N];
 
endmodule

sel_prio
case (sel)
0: 1
1: base
2: priority
3: round_priority

double_grant = double_req &~ (double_req - sel_prio) ;

cnt_en = |gnt & sel==3