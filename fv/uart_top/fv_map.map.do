
//input ports
add mapped point clk clk -type PI PI
add mapped point rst_n rst_n -type PI PI
add mapped point scan_en scan_en -type PI PI
add mapped point scan_in scan_in -type PI PI
add mapped point rx rx -type PI PI
add mapped point tx_data[7] tx_data[7] -type PI PI
add mapped point tx_data[6] tx_data[6] -type PI PI
add mapped point tx_data[5] tx_data[5] -type PI PI
add mapped point tx_data[4] tx_data[4] -type PI PI
add mapped point tx_data[3] tx_data[3] -type PI PI
add mapped point tx_data[2] tx_data[2] -type PI PI
add mapped point tx_data[1] tx_data[1] -type PI PI
add mapped point tx_data[0] tx_data[0] -type PI PI
add mapped point tx_start tx_start -type PI PI

//output ports
add mapped point scan_out scan_out -type PO PO
add mapped point rx_data[7] rx_data[7] -type PO PO
add mapped point rx_data[6] rx_data[6] -type PO PO
add mapped point rx_data[5] rx_data[5] -type PO PO
add mapped point rx_data[4] rx_data[4] -type PO PO
add mapped point rx_data[3] rx_data[3] -type PO PO
add mapped point rx_data[2] rx_data[2] -type PO PO
add mapped point rx_data[1] rx_data[1] -type PO PO
add mapped point rx_data[0] rx_data[0] -type PO PO
add mapped point rx_valid rx_valid -type PO PO
add mapped point tx tx -type PO PO
add mapped point tx_busy tx_busy -type PO PO

//inout ports




