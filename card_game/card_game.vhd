----------------------------------------------------------------------------------------------------------

-- Title        : Design of a memory card game in VHDL

-- Project      : Memory card game

----------------------------------------------------------------------------------------------------------

-- File         : card_game.vhd

-- Authors      : Aleksandar Petoš, Aleksa Stevanić

-- Subject      : Introduction to VLSI Systems Design

-----------------------------------------------------------------------------------------------------------

-- Description  : This file contains entity of a card game with all input and output

-- ports, instantation of components random.vhd, diff.vhd, rom.vhd, vga_sync.vhd,

-- pll.vhd, Logika.vhd and processes proWriteProcess, AddressCalculation, CardSelectionProcess      

-- which are used to connect previously instantiated components.

-----------------------------------------------------------------------------------------------------------

-- Revisions    :

-- Date             Version             Author                  Description

-- 17/12/2022       1                   Aleksandar, Aleksa      Created

-- 20/12/2022       2                   Aleksandar, Aleksa      Simulation success

-- 21/12/2022       3                   Aleksandar, Aleksa      Major revision

------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------------------------------------------------	

entity card_game is
    port(
        clk_50Mhz : in std_logic;
        next_card_in : in std_logic;
        previous_card_in : in std_logic;
        select_card_in : in std_logic;
        reset : in std_logic;
        VGA_CLK : out std_logic;
        VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N : out std_logic;
        VGA_R, VGA_G, VGA_B : out std_logic_vector(7 downto 0);
        led : out std_logic_vector(7 downto 0)
    );

end card_game;

-----------------------------------------------------------------------------------------------------	

architecture rtl of card_game is

-----------------------------------------------------------------------------------------------------	

component vga_sync is
    generic (
        -- Default display mode is 1024x768@60Hz
        -- Tested for display mode 800x600@50Hz
        -- Horizontal line
        H_SYNC	: integer := 136;		-- sync pulse in pixels -- 120
        H_BP		: integer := 160;		-- back porch in pixels -- 64
        H_FP		: integer := 24;		-- front porch in pixels -- 56
        H_DISPLAY: integer := 1024;	-- visible pixels -- 800
        -- Vertical line
        V_SYNC	: integer := 6;		-- sync pulse in pixels -- 6
        V_BP		: integer := 29;		-- back porch in pixels -- 23
        V_FP		: integer := 3;		-- front porch in pixels -- 37
        V_DISPLAY: integer := 768		-- visible pixels -- 600
    );
    port (
        clk : in std_logic;
        reset : in std_logic;  
        hsync, vsync : out std_logic;
        sync_n, blank_n : out std_logic;
        hpos : out integer range 0 to H_DISPLAY - 1;
        vpos : out integer range 0 to V_DISPLAY - 1;
        Rin, Gin, Bin : in std_logic_vector(7 downto 0);
        Rout, Gout, Bout : out std_logic_vector(7 downto 0);
        ref_tick : out std_logic
    );
end component;

-----------------------------------------------------------------------------------------------------	

component Logika is
    port (
        ready : in std_logic;
        in_was_previous: in std_logic;
        in_was_next: in std_logic;
        in_was_select: in std_logic;
        in0 : in std_logic_vector(23 downto 0);
        in1 : in std_logic_vector(23 downto 0);
        in2 : in std_logic_vector(23 downto 0);
        in3 : in std_logic_vector(23 downto 0);
        in4 : in std_logic_vector(23 downto 0);
        in5 : in std_logic_vector(23 downto 0);
        in6 : in std_logic_vector(23 downto 0);
        in7 : in std_logic_vector(23 downto 0);
        in8 : in std_logic_vector(23 downto 0);
        in9 : in std_logic_vector(23 downto 0);
        in10 : in std_logic_vector(23 downto 0);
        in11 : in std_logic_vector(23 downto 0);
        in12 : in std_logic_vector(23 downto 0);
        in13 : in std_logic_vector(23 downto 0);
        in14 : in std_logic_vector(23 downto 0);
        in15 : in std_logic_vector(23 downto 0);
        in16 : in std_logic_vector(23 downto 0);
        in17 : in std_logic_vector(23 downto 0);
        in18 : in std_logic_vector(23 downto 0);
        in19 : in std_logic_vector(23 downto 0);
        in20 : in std_logic_vector(23 downto 0);
        in21 : in std_logic_vector(23 downto 0);
        in22 : in std_logic_vector(23 downto 0);
        in23 : in std_logic_vector(23 downto 0);
        next_positon: in std_logic; -- sledeća pozicija
        previous_position: in std_logic;-- prethodna pozicija
        select_position: in std_logic; -- okreni kartu;
        clk: in std_logic;
        reset: in std_logic;
        inverted_position: out integer range 0 to 23 ;-- izlazna pozicija okrenute karte
        outupside_down_cards: out std_logic_vector (23 downto 0);-- jedinice na poziciji okrenute karte
        position_flag : out std_logic;
        finish_final : out std_logic;
        spent_time_final : out integer range 0 to 255
    );
