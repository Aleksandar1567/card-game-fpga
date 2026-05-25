LIBRARY ieee;                                               
USE ieee.std_logic_1164.all; 
use ieee.std_logic_textio.all;
use std.textio.all;     
ENTITY card_game_vhd_tst IS
END card_game_vhd_tst;
ARCHITECTURE card_game_arch OF card_game_vhd_tst IS
-- constants
constant CLK_PERIOD : time := 20 ns  ;
constant VGA_CLK_PERIOD : time := 15.3846 ns   ;                                                 
SIGNAL clk_50Mhz : STD_LOGIC :='1';
SIGNAL next_card_in : STD_LOGIC :='0';
SIGNAL previous_card_in : STD_LOGIC :='0';
SIGNAL reset : STD_LOGIC;
SIGNAL select_card_in : STD_LOGIC :='0';
SIGNAL VGA_B : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL VGA_BLANK_N : STD_LOGIC;
SIGNAL VGA_CLK : STD_LOGIC;
SIGNAL VGA_G : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL VGA_HS : STD_LOGIC;
SIGNAL VGA_R : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL VGA_SYNC_N : STD_LOGIC;
SIGNAL VGA_VS : STD_LOGIC;
SIGNAL led : std_logic_vector(7 downto 0);
COMPONENT card_game
	PORT (
	clk_50Mhz : IN STD_LOGIC;
	next_card_in : IN STD_LOGIC;
	previous_card_in : IN STD_LOGIC;
	reset : IN STD_LOGIC;
	select_card_in : IN STD_LOGIC;
	VGA_B : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	VGA_BLANK_N : OUT STD_LOGIC;
	VGA_CLK : OUT STD_LOGIC;
	VGA_G : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	VGA_HS : OUT STD_LOGIC;
	VGA_R : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	VGA_SYNC_N : OUT STD_LOGIC;
	VGA_VS : OUT STD_LOGIC;
	led : out std_logic_vector(7 downto 0)
	);
END COMPONENT;
BEGIN
	i1 : card_game
	PORT MAP (
-- list connections between master ports and signals
	clk_50Mhz => clk_50Mhz,
	next_card_in => next_card_in,
	previous_card_in => previous_card_in,
	reset => reset,
	select_card_in => select_card_in,
	VGA_B => VGA_B,
	VGA_BLANK_N => VGA_BLANK_N,
	VGA_CLK => VGA_CLK,
	VGA_G => VGA_G,
	VGA_HS => VGA_HS,
	VGA_R => VGA_R,
	VGA_SYNC_N => VGA_SYNC_N,
	VGA_VS => VGA_VS,
	led => led
	);
                                   
clk_50MHz <= not clk_50MHz after CLK_PERIOD/2;                                     
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        reset <= '1';
	wait for 1*VGA_CLK_PERIOD;
	reset <= '0' ; 
	wait for 33 ms;
	next_card_in <='1';
	wait for VGA_CLK_PERIOD;
	next_card_in <='0';
	wait for 16.5 ms;
	wait;              
END PROCESS always;  

process (VGA_CLK)
    file file_pointer: text open WRITE_MODE is "C:\Users\aleks\Desktop\new.txt";
    variable line_el: line;
begin

    if rising_edge(VGA_CLK) then

        -- Write the time
        --write(line_el, now); -- write the line.
	write(line_el, now/ns); -- write the line.
	write(line_el, string'(" ns:"));-- write  line.

        -- Write the hsync
        write(line_el, string'(" "));
        write(line_el, std_logic(VGA_HS)); -- write the line.

        -- Write the vsync
        write(line_el, string'(" "));
        write(line_el, std_logic(VGA_VS)); -- write the line.
	
        -- Write the red
        write(line_el, string'(" "));
        write(line_el, std_logic_vector(VGA_R)); -- write the line.

        -- Write the green
        write(line_el, string'(" "));
        write(line_el, std_logic_vector(VGA_G)); -- write the line.

        -- Write the blue
        write(line_el, string'(" "));
        write(line_el, std_logic_vector(VGA_B)); -- write the line.

        writeline(file_pointer, line_el); -- write the contents into the file.

    end if;
end process;                                                                  
END card_game_arch;
