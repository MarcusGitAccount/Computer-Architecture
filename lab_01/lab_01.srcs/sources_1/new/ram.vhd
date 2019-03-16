----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2019 09:53:25 PM
-- Design Name: 
-- Module Name: ram - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity ram is
  port(
    we: in std_logic; -- write enable
    data_in: in std_logic_vector(15 downto 0);
    data_out: out std_logic_vector(15 downto 0);
    addr: in std_logic_vector(3 downto 0);
    clk: in std_logic
  );
end ram;

architecture Behavioral of ram is
type reg_file_data is array(15 downto 0) of std_logic_vector(15 downto 0);

-- Function to init each line in the memory with a one_hot(index) vector
  function init_memory return reg_file_data is
  variable data: reg_file_data;
  begin
    for index in data'range loop
      data(index) := std_logic_vector(to_unsigned(index, 16));
    end loop;
    return data;
  end init_memory;
  
signal mem_data: reg_file_data := init_memory;

begin
  memory_logic: process(clk, data_in, we, addr)
  begin
    if rising_edge(clk) then
      if we = '1' then
        mem_data(conv_integer(addr)) <= data_in;
      end if;
    end if;
    
    data_out <= mem_data(conv_integer(addr));
  end process;
end Behavioral;
