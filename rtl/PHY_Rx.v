`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/26 16:55:55
// Design Name: 
// Module Name: PHY_Rx
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


module PHY_Rx(
    input               i_clk           ,
    input               i_rst           ,

    output [31:0]       o_rx_axis_data  ,
    output [3 :0]       o_rx_axis_keep  ,    
    output              o_rx_axis_valid ,
    output              o_rx_axis_last  ,
    input               i_rx_axis_ready ,

    input               i_rx_ByteAlign  ,
    input  [31:0]       i_gt_rx_data    ,
    input  [3 :0]       i_gt_rx_char    
);
/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [31:0]     ro_rx_axis_data    ;
reg  [3 :0]     ro_rx_axis_keep    ;
reg             ro_rx_axis_valid   ;
reg             ro_rx_axis_last    ;

reg  [1 :0]     ri_rx_ByteAlign ;
(* MARK_DEBUG = "TRUE"*)reg  [31:0]     ri_gt_rx_data   ;
(* MARK_DEBUG = "TRUE"*)reg  [3 :0]     ri_gt_rx_char   ;
reg  [31:0]     ri_gt_rx_data_1d;
reg  [3 :0]     ri_gt_rx_char_1d;
reg  [31:0]     ri_gt_rx_data_2d;
reg  [3 :0]     ri_gt_rx_char_2d;
reg             r_run           ;


(* MARK_DEBUG = "TRUE"*)reg             r_comma_access  ;
reg             r_sof           ;
reg             r_eof           ;
reg             r_eof_1f        ;
reg             r_eof_2f        ;
reg  [3 :0]     r_sof_local     ;
reg  [3 :0]     r_eof_local     ;
/***************wire******************/
wire [31:0]     w_gt_rx_data    ;
wire [3 :0]     w_gt_rx_char    ;

/***************component*************/

/***************assign****************/
assign o_rx_axis_data  = ro_rx_axis_data  ;
assign o_rx_axis_keep  = ro_rx_axis_keep;
assign o_rx_axis_valid = ro_rx_axis_valid ;
assign o_rx_axis_last  = ro_rx_axis_last  ;
assign w_gt_rx_data = {i_gt_rx_data[7:0],i_gt_rx_data[15:8],i_gt_rx_data[23:16],i_gt_rx_data[31:24]};
assign w_gt_rx_char = {i_gt_rx_char[0],i_gt_rx_char[1],i_gt_rx_char[2],i_gt_rx_char[3]};
/***************always****************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ri_rx_ByteAlign <= 'd0;
    else
        ri_rx_ByteAlign <= {ri_rx_ByteAlign[0],i_rx_ByteAlign};
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_gt_rx_data <= 'd0;
        ri_gt_rx_char <= 'd0;  
        ri_gt_rx_data_1d <= 'd0;
        ri_gt_rx_char_1d <= 'd0;    
        ri_gt_rx_data_2d <= 'd0;
        ri_gt_rx_char_2d <= 'd0;          
    end
    else begin
        ri_gt_rx_data <= w_gt_rx_data;
        ri_gt_rx_char <= w_gt_rx_char;       
        ri_gt_rx_data_1d <= ri_gt_rx_data;
        ri_gt_rx_char_1d <= ri_gt_rx_char; 
        ri_gt_rx_data_2d <= ri_gt_rx_data_1d;
        ri_gt_rx_char_2d <= ri_gt_rx_char_1d; 
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_comma_access <= 'd0;
    else if((ri_gt_rx_data[15:0] == 16'hbc50) && (ri_gt_rx_char[1:0] == 2'b10) && (w_gt_rx_data[31:24] == 8'hfb) && (w_gt_rx_char[3] == 1'b1))
        r_comma_access <= 'd1;
    else if((ri_gt_rx_data[23:0] == 24'hbc50fb) && (ri_gt_rx_char[2:0] == 3'b101))
        r_comma_access <= 'd1;
    else if((ri_gt_rx_data[31:8] == 24'hbc50fb) && (ri_gt_rx_char[3:0] == 4'b1010))
        r_comma_access <= 'd1;
    else if((ri_gt_rx_data_1d[7:0] == 8'hbc) && (ri_gt_rx_char_1d[0] == 1'b1) && (ri_gt_rx_data[31:16] == 16'h50fb) && (ri_gt_rx_char[3:2] == 2'b01))
        r_comma_access <= 'd1;
    else
        r_comma_access <= r_comma_access;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_sof <= 'd0;
    else if(r_comma_access && (ri_gt_rx_data_1d[31:24] == 8'hfb) && (ri_gt_rx_char_1d[3] == 1'b1))
        r_sof <= 'd1;
    else if(r_comma_access && (ri_gt_rx_data_1d[23:16] == 8'hfb) && (ri_gt_rx_char_1d[2] == 1'b1))
        r_sof <= 'd1;
    else if(r_comma_access && (ri_gt_rx_data_1d[15:8] == 8'hfb) && (ri_gt_rx_char_1d[1] == 1'b1))
        r_sof <= 'd1;
    else if(r_comma_access && (ri_gt_rx_data_1d[7:0] == 8'hfb) && (ri_gt_rx_char_1d[0] == 1'b1))
        r_sof <= 'd1;
    else
        r_sof <= 'd0;
end
//1表示最高字节位置(从左到右)
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_sof_local <= 'd0;
    else if(r_comma_access && (ri_gt_rx_data_1d[31:24] == 8'hfb) && (ri_gt_rx_char_1d[3] == 1'b1))
        r_sof_local <= 'd1;
    else if(r_comma_access && (ri_gt_rx_data_1d[23:16] == 8'hfb) && (ri_gt_rx_char_1d[2] == 1'b1))
        r_sof_local <= 'd2;
    else if(r_comma_access && (ri_gt_rx_data_1d[15:8] == 8'hfb) && (ri_gt_rx_char_1d[1] == 1'b1))
        r_sof_local <= 'd3;
    else if(r_comma_access && (ri_gt_rx_data_1d[7:0] == 8'hfb) && (ri_gt_rx_char_1d[0] == 1'b1))
        r_sof_local <= 'd4;
    else
        r_sof_local <= r_sof_local;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_eof <= 'd0;
    else if(r_comma_access && (ri_gt_rx_data_1d[31:24] == 8'hfd) && (ri_gt_rx_char_1d[3] == 1'b1))
        r_eof <= 'd1;
    else if(r_comma_access && (ri_gt_rx_data_1d[23:16] == 8'hfd) && (ri_gt_rx_char_1d[2] == 1'b1))
        r_eof <= 'd1;
    else if(r_comma_access && (ri_gt_rx_data_1d[15:8] == 8'hfd) && (ri_gt_rx_char_1d[1] == 1'b1))
        r_eof <= 'd1;
    else if(r_comma_access && (ri_gt_rx_data_1d[7:0] == 8'hfd) && (ri_gt_rx_char_1d[0] == 1'b1))
        r_eof <= 'd1;
    else
        r_eof <= 'd0;
end
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_eof_1f <= 'd0;
    else if(r_comma_access && (ri_gt_rx_data[31:24] == 8'hfd) && (ri_gt_rx_char[3] == 1'b1))
        r_eof_1f <= 'd1;
    else if(r_comma_access && (ri_gt_rx_data[23:16] == 8'hfd) && (ri_gt_rx_char[2] == 1'b1))
        r_eof_1f <= 'd1;
    else if(r_comma_access && (ri_gt_rx_data[15:8] == 8'hfd) && (ri_gt_rx_char[1] == 1'b1))
        r_eof_1f <= 'd1;
    else if(r_comma_access && (ri_gt_rx_data[7:0] == 8'hfd) && (ri_gt_rx_char[0] == 1'b1))
        r_eof_1f <= 'd1;
    else
        r_eof_1f <= 'd0;
end
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_eof_2f <= 'd0;
    else if(r_comma_access && (w_gt_rx_data[31:24] == 8'hfd) && (w_gt_rx_char[3] == 1'b1))
        r_eof_2f <= 'd1;
    else if(r_comma_access && (w_gt_rx_data[23:16] == 8'hfd) && (w_gt_rx_char[2] == 1'b1))
        r_eof_2f <= 'd1;
    else if(r_comma_access && (w_gt_rx_data[15:8] == 8'hfd) && (w_gt_rx_char[1] == 1'b1))
        r_eof_2f <= 'd1;
    else if(r_comma_access && (w_gt_rx_data[7:0] == 8'hfd) && (w_gt_rx_char[0] == 1'b1))
        r_eof_2f <= 'd1;
    else
        r_eof_2f <= 'd0;
end
//1表示最高字节位置(从左到右)
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_eof_local <= 'd0;
    else if(r_comma_access && (w_gt_rx_data[31:24] == 8'hfd) && (w_gt_rx_char[3] == 1'b1))
        r_eof_local <= 'd1;
    else if(r_comma_access && (w_gt_rx_data[23:16] == 8'hfd) && (w_gt_rx_char[2] == 1'b1))
        r_eof_local <= 'd2;
    else if(r_comma_access && (w_gt_rx_data[15:8] == 8'hfd) && (w_gt_rx_char[1] == 1'b1))
        r_eof_local <= 'd3;
    else if(r_comma_access && (w_gt_rx_data[7:0] == 8'hfd) && (w_gt_rx_char[0] == 1'b1))
        r_eof_local <= 'd4;
    else
        r_eof_local <= r_eof_local;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_run <= 'd0;
    else if(r_eof)
        r_run <= 'd0;
    else if(r_sof)
        r_run <= 'd1;
    else
        r_run <= r_run;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_rx_axis_data <= 'd0;
    else if((r_sof || r_run) && r_sof_local == 'd1)
        ro_rx_axis_data <= {ri_gt_rx_data_2d[23:0],ri_gt_rx_data_1d[31:24]};
    else if((r_sof || r_run) && r_sof_local == 'd2)
        ro_rx_axis_data <= {ri_gt_rx_data_2d[15:0],ri_gt_rx_data_1d[31:16]};
    else if((r_sof || r_run) && r_sof_local == 'd3)
        ro_rx_axis_data <= {ri_gt_rx_data_2d[7:0],ri_gt_rx_data_1d[31:8]};
    else if((r_sof || r_run) && r_sof_local == 'd4)
        ro_rx_axis_data <= ri_gt_rx_data_1d;
    else
        ro_rx_axis_data <= ro_rx_axis_data;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_rx_axis_keep <= 'd0;
    else if(ro_rx_axis_last)
        ro_rx_axis_keep <= 'd0;
    else if(r_eof_1f && (r_sof_local >= (r_eof_local - 1)))
        ro_rx_axis_keep <= (4'hf << (r_sof_local + 1 - r_eof_local));
    else if(r_eof && (r_sof_local < (r_eof_local - 1)))
        ro_rx_axis_keep <= (8'hff << (4-(r_eof_local - 1 - r_sof_local)));
    else if(r_sof || r_run)
        ro_rx_axis_keep <= 8'hff;
    else
        ro_rx_axis_keep <= 'd0;
end
 
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_rx_axis_valid <= 'd0;
    else if(ro_rx_axis_last)
        ro_rx_axis_valid <= 'd0;
    else if(r_sof)
        ro_rx_axis_valid <= 'd1;
    else
        ro_rx_axis_valid <= ro_rx_axis_valid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_rx_axis_last <= 'd0;
    else if(ro_rx_axis_last)
        ro_rx_axis_last <= 'd0;
    else if(r_eof_2f && (r_sof_local == 4 && r_eof_local == 1))
        ro_rx_axis_last <= 'd1;
    else if(r_eof_1f && (r_sof_local >= (r_eof_local - 1)))
        ro_rx_axis_last <= 'd1;
    else if(r_eof)
        ro_rx_axis_last <= 'd1;
    else
        ro_rx_axis_last <= 'd0;
end
endmodule
