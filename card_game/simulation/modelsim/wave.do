onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /card_game_vhd_tst/VGA_B
add wave -noupdate /card_game_vhd_tst/VGA_CLK
add wave -noupdate /card_game_vhd_tst/VGA_G
add wave -noupdate /card_game_vhd_tst/VGA_HS
add wave -noupdate /card_game_vhd_tst/VGA_R
add wave -noupdate /card_game_vhd_tst/VGA_VS
add wave -noupdate /card_game_vhd_tst/i1/on_card
add wave -noupdate /card_game_vhd_tst/i1/card
add wave -noupdate /card_game_vhd_tst/i1/hpos
add wave -noupdate /card_game_vhd_tst/i1/vpos
add wave -noupdate /card_game_vhd_tst/i1/i
add wave -noupdate /card_game_vhd_tst/i1/j
add wave -noupdate /card_game_vhd_tst/i1/datamem
add wave -noupdate /card_game_vhd_tst/i1/address
add wave -noupdate /card_game_vhd_tst/i1/color
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15448316920 ps} 0}
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {33600 us}
