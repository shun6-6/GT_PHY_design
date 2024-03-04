`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/26 16:55:55
// Design Name: 
// Module Name: PHY_module
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


module PHY_module(
    input               i_tx_clk        ,
    input               i_tx_rst        ,
    input               i_rx_clk        ,
    input               i_rx_rst        ,

    input  [31:0]       i_tx_axis_data  ,
    input  [3 :0]       i_tx_axis_keep  ,    
    input               i_tx_axis_valid ,
    input               i_tx_axis_last  ,
    output              o_tx_axis_ready ,
    output [31:0]       o_rx_axis_data  ,
    output [3 :0]       o_rx_axis_keep  ,    
    output              o_rx_axis_valid ,
    output              o_rx_axis_last  ,
    input               i_rx_axis_ready ,

    input               i_gt_tx_done    ,
    output [31:0]       o_gt_tx_data    ,
    output [3 :0]       o_gt_tx_char    ,
    input               i_rx_ByteAlign  ,
    input  [31:0]       i_gt_rx_data    ,
    input  [3 :0]       i_gt_rx_char    
);

PHY_Tx PHY_tx_u0(
    .i_clk              (i_tx_clk       ),
    .i_rst              (i_tx_rst       ),

    .i_tx_axis_data     (i_tx_axis_data ),
    .i_tx_axis_keep     (i_tx_axis_keep ),
    .i_tx_axis_valid    (i_tx_axis_valid),
    .i_tx_axis_last     (i_tx_axis_last ),
    .o_tx_axis_ready    (o_tx_axis_ready),

    .i_gt_tx_done       (i_gt_tx_done   ),
    .o_gt_tx_data       (o_gt_tx_data   ),
    .o_gt_tx_char       (o_gt_tx_char   )
);

PHY_Rx PHY_rx_u0(
    .i_clk              (i_rx_clk       ),
    .i_rst              (i_rx_rst       ),

    .o_rx_axis_data     (o_rx_axis_data ),
    .o_rx_axis_keep     (o_rx_axis_keep ),
    .o_rx_axis_valid    (o_rx_axis_valid),
    .o_rx_axis_last     (o_rx_axis_last ),
    .i_rx_axis_ready    (i_rx_axis_ready),

    .i_rx_ByteAlign     (i_rx_ByteAlign ),
    .i_gt_rx_data       (i_gt_rx_data   ),
    .i_gt_rx_char       (i_gt_rx_char   )
);

endmodule
