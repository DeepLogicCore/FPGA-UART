module uart_tx
#(
    parameter           BAUD = 9600,
    parameter           CLK_FRE  = 50_000_000
)(
    input               clk         ,
    input               rst_n       ,
    input  [7:0]        data        ,
    input               data_flag   ,
    output              tx          
);
localparam              BAUD_CNT_MAX = CLK_FRE/BAUD;
reg [31:0]              baud_cnt;
reg [4:0]               bit_cnt;
reg                     work_en; 
reg                     tx_reg;  
reg [7:0]   data_reg;

reg  data_flag_reg1,data_flag_reg2;
wire    data_flag_edge;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)   begin
        data_flag_reg1 <= 'd0;  
        data_flag_reg2 <= 'd0;
    end else  begin 
        data_flag_reg1 <= data_flag;
        data_flag_reg2 <= data_flag_reg1;
    end
end
assign data_flag_edge = (data_flag_reg2==1'b1)&&(data_flag_reg1==1'b0);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)              data_reg <= 'd0;
    else if(data_flag_edge)      data_reg <= data;     
    else                    data_reg <= data_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)              work_en <= 'b0;
    else if(data_flag_edge)      work_en <= 'b1;
    else if(baud_cnt==BAUD_CNT_MAX-1 && bit_cnt==4'd9)
                            work_en <= 'b0;
    else                    work_en <= work_en;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)              baud_cnt <= 'd0;
    else if(work_en==1'b0||baud_cnt==BAUD_CNT_MAX-1)
                            baud_cnt <= 'd0;
    else                    baud_cnt <= baud_cnt+1'b1;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)              bit_cnt <= 'd0;
    else if(work_en == 'b0) bit_cnt <= 'd0;
    else if(baud_cnt==BAUD_CNT_MAX-1)
                            bit_cnt <= bit_cnt +1'b1;
    else                    bit_cnt <= bit_cnt;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)              tx_reg <= 1'b1;
    else begin
        case(bit_cnt)
        0   :   tx_reg <= 1'b0;
        1   :   tx_reg <= data_reg[0];
        2   :   tx_reg <= data_reg[1];
        3   :   tx_reg <= data_reg[2];
        4   :   tx_reg <= data_reg[3];
        5   :   tx_reg <= data_reg[4];
        6   :   tx_reg <= data_reg[5];
        7   :   tx_reg <= data_reg[6];
        8   :   tx_reg <= data_reg[7];  
        9   :   tx_reg <= 1'b1;   
        default:tx_reg <= 1'b1;    
        endcase
    end
end

assign      tx = tx_reg;
endmodule