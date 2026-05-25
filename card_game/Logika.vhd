----------------------------------------------------------------------------------------------------------

-- Title        : Design of a memory card game in VHDL

-- Project      : Memory card game

----------------------------------------------------------------------------------------------------------

-- File         : Logika.vhd

-- Authors      : Aleksandar Petoš, Aleksa Stevanić

-- Subject      : Introduction to VLSI Systems Design

-----------------------------------------------------------------------------------------------------------

-- Description  : This file contains logic behind memory card game which defines states and output signals

-- which are used to draw cards in specific mode and generate counter as timer while playing the game


-----------------------------------------------------------------------------------------------------------

-- Revisions    :

-- Date             Version             Author                  Description

-- 16/12/2022       1                   Aleksandar, Aleksa      Created

-- 20/12/2022       2                   Aleksandar, Aleksa      Simulation success

-- 21/12/2022       3                   Aleksandar, Aleksa      Major revision

------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------------------------------------------------
entity Logika is
port (
ready : in std_logic; --signal koji nam kaze da li su spremne random boje
in_was_previous: in std_logic; --koji signal je inicirao randommizaciju
in_was_next: in std_logic;
in_was_select: in std_logic;
in0 : in std_logic_vector(23 downto 0); --preko svakog od inx(x je broj)
in1 : in std_logic_vector(23 downto 0); --uzimam random boju i smestam na poziciju x
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
select_position:in std_logic; -- okreni kartu;
clk: in std_logic;
reset: in std_logic;
inverted_position: out integer range 0 to 23 ;-- izlazna pozicija okrenute karte
outupside_down_cards: out std_logic_vector (23 downto 0);-- jedinice na poziciji okrenute karte
position_flag : out std_logic; --u nekim stanjima ne zelim da crtam invertovanu bit mapu
finish_final : out std_logic;  --signal koji je aktivan kada smo presli igricu
spent_time_final : out integer range 0 to 255 --signal koji kaze koliko desetina sekundi je proslo
);
end entity;
-----------------------------------------------------------------------------------------------------
architecture Behavioral of Logika is 
-----------------------------------------------------------------------------------------------------
constant C_SECONDS : integer :=200000; -- 65 000 000
-----------------------------------------------------------------------------------------------------
signal upside_down_cards : std_logic_vector (23 downto 0); --jedinice na poziciji okrenute karte
signal position_ready : std_logic; -- govori nam kad je pozicija validna
signal constant_upsidedown : std_logic_vector (23 downto 0); -- stalne promene u sistemu 
signal position : integer range 0 to 23; -- pozicija inverovane karte
type State_t is (stInit, stUpdatePositionPrev, stUpdatePositionNext, stFirstCard, stSecondCard, st5sec, stEnd);
signal state_reg, next_state : State_t; --definicja stanja 

signal firstCard : std_logic; --signal koji kaze da li je selektovana karta prva

type arrayofvector is array (0 to 23) of std_logic_vector (23 downto 0);
signal myarray : arrayofvector; --niz boja

signal positionFlag : std_logic; -- pomocni signal  

signal card1 : std_logic_vector (23 downto 0); --signal koji cuva prvu selektovanu kartu
signal card2 : std_logic_vector (23 downto 0); --signal koji cuva drugu selektovanu kartu
signal card2set : std_logic;

signal counter : integer :=0; --brojac taktova
signal timer : integer :=0; --brojac seknudi (za stanje st5sec)

signal counter_led : integer :=0;  --signali koji se koriste za brojanje desetina sekundi
signal timer_led : integer range 0 to 255 :=0;
signal finish : std_logic :='0';
-----------------------------------------------------------------------------------------------------
begin 
	--uzimamo vrednosti random boja
	myarray(0)<=in0;
	myarray(1)<=in1;
	myarray(2)<=in2;
	myarray(3)<=in3;
	myarray(4)<=in4;
	myarray(5)<=in5;
	myarray(6)<=in6;
	myarray(7)<=in7;
	myarray(8)<=in8;
	myarray(9)<=in9;
	myarray(10)<=in10;
	myarray(11)<=in11;
	myarray(12)<=in12;
	myarray(13)<=in13;
	myarray(14)<=in14;
	myarray(15)<=in15;
	myarray(16)<=in16;
	myarray(17)<=in17;
	myarray(18)<=in18;
	myarray(19)<=in19;
	myarray(20)<=in20;
	myarray(21)<=in21;
	myarray(22)<=in22;
	myarray(23)<=in23;


	--position ready nam govori da li moguce da karta sa date pozicije bude invertovana
	position_ready<= not upside_down_cards(position); 
    position_flag<=positionFlag;
