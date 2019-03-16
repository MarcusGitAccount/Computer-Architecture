----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2019 09:13:26 PM
-- Design Name: 
-- Module Name: rom - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: 256 x 16 ROM implementation
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
  port (
    addr: in std_logic_vector(7 downto 0);
    rout: out std_logic_vector(15 downto 0);
    ce: in std_logic
  );
end rom;

architecture Behavioral of rom is
type rom_mem_data is array(255 downto 0) of std_logic_vector(15 downto 0);

-- Function to init each line in the memory with a one_hot(index) vector
  function init_memory return rom_mem_data is
  variable data: rom_mem_data;
  begin
    for index in data'range loop
      data(index) := std_logic_vector(to_unsigned(index, 16));
    end loop;
    return data;
  end init_memory;
  
signal data: rom_mem_data := init_memory;
begin
  rout <= data(conv_integer(addr));
end Behavioral;
