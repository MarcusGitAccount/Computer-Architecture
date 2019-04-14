----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2019 04:20:35 PM
-- Design Name: 
-- Module Name: mem - Behavioral
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
-- RAM implementation for MIPS 16bit unicycle
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mem is
  port (
    clk, enable, MemWrite: in std_logic;
    ram_address: in std_logic_vector(15 downto 0);
    ram_wd: in std_logic_vector(15 downto 0);
    rdata: out std_logic_vector(15 downto 0)
  );
end mem;

architecture Behavioral of mem is

type memdatatype is array(31 downto 0) of std_logic_vector(15 downto 0);
signal mem_data: memdatatype := (
  0 => x"0007", -- element to be searched
  1 => x"0008", -- array size
  2 => x"0000", -- arr[0]
  3 => x"0002", -- arr[1]
  4 => x"0005", -- arr[2]
  5 => x"0005", -- arr[3]
  6 => x"0007", -- arr[4]
  7 => x"000A", -- arr[5]
  8 => x"000F", -- arr[6]
  9 => x"0012", -- arr[7]
 others => x"0000"
);

begin
  memory_logic: process(clk, enable, MemWrite, ram_address, ram_wd)
  begin
    if rising_edge(clk) then
      if MemWrite = '1' then
        if enable = '1' then
          mem_data(conv_integer(ram_address(4 downto 0))) <= ram_wd;
        end if;
      end if;
    end if;
    
    rdata <= mem_data(conv_integer(ram_address(4 downto 0)));
  end process;
end Behavioral;