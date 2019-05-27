----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/21/2019 12:43:47 PM
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

component tx_comp is
  port (
    rst, tx_en: in std_logic;
    tx, tx_rdy: out std_logic;
    clk, baud_enable: in std_logic; -- basically baud enable
    tx_data: in std_logic_vector(7 downto 0)
  );
end component;

component mpg is
  port (
    clk: in std_logic;
    btn: in std_logic;
    enable: out std_logic
  );
end component;

constant baud_final: std_logic_vector(13 downto 0) := b"10100010101111"; -- 10415
signal baud_cnt: std_logic_vector(13 downto 0) := (others => '0');
signal baud: std_logic;
signal char: std_logic_vector(7 downto 0); --- := x"41"; -- 'A'
signal tx_en: std_logic := '0';
signal button, tx_ready: std_logic;
signal mpg_counter: std_logic_vector(3 downto 0) := x"0";
begin
  char <= sw(7 downto 0);
  led(7 downto 0) <= sw(7 downto 0);
  --led(15) <= tx_en;
 
  first_button: mpg port map(
    btn => btn(0), 
    clk => clk, 
    enable => button);

  transmitter: tx_comp port map(
    rst => '0',
    tx_rdy => tx_ready,
    tx_en => tx_en,
    tx => tx,
    clk => clk,
    baud_enable => baud,
    tx_data => char
  );

  baud_rate: process(clk)
  begin
    if rising_edge(clk) then
      if baud_cnt = baud_final then
        baud_cnt <= (others => '0');
--        baud <= '1';
      else
        baud_cnt <= baud_cnt + 1;
--        baud <= '0';
      end if;
    end if;
  end process;
  
--  mpg_count: process(clk, button)
--  begin
--    if rising_edge(clk) then
--      if button = '1' then
--        mpg_counter <= mpg_counter + 1;
--      end if;
--    end if;
--  end process;
  
--  led(15 downto 12) <= mpg_counter;
  
  tx_enables: process(clk, button, baud)
  begin
    if rising_edge(clk) then
      if baud = '0' then
        if button = '1' then
          tx_en <= '1';
        end if;
      elsif baud = '1' then
        tx_en <= '0';
      end if;
    end if;
  end process;
  
  baud <= '1' when baud_cnt = baud_final else '0';

--  async baud reset
--  tx_enable: process(clk, button, baud)
--  begin
--    if baud = '1' then
--      tx_en <= '0';
--    elsif rising_edge(clk) then
--      if button = '1' then
--        tx_en <= '1';
--      end if;
--    end if;
--  end process;
end Behavioral;
