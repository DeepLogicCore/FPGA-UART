module uart_rx
#(
    parameter           BAUD = 9600,
    parameter           CLK_FRE  = 50_000_000
)(
    input               clk         ,
    input               rst_n       ,
    input               rx          ,
    output  [7:0]       data        ,
    output              data_flag
);
localparam              BAUD_CNT_MAX = CLK_FRE/BAUD;
reg                     rx_reg1,rx_reg2,rx_reg3;
reg                     start_flag,work_en;
reg [31:0]              baud_cnt;
reg [4:0]               bit_cnt;
reg [7:0]               rx_data;
reg [7:0]               data_reg;
reg                     rx_done;

//第一拍是同步，二三拍是消除亚稳态
always @(posedge clk or negedge rst_n ) begin
    if(!rst_n)  begin
        rx_reg1 <= 1'b1;
        rx_reg2 <= 1'b1;
        rx_reg3 <= 1'b1;
    end
    else begin
        rx_reg1 <= rx;
        rx_reg2 <= rx_reg1;
        rx_reg3 <= rx_reg2;
    end
end
//捕捉起始位的下降沿作为开始标志
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)          start_flag <= 1'b0;
    else if((rx_reg2==1'b0)&&(rx_reg3==1'b1)&&(work_en == 1'b0))                   
                        start_flag <= 1'b1;
    else    
                        start_flag <= 1'b0;
end
//收到起始位后拉高工作使能，当计数8个波特后拉低工作使能
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)          work_en <= 1'b0;
    else if(start_flag) work_en <= 1'b1;
    else if((baud_cnt == BAUD_CNT_MAX -1'b1) && (bit_cnt == 4'd8))           
                        work_en <= 1'b0;
    else                work_en <= work_en ;
end
//在工作使能有效下，计算一个波特
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)          baud_cnt <= 32'd0;
    else if(work_en == 1'b1)
            if((baud_cnt == BAUD_CNT_MAX -1'b1))
                        baud_cnt <= 32'd0;
            else
                        baud_cnt <= baud_cnt+1'b1;        
    else    
                        baud_cnt <= 32'd0;
end
//在工作使能有效下，计算数据位
always @(posedge clk or negedge rst_n) begin
     if(!rst_n)         bit_cnt <= 4'd0;
     else if (work_en <= 1'b0)
                        bit_cnt <= 4'd0;
     else if (baud_cnt == BAUD_CNT_MAX -1'b1)
                        bit_cnt <= bit_cnt + 1'b1;
     else    
                        bit_cnt <= bit_cnt;    
end
always @(posedge clk or negedge rst_n) begin
     if(!rst_n)         rx_data <= 8'd0;
     else if (work_en && baud_cnt == BAUD_CNT_MAX/2) begin
            case(bit_cnt)
                0: rx_data <= rx_data;
                1: rx_data[0] <= rx;
                2: rx_data[1] <= rx;                
                3: rx_data[2] <= rx;
                4: rx_data[3] <= rx;  
                5: rx_data[4] <= rx;
                6: rx_data[5] <= rx;                
                7: rx_data[6] <= rx;
                8: rx_data[7] <= rx;
            default :rx_data <= rx_data;
            endcase
     end
end
always @(posedge clk or negedge rst_n) begin
     if(!rst_n)             rx_done  <= 1'b0;
     else if((baud_cnt == BAUD_CNT_MAX -1'b1) && (bit_cnt == 4'd8))
                            rx_done  <= 1'b1;
    else                    rx_done  <= 1'b0;
end
always @(posedge clk or negedge rst_n) begin
     if(!rst_n)             data_reg<=8'd0;
     else if((baud_cnt == BAUD_CNT_MAX -1'b1) && (bit_cnt == 4'd8))  
                            data_reg<=rx_data;
     else                   data_reg<=data_reg;
end
assign  data = data_reg;
assign  data_flag = rx_done;



endmodule