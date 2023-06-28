`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: weirong dong
// asy fifo
// Create Date: 2023/06/28 19:41:12
// Design Name: 
// Module Name: ays_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
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
module asy_fifo(
    wr_clk,
    rd_clk,
    wr_rstn,
    rd_rstn,
    wr_en,
    rd_en,
    wr_data,
    rd_data,
    fifo_empty,
    fifo_full
    );
    input wr_clk,rd_clk,wr_rstn,rd_rstn,wr_en,rd_en;
    input [`width-1:0] wr_data;
    output reg [`width-1:0] rd_data;
    output reg fifo_empty,fifo_full;

    //Define a FIFO, width/depth
    reg [`width-1:0] fifo [`depth-1:0];//depth-1

    // binary pointer
    reg [`addr:0] wr_pt;
    reg [`addr:0] rd_pt;

    // gray code pointer
    wire [`addr:0] wr_ptg;
    wire [`addr:0] rd_ptg;
    // Before synchronizer, use one more ff (its own clk) to avoid setup time violation
    reg [`addr:0] wr_ptgd;
    reg [`addr:0] rd_ptgd;
    // synchronizer: 2 flip flop
    reg [`addr:0] wr_ptgr;//after one ff
    reg [`addr:0] rd_ptgr;
    reg [`addr:0] wr_ptgrr;//after two ff
    reg [`addr:0] rd_ptgrr;

    //binary to gray: the MSB remains the same, the other bits move to gray
    assign wr_ptg=wr_pt[`addr:0]^(wr_pt[`addr:0]>>1);                   //why >>> but not >>?
    assign rd_ptg=rd_pt[`addr:0]^(rd_pt[`addr:0]>>1);

    // Before synchronizer, use one more ff (its own clk) to avoid setup time violation
    always@(posedge wr_clk, negedge wr_rstn)begin
        if(!wr_rstn)begin
            wr_ptgd<=0; 
        end
        else begin
            wr_ptgd<=wr_ptg;  // one ff
        end
    end 

    always@(posedge rd_clk, negedge rd_rstn)begin
        if(!rd_rstn)begin
            rd_ptgd<=0; 
        end
        else begin
            rd_ptgd<=rd_ptg;  // one ff
        end
    end

    //sychronize by two flip flop
    always@(posedge wr_clk, negedge wr_rstn)begin
        if(!wr_rstn)begin
            wr_ptgr<=0; wr_ptgrr<=0;
        end
        else begin
            wr_ptgr<=wr_ptgd;  // one ff
            wr_ptgrr<=wr_ptgr;// two ff
        end
    end
    
    always@(posedge rd_clk, negedge rd_rstn)begin
        if(!rd_rstn)begin
            rd_ptgr<=0; rd_ptgrr<=0;
        end
        else begin
            rd_ptgr<=rd_ptgd;  // one ff
            rd_ptgrr<=rd_ptgr;// two ff
        end
    end

    //determine full or empty
    always@(*)begin
        if(!wr_rstn)begin
            fifo_full=0;
        end
        else if(wr_ptg[`addr:`addr-1]!=rd_ptgrr[`addr:`addr-1]&&wr_ptg[`addr-2:0]==rd_ptgrr[`addr-2:0]) begin
            fifo_full=1;
        end
        else begin
            fifo_full=0;
        end
    end

    always@(*)begin
        if(!rd_rstn)begin
            fifo_empty=0;
        end
        else if(rd_ptg==wr_ptgrr) begin
            fifo_empty=1;
        end
        else begin
            fifo_empty=0;
        end
    end

    //write data
    always@(posedge wr_clk, negedge wr_rstn)begin
        if(!wr_rstn) begin
            wr_pt<=0;
        end
        else if(!fifo_full&&wr_en)begin
            fifo[wr_pt[`addr-1:0]]<=wr_data;
            wr_pt<=wr_pt+1;
        end
        else begin
            wr_pt<=wr_pt;
        end
    end

    //read data
    always@(posedge rd_clk, negedge rd_rstn)begin
        if(!rd_rstn) begin
            rd_pt<=0;
        end
        else if(!fifo_empty&&rd_en)begin
            rd_data<=fifo[rd_pt[`addr-1:0]];
            rd_pt<=rd_pt+1;
        end
        else begin
            rd_pt<=rd_pt;
        end
    end
endmodule
