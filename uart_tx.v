// =============================================================================
// Module : uart_tx
// Description : 8N1 UART Transmitter (8 data bits, no parity, 1 stop bit)
//               Oversampling factor = 16  (same baud divider as RX)
// =============================================================================
module uart_tx #(
    parameter BAUD_DIV = 54
)(
    input  wire       clk,
    input  wire       rst_n,
    // DFT ports
    input  wire       scan_en,
    input  wire       scan_in,
    output wire       scan_out,
    // Functional ports
    input  wire [7:0] tx_data,    // Byte to transmit
    input  wire       tx_start,   // Pulse HIGH for 1 clk to begin TX
    output reg        tx,         // UART serial output
    output reg        tx_busy     // HIGH while transmitting
);

    // -------------------------------------------------------------------------
    // Baud-rate tick generator (x16 oversampling; tick every 1/16 bit period)
    // -------------------------------------------------------------------------
    reg [$clog2(BAUD_DIV)-1:0] baud_cnt;
    reg                         baud_tick;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt  <= 0;
            baud_tick <= 1'b0;
        end else begin
            if (baud_cnt == BAUD_DIV - 1) begin
                baud_cnt  <= 0;
                baud_tick <= 1'b1;
            end else begin
                baud_cnt  <= baud_cnt + 1;
                baud_tick <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // State machine
    // -------------------------------------------------------------------------
    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    reg [1:0]  state;
    reg [3:0]  sample_cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            sample_cnt <= 4'd0;
            bit_idx    <= 3'd0;
            shift_reg  <= 8'd0;
            tx         <= 1'b1;   // line idle high
            tx_busy    <= 1'b0;
        end else begin
            case (state)
                // ---------------------------------------------------------
                IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        shift_reg  <= tx_data;
                        state      <= START;
                        sample_cnt <= 4'd0;
                        tx_busy    <= 1'b1;
                    end
                end

                // ---------------------------------------------------------
                START: begin
                    tx <= 1'b0;   // start bit
                    if (baud_tick) begin
                        if (sample_cnt == 4'd15) begin
                            state      <= DATA;
                            sample_cnt <= 4'd0;
                            bit_idx    <= 3'd0;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                end

                // ---------------------------------------------------------
                DATA: begin
                    tx <= shift_reg[bit_idx];
                    if (baud_tick) begin
                        if (sample_cnt == 4'd15) begin
                            sample_cnt <= 4'd0;
                            if (bit_idx == 3'd7) begin
                                state   <= STOP;
                                bit_idx <= 3'd0;
                            end else begin
                                bit_idx <= bit_idx + 1;
                            end
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                end

                // ---------------------------------------------------------
                STOP: begin
                    tx <= 1'b1;   // stop bit
                    if (baud_tick) begin
                        if (sample_cnt == 4'd15) begin
                            sample_cnt <= 4'd0;
                            state      <= IDLE;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                end

                default: begin
                    state <= IDLE;
                    tx    <= 1'b1;
                end
            endcase
        end
    end

endmodule
