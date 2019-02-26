----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 01:51:21 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
  port(
    btn: in std_logic_vector(5 downto 0);
    clk: in std_logic;
    led: out std_logic_vector(15 downto 0)
  );
end top;

architecture Behavioral of top is

component mpg
  port (
    clk: in std_logic;
    btn: in std_logic;
    enable: out std_logic
  );
end component;
signal counter: std_logic_vector(2 downto 0) := (others => '0');
signal codes_ocd: std_logic_vector(7 downto 0) := (others => '0');
signal mpg_out: std_logic;
begin
  divider: process(clk)
  begin
    if rising_edge(clk) then
      if mpg_out = '1' then
        counter <= counter + 1;
      end if;
    end if;
  end process;
  
  decoder: process(counter)
  begin
   case counter is
      when "000"  => led(7 downto 0) <= "00000001";
      when "001"  => led(7 downto 0) <= "00000010";
      when "010"  => led(7 downto 0) <= "00000100";
      when "011"  => led(7 downto 0) <= "00001000";
      when "100"  => led(7 downto 0) <= "00010000";
      when "101"  => led(7 downto 0) <= "00100000";
      when "110"  => led(7 downto 0) <= "01000000";
      when "111"  => led(7 downto 0) <= "10000000";
      when others => led(7 downto 0) <= "00000000";
   end case;
  end process;
  
  comp: mpg port map(
    btn => btn(0), 
    clk => mpg_out, 
    enable => mpg_out);
end Behavioral;   