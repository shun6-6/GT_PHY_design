`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/28 21:10:48
// Design Name: 
// Module Name: SIM_phy_TB
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


module SIM_phy_TB();
localparam      P_ST_INIT   = 0,
                P_ST_IDLE   = 1,
                P_ST_COMMA  = 2,
                P_ST_SOF    = 3,
                P_ST_DATA   = 4,
                P_ST_EOF    = 5,
                P_ST_EOF2   = 6;
reg clk ,rst;

always begin
    clk = 0;
    #10;
    clk = 1;
    #10;
end

initial begin
    rst = 1;
    #50;
    @(posedge clk) rst = 0;
end

reg [31:0]      r_tx_axis_data ;
reg [3 :0]      r_tx_axis_keep ;
reg             r_tx_axis_valid;
reg             r_tx_axis_last ;
wire            w_tx_axis_ready;
reg  [7:0]      r_send_value    ;

wire [31:0]       w_gt_tx_data;
wire [3 :0]       w_gt_tx_char;

reg  [79:0] monitor_st;
always@(PHY_module_U0.PHY_tx_u0.r_cur_state)begin
    case(PHY_module_U0.PHY_tx_u0.r_cur_state)
        P_ST_INIT  : monitor_st = "P_ST_INIT ";
        P_ST_IDLE  : monitor_st = "P_ST_IDLE ";
        P_ST_COMMA : monitor_st = "P_ST_COMMA";
        P_ST_SOF   : monitor_st = "P_ST_SOF  ";
        P_ST_DATA  : monitor_st = "P_ST_DATA ";
        P_ST_EOF   : monitor_st = "P_ST_EOF  ";
        P_ST_EOF2  : monitor_st = "P_ST_EOF2 ";   
        default : monitor_st = "P_ST_IDLE "; 
    endcase
end

PHY_module PHY_module_U0(
    .i_tx_clk           (clk),
    .i_tx_rst           (rst),
    .i_rx_clk           (clk),
    .i_rx_rst           (rst),

    .i_tx_axis_data     (r_tx_axis_data ),
    .i_tx_axis_keep     (r_tx_axis_keep ),    
    .i_tx_axis_valid    (r_tx_axis_valid),
    .i_tx_axis_last     (r_tx_axis_last ),
    .o_tx_axis_ready    (w_tx_axis_ready),
    .o_rx_axis_data     (),
    .o_rx_axis_keep     (),    
    .o_rx_axis_valid    (),
    .o_rx_axis_last     (),
    .i_rx_axis_ready    (1),

    .i_gt_tx_done       (1),
    .o_gt_tx_data       (w_gt_tx_data),
    .o_gt_tx_char       (w_gt_tx_char),
    .i_rx_ByteAlign     (1),
    .i_gt_rx_data       (w_gt_tx_data),
    .i_gt_rx_char       (w_gt_tx_char)
);

initial begin
    r_tx_axis_data  = 'd0;
    r_tx_axis_keep  = 'd0;
    r_tx_axis_valid = 'd0;
    r_tx_axis_last  = 'd0;  
    r_send_value    = 'd0; 
    wait(!rst);
   // forever begin
    phy_tx_test(10,4'b1100); 
   // end
end


task phy_tx_test(input [7:0] len,input [3:0]last_keep);
begin:phy_tx_test
    integer i;
    r_tx_axis_data  <= 'd0;
    r_tx_axis_keep  <= 'd0;
    r_tx_axis_valid <= 'd0;
    r_tx_axis_last  <= 'd0; 
    r_send_value    <= 'd1;
    @(posedge clk);
    wait(w_tx_axis_ready);
    for(i = 0; i < len; i = i + 1)begin
        r_send_value <= r_send_value + 1;
        r_tx_axis_data  <= {r_send_value,r_send_value,r_send_value,r_send_value};
        r_tx_axis_valid <= 'd1;
        if(i == len-1)
            r_tx_axis_keep <= last_keep;
        else
            r_tx_axis_keep <= 4'b1111;
        if(i == len-1)
            r_tx_axis_last <= 'd1; 
        else
            r_tx_axis_last <= 'd0; 
        @(posedge clk);        
    end
    r_tx_axis_data  <= 'd0;
    r_tx_axis_keep  <= 'd0;
    r_tx_axis_valid <= 'd0;
    r_tx_axis_last  <= 'd0; 
    r_send_value    <= 'd0;    
    @(posedge clk); 
end
endtask

endmodule
