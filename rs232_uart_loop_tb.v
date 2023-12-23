`timescale 1ns/1ns
module rs232_uart_loop_tb();
reg    clk, rst_n,rx;
wire   tx;

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    rx    = 1'b1;
    #50
    rst_n = 1'b1;
end
always #10 clk = ~clk;

initial begin
    #200
    rx_bit(8'd0);
    rx_bit(8'd1);
    rx_bit(8'd2);
    rx_bit(8'd3);
    rx_bit(8'd4);
    rx_bit(8'd5);
    rx_bit(8'd6);
    rx_bit(8'd7);
    #200;
    $stop;
end



task  rx_bit(
        input  [7:0] data
);
    integer i;
begin
for(i=0;i<10;i=i+1) begin
    case(i)
        0 : rx<=1'b0;
        1 : rx <= data[0];
        2 : rx <= data[1];
        3 : rx <= data[2];
        4 : rx <= data[3];
        5 : rx <= data[4];
        6 : rx <= data[5];
        7 : rx <= data[6];
        8 : rx <= data[7];
        9 : rx<=1'b1;
    endcase
    #(50_000_000*20/9600);
end
end
endtask

rs232_uart_loop#(
        .BAUD (9600),
        .CLK_FRE  (50_000_000)
)rs232_uart_loop_u(
        .clk    (clk),
        .rst_n  (rst_n),
        .rx     (rx),
        .tx     (tx)
);


endmodule