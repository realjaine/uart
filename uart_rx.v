// =============================================================================
// Module : uart_rx
// Description : 8N1 UART Receiver (8 data bits, no parity, 1 stop bit)
//               Oversampling factor = 16
//               Baud rate set via BAUD_DIV parameter
// =============================================================================
module uart_rx #(
    parameter BAUD_DIV = 54   // clk_freq / (baud_rate * 16)  e.g. 50MHz/57600/16
)(
    input  wire       clk,        // System clock
    input  wire       rst_n,      // Active-low async reset
    input  wire       rx,         // UART serial input
    // DFT ports
    input  wire       scan_en,    // Scan enable  (muxed_scan)
    input  wire       scan_in,    // Scan chain input
    output wire       scan_out,   // Scan chain output
    // Functional ports
    output reg  [7:0] rx_data,    // Received byte
    output reg        rx_valid    // Pulses HIGH for 1 clk when byte is ready
);

    // -------------------------------------------------------------------------
    // Baud-rate tick generator (x16 oversampling)
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
    // RX synchroniser (2-FF metastability guard)
    // -------------------------------------------------------------------------
    reg rx_sync0, rx_sync1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync0 <= 1'b1;
            rx_sync1 <= 1'b1;
        end else begin
            rx_sync0 <= rx;
            rx_sync1 <= rx_sync0;
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
    reg [3:0]  sample_cnt;   // counts 0-15 oversampling ticks
    reg [3:0]  sample_mid;   // samples at mid-bit (tick 7)
    reg [2:0]  bit_idx;      // which data bit we are receiving
    reg [7:0]  shift_reg;    // shift register

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            sample_cnt <= 4'd0;
            bit_idx    <= 3'd0;
            shift_reg  <= 8'd0;
            rx_data    <= 8'd0;
            rx_valid   <= 1'b0;
        end else begin
            rx_valid <= 1'b0;   // default: de-assert

            case (state)
                // ---------------------------------------------------------
                IDLE: begin
                    if (rx_sync1 == 1'b0) begin   // start-bit detected
                        state      <= START;
                        sample_cnt <= 4'd0;
                    end
                end

                // ---------------------------------------------------------
                START: begin
                    if (baud_tick) begin
                        if (sample_cnt == 4'd7) begin
                            // Mid-point of start bit – verify it is still LOW
                            if (rx_sync1 == 1'b0) begin
                                state      <= DATA;
                                sample_cnt <= 4'd0;
                                bit_idx    <= 3'd0;
                            end else begin
                                state <= IDLE;  // false start
                            end
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                end

                // ---------------------------------------------------------
                DATA: begin
                    if (baud_tick) begin
                        if (sample_cnt == 4'd15) begin
                            sample_cnt          <= 4'd0;
                            shift_reg[bit_idx]  <= rx_sync1;
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
                    if (baud_tick) begin
                        if (sample_cnt == 4'd15) begin
                            sample_cnt <= 4'd0;
                            if (rx_sync1 == 1'b1) begin   // valid stop bit
                                rx_data  <= shift_reg;
                                rx_valid <= 1'b1;
                            end
                            state <= IDLE;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
