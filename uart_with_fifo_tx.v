module uart_with_fifo_tx(clk_in,rst,tx_en,wr_en,din,full,almost_full,tx_serial_data);

input wire clk_in;
input wire rst;
input wire tx_en;
input wire wr_en;
input wire[7:0] din;
output wire full;
output wire almost_full;

output wire tx_serial_data;


// ---------------FIFO READ SCHEME-------------------------
reg rd_en,rd_en_r,rd_en_r2;
wire[7:0] tx_data_in;
reg[1:0] fifo_read;
wire[7:0] dout; 
reg read_from_empty_fifo;

// reg [7:0] wait_time;  Instead Of Waiting, Simplying Detecting FIFO ~EMPTY is Easier And Safer

assign tx_data_in = dout;

always@(posedge clk_in) begin
    if (rst) begin
        fifo_read <= 0;
        read_from_empty_fifo <= 0;
        rd_en <= 0;
        // wait_time <= 0;
    end
    else begin
        rd_en_r <= rd_en;
        rd_en_r2 <= rd_en_r;

        // if (rd_en) begin
        //     tx_data_in <= dout;
        // end 

        // Make Proper RD_EN
        case(fifo_read)
            2'b00: begin
                // wait_time <= wait_time + 1; // Wait A While For Data To Load IN
                //if (wait_time > 8'h0F) begin
                if (!empty) begin
                    rd_en <= 1;
                    fifo_read <= 2'b01; // Activate The Cycle...(To Keep Itself Working)
                end
            end
            2'b01: begin
                rd_en <= 0;
                if (tx_finish) begin     
                // Adding FIFO NOT EMPTY to Avoid Reading A Lot Of Empty Data
                      fifo_read <= 2'b10;    
                end
            end
            2'b10: begin
                if (!empty) begin
                    rd_en <= 1;
                    fifo_read <= 2'b01; 
                end   
            end
        endcase

    end
end  

// --------------- The FIFO -----------------
wire[9:0] data_count;
fifo_generator_0 fifo0 (
  .clk(clk_in),                    // input wire clk
  .srst(rst),                  // input wire srst
  .din(din),                    // input wire [7 : 0] din
  .wr_en(wr_en),                // input wire wr_en
  .rd_en(rd_en),                // input wire rd_en
  .dout(dout),                  // output wire [7 : 0] dout
  .full(full),                  // output wire full
  .almost_full(almost_full),    // output wire almost_full
  .empty(empty),                // output wire empty
  .almost_empty(almost_empty),  // output wire almost_empty
  .data_count(data_count)      // output wire [9 : 0] data_count
);


// -------------- The UART_TX ------------------
uart_tx uart_tx0(
    .clk_in(clk_in),
    .tx_en(tx_en),
    .rst(rst),
    .tx_data_en(rd_en),    //rd_en Sync With TX_DATA_EN
    .tx_data_in(tx_data_in),
    .tx_finish(tx_finish),
    .tx_serial_data(tx_serial_data)
);




endmodule