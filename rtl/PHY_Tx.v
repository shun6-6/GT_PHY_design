`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/26 16:55:55
// Design Name: 
// Module Name: PHY_Tx
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


module PHY_Tx(
    input               i_clk           ,
    input               i_rst           ,

    input  [31:0]       i_tx_axis_data  ,
    input  [3 :0]       i_tx_axis_keep  ,    
    input               i_tx_axis_valid ,
    input               i_tx_axis_last  ,
    output              o_tx_axis_ready ,

    input               i_gt_tx_done    ,
    output [31:0]       o_gt_tx_data    ,
    output [3 :0]       o_gt_tx_char    
);
/***************function**************/

/***************parameter*************/
localparam      P_INSERT_LEN = 500;
localparam      P_ST_INIT   = 0,
                P_ST_IDLE   = 1,
                P_ST_COMMA  = 2,
                P_ST_SOF    = 3,
                P_ST_DATA   = 4,
                P_ST_EOF    = 5,
                P_ST_EOF2   = 6,
                P_ST_INSERT = 7;
/***************port******************/             

/***************mechine***************/
reg  [7 :0]     r_cur_state     ;
reg  [7 :0]     r_nxt_state     ;
reg  [15:0]     r_st_cnt        ;
/***************reg*******************/
reg  [31:0]     ro_gt_tx_data   ;
reg  [3 :0]     ro_gt_tx_char   ;
reg             ri_tx_axis_valid;
reg             ri_tx_axis_valid_1d;
reg             ro_tx_axis_ready;
reg  [3 :0]     ri_tx_axis_keep ;
reg  [15:0]     r_tx_data_len   ;
reg             r_fifo_rden     ;
reg  [31:0]     r_fifo_dout     ;
/***************wire******************/
wire [31:0]     w_fifo_dout     ;
wire            w_fifo_full     ;
wire            w_fifo_empty    ;
wire [31:0]     w_lfsr_data     ;
/***************component*************/
//该FIFO模式为first word fall through模式，读潜伏期为0
FIFO_32X1024 FIFO_32X1024_tx (
  .clk              (i_clk          ),
  .din              (i_tx_axis_data    ),
  .wr_en            (i_tx_axis_valid   ),
  .rd_en            (r_fifo_rden    ),
  .dout             (w_fifo_dout    ),
  .full             (w_fifo_full    ),
  .empty            (w_fifo_empty   )
);

LFSR_gen#(
    .P_LFSR_INIT    (16'hA076)
)LFSR_gen_u0(
    .i_clk          (i_clk ),
    .i_rst          (i_rst ),
    .o_lfsr_data    (w_lfsr_data) 
);
/***************assign****************/
assign o_tx_axis_ready = ro_tx_axis_ready;
assign o_gt_tx_data = {ro_gt_tx_data[7:0],ro_gt_tx_data[15:8],ro_gt_tx_data[23:16],ro_gt_tx_data[31:24]};
assign o_gt_tx_char = {ro_gt_tx_char[0],ro_gt_tx_char[1],ro_gt_tx_char[2],ro_gt_tx_char[3]};
/***************always****************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cur_state <= P_ST_INIT;
    else
        r_cur_state <= r_nxt_state;
end
//fifo有潜伏期，哪怕此时已经将数据输入，FIFO空信号依旧为高，潜伏期结束后才会拉低
always @(*)begin
    case (r_cur_state)
        P_ST_INIT   : r_nxt_state = i_gt_tx_done ? P_ST_IDLE : P_ST_INIT;
        P_ST_IDLE   : r_nxt_state = ri_tx_axis_valid_1d ? P_ST_COMMA : 
                                    r_st_cnt == P_INSERT_LEN ? P_ST_INSERT : P_ST_IDLE;
        P_ST_COMMA  : r_nxt_state = P_ST_SOF;
        P_ST_SOF    : r_nxt_state = P_ST_DATA;
        P_ST_DATA   : r_nxt_state = !i_tx_axis_valid && (r_st_cnt == r_tx_data_len - 3) ? P_ST_EOF :P_ST_DATA ;
        P_ST_EOF    : r_nxt_state = ri_tx_axis_keep >= 4'b1110 ? P_ST_EOF2 : P_ST_IDLE;
        P_ST_EOF2   : r_nxt_state = P_ST_IDLE;
        P_ST_INSERT : r_nxt_state = ri_tx_axis_valid_1d ? P_ST_COMMA :
                                    r_st_cnt == 1 ? P_ST_IDLE : P_ST_INSERT;
        default     : r_nxt_state = P_ST_INIT;
    endcase
end


always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_st_cnt <= 'd0;
    else if(r_cur_state != r_nxt_state)
        r_st_cnt <= 'd0;
    else
        r_st_cnt <= r_st_cnt + 'd1;
end


always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_gt_tx_data <= 'd0;
        ro_gt_tx_char <= 'd0;
    end 
    else if(r_cur_state == P_ST_COMMA)begin
        // ro_gt_tx_data <= 32'h50BC50BC;
        ro_gt_tx_data <= 32'hbc50bc50;
        ro_gt_tx_char <= 4'b1010;
    end
    else if(r_cur_state == P_ST_SOF)begin
        ro_gt_tx_data <= {8'hFB,w_fifo_dout[31:8]};
        ro_gt_tx_char <= 4'b1000;
    end
    else if(r_cur_state == P_ST_DATA)begin
        ro_gt_tx_data <= {r_fifo_dout[7:0],w_fifo_dout[31:8]};
        ro_gt_tx_char <= 4'b0000;
    end
    else if(r_cur_state == P_ST_EOF && ri_tx_axis_keep == 4'b1000)begin
        ro_gt_tx_data <= {r_fifo_dout[7:0],w_fifo_dout[31:24],8'hfd,w_lfsr_data[31:24]};
        ro_gt_tx_char <= 4'b0010;
    end
    else if(r_cur_state == P_ST_EOF && ri_tx_axis_keep == 4'b1100)begin
        ro_gt_tx_data <= {r_fifo_dout[7:0],w_fifo_dout[31:16],8'hfd};
        ro_gt_tx_char <= 4'b0001;
    end
    else if(r_cur_state == P_ST_EOF && ri_tx_axis_keep == 4'b1110)begin
        ro_gt_tx_data <= {r_fifo_dout[7:0],w_fifo_dout[31:8]};
        ro_gt_tx_char <= 4'b0000;
    end
    else if(r_cur_state == P_ST_EOF && ri_tx_axis_keep == 4'b1111)begin
        ro_gt_tx_data <= {r_fifo_dout[7:0],w_fifo_dout[31:8]};
        ro_gt_tx_char <= 4'b0000;
    end
    else if(r_cur_state == P_ST_EOF2 && ri_tx_axis_keep == 4'b1110)begin
        ro_gt_tx_data <= {8'hfd,w_lfsr_data[31:8]};
        ro_gt_tx_char <= 4'b1000;
    end
    else if(r_cur_state == P_ST_EOF2 && ri_tx_axis_keep == 4'b1111)begin
        ro_gt_tx_data <= {r_fifo_dout[7:0],8'hfd,w_lfsr_data[31:16]};
        ro_gt_tx_char <= 4'b0100;
    end
    else if(r_cur_state == P_ST_INSERT)begin
        ro_gt_tx_data <= {16'hbc50,16'hbc50};
        ro_gt_tx_char <= 4'b0101;
    end
    else begin
        ro_gt_tx_data <= w_lfsr_data;
        ro_gt_tx_char <= 4'b0000;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_dout <= 'd0;
    else
        r_fifo_dout <= w_fifo_dout;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ri_tx_axis_keep <= 'd0;
    else if(i_tx_axis_last)
        ri_tx_axis_keep <= i_tx_axis_keep;
    else
        ri_tx_axis_keep <= ri_tx_axis_keep;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_rden <= 'd0;
    else if(w_fifo_empty)
        r_fifo_rden <= 'd0;
    else if(r_cur_state == P_ST_COMMA)
        r_fifo_rden <= 'd1;
    else
        r_fifo_rden <= r_fifo_rden;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_tx_axis_ready <= 'd0;
    else if(i_tx_axis_last)
        ro_tx_axis_ready <= 'd0;
    else if(r_cur_state == P_ST_IDLE)
        ro_tx_axis_ready <= 'd1;
    else
        ro_tx_axis_ready <= ro_tx_axis_ready;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_tx_axis_valid <= 'd0;
        ri_tx_axis_valid_1d <= 'd0;        
    end
    else begin
        ri_tx_axis_valid <= i_tx_axis_valid;       
        ri_tx_axis_valid_1d <= ri_tx_axis_valid;      
    end

end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_tx_data_len <= 'd0;
    else if(i_tx_axis_valid && !ri_tx_axis_valid)
        r_tx_data_len <= 'd1;
    else if(i_tx_axis_valid)
        r_tx_data_len <= r_tx_data_len + 1;
    else
        r_tx_data_len <= r_tx_data_len;
end



endmodule
