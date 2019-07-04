module uart_test_top (Sys_clk, rst_n, SW3, RX, TX, led_on);

// ------------------------------
// A Module For Testing UART VALID
// SW5 - TX
// SW6 - RX
// if SW3 pressed, Send Certain Char Through TX
// Then Wait For 1 Second
// If REceiving Data From RX
// Send It Back 2 
// -------------------------------


input wire Sys_clk;
input wire rst_n;
input wire SW3;
input wire RX;
output wire TX;
output wire led_on;

assign led_on = ~SW3;   // Using Led To Denote

// ------------The MAIN CONTROL LOGIC
reg main_state;
parameter IDLE = 1'b0;
parameter SEND = 1'b1;
parameter wait_time = 50_000_000;
reg[31:0] wait_time_cnt;

always@(posedge clk_out1)  begin
    if (rst) begin
        main_state <= 0;
        tx_data_in <= 0;
        wait_time_cnt <= 0;
    end
    else begin

        case(main_state)
            IDLE: begin
                tx_data_en <= 0;
                if (~SW3) begin
                    wait_time_cnt <= wait_time_cnt + 1;
                end
                else begin
                    wait_time_cnt <= 0;
                end 

                if (wait_time_cnt > wait_time) begin    // Hold SW3 For 0.5s
                    main_state <= SEND;
                    tx_data_in <= 8'b11111111;
                end

                if (rx_finish) begin
                    tx_data_in <= rx_data;
                    main_state <= SEND;
                end
            end
            SEND: begin
                tx_data_en <= 1;
                main_state <= IDLE;
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

// --------------The UART(BASE CLK 100MHZ)
wire[7:0] rx_data;
reg[7:0] tx_data_in;
reg tx_data_en;

uart_tx uart_tx0(
    .clk_in(clk_out1),
    .tx_en(tx_en),
    .rst(rst),
    .tx_data_en(tx_data_en),
    .tx_data_in(tx_data_in),
    .tx_finish(tx_finish),
    .tx_serial_data(TX)
);

uart_rx uart_rx0(
    .clk_in(clk_out1),
    .rx_en(rx_en),
    .rst(rst),
    .rx_serial_data(RX),
    .rx_finish(rx_finish),
    .rx_data(rx_data)
);

baud_gen baud_gen0(
    .clk_in(clk_out1),
    .tx_en(tx_en),
    .rx_en(rx_en)
);




endmodule