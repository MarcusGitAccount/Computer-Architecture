----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2019 12:17:03 PM
-- Design Name: 
-- Module Name: register_file - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Implementation of a register file of 16 x 16
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
  port (
    ra1, ra2, ra3: in  std_logic_vector(2 downto 0);   -- read addresses
    rd1, rd2, rd3: out std_logic_vector(15 downto 0);  -- read data
    wa: in std_logic_vector(2 downto 0);          -- write address
    wd: in std_logic_vector(15 downto 0);         -- write data
    clk, regwr, enable: in std_logic              -- clock and write enabled
  );
end register_file;

architecture Behavioral of register_file is
type reg_file_data is array(7 downto 0) of std_logic_vector(15 downto 0);
  
signal mem_data: reg_file_data := (others => x"0000");

begin
  memory_logic: process(clk, regwr, ra1, ra2, ra3, wa, wd, enable)
  begin
    if falling_edge(clk) then -- change made for MIPS pipeline
      if regwr = '1' then
        if enable = '1' then
          mem_data(conv_integer(wa)) <= wd;
        end if;
      end if;
    end if;
    
    rd1 <= mem_data(conv_integer(ra1));
    rd2 <= mem_data(conv_integer(ra2));
    rd3 <= mem_data(conv_integer(ra3)); -- leds debugging port
  end process;
end Behavioral;
