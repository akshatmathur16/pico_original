onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/top/clk
add wave -noupdate /testbench/top/resetn
add wave -noupdate /testbench/top/trap
add wave -noupdate /testbench/top/trace_valid
add wave -noupdate /testbench/top/trace_data
add wave -noupdate /testbench/top/tests_passed
add wave -noupdate /testbench/top/irq
add wave -noupdate /testbench/top/count_cycle
add wave -noupdate /testbench/top/mem_axi_awvalid
add wave -noupdate /testbench/top/mem_axi_awready
add wave -noupdate /testbench/top/mem_axi_awaddr
add wave -noupdate /testbench/top/mem_axi_awprot
add wave -noupdate /testbench/top/mem_axi_wvalid
add wave -noupdate /testbench/top/mem_axi_wready
add wave -noupdate /testbench/top/mem_axi_wdata
add wave -noupdate /testbench/top/mem_axi_wstrb
add wave -noupdate /testbench/top/mem_axi_bvalid
add wave -noupdate /testbench/top/mem_axi_bready
add wave -noupdate /testbench/top/mem_axi_arvalid
add wave -noupdate /testbench/top/mem_axi_arready
add wave -noupdate /testbench/top/mem_axi_araddr
add wave -noupdate /testbench/top/mem_axi_arprot
add wave -noupdate /testbench/top/mem_axi_rvalid
add wave -noupdate /testbench/top/mem_axi_rready
add wave -noupdate /testbench/top/mem_axi_rdata
add wave -noupdate /testbench/top/cycle_counter
add wave -noupdate -radix ascii /testbench/top/uut/picorv32_core/dbg_ascii_state
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/current_pc
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/next_pc
add wave -noupdate /testbench/top/uut/picorv32_core/cpuregs_rs1
add wave -noupdate /testbench/top/uut/picorv32_core/cpuregs_rs2
add wave -noupdate /testbench/top/uut/picorv32_core/cpu_state_trap
add wave -noupdate -radix binary /testbench/top/uut/picorv32_core/cpu_state
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h1/data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h1/encoded_data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h1/parity_bits
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h2/data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h2/encoded_data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h2/parity_bits
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h3/data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h3/encoded_data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h3/parity_bits
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h4/data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h4/encoded_data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h4/parity_bits
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h5/data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h5/encoded_data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h5/parity_bits
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h6/data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h6/encoded_data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h6/parity_bits
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h7/data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h7/encoded_data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h7/parity_bits
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h8/data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h8/encoded_data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h8/parity_bits
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h11/data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h11/encoded_data
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h11/parity_bits
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h22/reg_op1
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h22/rec_reg_op1
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h22/reg_op1_a
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h22/syndrome
add wave -noupdate -radix hexadecimal /testbench/top/uut/picorv32_core/h22/syndrome_encoded
add wave -noupdate /testbench/top/uut/picorv32_core/in_err2
add wave -noupdate /testbench/top/uut/picorv32_core/in_err1
add wave -noupdate /testbench/top/uut/picorv32_core/in_err2
add wave -noupdate /testbench/in_err
add wave -noupdate /testbench/in_err1
add wave -noupdate /testbench/in_err2
add wave -noupdate /testbench/top/in_err
add wave -noupdate /testbench/top/in_err1
add wave -noupdate /testbench/top/in_err2
add wave -noupdate /testbench/top/uut/picorv32_core/cpu_state
add wave -noupdate /testbench/top/uut/picorv32_core/cpu_state_invalid
add wave -noupdate /testbench/top/uut/picorv32_core/syndrome
add wave -noupdate /testbench/top/uut/picorv32_core/syndrome_encoded
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2275612719 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 313
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {877842 ns}
