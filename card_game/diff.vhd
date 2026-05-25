library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity diff is
	port (
		clk : in std_logic;
		reset : in std_logic;
		tast : in std_logic;
		one : out std_logic
	);
end diff;

architecture behav of diff is
type state is (s0, s1, s2);
signal state_reg, next_state : state;

begin

process (clk, reset)
begin
	if (reset = '1') then
		state_reg <= s0;
	elsif rising_edge(clk) then
		state_reg <= next_state;
	end if;
end process;

process (state_reg, tast)
begin
	case state_reg is
		when s0 =>
			if tast = '0' then
				next_state <= s1;
			else
				next_state <= s0;
			end if;
		when s1 =>
			if tast = '1' then
				next_state <= s2;
			else
				next_state <= s1;
			end if;
		when s2 =>
			next_state <= s0;
	end case;
end process;

one <= '1' when state_reg = s2 else
		 '0';

end behav;