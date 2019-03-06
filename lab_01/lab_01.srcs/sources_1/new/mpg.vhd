----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 12:52:37 PM
-- Design Name: 
-- Module Name: monoimpuls - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Monopulse generator implementation
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mpg is
  port (
    clk: in std_logic;
    btn: in std_logic;
    enable: out std_logic
  );
end mpg;

architecture Behavioral of mpg is
  signal counter: std_logic_vector(15 downto 0) := (others => '0');
  signal q1: std_logic;
  signal q2: std_logic;
  signal q3: std_logic;
begin
  divider: process(clk)
  begin
    if rising_edge(clk) then
      counter <= counter + 1;
    end if;
  end process;
  
  first: process(clk)
  begin
    if rising_edge(clk) then
      if counter = x"FFFF" then
        q1 <= btn;
      end if;
    end if;
  end process;
  
  last_two: process(clk)
  begin
    if rising_edge(clk) then
      q2 <= q1;
      q3 <= q2;
    end if;
  end process;
  
  enable <= q2 and (not q3);
end Behavioral;