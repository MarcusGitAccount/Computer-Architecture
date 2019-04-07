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
  type instr_mem_data_type is array(15 downto 0) of std_logic_vector(15 downto 0);
  signal instructions: instr_mem_data_type := (
    0 => x"000F",
    1 => x"00F0",
    2 => x"00FF",
    3 => x"0F00",
    4 => x"0F0F",
    5 => x"0FFF",
    others => (others => '0')
  );
  signal pc: std_logic_vector(15 downto 0) := x"0000";
begin
  next_instr_addr <= pc; -- pc + 1 !!!!!!!!!!
  instr <= instructions(conv_integer(pc));
  
  counter: process(clk, jmp, pcsrc, reset)
  begin
    if reset = '1' then
      pc <= x"0000";
    elsif rising_edge(clk) then
      if enable = '1' then
        if jmp = '1' then
          pc <= jmp_addr; -- this is to be calculated outside the instruction fetch component
        elsif pcsrc = '1' then
          pc <= branch_addr;
        else
          pc <= pc + 1;
        end if;
      end if;
    end if;
  end process;
end Behavioral;
