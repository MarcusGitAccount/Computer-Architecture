----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/28/2019 09:23:18 AM
-- Design Name: 
-- Module Name: test_env - Behavioral
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
    an: out std_logic_vector  (3 downto 0);
    rx: in std_logic;
    tx: out std_logic
  );
end test_env;

architecture Behavioral of test_env is
component rx_comp is
  port (
    clk, rst: in std_logic;
    rx, baud_en: in std_logic;
    rx_rdy: out std_logic;
    rx_data: out std_logic_vector(7 downto 0)
  );
end component;

component ssd is
  port (
    digits: in std_logic_vector(15 downto 0);
    clk: in std_logic;
    cat: out std_logic_vector(6 downto 0);
    an: out std_logic_vector(3 downto 0)
  );
end component;

signal counter: std_logic_vector(11 downto 0) := x"000";
signal baud_en: std_logic := '0';
signal digits: std_logic_vector(15 downto 0) := x"0000";
signal rx_rdy: std_logic;
signal rx_data: std_logic_vector(7 downto 0);
constant counter_end: std_logic_vector(11 downto 0) := x"28A"; -- 0 to 650 counter

begin
  leds: ssd port map(
    digits => digits, clk => clk,
    cat => cat, an => an
  );
  
  fsm: rx_comp port map(
    clk => clk, rst => '0',
    baud_en => baud_en, rx => rx,
    rx_data => rx_data,
    rx_rdy => rx_rdy
  );

  digits(7 downto 0) <= rx_data;

  counting: process(clk)
  begin
    if rising_edge(clk) then
      if counter < counter_end then
        counter <= counter + 1;
        baud_en <= '0';
      elsif counter = counter_end then
        counter <= x"000";
        baud_en <= '1';
      end if;
    end if;
  end process;
end Behavioral;
