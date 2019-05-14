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
    0 => b"010_000_001_0000001",    -- lw $1, $0, 1
    1 => b"010_000_111_0000000",    -- lw $7, $0, 0
    2 => b"000_010_000_010_0_100",  -- and $2, $2, $0
    3 => b"001_001_011_1111111",    -- addi $3, $1, -1
    4 => b"001_000_100_0000010",    -- addi $4, $0, 2
    5 => b"000_010_011_101_0_000",  -- add $5, $2, $3

    6 => b"000_000_000_000_0_000",  -- NoOp
    7 => b"000_000_000_000_0_000",  -- NoOp
    8 => b"000_101_000_101_1_110",  -- sra $5, $5, 1

    9 => b"000_000_000_000_0_000",   -- NoOp
    10 => b"000_000_000_000_0_000",  -- NoOp
    11 => b"000_101_100_110_0_000",  -- add $6, $5, $4

    12 => b"000_000_000_000_0_000",  -- NoOp
    13 => b"000_000_000_000_0_000",  -- NoOp
    14 => b"010_110_110_0000000",    -- lw $6, $6, 0

    15 => b"110_010_011_0011111",    -- bgt $2, $3, 31 => 47
    17 => b"000_000_000_000_0_000",  -- NoOp
    18 => b"000_000_000_000_0_000",  -- NoOp
    19 => b"000_000_000_000_0_000",  -- NoOp

    20 => b"100_110_111_0010101",    -- beq $6, $7, 21 => 42
    21 => b"000_000_000_000_0_000",  -- NoOp
    22 => b"000_000_000_000_0_000",  -- NoOp
    23 => b"000_000_000_000_0_000",  -- NoOp

    24 => b"110_110_111_0000111",    -- bgt $6, $7, 7 => 32
    25 => b"000_000_000_000_0_000",  -- NoOp
    26 => b"000_000_000_000_0_000",  -- NoOp
    27 => b"000_000_000_000_0_000",  -- NoOp

    28 => b"101_110_111_0001000",    -- blt $6, $7, 8 => 37
    29 => b"000_000_000_000_0_000",  -- NoOp
    30 => b"000_000_000_000_0_000",  -- NoOp
    31 => b"000_000_000_000_0_000",  -- NoOp

    32 => b"001_101_011_1111111",   -- addi $3, $5, -1

    33 => b"100_000_000_1100011",    -- beq $0, $0, -29 => 5
    34 => b"000_000_000_000_0_000",  -- NoOp
    35 => b"000_000_000_000_0_000",  -- NoOp
    36 => b"000_000_000_000_0_000",  -- NoOp

    37 => b"001_101_010_0000001",   -- addi $2, $5, 1

    38 => b"100_000_000_1011110",   -- beq $0, $0, -34 => 5
    39 => b"000_000_000_000_0_000",  -- NoOp
    40 => b"000_000_000_000_0_000",  -- NoOp
    41 => b"000_000_000_000_0_000",  -- NoOp

    42 => b"000_101_000_001_0_000", -- add $1, $5, $0

    43 => b"100_000_000_0000001",    -- beq $0, $0, 4 => 48
    44 => b"000_000_000_000_0_000",  -- NoOp
    45 => b"000_000_000_000_0_000",  -- NoOp
    46 => b"000_000_000_000_0_000",  -- NoOp

    47 => b"001_000_001_1111111",   -- addi $1, $0, -1
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