end component;

-----------------------------------------------------------------------------------------------------

component rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
end component;

-----------------------------------------------------------------------------------------------------	

component pll is
    port (
        refclk   : in  std_logic := '0'; --  refclk.clk
        rst      : in  std_logic := '0'; --   reset.reset
        outclk_0 : out std_logic         -- outclk0.clk
    );
end component;

-----------------------------------------------------------------------------------------------------
	
component diff is
	port (
		clk : in std_logic;
		reset : in std_logic;
		tast : in std_logic;
		one : out std_logic
	);
end component;

-----------------------------------------------------------------------------------------------------	

component random is
    port (
        clk, reset: in std_logic;
        output: out std_logic_vector(4 downto 0);
        ready : out std_logic;
        count1 : in std_logic;
        count2  : in std_logic;
        count3 : in std_logic;
        was_previous : out std_logic;
        was_next : out std_logic;
        was_select : out std_logic
        );
end component;

-----------------------------------------------------------------------------------------------------	
-- Važne konstante koje su korišćene

constant CARD_WIDTH : integer := 170;
constant CARD_HEIGHT : integer := 192;
constant V_DISPLAY: integer := 768;
constant H_DISPLAY: integer := 1024;

-----------------------------------------------------------------------------------------------------	
-- Korišćene boje koje će biti permutovane na slučajan način pomoću generatora slučajnih brojeva

type initial_array is array(0 to 23) of std_logic_vector(23 downto 0); 
                                                                       
signal initial_color : initial_array :=(x"00FFFF",x"00FFFF", x"FF00FF",x"FF00FF", 
    x"FFFF00",x"FFFF00", x"000000",x"000000", x"FFFFFF",x"FFFFFF", x"FF0000",x"FF0000",
    x"0000FF",x"0000FF", x"00FF00",x"00FF00", x"7D7D7D",x"7D7D7D", x"7D007D",x"7D007D", 
    x"FFA500",x"FFA500",x"F9D1D0",  x"F9D1D0");

-----------------------------------------------------------------------------------------------------
-- Niz u koji se smeštaju na slučajan način raspoređene boje

type random_array is array(0 to 23) of std_logic_vector(23 downto 0); 

signal random_color : random_array :=(others=>(others =>'0')); 

-----------------------------------------------------------------------------------------------------
-- Signali koji se koriste u procesu iscrtavanja 

signal hpos : integer range 0 to H_DISPLAY - 1;

signal vpos : integer range 0 to V_DISPLAY - 1;

-----------------------------------------------------------------------------------------------------
--Signali koji se koriste u procesu čitanja iz ROM memorije

signal datamem : std_logic_vector(11 downto 0); -- podatak iz memorije

signal address : unsigned(14 downto 0); -- adresa sa koje čitamo podatak

signal Rcard, Gcard, Bcard : std_logic_vector(7 downto 0); -- boja karte, ulazni signali za vga_sync

signal color : std_logic_vector(23 downto 0); -- boja u koju se smeštaju podaci o boji pročitani iz ROM
                                              -- memorije

-----------------------------------------------------------------------------------------------------
-- Signali koji povezuju generator slučajnih brojeva i glavnu strukturu

signal ready : std_logic; -- izlazni signal iz generatora slučajni brojeva, 
                          -- da li je dao validne brojeve
                          
signal random_position : std_logic_vector(4 downto 0); -- izlazni signal iz generatora slučajni brojeva,
                                                       -- slučajni brojevi [0, 24]

signal pom1, pom2, pom3 : std_logic; -- izlazni signali iz generatora slučajni brojeva, 
                                     -- pomoćni ulazni signali za logiku

-----------------------------------------------------------------------------------------------------
-- Izlazni signali iz 3 diferencijatora ivice

signal next_card, previous_card, select_card : std_logic; 

-----------------------------------------------------------------------------------------------------
-- Pomoćni signali koji povezuju logiku i ostatak sistema

signal led_end : integer; -- signal za generisanje vremenskih jedinica za koje se pogode sve karte

signal finish : std_logic; -- signal koji postaje aktivan kada se pogode sve karte

signal flagic : std_logic; -- pomoćni izlazni signal iz logike za iscrtavanje invertovane bit mape

