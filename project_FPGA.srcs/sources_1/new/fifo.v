module fifo (
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [7:0] data_in,
    output reg [7:0] data_out,
    output reg fifo_full,
    output reg fifo_empty,
    output reg data_out_valid
);

    parameter DEPTH = 16;
    parameter ADDR_WIDTH = 4; // log2(16) = 4

    reg [7:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
    reg [ADDR_WIDTH:0] count; // count range = 0 to DEPTH

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            fifo_full <= 0;
            fifo_empty <= 1;
            data_out_valid <= 0;
        end else begin
            // Write operation
            if (wr_en && !fifo_full) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end

            // Read operation
            if (rd_en && !fifo_empty) begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
                data_out_valid <= 1;
            end else begin
                data_out_valid <= 0;
            end

            // Status
            fifo_full <= (count == DEPTH);
            fifo_empty <= (count == 0);
        end
    end

endmodule
