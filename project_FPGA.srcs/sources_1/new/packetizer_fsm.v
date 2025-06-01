module packetizer_fsm (
    input wire clk,
    input wire rst,                   // Active-high synchronous reset
    input wire fifo_empty,
    input wire tx_ready,
    input wire [7:0] fifo_data_out,
    output reg fifo_rd_en,
    output reg serial_out,
    output reg tx_busy
);

    // FSM state encoding
    parameter IDLE      = 2'b00;
    parameter READ      = 2'b01;
    parameter SEND      = 2'b10;
    parameter WAIT_DONE = 2'b11;

    reg [1:0] state, next_state;

    // Internal signals
    reg [9:0] shift_reg;     // 1 start bit + 8 data bits + 1 stop bit
    reg [3:0] bit_count;     // up to 10 bits

    // FSM: Sequential block
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // FSM: Combinational block for state transitions
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (!fifo_empty && tx_ready)
                    next_state = READ;
            end

            READ: begin
                next_state = SEND;
            end

            SEND: begin
                if (bit_count == 4'd9)
                    next_state = WAIT_DONE;
            end

            WAIT_DONE: begin
                if (tx_ready)
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // Output and data path logic
    always @(posedge clk) begin
        if (rst) begin
            fifo_rd_en  <= 0;
            serial_out  <= 1'b1; // idle state of UART line is high
            tx_busy     <= 0;
            shift_reg   <= 10'b1111111111;
            bit_count   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    fifo_rd_en  <= 0;
                    serial_out  <= 1'b1;
                    tx_busy     <= 0;
                    bit_count   <= 0;
                end

                READ: begin
                    fifo_rd_en  <= 1;  // trigger FIFO read
                    tx_busy     <= 1;
                    // Load 10-bit shift register: start(0) + data[7:0] + stop(1)
                    shift_reg   <= {1'b1, fifo_data_out, 1'b0};
                end

                SEND: begin
                    fifo_rd_en <= 0;
                    serial_out <= shift_reg[0];
                    shift_reg  <= {1'b1, shift_reg[9:1]}; // shift right, pad stop bit
                    bit_count  <= bit_count + 1;
                end

                WAIT_DONE: begin
                    serial_out <= 1'b1; // line idle
                end

                default: begin
                    fifo_rd_en <= 0;
                    serial_out <= 1'b1;
                    tx_busy    <= 0;
                end
            endcase
        end
    end

endmodule
