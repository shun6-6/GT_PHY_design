`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/29 19:25:14
// Design Name: 
// Module Name: LFSR_gen
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


module LFSR_gen#(
    parameter       P_LFSR_INIT = 16'hA076
)(
    input           i_clk       ,
    input           i_rst       ,

    output [31:0]   o_lfsr_data 
);
reg  [31:0] r_lfsr_data ;
reg  [15:0] r_lfsr      ;
wire [47:0] w_xor_run   ;

assign w_xor_run[47:32] = r_lfsr;
assign o_lfsr_data = r_lfsr_data;
genvar i;
generate
    for(i = 0 ; i < 32 ; i = i + 1)begin
        assign w_xor_run[31 - i] = w_xor_run[47 - i]^w_xor_run[46 - i]^w_xor_run[45 - i]^w_xor_run[32 - i];
    end
endgenerate

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_lfsr <= P_LFSR_INIT;
    else
        r_lfsr <= w_xor_run[15:0];
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_lfsr_data <= 'd0;
    else
        r_lfsr_data <= w_xor_run[31:0];  
end

endmodule