//Sequential Pins
add mapped point u_rx/sample_cnt[1]/q u_rx_sample_cnt_reg[1]/Q  -type DFF DFF
add mapped point u_rx/sample_cnt[2]/q u_rx_sample_cnt_reg[2]/Q  -type DFF DFF
add mapped point u_rx/sample_cnt[3]/q u_rx_sample_cnt_reg[3]/Q  -type DFF DFF
add mapped point u_rx/bit_idx[1]/q u_rx_bit_idx_reg[1]/Q  -type DFF DFF
add mapped point u_tx/bit_idx[2]/q u_tx_bit_idx_reg[2]/Q  -type DFF DFF
add mapped point u_rx/bit_idx[2]/q u_rx_bit_idx_reg[2]/Q  -type DFF DFF
add mapped point u_rx/state[1]/q u_rx_state_reg[1]/Q  -type DFF DFF
add mapped point u_rx/shift_reg[0]/q u_rx_shift_reg_reg[0]/Q  -type DFF DFF
add mapped point u_rx/sample_cnt[0]/q u_rx_sample_cnt_reg[0]/Q  -type DFF DFF
add mapped point u_rx/sample_cnt[0]/q u_rx_sample_cnt_reg[0]/QN  -type DFF DFF
add mapped point u_rx/shift_reg[4]/q u_rx_shift_reg_reg[4]/Q  -type DFF DFF
add mapped point u_rx/state[0]/q u_rx_state_reg[0]/Q  -type DFF DFF
add mapped point u_rx/bit_idx[0]/q u_rx_bit_idx_reg[0]/Q  -type DFF DFF
add mapped point u_rx/shift_reg[2]/q u_rx_shift_reg_reg[2]/Q  -type DFF DFF
add mapped point u_rx/shift_reg[6]/q u_rx_shift_reg_reg[6]/Q  -type DFF DFF
add mapped point u_tx/tx/q u_tx_tx_reg/Q  -type DFF DFF
add mapped point u_rx/shift_reg[1]/q u_rx_shift_reg_reg[1]/Q  -type DFF DFF
add mapped point u_rx/shift_reg[5]/q u_rx_shift_reg_reg[5]/Q  -type DFF DFF
add mapped point u_tx/baud_cnt[5]/q u_tx_baud_cnt_reg[5]/Q  -type DFF DFF
add mapped point u_tx/bit_idx[1]/q u_tx_bit_idx_reg[1]/Q  -type DFF DFF
add mapped point u_rx/shift_reg[7]/q u_rx_shift_reg_reg[7]/Q  -type DFF DFF
add mapped point u_rx/shift_reg[3]/q u_rx_shift_reg_reg[3]/Q  -type DFF DFF
add mapped point u_tx/bit_idx[0]/q u_tx_bit_idx_reg[0]/Q  -type DFF DFF
add mapped point u_tx/state[0]/q u_tx_state_reg[0]/Q  -type DFF DFF
add mapped point u_tx/baud_cnt[4]/q u_tx_baud_cnt_reg[4]/Q  -type DFF DFF
add mapped point u_rx/rx_data[2]/q u_rx_rx_data_reg[2]/Q  -type DFF DFF
add mapped point u_tx/sample_cnt[3]/q u_tx_sample_cnt_reg[3]/Q  -type DFF DFF
add mapped point u_rx/rx_data[6]/q u_rx_rx_data_reg[6]/Q  -type DFF DFF
add mapped point u_rx/rx_data[7]/q u_rx_rx_data_reg[7]/Q  -type DFF DFF
add mapped point u_rx/rx_data[0]/q u_rx_rx_data_reg[0]/Q  -type DFF DFF
add mapped point u_rx/rx_data[1]/q u_rx_rx_data_reg[1]/Q  -type DFF DFF
add mapped point u_rx/rx_data[4]/q u_rx_rx_data_reg[4]/Q  -type DFF DFF
add mapped point u_rx/rx_data[3]/q u_rx_rx_data_reg[3]/Q  -type DFF DFF
add mapped point u_rx/rx_data[5]/q u_rx_rx_data_reg[5]/Q  -type DFF DFF
add mapped point u_tx/state[1]/q u_tx_state_reg[1]/Q  -type DFF DFF
add mapped point u_rx/rx_valid/q u_rx_rx_valid_reg/Q  -type DFF DFF
add mapped point u_tx/sample_cnt[1]/q u_tx_sample_cnt_reg[1]/Q  -type DFF DFF
add mapped point u_tx/sample_cnt[2]/q u_tx_sample_cnt_reg[2]/Q  -type DFF DFF
add mapped point u_tx/baud_cnt[3]/q u_tx_baud_cnt_reg[3]/Q  -type DFF DFF
add mapped point u_tx/sample_cnt[0]/q u_tx_sample_cnt_reg[0]/Q  -type DFF DFF
add mapped point u_tx/sample_cnt[0]/q u_tx_sample_cnt_reg[0]/QN  -type DFF DFF
add mapped point u_tx/baud_cnt[2]/q u_tx_baud_cnt_reg[2]/Q  -type DFF DFF
add mapped point u_tx/baud_cnt[1]/q u_tx_baud_cnt_reg[1]/Q  -type DFF DFF
add mapped point u_tx/baud_cnt[0]/q u_tx_baud_cnt_reg[0]/Q  -type DFF DFF
add mapped point u_tx/tx_busy/q u_tx_tx_busy_reg/Q  -type DFF DFF
add mapped point u_tx/shift_reg[3]/q u_tx_shift_reg_reg[3]/Q  -type DFF DFF
add mapped point u_tx/shift_reg[2]/q u_tx_shift_reg_reg[2]/Q  -type DFF DFF
add mapped point u_tx/shift_reg[4]/q u_tx_shift_reg_reg[4]/Q  -type DFF DFF
add mapped point u_tx/shift_reg[5]/q u_tx_shift_reg_reg[5]/Q  -type DFF DFF
add mapped point u_tx/shift_reg[0]/q u_tx_shift_reg_reg[0]/Q  -type DFF DFF
add mapped point u_tx/shift_reg[1]/q u_tx_shift_reg_reg[1]/Q  -type DFF DFF
add mapped point u_tx/shift_reg[7]/q u_tx_shift_reg_reg[7]/Q  -type DFF DFF
add mapped point u_tx/shift_reg[6]/q u_tx_shift_reg_reg[6]/Q  -type DFF DFF
add mapped point u_tx/baud_tick/q u_tx_baud_tick_reg/Q  -type DFF DFF
add mapped point u_rx/rx_sync1/q u_rx_rx_sync1_reg/Q  -type DFF DFF
add mapped point u_rx/rx_sync0/q u_rx_rx_sync0_reg/Q  -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
