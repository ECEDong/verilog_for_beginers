`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: weirong dong
// 
// Create Date: 2023/06/25 11:09:35
// Design Name: 
// Module Name: round_robin_arbiter

// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.vh"
//`define N 8
module round_robin_arbiter(
    input           clk,
    input           rstn,
    input   [`N-1:0] req,
    output  [`N-1:0] grant // priority is 0010 =>  1230, 3 enjoy the most priority
    );
    reg [`N-1:0] pre_grant;//previous grant
    wire [`N-1:0] priority;
    wire [2*`N-1:0] double_req;
    wire [2*`N-1:0] double_grant;
    assign  double_req = {req[`N-1:0],req[`N-1:0]};
    always@(posedge clk, negedge rstn)begin//asynchronous reset
        if(!rstn)begin
            pre_grant<={1'b1,{`N-1{1'b0}}};
        end
        else if(|req)begin
            pre_grant<=grant;
        end
    end
    assign priority={pre_grant[`N-2:0],pre_grant[`N-1]};
    assign double_grant=double_req&~(double_req-priority);
    assign grant=(double_grant[`N-1:0]|double_grant[2*`N-1:`N]);
    

endmodule
