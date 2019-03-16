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

component rom
  port (
    addr: in std_logic_vector(7 downto 0);
    rout: out std_logic_vector(15 downto 0);
    ce: in std_logic
  );
end component;

component ram
  port(
    we: in std_logic; -- write enable
    data_in: in std_logic_vector(15 downto 0);
    data_out: out std_logic_vector(15 downto 0);
    addr: in std_logic_vector(3 downto 0);
    clk: in std_logic
  );
end component;

signal counter_enable, regwr: std_logic;
signal counter: std_logic_vector(7 downto 0) := (others => '0');
signal wd, rd1, rd2: std_logic_vector(15 downto 0);
signal displayed: std_logic_vector(15 downto 0);
signal rom_out, ram_out: std_logic_vector(15 downto 0);

signal reg_clk_enable, ram_clk_enable: std_logic;
signal clk_reg, clk_ram: std_logic;

begin  
  first_button: mpg port map(
    btn => btn(0), 
    clk => clk, 
    enable => counter_enable);
  
  second_button: mpg port map(
    btn => btn(1),
    clk => clk,
    enable => regwr
  );
  
  ssd_comp: ssd port map(
    clk => clk,
    digits => displayed,
    an => an,
    cat => cat);
  
  reg_file_comp: register_file port map(
    ra1 => counter(3 downto 0), 
    ra2 => counter(3 downto 0),
    rd1 => rd1, 
    rd2 => rd2,
    wa => counter(3 downto 0),
    wd => displayed,
    clk => clk_reg,
    regwr => regwr
  );
  
  rom_comp: rom port map(
    addr => counter,
    rout => rom_out,
    ce => '1'
  );
  
  ram_comp: ram port map(
    we => regwr,
    data_in => displayed,
    data_out => ram_out,
    addr => counter(3 downto 0),
    clk => clk_ram
  );
  
  address_counter: process(counter_enable)
  begin
    if rising_edge(clk) then
      if counter_enable = '1' then
        counter <= counter + 1;
      end if;
    end if;
  end process;
  
  mux_choose_memory: process(sw)
  begin
    case sw(2 downto 0) is
      when "001"  => 
        displayed <= rd1 + rd2;
        reg_clk_enable <= '1';
        ram_clk_enable <= '0';
      when "010"  => 
        displayed <= rom_out;
        reg_clk_enable <= '0';
        ram_clk_enable <= '0';
      when "100"  => 
        displayed <= ram_out(13 downto 0) & b"00";
        reg_clk_enable <= '0';
        ram_clk_enable <= '1';
      when others => 
        displayed <= x"0000";
    end case;
  end process;
  
  led(15 downto 8) <= counter;
  led(2 downto 0) <= sw(2 downto 0);
  
  clk_reg <= clk and reg_clk_enable;
  clk_ram <= clk and ram_clk_enable;
end Behavioral;   