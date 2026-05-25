-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "12/13/2022 20:00:36"
                                                            
-- Vhdl Test Bench template for design  :  random
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY random_vhd_tst IS
END random_vhd_tst;
ARCHITECTURE random_arch OF random_vhd_tst IS
-- constants
constant C_CLK_PERIOD : time := 20 ns;
                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC :='1';
SIGNAL ready : STD_LOGIC :='0';
SIGNAL count1 : STD_LOGIC :='0';
SIGNAL count2 : STD_LOGIC :='0';
SIGNAL count3 : STD_LOGIC :='0';
SIGNAL was_previous : STD_LOGIC ;
SIGNAL was_next : STD_LOGIC ;
SIGNAL was_select : STD_LOGIC ;
SIGNAL output : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL reset : STD_LOGIC;
COMPONENT random
	PORT (
	clk : IN STD_LOGIC;
	count1 : IN STD_LOGIC;
	ready : OUT STD_LOGIC;
	was_previous : OUT STD_LOGIC;
	was_next : OUT STD_LOGIC;
	was_select : OUT STD_LOGIC;
	count2 : IN STD_LOGIC;
	count3 : IN STD_LOGIC;
	output : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
	reset : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : random
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	ready => ready,
	was_previous => was_previous,
	was_next => was_next,
	was_select => was_select,
	count1 => count1,
	count2 => count2,
	count3 => count3,
	output => output,
	reset => reset
	);
clk <= not clk after C_CLK_PERIOD/2;                                           
always : PROCESS                                              
	                     
BEGIN                                                         
       reset <='1';
	wait for C_CLK_PERIOD;
	reset <='0';
	wait for 10*C_CLK_PERIOD; 
	count1 <='1';
	wait for C_CLK_PERIOD;
	count1 <='0';       
WAIT;                                                        
END PROCESS always;                                          
END random_arch;
