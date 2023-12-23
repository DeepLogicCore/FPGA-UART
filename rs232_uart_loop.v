module rs232_uart_loop#(
                parameter           BAUD = 9600,
                parameter           CLK_FRE  = 50_000_000
)(
                input       clk,
                input       rst_n,
                input       rx,
                output      tx
);

wire  [7:0]     data;
wire            data_flag;
uart_rx #(
                .BAUD       (9600),
                .CLK_FRE    (50_000_000)
)uart_rx_u(
                .clk        (clk) ,
                .rst_n      (rst_n) ,
                .rx         (rx) ,
                .data       (data) ,
                .data_flag  (data_flag)
);

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