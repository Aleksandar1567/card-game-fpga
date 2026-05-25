library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity random is
    port (
        clk, reset: in std_logic;
        output: out std_logic_vector(4 downto 0); -- 5-bitni random broj
        ready : out std_logic; -- signal koji se aktivira kada imamo spremna 24 broja
        count1 : in std_logic; -- previous_card
        count2  : in std_logic; -- next_card
        count3 : in std_logic; -- select_card
        was_previous : out std_logic; -- indikator da je došao zahtjev sa ulaza previous_card
        was_next : out std_logic; -- indikator da je došao zahtjev sa ulaza next_card
        was_select : out std_logic -- indikator da je došao zahtjev sa ulaza select_card
        );
end random;

architecture behavioral of random is
    signal St0, St1: std_logic_vector (4 downto 0);
    signal feedback: std_logic;
    signal new_number : std_logic_vector(4 downto 0);
    signal temp :std_logic;
    signal counter : integer := 100; -- brojač koji će generisati signal ready nakon što odbroji 100 taktova
    signal count : std_logic;


begin
    count <='1' when count1='1' or count2='1' or count3='1' else '0';
    new_number <= St0(4 downto 0) when(temp = '1') else (others =>'0');  
    
    RememberProcess : process(clk) is
    begin
        if(rising_edge(clk)) then
           
            if (count1 = '1') then
                was_previous <='1';
                was_next<='0';
                was_select<='0';
            elsif (count2 = '1') then
                was_next <='1';
                was_previous<='0';
                was_select<='0';
            elsif (count3 = '1') then
                was_select <='1';
                was_next <='0';
                was_previous<='0';
            end if;
        end if;
    end process;
    

    StateReg: process (reset, clk)
    begin
        if (reset = '1') then
            St0 <= (0=>'1', others =>'0');
        elsif rising_edge(clk) then
            St0 <= St1;
            if counter = 0 then
                ready <= '1';
            end if;
        end if;
    end process;

    FF : process (clk, count)
    begin
        if(count = '1') then
            if rising_edge(clk) then
                temp <='1';
            end if;
        end if;
    end process;
    

    feedback <= St0(4) xor St0(3) xor St0(2) xor St0(0);
    St1 <= feedback & St0(4 downto 1);
    
    WriteProcess : process(clk) is
    begin 
        if (rising_edge(clk)) then 
            if new_number< "11000" then
                output<=new_number;
            elsif new_number = "11000" then
                output<=(others =>'0');
            end if;
        end if;
    end process;
    
    CounterProcess : process(reset, clk) is
    begin
        if reset ='1' then
            counter <= 100;
        elsif rising_edge(clk) then
            if (count = '1') then
                counter <= counter - 1;
            elsif (counter /=100) then
                counter <= counter - 1;
            end if;
        end if;
    end process;

end behavioral;