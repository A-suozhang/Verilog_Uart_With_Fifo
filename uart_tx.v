module uart_tx (clk_in, tx_en, rst, tx_data_en, tx_data_in, tx_finish, tx_serial_data);

  input  clk_in;
  input  tx_en;   // Output Of BaudGEN, Denote The Baud RAte
  input  rst;
  input  tx_data_en;  // Denote That The INput Data Is Now Valid
  input[7:0]  tx_data_in;

  output tx_finish;
  output reg tx_serial_data;


parameter IDLE = 1'b0;
parameter SEND = 1'b1;

reg state;

reg[3:0] tx_cnt;    // TX Data Counter
reg tx_finish_r;

always @(posedge clk_in) begin

    if (rst) begin
      state <= IDLE;
      tx_finish_r <= 1'b0;
      tx_serial_data <= 1'b1;
      tx_cnt <= 0;
    end

    else begin
      case(state)
        IDLE: begin
          tx_serial_data <= 1'b1;
          tx_finish_r <= 1'b1;

          if (tx_data_en) begin
            state <= SEND;
          end
          else begin
            state <= IDLE;
          end

        end
        SEND: begin
          tx_finish_r <= 0;
          if (tx_en == 1) begin

            if (tx_cnt < 4'd9) begin
              tx_cnt <= tx_cnt + 1;
            end
            else begin
              tx_cnt <= 0;
              state <= IDLE;
              // tx_finish_r <= 1;
            end

            case(tx_cnt) 
            // SERIAL - NEG
            4'd0: tx_serial_data <= 0; // Start Bit
            4'd1: tx_serial_data <= tx_data_in[0];
            4'd2: tx_serial_data <= tx_data_in[1];
            4'd3: tx_serial_data <= tx_data_in[2];
            4'd4: tx_serial_data <= tx_data_in[3];
            4'd5: tx_serial_data <= tx_data_in[4];
            4'd6: tx_serial_data <= tx_data_in[5];
            4'd7: tx_serial_data <= tx_data_in[6];
            4'd8: tx_serial_data <= tx_data_in[7];
            4'd9: tx_serial_data <= 1; // Stop BIT
            endcase
          end
        end
       endcase
    end    
end

// Capture When Data Transfer IS Over
reg tx_finish_r2, tx_finish_r3;
always @(posedge clk_in) begin
    if (rst) begin
      tx_finish_r2 <= 0;
      tx_finish_r3 <= 0;
    end
    else begin
      tx_finish_r2 <= tx_finish_r;
      tx_finish_r3 <= tx_finish_r2;
    end
end

assign tx_finish = tx_finish_r2 & ~tx_finish_r3;



endmodule