signal selected_card : integer range 0 to 23; -- pomoćni niz koji kaže da je odgovarajuća karta 
                                              -- selektovana

signal inverted_card : std_logic_vector(23 downto 0); -- pomoćni niz koji kaže da odgovarajuća karta 
                                                      -- ima invertovanu bit mapu
                                                      
-----------------------------------------------------------------------------------------------------
-- Ostali signali, pomoćni signali za pozicioniranje karte 

signal clk_vga : std_logic; -- izlazni signal iz pll-a

signal j : integer range 0 to CARD_HEIGHT; -- signal koji precizira gde je pauza između iscrtavanja

signal card : integer range 0 to 23; -- signal koji daje poziciju karte, 0..23

signal n : integer range 0 to 5; -- broj kolona

signal m : integer range 0 to 3; -- broj vrsta/redova

signal counter : integer :=0; -- brojač koji kaže da smo uzeli 24 broja sa random generatora

type position_array is array(0 to 23) of integer range 0 to 23;

signal position : position_array := (0=>1, others =>0); -- važan signal koji povezuje logiku i iscrtavanje
-----------------------------------------------------------------------------------------------------
-- Pomoćni signali za WriteProcess

signal i : integer := 0;

signal indicator : integer :=0; -- pomoćni signal prilikom upisa slučajne boje u niz

signal previous_number : std_logic_vector(4 downto 0) :="00000";

-----------------------------------------------------------------------------------------------------
begin 
Rcard <= color(23 downto 16);
Gcard <= color(15 downto 8);
Bcard <= color(7 downto 0);

-----------------------------------------------------------------------------------------------------	
-- proces u kome se uzima broj sa random generatora i onda se koristi kao pozicija u inicijalnom nizu 12x2 boje
-- da bi se formirao niz nasumično raspoređenih boja

WriteProcess : process(reset, clk_vga) is
begin
    if reset = '1' then
        indicator <= 0;
        counter <= 0;
    elsif rising_edge(clk_vga) then
        if ((next_card = '1' or select_card ='1' or previous_card = '1') and indicator /= 2) then
            indicator <= 1;
        elsif random_position /= "00000" and indicator = 1 then
            indicator <= 2;
            random_color(counter) <= initial_color(to_integer(unsigned(random_position)));
            counter <= counter + 1;
            previous_number <= random_position;
        elsif indicator = 2 and counter /= 24 then
            if previous_number /= random_position then
                if counter <= 23 then
                   previous_number <= random_position;
                   counter <= counter+1;
                   random_color(counter)<=initial_color(to_integer(unsigned(random_position)));
                end if;
            end if;
        end if;
    end if;

