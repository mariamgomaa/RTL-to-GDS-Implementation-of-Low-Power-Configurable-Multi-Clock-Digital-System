onerror {resume}
radix define SYS_CTRL_STATES {
    "4'b0000" "IDEAL",
    "4'b0001" "RF_WRITE_ADDRESS_ST",
    "4'b0011" "RF_WRITE_DATA_ST",
    "4'b0010" "RF_READ_ADDRESS_ST",
    "4'b0110" "RF_FIFO_WRITE_ST",
    "4'b0100" "FIFO_WAIT_STATE",
    "4'b0101" "ALU_OPERAND_A_ST",
    "4'b0111" "ALU_OPERAND_B_ST",
    "4'b1111" "ALU_FUN_ST",
    "4'b1110" "ALU_DATA_ST",
    "4'b1100" "ALU_FIFO_LSB_ST",
    "4'b1000" "ALU_FIFO_MSB_ST",
    -default default
}
radix define FSM_STATES {
    "3'b000" "IDLE",
    "3'b001" "START",
    "3'b011" "RECIEVING",
    "3'b010" "PARITY",
    "3'b110" "STOP",
    "3'b100" "EERORCHCK",
    -default default
}
radix define FSM_STATES_TX {
    "3'b000" "IDLE",
    "3'b001" "START",
    "3'b010" "PARITY",
    "3'b011" "TRANSMITION",
    "3'b110" "STOP",
    -default default
}
radix define FSM_STATES_RX {
    "3'b000" "IDLE",
    "3'b001" "START",
    "3'b011" "RECIEVING",
    "3'b010" "PARITY",
    "3'b110" "STOP",
    "3'b100" "EERORCHCK",
    -default default
}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group dut /SYS_TOP_TB/dut/framing_error
add wave -noupdate -expand -group dut /SYS_TOP_TB/dut/parity_error
add wave -noupdate -expand -group dut /SYS_TOP_TB/dut/REF_CLK
add wave -noupdate -expand -group dut /SYS_TOP_TB/dut/RST_N
add wave -noupdate -expand -group dut /SYS_TOP_TB/dut/UART_CLK
add wave -noupdate -expand -group dut /SYS_TOP_TB/dut/UART_RX_IN
add wave -noupdate -expand -group dut /SYS_TOP_TB/dut/UART_TX_O
add wave -noupdate -expand -group ALU /SYS_TOP_TB/dut/u_ALU/A
add wave -noupdate -expand -group ALU /SYS_TOP_TB/dut/u_ALU/ALU_FUN
add wave -noupdate -expand -group ALU /SYS_TOP_TB/dut/u_ALU/ALU_OUT_VALID
add wave -noupdate -expand -group ALU /SYS_TOP_TB/dut/u_ALU/B
add wave -noupdate -expand -group ALU /SYS_TOP_TB/dut/u_ALU/EN
add wave -noupdate -expand -group register_file /SYS_TOP_TB/dut/u_register_file/RdData
add wave -noupdate -expand -group register_file /SYS_TOP_TB/dut/u_register_file/RdData_Valid
add wave -noupdate -expand -group register_file /SYS_TOP_TB/dut/u_register_file/RdEn
add wave -noupdate -expand -group register_file /SYS_TOP_TB/dut/u_register_file/reg_file
add wave -noupdate -expand -group register_file /SYS_TOP_TB/dut/u_register_file/WrData
add wave -noupdate -expand -group register_file /SYS_TOP_TB/dut/u_register_file/WrEn
add wave -noupdate -expand -group control_unit -radix SYS_CTRL_STATES /SYS_TOP_TB/dut/u_SYS_CTRL/current_state
add wave -noupdate -expand -group control_unit -radix SYS_CTRL_STATES /SYS_TOP_TB/dut/u_SYS_CTRL/next_state
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/Address
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/ALU_EN
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/ALU_FUN
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/RdData
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/RdData_Valid
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/RdEn
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/RX_D_VLD
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/RX_P_DATA
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/TX_D_VLD
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/TX_P_DATA
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/WrData
add wave -noupdate -expand -group control_unit /SYS_TOP_TB/dut/u_SYS_CTRL/WrEn
add wave -noupdate -group fifo -radix decimal -childformat {{{/SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem[0]} -radix decimal} {{/SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem[1]} -radix decimal} {{/SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem[2]} -radix decimal} {{/SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem[3]} -radix decimal} {{/SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem[4]} -radix decimal}} -expand -subitemconfig {{/SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem[0]} {-radix decimal} {/SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem[1]} {-radix decimal} {/SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem[2]} {-radix decimal} {/SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem[3]} {-radix decimal} {/SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem[4]} {-radix decimal}} /SYS_TOP_TB/dut/u_asynch_fifo/u_FIFO_MEM_CNTRL/mem
add wave -noupdate -group fifo /SYS_TOP_TB/dut/u_asynch_fifo/empty
add wave -noupdate -group fifo /SYS_TOP_TB/dut/u_asynch_fifo/full
add wave -noupdate -group fifo /SYS_TOP_TB/dut/u_asynch_fifo/rd_data
add wave -noupdate -group fifo /SYS_TOP_TB/dut/u_asynch_fifo/wr_data
add wave -noupdate -group Rx -radix FSM_STATES_RX /SYS_TOP_TB/dut/u_UART_TOP/u_UART_RX_TOP/u_UART_RX_FSM/current_state
add wave -noupdate -group Rx -radix FSM_STATES_RX /SYS_TOP_TB/dut/u_UART_TOP/u_UART_RX_TOP/u_UART_RX_FSM/next_state
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/u_UART_RX_TOP/u_UART_RX_FSM/data_sample_en
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/u_UART_RX_TOP/u_UART_RX_FSM/data_valid
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/DATA_VALID
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/PAR_EN
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/par_err
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/PAR_TYPE
add wave -noupdate -group Rx -radix unsigned /SYS_TOP_TB/dut/u_UART_TOP/prescale
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/tx_clk
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/rx_clk
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/RX_IN
add wave -noupdate -group Rx -radix unsigned /SYS_TOP_TB/dut/u_UART_TOP/u_UART_RX_TOP/u_edge_bit_counter/edge_cnt
add wave -noupdate -group Rx -radix unsigned /SYS_TOP_TB/dut/u_UART_TOP/u_UART_RX_TOP/u_edge_bit_counter/edge_cnt_reg
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/u_UART_RX_TOP/u_strt_check/strt_glitch
add wave -noupdate -group Rx -radix unsigned /SYS_TOP_TB/dut/u_UART_TOP/u_UART_RX_TOP/u_edge_bit_counter/bit_cnt
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/u_UART_RX_TOP/u_edge_bit_counter/counter_en
add wave -noupdate -group Rx -radix hexadecimal /SYS_TOP_TB/dut/u_UART_TOP/RX_P_DATA
add wave -noupdate -group Rx /SYS_TOP_TB/dut/u_UART_TOP/stp_err
add wave -noupdate -expand -group tx /SYS_TOP_TB/dut/u_UART_TOP/u_UART_TX_TOP/u_serializer/ser_done
add wave -noupdate -expand -group tx -radix FSM_STATES_TX /SYS_TOP_TB/dut/u_UART_TOP/u_UART_TX_TOP/u_fsm/current_state
add wave -noupdate -expand -group tx -radix FSM_STATES_TX /SYS_TOP_TB/dut/u_UART_TOP/u_UART_TX_TOP/u_fsm/next_state
add wave -noupdate -expand -group tx /SYS_TOP_TB/dut/u_UART_TOP/u_UART_TX_TOP/u_serializer/ser_en
add wave -noupdate -expand -group tx /SYS_TOP_TB/dut/u_UART_TOP/busy
add wave -noupdate -expand -group tx /SYS_TOP_TB/dut/u_UART_TOP/tx_clk
add wave -noupdate -expand -group tx /SYS_TOP_TB/dut/u_UART_TOP/TX_out
add wave -noupdate -expand -group tx /SYS_TOP_TB/dut/u_UART_TOP/u_UART_TX_TOP/DATA_VALID
add wave -noupdate -expand -group tx -radix unsigned /SYS_TOP_TB/dut/u_UART_TOP/u_UART_TX_TOP/P_DATA
add wave -noupdate -expand -group tx -radix binary /SYS_TOP_TB/dut/u_UART_TOP/u_UART_TX_TOP/u_serializer/DATA_reg
add wave -noupdate -expand -group tx /SYS_TOP_TB/dut/u_UART_TOP/u_UART_TX_TOP/u_serializer/ser_data
add wave -noupdate -expand -group tx /SYS_TOP_TB/dut/u_UART_TOP/u_UART_TX_TOP/u_serializer/count
add wave -noupdate -expand -group tx /SYS_TOP_TB/dut/u_UART_TOP/TX_P_DATA
add wave -noupdate -expand -group tx /SYS_TOP_TB/dut/u_UART_TOP/u_UART_TX_TOP/u_serializer/ser_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3581509924 ps} 1} {{Cursor 2} {3303726242 ps} 1} {{Cursor 3} {3672112764 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 150
configure wave -valuecolwidth 101
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {4383254877 ps} {4935935022 ps}
