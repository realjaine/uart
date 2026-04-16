// =============================================================================
// Module : uart_top
// Description : Top-level wrapper instantiating uart_rx and uart_tx.
//               Scan chains are stitched: RX chain feeds TX chain.
//               Single scan_in / scan_out pair exposed at top level.
// =============================================================================
module uart_top #(
    parameter BAUD_DIV = 54
)(
    input  wire       clk,
    input  wire       rst_n,
    // DFT ports
    input  wire       scan_en,
    input  wire       scan_in,
    output wire       scan_out,
    // UART RX
    input  wire       rx,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    // UART TX
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output wire       tx,
    output wire       tx_busy
);

    wire scan_mid;   // inter-instance scan wire (RX scan_out -> TX scan_in)

    uart_rx #(.BAUD_DIV(BAUD_DIV)) u_rx (
        .clk      (clk),
        .rst_n    (rst_n),
        .rx       (rx),
        .scan_en  (scan_en),
        .scan_in  (scan_in),
        .scan_out (scan_mid),
        .rx_data  (rx_data),
        .rx_valid (rx_valid)
    );

    uart_tx #(.BAUD_DIV(BAUD_DIV)) u_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .scan_en  (scan_en),
        .scan_in  (scan_mid),
        .scan_out (scan_out),
        .tx_data  (tx_data),
        .tx_start (tx_start),
        .tx       (tx),
        .tx_busy  (tx_busy)
    );

endmodule
