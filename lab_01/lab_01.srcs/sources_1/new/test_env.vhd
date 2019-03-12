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

entity test_env is
  port(
    sw: in std_logic_vector(15 downto 0);
    btn: in std_logic_vector(4 downto 0);
    clk: in std_logic;
    led: out std_logic_vector(15 downto 0);
    cat: out std_logic_vector(6 downto 0);
    an: out std_logic_vector  (3 downto 0)
  );
end test_env;

architecture Behavioral of test_env is
component mpg
  port (
    clk: in std_logic;
    btn: in std_logic;
    enable: out std_logic
  );
end component;

component ssd
  port (
    digits: in std_logic_vector(15 downto 0);
    clk: in std_logic;
    cat: out std_logic_vector(6 downto 0);
    an: out std_logic_vector(3 downto 0)
  );
end component;

component  register_file
  port (
    ra1, ra2: in  std_logic_vector(3 downto 0);   -- read addresses
    rd1, rd2: out std_logic_vector(15 downto 0);  -- read data
    wa: in std_logic_vector(3 downto 0);          -- write address
    wd: in std_logic_vector(15 downto 0);         -- write data
    clk, regwr: in std_logic                      -- clock and write enabled
  );
end component;

signal counter: std_logic_vector(2 downto 0) := (others => '0');
signal mpg_out: std_logic;
signal sel: std_logic_vector(1 downto 0) := (others => '0');
signal result: std_logic_vector(15 downto 0) := (others => '0');

begin 
  led(7 downto 0) <= sw(7 downto 0);
  led(14 downto 13) <= sel; -- display current operation
  led(15) <= '1' when result = x"0000" else '0'; -- alu zero flag

  counter_ssd: process(clk, mpg_out)
  begin
    if rising_edge(clk) then
      if mpg_out = '1' then
        sel <= sel + 1;
      end if;
    end if;
  end process;
  
  alu: process(sel, sw(7 downto 0))
  begin
    -- all operands are extended to a size of 16 bits
    case sel is
      -- addition
      when "00" => 
        result <= (x"000" & sw(7 downto 4)) + (x"000" & sw(3 downto 0));
      -- substraction
      when "01" =>
        result <= (x"000" & sw(7 downto 4)) - (x"000" & sw(3 downto 0));
      -- left shift by 2
      when "10" =>
        result <= b"000000" & sw(7 downto 0) & b"00";
      -- right shift by 2
      when "11" =>
        result <= b"0000000000" & sw(7 downto 2);
      when others => 
        result <= (others => '0');
    end case;
  end process;
  
  mpg_comp: mpg port map(
    btn => btn(0), 
    clk => clk, 
    enable => mpg_out);
  
  ssd_comp: ssd port map(
    clk => clk,
    digits => result,
    an => an,
    cat => cat);
end Behavioral;   