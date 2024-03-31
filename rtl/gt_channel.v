`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/26 16:55:55
// Design Name: 
// Module Name: gt_channel
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


module gt_channel(
    input                   i_sysclk                    ,
    input                   i_gtrefclk                  ,
    input                   i_rx_rst                    ,
    input                   i_tx_rst                    ,
    output                  o_tx_done                   ,
    output                  o_rx_done                   ,
    input                   i_tx_polarity               ,
    input  [3 :0]           i_tx_diffctrl               ,
    input  [4 :0]           i_txpostcursor              ,
    input  [4 :0]           i_txpercursor               ,     
    input                   i_rx_polarity               ,
    input  [2 :0]           i_loopback                  ,
    input  [8 :0]           i_drpaddr                   , 
    input                   i_drpclk                    ,
    input  [15:0]           i_drpdi                     , 
    output [15:0]           o_drpdo                     , 
    input                   i_drpen                     ,
    output                  o_drprdy                    , 
    input                   i_drpwe                     ,
    input                   i_qplllock                  , 
    input                   i_qpllrefclklost            , 
    output                  o_qpllreset                 ,
    input                   i_qplloutclk                , 
    input                   i_qplloutrefclk             , 
    output                  o_rx_ByteAlign              ,
    output                  o_rx_clk                    ,
    output [31:0]           o_rx_data                   ,
    output [3 :0]           o_rx_char                   ,

    output                  o_tx_clk                    ,
    input  [31:0]           i_tx_data                   ,
    input  [3 :0]           i_tx_char                   ,

    output                  o_gt_tx_p                   ,
    output                  o_gt_tx_n                   ,
    input                   i_gt_rx_p                   ,
    input                   i_gt_rx_n                   
);  

wire                        w_qpll_reset                ;
wire                        w_gt_qpll_reset             ;
wire                        w_commonreset               ;
wire                        gt0_txusrclk_i              ;
wire                        gt0_txusrclk2_i             ;
wire                        gt0_txoutclk_i              ;
wire                        gt0_txmmcm_lock_i           ;
wire                        gt0_txmmcm_reset_i          ;
wire                        gt0_rxusrclk_i              ;
wire                        gt0_rxusrclk2_i             ;
wire                        gt0_rxmmcm_lock_i           ;
wire                        gt0_rxmmcm_reset_i          ;


assign w_qpll_reset = w_commonreset | w_gt_qpll_reset   ;
assign o_qpllreset  = w_qpll_reset                      ;
assign o_tx_clk = gt0_txusrclk2_i;
assign o_rx_clk = gt0_rxusrclk2_i;

gtwizard_0_GT_USRCLK_SOURCE gt_usrclk_source
(
 
    .GT0_TXUSRCLK_OUT           (gt0_txusrclk_i         ),
    .GT0_TXUSRCLK2_OUT          (gt0_txusrclk2_i        ),
    .GT0_TXOUTCLK_IN            (gt0_txoutclk_i         ),
    .GT0_TXCLK_LOCK_OUT         (gt0_txmmcm_lock_i      ),
    .GT0_TX_MMCM_RESET_IN       (gt0_txmmcm_reset_i     ),
    .GT0_RXUSRCLK_OUT           (gt0_rxusrclk_i         ),
    .GT0_RXUSRCLK2_OUT          (gt0_rxusrclk2_i        ),
    .GT0_RXCLK_LOCK_OUT         (gt0_rxmmcm_lock_i      ),
    .GT0_RX_MMCM_RESET_IN       (gt0_rxmmcm_reset_i     )
);  

gtwizard_0_common_reset # 
(
    .STABLE_CLOCK_PERIOD            (                       )    
)
common_reset_i
(    
    .STABLE_CLOCK                   (i_sysclk               ),           
    .SOFT_RESET                     (i_tx_rst               ),      
    .COMMON_RESET                   (w_commonreset          )          
);

gtwizard_0  gtwizard_0_i
(
    .sysclk_in                      (i_sysclk               ), //SYSCLK是一个自由运行的系统/板载时钟，用于驱动示例设计中的FPGA逻辑。当启用DRP接口时，DRP_CLK连接到示例设计中的SYSCLK。需要在XDC中对此时钟进行约束。
    .soft_reset_tx_in               (i_tx_rst               ), 
    .soft_reset_rx_in               (i_rx_rst               ), 
    .dont_reset_on_data_error_in    (0                      ), 
    .gt0_tx_fsm_reset_done_out      (o_tx_done              ),
    .gt0_rx_fsm_reset_done_out      (),     
    .gt0_data_valid_in              (1                      ), 
    .gt0_tx_mmcm_lock_in            (gt0_txmmcm_lock_i      ), 
    .gt0_tx_mmcm_reset_out          (gt0_txmmcm_reset_i     ), 
    .gt0_rx_mmcm_lock_in            (gt0_rxmmcm_lock_i      ),
    .gt0_rx_mmcm_reset_out          (gt0_rxmmcm_reset_i     ), 
    .gt0_drpaddr_in                 (i_drpaddr              ),     
    .gt0_drpclk_in                  (i_sysclk               ),     
    .gt0_drpdi_in                   (i_drpdi                ),     
    .gt0_drpdo_out                  (o_drpdo                ),     
    .gt0_drpen_in                   (i_drpen                ),     
    .gt0_drprdy_out                 (o_drprdy               ),     
    .gt0_drpwe_in                   (i_drpwe                ),     

    .gt0_dmonitorout_out            (),     
    .gt0_loopback_in                (i_loopback             ),  
    .gt0_eyescanreset_in            (0                      ), 
    .gt0_rxuserrdy_in               (1                      ),
    .gt0_eyescandataerror_out       (), 
    .gt0_eyescantrigger_in          (0                      ),
    .gt0_rxclkcorcnt_out            (                       ),
    .gt0_rxusrclk_in                (gt0_rxusrclk_i         ), 
    .gt0_rxusrclk2_in               (gt0_rxusrclk2_i        ), 
    .gt0_rxdata_out                 (o_rx_data              ),//接收数据,位宽为IP配置的用户位宽
    .gt0_rxdisperr_out              (), 
    .gt0_rxnotintable_out           (), 
    .gt0_gtxrxp_in                  (i_gt_rx_p              ),//输入差分引脚    
    .gt0_gtxrxn_in                  (i_gt_rx_n              ),//输入差分引脚    
    .gt0_rxbyteisaligned_out        (o_rx_ByteAlign         ),//接收数据字节对齐指示信号
    .gt0_rxdfelpmreset_in           (0                      ), 
    .gt0_rxmonitorout_out           (),     
    .gt0_rxmonitorsel_in            (0                      ), 
    .gt0_rxoutclkfabric_out         (),     
    .gt0_gtrxreset_in               (i_rx_rst               ), 
    .gt0_rxpmareset_in              (i_rx_rst               ), 
    .gt0_rxpolarity_in              (i_rx_polarity          ), 
    .gt0_rxcharisk_out              (o_rx_char              ),//标记接收的有效的8B/10BK字符。高位比特对应数据路径的高位字节。
    .gt0_rxresetdone_out            (o_rx_done              ), 
    .gt0_txpostcursor_in            (i_txpostcursor         ), 
    .gt0_txprecursor_in             (i_txpercursor          ), 
    .gt0_gttxreset_in               (i_tx_rst               ), 
    .gt0_txuserrdy_in               (1                      ), 
    .gt0_txusrclk_in                (gt0_txusrclk_i         ), 
    .gt0_txusrclk2_in               (gt0_txusrclk2_i        ), 
    .gt0_txdiffctrl_in              (i_tx_diffctrl          ), 
    .gt0_txdata_in                  (i_tx_data              ),//与接收同理 
    .gt0_gtxtxn_out                 (o_gt_tx_n              ),//与接收同理     
    .gt0_gtxtxp_out                 (o_gt_tx_p              ),//与接收同理     
    .gt0_txoutclk_out               (gt0_txoutclk_i         ), 
    .gt0_txoutclkfabric_out         (),     
    .gt0_txoutclkpcs_out            (),     
    .gt0_txcharisk_in               (i_tx_char              ),//与接收同理  
    .gt0_txresetdone_out            (),     
    .gt0_txpolarity_in              (i_tx_polarity          ), 

    .gt0_qplllock_in                (i_qplllock             ),
    .gt0_qpllrefclklost_in          (i_qpllrefclklost       ),
    .gt0_qpllreset_out              (w_gt_qpll_reset        ),
    .gt0_qplloutclk_in              (i_qplloutclk           ),
    .gt0_qplloutrefclk_in           (i_qplloutrefclk        ) 
);

endmodule
