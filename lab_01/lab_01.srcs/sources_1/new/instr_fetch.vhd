----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2019 12:44:37 PM
-- Design Name: 
-- Module Name: instr_fetch - Behavioral
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

entity instr_fetch is
  port (
    branch_addr, jmp_addr: in std_logic_vector(15 downto 0);
    clk, jmp, pcsrc: in std_logic;
    next_instr_addr: out std_logic_vector(15 downto 0);
    instr: out std_logic_vector(15 downto 0);
    
    enable, reset: in std_logic
  );
end instr_fetch;

architecture Behavioral of instr_fetch is
  type instr_mem_data_type is array(32767 downto 0) of std_logic_vector(15 downto 0);
  signal instructions: instr_mem_data_type := (
    0 => b"010_000_001_0000001",
    1 => b"010_000_111_0000000",
    2 => b"000_010_000_010_0_100",
    3 => b"001_001_011_1111111",
    4 => b"001_000_100_0000010",
    5 => b"000_010_011_101_0_000",
    6 => b"000_101_000_101_1_110",
    7 => b"000_101_100_110_0_000",
    8 => b"010_110_110_0000000",
    9 => b"110_010_011_0001000",
    10 => b"100_110_111_0000110",
    11 => b"110_110_111_0000001",
    12 => b"101_110_111_0000010",
    13 => b"001_101_011_1111111",
    14 => b"100_000_000_1110110",
    15 => b"001_101_010_0000001",
    16 => b"100_000_000_1110100",
    17 => b"000_101_000_001_0_000",
    18 => b"100_000_000_0000001",
    19 => b"001_000_001_1111111",
    others => x"0000"
  );
  
signal aux, pc: std_logic_vector(15 downto 0) := x"0000";
begin
  instr <= instructions(conv_integer(pc));
  
  counter: process(clk, jmp, pcsrc, reset)
  begin
    if reset = '1' then
      pc <= x"0000";
    elsif rising_edge(clk) then
      if enable = '1' then
        if jmp = '1' then
          pc <= jmp_addr;
        elsif pcsrc = '1' then
          pc <= branch_addr;
        else
          pc <= pc + 1;
        end if;
      end if;
    end if;
  end process;
  
  aux <= pc + 1;
  next_instr_addr <= aux;
end Behavioral;