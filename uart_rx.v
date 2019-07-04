module uart_rx(clk_in,rx_en,rst,rx_serial_data,rx_finish,rx_data);

input wire clk_in;
input wire rx_en;
input wire rst;

input wire rx_serial_data;
output wire rx_finish;
output reg[7:0] rx_data;

// Get The RX sync Signal
// Double Latch The Input
reg rx_serial_data_r,rx_serial_data_r2,rx_serial_data_r3;

always@(posedge clk_in) begin
    if(rst) begin
        rx_serial_data_r <= 1;
        rx_serial_data_r2 <= 1;
        rx_serial_data_r3 <= 1;
    end 
    else if (rx_en == 1) begin
        rx_serial_data_r <= rx_serial_data;
        rx_serial_data_r2 <= rx_serial_data_r;
        rx_serial_data_r3 <= rx_serial_data_r2;
    end
end

wire rx_sync = rx_serial_data_r3;

parameter IDLE = 1'b0;
parameter READ = 1'b1;

reg state;
reg[3:0] sample_cnt;
reg[2:0] rx_cnt;

always @(posedge clk_in) begin
    if (rst) begin
        sample_cnt <= 0;
        rx_cnt <= 0;
        rx_data <= 0;
        state <= IDLE;
    end

    else if (rx_en == 1) begin

        case(state)
            IDLE: begin
            
                rx_cnt <= 0;
                // Justify When To Start Read
                if (rx_sync == 0) begin // Testing The RX Serial 0 (probably START BIT) 
                    sample_cnt <= sample_cnt + 1;

                    if (sample_cnt == 4'd7) begin   // More Than Half The Cycle Is 0
                        state <= READ;      // Enter Read-State
                    end 
                end

                else begin
                    sample_cnt <= 0;
                end

            end
            READ:  begin

                sample_cnt <= sample_cnt+1;

                if (sample_cnt == 4'd7) begin   
                // Dont pose "sample_cnt == 4'd15 here 
                // because the signal may not last till end
                // (cause the clk_tx & clk_rx is not *16 accurately), 
                // we could just sample The signal in middle"

                    rx_cnt <= rx_cnt + 1;

                    if (rx_cnt == 4'd7) begin
                        state <= IDLE;
                        rx_finish_r <= 1;
                    end

                    else begin
                        state <= state;
                        rx_finish_r <= 0;
                    end

                    case(rx_cnt)
                        3'd0: rx_data[0] <= rx_sync;
                        3'd1: rx_data[1] <= rx_sync;
                        3'd2: rx_data[2] <= rx_sync;
                        3'd3: rx_data[3] <= rx_sync;
                        3'd4: rx_data[4] <= rx_sync;
                        3'd5: rx_data[5] <= rx_sync;
                        3'd6: rx_data[6] <= rx_sync;
                        3'd7: rx_data[7] <= rx_sync;
                    endcase

                end
            end
        endcase
    end   
end

// Denote The rx_finish Flag
reg rx_finish_r, rx_finish_r2, rx_finish_r3;

always@(posedge clk_in) begin
    if (rst) begin
        rx_finish_r2 <= 0;
        rx_finish_r3 <= 0;
    end
    else begin
        rx_finish_r2 <= rx_finish_r;
        rx_finish_r3 <= rx_finish_r2;
    end
end

assign rx_finish = rx_finish_r2 & ~rx_finish_r3;


endmodule