end process;
-----------------------------------------------------------------------------------------------------	
-- proces koji povezuje podatke upisane u ROM memoriji i iscrtavanje na ekranu,
-- definisane su pozicije karata
AddressCalculation: process(reset, clk_vga)
	begin
		if (reset = '1') then
			address <= (others => '0');
            j <=0;
		elsif (rising_edge(clk_vga)) then
            if (hpos = H_DISPLAY -1) and vpos = (V_DISPLAY-1) then
                address<=(others =>'0');
            else
                if vpos >=0 and vpos < CARD_HEIGHT then
                    j <=vpos;
                    m <= 0;
                    if hpos >=0 and hpos < CARD_WIDTH then
                        n <=0;
                        address <= address + 1;
                    elsif hpos = CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*vpos, address'length);
                    elsif hpos >CARD_WIDTH and hpos < 2*CARD_WIDTH then
                        n <=1;
                        address <= address + 1;
                    elsif hpos = 2*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*vpos, address'length);
                    elsif hpos >2*CARD_WIDTH and hpos < 3*CARD_WIDTH then
                        n <=2;
                        address <= address + 1;    
                    elsif hpos = 3*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*vpos, address'length);
                    elsif hpos >3*CARD_WIDTH and hpos < 4*CARD_WIDTH then
                        n <=3;
                        address <= address + 1;
                    elsif hpos = 4*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*vpos, address'length);
                    elsif hpos >4*CARD_WIDTH and hpos < 5*CARD_WIDTH then
                        n <=4;
                        address <= address + 1;
                    elsif hpos = 5*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*vpos, address'length);
                    elsif hpos >5*CARD_WIDTH and hpos < 6*CARD_WIDTH then
                        n <=5;
                        address <= address + 1;
                    elsif hpos = 6*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*(vpos+1), address'length);
                    end if;
                elsif vpos = 1*CARD_HEIGHT then
                    address<=(others =>'0');
                elsif vpos >CARD_HEIGHT and vpos < 2*CARD_HEIGHT then
                    j <= vpos - CARD_HEIGHT - 1;
                    m <= 1;
                    if hpos >=0 and hpos < CARD_WIDTH then
                        address <= address + 1;
                        n <=0;
                    elsif hpos = CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >CARD_WIDTH and hpos < 2*CARD_WIDTH then
                        address <= address + 1;
                        n <=1;
                    elsif hpos = 2*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >2*CARD_WIDTH and hpos < 3*CARD_WIDTH then
                    n <=2;
                        address <= address + 1;    
                    elsif hpos = 3*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >3*CARD_WIDTH and hpos < 4*CARD_WIDTH then
                    n <=3;
                        address <= address + 1;
                    elsif hpos = 4*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >4*CARD_WIDTH and hpos < 5*CARD_WIDTH then
                    n <=4;
                        address <= address + 1;
                    elsif hpos = 5*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >5*CARD_WIDTH and hpos < 6*CARD_WIDTH then
                    n <=5;
                        address <= address + 1;
                    elsif hpos = 6*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*(j+1), address'length);
                    end if;
                elsif vpos = 2*CARD_HEIGHT then
                    address<=(others =>'0');
                elsif vpos >2*CARD_HEIGHT and vpos < 3*CARD_HEIGHT then
                    m <= 2;
                    j <= vpos - 2*CARD_HEIGHT - 1;
                    if hpos >=0 and hpos < CARD_WIDTH then
                    n <=0;
                        address <= address + 1;
                    elsif hpos = CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >CARD_WIDTH and hpos < 2*CARD_WIDTH then
                    n <=1;
                        address <= address + 1;
                    elsif hpos = 2*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >2*CARD_WIDTH and hpos < 3*CARD_WIDTH then
                    n <=2;
                        address <= address + 1;    
                    elsif hpos = 3*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >3*CARD_WIDTH and hpos < 4*CARD_WIDTH then
                    n <=3;
                        address <= address + 1;
                    elsif hpos = 4*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >4*CARD_WIDTH and hpos < 5*CARD_WIDTH then
                    n <=4;
                        address <= address + 1;
                    elsif hpos = 5*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >5*CARD_WIDTH and hpos < 6*CARD_WIDTH then
                    n <=5;
                        address <= address + 1;
                    elsif hpos = 6*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*(j+1), address'length);
                    end if;
                elsif vpos = 3*CARD_HEIGHT then
                    address<=(others =>'0');
                elsif vpos >3*CARD_HEIGHT and vpos < 4*CARD_HEIGHT then
                    m <= 3;
                    j <= vpos - 3*CARD_HEIGHT - 1;
                    if hpos >=0 and hpos < CARD_WIDTH then
                    n <=0;
                        address <= address + 1;
                    elsif hpos = CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >CARD_WIDTH and hpos < 2*CARD_WIDTH then
                    n <=1;
                        address <= address + 1;
                    elsif hpos = 2*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >2*CARD_WIDTH and hpos < 3*CARD_WIDTH then
                    n <=2;
                        address <= address + 1;    
                    elsif hpos = 3*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >3*CARD_WIDTH and hpos < 4*CARD_WIDTH then
                    n <=3;
                        address <= address + 1;
                    elsif hpos = 4*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >4*CARD_WIDTH and hpos < 5*CARD_WIDTH then
                    n <=4;
                        address <= address + 1;
                    elsif hpos = 5*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*j, address'length);
                    elsif hpos >5*CARD_WIDTH and hpos < 6*CARD_WIDTH then
                    n <=5;
                        address <= address + 1;
                    elsif hpos = 6*CARD_WIDTH then
                        address<=to_unsigned(CARD_WIDTH*(j+1), address'length);
                    end if;
                end if;
             end if;   
        end if;
	end process;
-----------------------------------------------------------------------------------------------------	
-- važan proces koji pretvara broj vrste i kolone u poziciju selektovane karte 0..23
PositionProcess : process(selected_card, position) is
begin
    case selected_card is
        when 0 =>
            position <=(0 =>1, others=>0);
        when 1 =>
            position <=(1 =>1, others=>0);
        when 2 =>
            position <=(2 =>1, others=>0);
        when 3 =>
            position <=(3 =>1, others=>0);
        when 4 =>
            position <=(4 =>1, others=>0);
        when 5 =>
            position <=(5 =>1, others=>0);
        when 6 =>
            position <=(6 =>1, others=>0); 
        when 7 =>
            position <=(7 =>1, others=>0);
        when 8 =>
            position <=(8 =>1, others=>0);
        when 9 =>
            position <=(9 =>1, others=>0);
        when 10 =>
            position <=(10 =>1, others=>0);
        when 11 =>
            position <=(11 =>1, others=>0);
        when 12 =>
            position <=(12 =>1, others=>0);
        when 13 =>
            position <=(13 =>1, others=>0);
        when 14 =>
            position <=(14 =>1, others=>0);
        when 15 =>
            position <=(15 =>1, others=>0); 
        when 16 =>
            position <=(16 =>1, others=>0);
        when 17 =>
            position <=(17 =>1, others=>0); 
        when 18 =>
            position <=(18 =>1, others=>0);
        when 19 =>
            position <=(19 =>1, others=>0);
        when 20 =>
            position <=(20 =>1, others=>0);
        when 21 =>
            position <=(21 =>1, others=>0);
        when 22 =>
            position <=(22 =>1, others=>0);
        when 23 =>
            position <=(23 =>1, others=>0);   
    end case;
    
end process;
-----------------------------------------------------------------------------------------------------
-- proces zadužen za iscrtavanje, da li iscrtava invertovanu bit mapu, poleđinu karte ili otkrivene karte
DisplayProcess : process(flagic, reset, datamem, position, card, color, inverted_card, random_color) is
begin
	if (reset = '1') then
		color <= (others => '0');
	else
        if (position(card) = 1 and flagic = '1') then
            color <= not datamem(11 downto 8) & x"0" & datamem(7 downto 4) & x"0" & datamem(3 downto 0) & x"0";
        elsif(inverted_card(card) = '1') then
            color <=random_color(card);
        else 
            color <= datamem(11 downto 8) & x"0" & datamem(7 downto 4) & x"0" & datamem(3 downto 0) & x"0";  
        end if;
	end if;
end process;
-----------------------------------------------------------------------------------------------------	
-- proces koji daje kodovanu poziciju karte, pretvara m i n u card, tj ako su m = 0, n = 0, card = 0 itd.         
CardSelectionProcess: process(m, n, card) is
begin
    case m is
        when 0 =>
            case n is
                when 0 =>
                    card <=0;
                when 1 =>
                    card <=1;
                when 2 =>
                    card <=2;
                when 3 =>
                    card <=3;
                when 4 =>
                    card <=4;
                when 5 =>
                    card <=5;      
            end case;
       when 1 =>
            case n is
                when 0 =>
                    card <=6;
                when 1 =>
                    card <=7;
                when 2 =>
                    card <=8;
                when 3 =>
                    card <=9;
                when 4 =>
                    card <=10;
                when 5 =>
                    card <=11;      
            end case;
       when 2 =>
            case n is
                when 0 =>
                    card <=12;
                when 1 =>
                    card <=13;
                when 2 =>
                    card <=14;
                when 3 =>
                    card <=15;
                when 4 =>
                    card <=16;
                when 5 =>
                    card <=17;      
            end case;
       when 3 =>
            case n is
                when 0 =>
                    card <=18;
                when 1 =>
                    card <=19;
                when 2 =>
                    card <=20;
                when 3 =>
                    card <=21;
                when 4 =>
                    card <=22;
                when 5 =>
                    card <=23;      
            end case;          
    end case;
end process;
-----------------------------------------------------------------------------------------------------	
-- instanciranje komponenti
vga_pll : pll port map (clk_50MHz, reset, clk_vga);

sync : vga_sync port map (clk_vga, reset, VGA_HS, VGA_VS, VGA_SYNC_N, VGA_BLANK_N, hpos, vpos, Rcard, Gcard, Bcard, VGA_R, VGA_G, VGA_B);

memory : rom port map(std_logic_vector(address), clk_vga, datamem);

rand : random port map(clk_vga, reset, random_position, ready, previous_card, next_card, select_card, pom1, pom2, pom3);

d1 : diff port map(clk_vga, reset, next_card_in, next_card);

d2 : diff port map(clk_vga, reset, previous_card_in, previous_card);

d3 : diff port map(clk_vga, reset, select_card_in, select_card);

log : Logika port map(ready, pom1, pom2, pom3, random_color(0), random_color(1), random_color(2), random_color(3),
random_color(4), random_color(5), random_color(6), random_color(7), random_color(8),
random_color(9), random_color(10), random_color(11), random_color(12), random_color(13), random_color(14),
random_color(15), random_color(16), random_color(17), random_color(18), random_color(19), random_color(20),
random_color(21), random_color(22), random_color(23),
 next_card, previous_card, select_card, clk_vga, reset, selected_card, inverted_card, flagic, finish, led_end);
 
VGA_CLK <= clk_vga;

led <= not std_logic_vector(to_unsigned(led_end, 8));

-----------------------------------------------------------------------------------------------------	


end rtl;