-----------------------------------------------------------------------------------------------------
	STATE_TRANSITION: process (reset, clk) is 
	begin
        if reset = '1' then
            state_reg <= stInit;
		elsif rising_edge(clk) then
            state_reg <= next_state;
		end if;    
	end process STATE_TRANSITION;
-----------------------------------------------------------------------------------------------------	
	CNT_PROCESS: process (clk,reset) is --proces koji određuje poziciju karte sa inv bitmapom
	begin
	if (reset='1') then 
		position<=0;
	else
		if rising_edge(clk) then
			case state_reg is
				when stInit =>
					positionFlag<='1';
					
					if (in_was_next='1' and ready ='1') then 
						position<=1;
					elsif(in_was_previous='1' and ready= '1') then  
						position<=23;
					elsif(in_was_next='0' and in_was_previous='0' and in_was_select='0') then
						position<=0;
					end if;
				when stUpdatePositionNext =>
					positionFlag<='1';
					if (next_positon='1' and position/=23) then
						position<=position+1;
					elsif (next_positon='1' and position=23) then
						position<=0;
					elsif(previous_position='1' and position/=0) then 
						position<=position-1;
					elsif(previous_position='1' and position=0) then
						position<=23;
					end if;------
					if (position_ready='0') then
						if (position=23) then
							position<=0;
						else	
							position <= position + 1;
						end if;
					end if;
				when stUpdatePositionPrev =>
					positionFlag<='1';
					if (previous_position='1' and position /=0)then 
						position<=position-1;
					elsif ( previous_position='1' and position = 0) then 
						position<=23;
					elsif(next_positon='1' and position/=23) then 
						position<=position+1;
					elsif(next_positon='1' and position=23) then
						position<=0;
					end if;-------------------
					if (position_ready='0') then
						if (position=0) then
							position<=23;
						else	
							position <= position - 1;
						end if;
					end if;
				when stFirstCard =>
					positionFlag<='1';
					if (position=23) then
						position<=0;
					else 
						position<=position+1;
					end if;
				when stSecondCard =>
					positionFlag<='1';
					if (position=23) then
						position<=0;
					else 
						position<=position+1;
					end if;
				when st5sec =>
					positionFlag<='0';
				when stEnd =>
					positionFlag<='0';
				end case;        
		end if;
	end if;
	end process;
-----------------------------------------------------------------------------------------------------	
	--proces koji nam govori da li je selektovana karta prva 
	FIRSTCARD_PROCESS: process (clk, reset) is 
	begin
		if (reset='1') then 
			firstCard<='0';
		elsif rising_edge(clk) then
			if (state_reg=stFirstCard) then 
			firstCard<='1';
			elsif (state_reg=stSecondCard)then
			firstCard<='0';
			end if;
		end if;
	end process FIRSTCARD_PROCESS;
