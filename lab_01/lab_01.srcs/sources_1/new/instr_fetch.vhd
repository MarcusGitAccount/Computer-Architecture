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
    instr: out std_logic_vector(15 downto 0)
  );
end instr_fetch;

architecture Behavioral of instr_fetch is
  type instr_mem_data_type is array(15 downto 0) of std_logic_vector(15 downto 0);
  signal instructions: instr_mem_data_type := (
    others => (others => '0')
  );
  signal pc: std_logic_vector(15 downto 0) := x"0000";
begin
  next_instr_addr <= pc + 1;
  instr <= instructions(conv_integer(pc));
  
  counter: process(clk, jmp, pcsrc)
  begin
    if rising_edge(clk) then
      if jmp = '1' then
        pc <= branch_addr; -- this is to be calculated outside the instruction fetch component
      elsif pcsrc = '1' then
        pc <= jmp_addr;
      else
        pc <= pc + 1;
      end if;
    end if;
  end process;
end Behavioral;
