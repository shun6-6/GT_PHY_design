`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/26 16:55:55
// Design Name: 
// Module Name: XC7100_TOP
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


module XC7100_TOP(
    input               i_sysclk_p  ,
    input               i_sysclk_n  ,
    input               i_gtrefclk_p,
    input               i_gtrefclk_n,

    output  [1 :0]      o_gt_tx_p   ,
    output  [1 :0]      o_gt_tx_n   ,
    input   [1 :0]      i_gt_rx_p   ,
    input   [1 :0]      i_gt_rx_n   ,
    output  [1 :0]      o_sfp_dis   
);
assign o_sfp_dis = 2'b00;

wire            i_sysclk        ;
wire            w_rx0_rst       ;
wire            w_tx0_rst       ;
(* MARK_DEBUG = "TRUE"*)wire            w_tx0_done      ;
(* MARK_DEBUG = "TRUE"*)wire            w_rx0_ByteAlign ;
wire            w_rx0_clk       ;
(* MARK_DEBUG = "TRUE"*)wire [31:0]     w_rx0_data      ;
(* MARK_DEBUG = "TRUE"*)wire [3 :0]     w_rx0_char      ;
wire            w_tx0_clk       ;
(* MARK_DEBUG = "TRUE"*)wire [31:0]     w_tx0_data      ;
(* MARK_DEBUG = "TRUE"*)wire [3 :0]     w_tx0_char      ;

wire            w_rx1_rst       ;
wire            w_tx1_rst       ;
(* MARK_DEBUG = "TRUE"*)wire            w_tx1_done      ;
(* MARK_DEBUG = "TRUE"*)wire            w_rx1_ByteAlign ;
wire            w_rx1_clk       ;
(* MARK_DEBUG = "TRUE"*)wire [31:0]     w_rx1_data      ;
(* MARK_DEBUG = "TRUE"*)wire [3 :0]     w_rx1_char      ;
wire            w_tx1_clk       ;
(* MARK_DEBUG = "TRUE"*)wire [31:0]     w_tx1_data      ;
(* MARK_DEBUG = "TRUE"*)wire [3 :0]     w_tx1_char      ;

(* MARK_DEBUG = "TRUE"*)wire [31:0]     w_tx0_axis_data ;
(* MARK_DEBUG = "TRUE"*)wire [3 :0]     w_tx0_axis_keep ;
(* MARK_DEBUG = "TRUE"*)wire            w_tx0_axis_valid;
(* MARK_DEBUG = "TRUE"*)wire            w_tx0_axis_last ;
(* MARK_DEBUG = "TRUE"*)wire            w_tx0_axis_ready;
(* MARK_DEBUG = "TRUE"*)wire [31:0]     w_rx0_axis_data ;
(* MARK_DEBUG = "TRUE"*)wire [3 :0]     w_rx0_axis_keep ;
(* MARK_DEBUG = "TRUE"*)wire            w_rx0_axis_valid;
(* MARK_DEBUG = "TRUE"*)wire            w_rx0_axis_last ;

(* MARK_DEBUG = "TRUE"*)wire [31:0]     w_tx1_axis_data ;
(* MARK_DEBUG = "TRUE"*)wire [3 :0]     w_tx1_axis_keep ;
(* MARK_DEBUG = "TRUE"*)wire            w_tx1_axis_valid;
(* MARK_DEBUG = "TRUE"*)wire            w_tx1_axis_last ;
(* MARK_DEBUG = "TRUE"*)wire            w_tx1_axis_ready;
(* MARK_DEBUG = "TRUE"*)wire [31:0]     w_rx1_axis_data ;
(* MARK_DEBUG = "TRUE"*)wire [3 :0]     w_rx1_axis_keep ;
(* MARK_DEBUG = "TRUE"*)wire            w_rx1_axis_valid;
(* MARK_DEBUG = "TRUE"*)wire            w_rx1_axis_last ;


IBUFDS #(
    .DIFF_TERM("FALSE"),       // Differential Termination
    .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
    .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
 ) IBUFDS_inst (
    .O(i_sysclk),  // Buffer output
    .I(i_sysclk_p),  // Diff_p buffer input (connect directly to top-level port)
    .IB(i_sysclk_n) // Diff_n buffer input (connect directly to top-level port)
 );

rst_gen_module#(
    .P_RST_CYCLE    (10             )   
)
rst_gen_module_u0
(
    .i_clk          (w_tx0_clk       ),
    .o_rst          (w_tx0_rst       )
);
rst_gen_module#(
    .P_RST_CYCLE    (10             )   
)
rst_gen_module_u1
(
    .i_clk          (w_rx0_clk       ),
    .o_rst          (w_rx0_rst       )
);

rst_gen_module#(
    .P_RST_CYCLE    (10             )   
)
rst_gen_module_u2
(
    .i_clk          (w_tx1_clk       ),
    .o_rst          (w_tx1_rst       )
);
rst_gen_module#(
    .P_RST_CYCLE    (10             )   
)
rst_gen_module_u3
(
    .i_clk          (w_rx1_clk       ),
    .o_rst          (w_rx1_rst       )
);



AXI_S_Gen_Data#(
    .P_KEEP             (4'b1000            )
)   
AXI_S_Gen_Data_u0   
(   
    .i_clk              (w_tx0_clk          ),
    .i_rst              (w_tx0_rst          ),

    .o_axi_s_data       (w_tx0_axis_data    ),
    .o_axi_s_keep       (w_tx0_axis_keep    ),
    .o_axi_s_last       (w_tx0_axis_last    ),
    .o_axi_s_valid      (w_tx0_axis_valid   ),
    .i_axi_s_ready      (w_tx0_axis_ready   )
);

PHY_module PHY_module_U0(
    .i_tx_clk           (w_tx0_clk          ),
    .i_tx_rst           (w_tx0_rst          ),
    .i_rx_clk           (w_rx0_clk          ),
    .i_rx_rst           (w_rx0_rst          ),

    .i_tx_axis_data     (w_tx0_axis_data    ),
    .i_tx_axis_keep     (w_tx0_axis_keep    ),    
    .i_tx_axis_valid    (w_tx0_axis_valid   ),
    .i_tx_axis_last     (w_tx0_axis_last    ),
    .o_tx_axis_ready    (w_tx0_axis_ready   ),
    .o_rx_axis_data     (w_rx0_axis_data    ),
    .o_rx_axis_keep     (w_rx0_axis_keep    ),    
    .o_rx_axis_valid    (w_rx0_axis_valid   ),
    .o_rx_axis_last     (w_rx0_axis_last    ),
    .i_rx_axis_ready    (1),

    .i_gt_tx_done       (1),
    .o_gt_tx_data       (w_tx0_data         ),
    .o_gt_tx_char       (w_tx0_char         ),
    .i_rx_ByteAlign     (1),
    .i_gt_rx_data       (w_rx0_data         ),
    .i_gt_rx_char       (w_rx0_char         )
);

AXI_S_Gen_Data#(
    .P_KEEP             (4'b1111            )
)
AXI_S_Gen_Data_u1
(
    .i_clk              (w_tx1_clk          ),
    .i_rst              (w_tx1_rst          ),

    .o_axi_s_data       (w_tx1_axis_data    ),
    .o_axi_s_keep       (w_tx1_axis_keep    ),
    .o_axi_s_last       (w_tx1_axis_last    ),
    .o_axi_s_valid      (w_tx1_axis_valid   ),
    .i_axi_s_ready      (w_tx1_axis_ready   )
);

PHY_module PHY_module_U1(
    .i_tx_clk           (w_tx1_clk          ),
    .i_tx_rst           (w_tx1_rst          ),
    .i_rx_clk           (w_rx1_clk          ),
    .i_rx_rst           (w_rx1_rst          ),

    .i_tx_axis_data     (w_tx1_axis_data    ),
    .i_tx_axis_keep     (w_tx1_axis_keep    ),    
    .i_tx_axis_valid    (w_tx1_axis_valid   ),
    .i_tx_axis_last     (w_tx1_axis_last    ),
    .o_tx_axis_ready    (w_tx1_axis_ready   ),
    .o_rx_axis_data     (w_rx1_axis_data    ),
    .o_rx_axis_keep     (w_rx1_axis_keep    ),    
    .o_rx_axis_valid    (w_rx1_axis_valid   ),
    .o_rx_axis_last     (w_rx1_axis_last    ),
    .i_rx_axis_ready    (1),

    .i_gt_tx_done       (1),
    .o_gt_tx_data       (w_tx1_data         ),
    .o_gt_tx_char       (w_tx1_char         ),
    .i_rx_ByteAlign     (1),
    .i_gt_rx_data       (w_rx1_data         ),
    .i_gt_rx_char       (w_rx1_char         )
);

gt_module gt_module_u0(
    .i_sysclk                    (i_sysclk          ),
    .i_gtrefclk_p                (i_gtrefclk_p      ),
    .i_gtrefclk_n                (i_gtrefclk_n      ),
    .i_rx0_rst                   (w_rx0_rst         ),
    .i_tx0_rst                   (w_tx0_rst         ),
    .o_tx0_done                  (w_tx0_done        ),
    .o_rx0_done                  (0                 ),
    .i_tx0_polarity              (4'b1100           ),
    .i_tx0_diffctrl              (5'b00011          ),
    .i_tx0postcursor             (5'b00111          ),
    .i_tx0percursor              (0),     
    .i_rx0_polarity              (0),
    .i_loopback0                 (0),
    .i_0_drpaddr                 (0), 
    .i_0_drpclk                  (i_sysclk          ),
    .i_0_drpdi                   (0), 
    .o_0_drpdo                   (), 
    .i_0_drpen                   (0),
    .o_0_drprdy                  (), 
    .i_0_drpwe                   (0),
    .o_rx0_ByteAlign             (w_rx0_ByteAlign   ),
    .o_rx0_clk                   (w_rx0_clk         ),
    .o_rx0_data                  (w_rx0_data        ),
    .o_rx0_char                  (w_rx0_char        ),
    .o_tx0_clk                   (w_tx0_clk         ),
    .i_tx0_data                  (w_tx0_data        ),
    .i_tx0_char                  (w_tx0_char        ),

    .i_rx1_rst                   (w_rx1_rst         ),
    .i_tx1_rst                   (w_tx1_rst         ),
    .o_tx1_done                  (w_tx1_done        ),
    .o_rx1_done                  (0                 ),
    .i_tx1_polarity              (4'b1100           ),
    .i_tx1_diffctrl              (5'b00011          ),
    .i_tx1postcursor             (5'b00111          ),
    .i_tx1percursor              (0),         
    .i_rx1_polarity              (0),
    .i_loopback1                 (0),
    .i_1_drpaddr                 (0), 
    .i_1_drpclk                  (0),
    .i_1_drpdi                   (0), 
    .o_1_drpdo                   (), 
    .i_1_drpen                   (0),
    .o_1_drprdy                  (), 
    .i_1_drpwe                   (0),
    .o_rx1_ByteAlign             (w_rx1_ByteAlign   ),
    .o_rx1_clk                   (w_rx1_clk         ),
    .o_rx1_data                  (w_rx1_data        ),
    .o_rx1_char                  (w_rx1_char        ),
    .o_tx1_clk                   (w_tx1_clk         ),
    .i_tx1_data                  (w_tx1_data        ),
    .i_tx1_char                  (w_tx1_char        ),

    .o_gt_tx0_p                  (o_gt_tx_p[0]      ),
    .o_gt_tx0_n                  (o_gt_tx_n[0]      ),
    .i_gt_rx0_p                  (i_gt_rx_p[0]      ),
    .i_gt_rx0_n                  (i_gt_rx_n[0]      ),
    .o_gt_tx1_p                  (o_gt_tx_p[1]      ),
    .o_gt_tx1_n                  (o_gt_tx_n[1]      ),
    .i_gt_rx1_p                  (i_gt_rx_p[1]      ),
    .i_gt_rx1_n                  (i_gt_rx_n[1]      )  
);

endmodule