-----------------------------------------------------------------------------------------------------	
	NEXT_STATE_LOGIC: process (ready,in_was_select,in_was_next,in_was_previous, timer,card1,card2,upside_down_cards,state_reg, next_positon, previous_position,select_position,position_ready,firstCard) is
    begin
		case (state_reg) is
			when stInit => 
				if (ready='1') then 
					if (in_was_next='1') then 
						next_state<=stUpdatePositionNext;
					elsif (in_was_previous='1') then 
						next_state<=stUpdatePositionPrev;
					elsif (in_was_select='1') then 
						next_state<=stFirstCard;
                    else 
                        next_state<=stInit;
					end if;
				else
					next_state<=stInit;
				end if;
			when stUpdatePositionNext =>
				if (next_positon='1' and position_ready='1') then
					next_state <= stUpdatePositionNext;
				elsif (previous_position= '1' and position_ready ='1') then
					next_state <= stUpdatePositionPrev;
				elsif (select_position = '1' and firstCard ='0') then 
					next_state <= stFirstCard;
				elsif (select_position = '1' and firstCard ='1') then
					next_state <= stSecondCard;
				else
					next_state<=stUpdatePositionNext;
				end if;
			when stUpdatePositionPrev =>
				if (next_positon='1' and position_ready='1') then
					next_state <= stUpdatePositionNext;
				elsif (previous_position= '1' and position_ready ='1') then
					next_state <= stUpdatePositionPrev;
				elsif (select_position = '1' and firstCard ='0') then 
					next_state <= stFirstCard;
				elsif (select_position = '1' and firstCard ='1') then
					next_state <= stSecondCard;
				else
					next_state <=stUpdatePositionPrev;
				end if;
			when stFirstCard =>
				next_state<=stupdatePositionNext;
			when stSecondCard=>
				if (upside_down_cards="111111111111111111111111") then 
					next_state<=stEnd;
				elsif (card1 /=card2) then 
					next_state<=st5sec;
				elsif (card1=card2) then 
					next_state<=stUpdatePositionNext; 
				else
					next_state<=stSecondCard;
				end if;
			when st5sec=>
				if (timer = 5) then 
					next_state<=stUpdatePositionNext;
				else 
					next_state<=st5sec;
				end if;
			when stEnd=>
				next_state<=stEnd;
		end case;    
   end process NEXT_STATE_LOGIC;
-----------------------------------------------------------------------------------------------------	
	PROCESS_TIMER: process (clk,reset) is
	begin
	if reset = '1' then
		counter <=0;
		timer <= 0;
		
	elsif rising_edge(clk) then
		case(state_reg) is
			when st5sec=>
				 
				if counter = C_SECONDS - 1 then
					counter <= 0;
					timer <= timer + 1;
				else
					counter <= counter + 1;
				end if;
				
			when others =>
				timer<=0;
				counter<=0;
		end case;
	end if;
	end process;
-----------------------------------------------------------------------------------------------------	
	--proces koji kontrolise sadržaj registara
	REGISTER_VALUES_PROCESS: process(clk) is 
	begin
		if rising_edge(clk) then 
				if(state_reg=stInit) then
					upside_down_cards<="000000000000000000000000";
					constant_upsidedown<="000000000000000000000000";
					card1<=x"FF00FF";
					card2<=x"FFFFFF";
				elsif(state_reg=stFirstCard) then
					upside_down_cards(position)<='1';
					card1<=myarray(position);
				elsif(state_reg=stSecondCard) then
					upside_down_cards(position)<='1';
					if(card1=card2) then --------------
						constant_upsidedown<=upside_down_cards;
						constant_upsidedown(position)<='1'; 
					end if;
				elsif(state_reg=stUpdatePositionNext) then
					if(position_ready='1' and firstCard='1') then
						card2<=myarray(position);                                                 
					end if;
				elsif(state_reg=stUpdatePositionPrev) then
					if(position_ready='1' and firstCard='1') then 
						card2<=myarray(position);
					end if;
				elsif(state_reg=st5sec) then 				
					if (timer=5) then
						upside_down_cards<=constant_upsidedown;
					end if;
				end if;
		end if;
	
	end process;
-----------------------------------------------------------------------------------------------------	
	
	outupside_down_cards<=upside_down_cards;
-----------------------------------------------------------------------------------------------------	
	OUTPUT_LOGIC_PROCESS:process(clk) is 
	begin
		if rising_edge(clk) then 
			if (position_ready='1') then
				inverted_position<=position;
			end if;
		end if;
	end process;
-----------------------------------------------------------------------------------------------------		
	--proces koji broji desetine sekundi 
	FINISH_COUNTER_PROCESS:process(clk,reset) is 
	begin 
	if (reset='1') then 
		counter_led <=0;
		timer_led <=0;
		finish <='0';

	elsif rising_edge(clk) then 
		if (state_reg/=stEnd) then 
			counter_led<=counter_led+1;
	
		if (counter_led>=10*C_SECONDS) then 
				timer_led<=timer_led+1;
                counter_led <=0;
		end if;
		elsif (state_reg<=stEnd) then
			finish<='1';
		end if;
		
	end if;
	end process;
		finish_final<=finish;
		spent_time_final<=timer_led;	 

-----------------------------------------------------------------------------------------------------
end Behavioral;