module baud_gen(clk_in,tx_en,rx_en);
// Genrating The Baud For Uart
// Creaating Certain Baud Rate With The Incoming Clk
// The RX CLK is Oversampled 16 

input wire clk_in;
output wire tx_en;
output wire rx_en;

parameter RX_MAX = 100_000_000/(115200 * 16);   // 100MHz as clk_in; 115200 as clk_rate
parameter TX_MAX = 100_000_000/(115200);

reg[15:0] rx_cnt = 0;
reg[15:0] tx_cnt = 0;

assign rx_en = (rx_cnt == 0);
assign tx_en = (tx_cnt == 0);

always @(posedge clk_in) begin
    if (rx_cnt == RX_MAX) begin
      rx_cnt <= 0;
    end
    else begin
      rx_cnt <= rx_cnt+1;
    end
end

always @(posedge clk_in) begin
    if (tx_cnt == TX_MAX) begin
      tx_cnt <= 0;
    end
    else begin
      tx_cnt <= tx_cnt + 1;
    end  
end


endmodule