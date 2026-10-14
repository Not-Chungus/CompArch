onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color White /testbench/clk
add wave -noupdate /testbench/rst_n
add wave -noupdate /testbench/DUT/pc_next
add wave -noupdate /testbench/DUT/pc
add wave -noupdate /testbench/DUT/pc_plus_4
add wave -noupdate /testbench/DUT/instruction
add wave -noupdate /testbench/DUT/PC/pc_next
add wave -noupdate /testbench/DUT/PC/pc
add wave -noupdate /testbench/DUT/Instr_mem/wr_en
add wave -noupdate -expand /testbench/DUT/Reg_file/register_file
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {159 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {210157 ps}
