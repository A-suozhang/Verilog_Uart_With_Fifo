module uart_tx_tb();

reg clk_in = 0;
reg rst;
reg tx_data_en;
reg[7:0] tx_data_in = 14;

wire tx_en,rx_en;

wire tx_finish;
wire tx_serial_data;

wire rx_finish;
wire rx_data;

always begin
  # 10 
  clk_in <= ~clk_in;
end

initial begin
  rst = 1;
  #200
  rst = 0;
end




uart_tx uart_tx0(
    .clk_in(clk_in),
    .tx_en(tx_en),
    .rst(rst),
    .tx_data_en(tx_data_en),
    .tx_data_in(tx_data_in),
    .tx_idle(tx_idle),
    .tx_finish(tx_finish),
    .tx_serial_data(tx_serial_data)
);

uart_rx uart_rx0(
    .clk_in(clk_in),
    .rx_en(rx_en),
    .rst(rst),
    .rx_serial_data(tx_serial_data),
    .rx_finish(rx_finish),
    .rx_data(rx_data)
);

baud_gen baud_gen0(
    .clk_in(clk_in),
    .tx_en(tx_en),
    .rx_en(rx_en)
);


endmodule
