`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/20 14:55:15
// Design Name: 
// Module Name: AXI_S_Gen_Data
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


module AXI_S_Gen_Data#(
    parameter           P_KEEP = 4'b1111 
)(
    input               i_clk           ,
    input               i_rst           ,

    output [31:0]       o_axi_s_data    ,
    output [3 :0]       o_axi_s_keep    ,
    output              o_axi_s_last    ,
    output              o_axi_s_valid   ,
    input               i_axi_s_ready   
);

reg  [31:0]             ro_axi_s_data   ;
reg  [3 :0]             ro_axi_s_keep   ;
reg                     ro_axi_s_last   ;
reg                     ro_axi_s_valid  ;
reg  [15:0]             r_cnt           ;

assign o_axi_s_data  = ro_axi_s_data    ;
assign o_axi_s_keep  = ro_axi_s_keep    ;
assign o_axi_s_last  = ro_axi_s_last    ;
assign o_axi_s_valid = ro_axi_s_valid   ;

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(r_cnt == 1000)
        r_cnt <= 'd0;
    else 
        r_cnt <= r_cnt + 1;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_axi_s_data <= 'd0;
    else 
        ro_axi_s_data <= r_cnt - 100;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_axi_s_keep <= 'd0;
    else if(r_cnt == 200 - 1)
        ro_axi_s_keep <= P_KEEP;
    else 
        ro_axi_s_keep <= 4'b1111;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_axi_s_last <= 'd0;
    else if(r_cnt == 200 - 1)
        ro_axi_s_last <= 'd1;
    else 
        ro_axi_s_last <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_axi_s_valid <= 'd0;
    else if(ro_axi_s_last)
        ro_axi_s_valid <= 'd0;
    else if(r_cnt == 99)
        ro_axi_s_valid <= 'd1;
    else 
        ro_axi_s_valid <= ro_axi_s_valid;
end

endmodule
