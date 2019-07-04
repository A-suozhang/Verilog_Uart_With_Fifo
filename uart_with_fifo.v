module uart_with_fifo_top(Sys_clk, rst_n,SW3,RX,TX,led_on);
// ------------------------------
// A Module For Testing Uart_With_FIFO
// SW5 TX
// SW6 RX
// Acquiring Data Sent From RX
// Passing FIFO ADD ONE
// Then Sending Back Through TX
// ------------------------------
input wire Sys_clk;
input wire rst_n;
input wire SW3;
input wire RX;
output wire TX;
output wire led_on;

assign led_on = ~SW3;   // Using Led To Denote

// --------------------- MAIN LOGIC ------------------------
// Reading From uart_with_fifo_rx
wire[7:0] local_data;
reg[2:0] wait_time;
reg rd_en,wr_en;
reg state;

assign local_data = dout;

always@(posedge clk_out1) begin
    if(rst) begin
      state <= 0;
      rd_en <= 0;
      wait_time <= 0;
    end
    else begin
      case(state) 
          1'b0: begin
              rd_en <= 0;
              wait_time <= wait_time + 1;
              if (wait_time > 3'd5) begin
                if(!empty) begin   // empty will last 2 cycle.making state stop in idle for 1 cycle
                    state <= 1;
                end  
              end
                 
          end
          1'b1: begin
              wait_time <= 0;
              rd_en <= 1;
              state <= 0;
          end
      endcase

      /*
      if (rd_en) begin
          wr_en <= 1;       // Write The local Data Into The TX_FIFO
      end
      else begin
          wr_en <= 0;
      end 
      */

    end
end

//------------- Do Something With local_data 
// -----------  loacal Data is The Data Valid
reg[7:0] processed_data; 
// Adjust From rd_en (1 cycle After rd_en, local_data valid)
// Here rd_en means input data valid
// ------------ WR Data Into FIFO
reg processed_state;
always@(posedge clk_out1) begin
    if (rst) begin
        processed_state <= 0;
    end
    else begin
        case(processed_state) 
          1'b0: begin
              wr_en <= 0;
              if(rd_en) begin
                  processed_state <= 1;
              end
          end
          // Do Process
          1'b1: begin
              processed_data <= local_data + 1;
              wr_en <= 1;  
              processed_state <= 0;
          end
        endcase
    end
end

// -------------The CLK WIZARD
clk_wiz_0 clk_wiz_test 
(
// Clock out ports
.clk_out1(clk_out1),     // output clk_out1
// Status and control signals
.reset(!rst_n), // input reset
.locked(locked),       // output locked
// Clock in ports
.clk_in1(Sys_clk));      // input clk_in1



// --------------The RESET PULSE
wire rst;
//rst is the signal after process
//used for other modules whose clk is not sys_clk
rstpulse rst_inst0(
    .clk_in(Sys_clk),
    .clk_sys(clk_out1),
    .rst_in(rst_n),
    .rst(rst)
);

// The UATY-RX With FIFO
// Receiving rx_Serial_data
// Decode & Fed Into FIFO
// Read The FIFO Outside The Module
wire[7:0] dout;
uart_with_fifo_rx uart_with_fifo_rx_0(
    .clk_in(clk_out1),
    .rst(rst),
    .rx_en(rx_en),
    .rx_serial_data(RX),
    .rd_en(rd_en),
    .dout(dout),
    .almost_empty(almost_empty),
    .empty(empty)
);

// The UART-TX With FIFO
// Reading The Processed Data Into FIFO
// Send Out From tx_serial_data
wire[7:0] din;
assign din = dout;
wire tx_serial_data_0;
uart_with_fifo_tx uart_with_fifo_tx_0(
  .clk_in(clk_out1),
  .rst(rst),
  .tx_en(tx_en),
  .wr_en(wr_en),
  .din(processed_data),
  .full(full),
  .almost_full(almost_full),
  .tx_serial_data(TX)
);

// Generate The Baud
baud_gen baud_gen0(
    .clk_in(clk_out1),
    .tx_en(tx_en),
    .rx_en(rx_en)
);

endmodule