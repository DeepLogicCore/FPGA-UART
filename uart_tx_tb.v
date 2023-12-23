`timescale 1ns/1ns
module uart_tx_tb();
reg clk,rst_n,data_flag;
reg [7:0] data;
wire    tx;

always #10 clk = ~clk;
initial begin
        clk = 0;
        rst_n =0 ;
        #50
        rst_n =1 ;
end

initial begin
        data_flag = 1'b0;
        data      = 8'd0;
        #200;
        //数据0
        data      = 8'd0;     
        data_flag = 1'b1;
        #20;
        data_flag = 1'b0;  
        #(5208*20*10);
        //数据1
        data      = 8'd1;     
        data_flag = 1'b1;
        #20;
        data_flag = 1'b0;  
        #(5208*20*10);
        //数据2
        data      = 8'd2;     
        data_flag = 1'b1;
        #20;
        data_flag = 1'b0;  
        #(5208*20*10);
        //数据3
        data      = 8'd3;     
        data_flag = 1'b1;
        #20;
        data_flag = 1'b0;  
        #(5208*20*10);
        //数据4
        data      = 8'd4;     
        data_flag = 1'b1;
        #20;
        data_flag = 1'b0;  
        #(5208*20*10);
        $stop;
end

uart_tx #(
        .BAUD (9600),
        .CLK_FRE (50_000_000)
)uart_tx_u(
        .clk         (clk),
        .rst_n       (rst_n),
        .data        (data),
        .data_flag   (data_flag),
        .tx          (tx)
);

endmodule