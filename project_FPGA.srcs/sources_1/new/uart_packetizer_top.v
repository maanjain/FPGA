module uart_packetizer_top (
    input wire clk,
    input wire rst,
    input wire [7:0] data_in,
    input wire data_valid,
    input wire tx_ready,
    output wire serial_out,
    output wire fifo_full,
    output wire tx_busy
);

    wire [7:0] fifo_data_out;
    wire fifo_empty, fifo_rd_en, data_out_valid;

    // FIFO instance
    fifo u_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(data_valid && !fifo_full),
        .rd_en(fifo_rd_en),
        .data_in(data_in),
        .data_out(fifo_data_out),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty),
        .data_out_valid(data_out_valid)
    );

    // FSM instance
    packetizer_fsm u_fsm (
        .clk(clk),
        .rst(rst),
        .fifo_empty(fifo_empty),
        .tx_ready(tx_ready),
        .fifo_data_out(fifo_data_out),
        .fifo_rd_en(fifo_rd_en),
        .serial_out(serial_out),
        .tx_busy(tx_busy)
    );

endmodule
