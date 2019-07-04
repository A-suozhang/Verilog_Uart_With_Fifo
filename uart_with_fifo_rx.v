module uart_with_fifo_rx(clk_in,rx_en,rst,rx_serial_data,rd_en,dout,almost_empty,empty);
// Acquiring Data From UART_RX
// Then Decode It Into Data
// Feed Into FIFO
// Other module can read from this fifo
// getting The output dout


input wire clk_in;
input wire rx_en;
input wire rst;
input wire rd_en;
input wire rx_serial_data;
output wire[7:0] dout;
output wire almost_empty;
output wire empty;




reg[7:0] rx_data_valid;
always@(posedge clk_in) begin
    if (rst) begin
        rx_data_valid <= 0;
    end 
    else begin
        if (rx_finish) begin
            rx_data_valid <= rx_data;
            wr_en = 1;
        end 
        else begin
            wr_en <= 0;
        end
    end
end

// ----The Instanc Of FIFO
reg wr_en;
wire[9:0] data_count;
fifo_generator_0 fifo0 (
  .clk(clk_in),                    // input wire clk
  .srst(rst),                  // input wire srst
  .din(rx_data_valid),                    // input wire [7 : 0] din
  .wr_en(wr_en),                // input wire wr_en
  .rd_en(rd_en),                // input wire rd_en
  .dout(dout),                  // output wire [7 : 0] dout
  .full(full),                  // output wire full
  .almost_full(almost_full),    // output wire almost_full
  .empty(empty),                // output wire empty
  .almost_empty(almost_empty),  // output wire almost_empty
  .data_count(data_count)      // output wire [9 : 0] data_count
);


//  ---The Intsantance Of UART_RX
wire[7:0] rx_data;
wire rx_finish;

uart_rx uart_rx0(
    .clk_in(clk_in),
    .rx_en(rx_en),
    .rst(rst),
    .rx_serial_data(rx_serial_data),
    .rx_finish(rx_finish),
    .rx_data(rx_data)
);



endmodule 

