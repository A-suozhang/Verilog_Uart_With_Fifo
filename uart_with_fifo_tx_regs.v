module uart_with_fifo_tx_regs(clk_in,rst,data2send_valid,tx_serial_data);
// ---------------------------------
// Sequentially Loading Data From A Set Of Local Regs
// Then Wrting Them Into UART_TX
// Output tx_serial_data

// - Data2Send Valid Denotes When The Regs' Value Is Valud


input wire clk_in;
input wire rst;
input wire data2send_valid;

output wire tx_serial_data;

wire full,empty,almost_empty,almost_full;
wire tx_en,tx_finish;

wire[9:0] data_count;


// If Data2Send Valid
// If The FIFO Is Not Almost FULL
// Fill The data Into DIN & WR_EN HIGH
parameter data2Send_num = 4'd14;    // Actual Number data2send_num+1
reg[3:0] data2Send_cnt;             // Adjust Bit Lenfth According To data2Send_num
reg[7:0] data2Send[0:data2Send_num];  // The Mem Set For data2Send
reg fifo_write;

reg write_to_full_fifo_error;

reg[7:0] din;


// ---------------FIFO WRITE SCHEME-------------------------
reg wr_en;

always@(posedge clk_in) begin

    if (rst) begin
        fifo_write <= 0;
        write_to_full_fifo_error <= 0;
        data2Send[0] = 8'b10000000;
        data2Send[1] = 8'b00000001;
        data2Send[2] = 8'b00000011;
        data2Send[3] = 8'b00000101;
        data2Send[4] = 8'b00001001;
        data2Send[5] = 8'b00010001;
        data2Send[6] = 8'b00100001;
        data2Send[7] = 8'b01000001;
        data2Send[8] = 8'b10000001;
        data2Send[9] = 8'b01000001;
        data2Send[10] = 8'b00010001;
        data2Send[11] = 8'b00010001;
        data2Send[12] = 8'b00001000;
        data2Send[13] = 8'b00000100;
        data2Send[14] = 8'b00000010;
        // data2Send[15] = 8'b00000001;
        data2Send_cnt <= 0;
        din <= 0;
    end

    else begin
        case(fifo_write)
            1'b0: begin
                wr_en <= 0;
                // If Input Data Are Valid Begin 
                if (data2send_valid) begin
                    fifo_write <= 1;
                    if (almost_full) begin
                        write_to_full_fifo_error <= 1;
                    end
                end  
            end
            1'b1: begin
                wr_en <= 1;
                din <= data2Send[data2Send_cnt];    // Feed The Current data2send 2 d_in
                data2Send_cnt <= data2Send_cnt +1;
               
                // Finishing Writing 
                if (data2Send_cnt == data2Send_num) begin
                    data2Send_cnt <= 0;
                    fifo_write <= 0;         
                end       
                 // Delay 1 Cycle So The data2send[0] could Be Loaded
                  
            end

        endcase
        
    end

end

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

reg[7:0] rx_data_valid;
always@(posedge clk_in) begin
    if (rst) begin
        rx_data_valid <= 0;
    end 
    else begin
        if (rx_finish) begin
            rx_data_valid <= rx_data;
        end 
    end
end



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

uart_tx uart_tx0(
    .clk_in(clk_in),
    .tx_en(tx_en),
    .rst(rst),
    .tx_data_en(rd_en),    //rd_en Sync With TX_DATA_EN
    .tx_data_in(tx_data_in),
    .tx_finish(tx_finish),
    .tx_serial_data(tx_serial_data)
);

wire[7:0] rx_data;
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
