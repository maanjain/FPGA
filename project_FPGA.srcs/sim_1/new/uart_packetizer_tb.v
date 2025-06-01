`timescale 1ns/1ps

module uart_packetizer_tb;

    reg clk = 0;
    reg rst = 1;
    reg tx_ready = 1;
    reg data_valid = 0;
    reg [7:0] data_in;

    wire serial_out;
    wire fifo_full, tx_busy;

    uart_packetizer_top uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_valid(data_valid),
        .tx_ready(tx_ready),
        .serial_out(serial_out),
        .fifo_full(fifo_full),
        .tx_busy(tx_busy)
    );

    // Clock generation: 50MHz
    always #10 clk = ~clk;

    initial begin
        $dumpfile("uart_packetizer.vcd");
        $dumpvars(0, uart_packetizer_tb);

        #30 rst = 0;

        // Write two data bytes into FIFO
        #20 send_byte(8'hAB);
        #200 send_byte(8'h3C);

        // Wait for transmission to complete
        #2000 $finish;
    end

    task send_byte(input [7:0] byte);
        begin
            data_in = byte;
            data_valid = 1;
            #20;
            data_valid = 0;
        end
    endtask

endmodule
