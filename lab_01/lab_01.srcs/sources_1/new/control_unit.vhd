----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2019 03:19:03 PM
-- Design Name: 
-- Module Name: control_unit - Behavioral
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

entity control_unit is
  port (
    RegWr, RegDest, ExtOp, AluSrc, MemWr, MemtoReg, Jump, B, L, G: out std_logic;
    AluOp: out std_logic_vector(1 downto 0);
    op_code: in std_logic_vector(2 downto 0);
    debug_row: out std_logic_vector(0 to 15)
  );
end control_unit;

architecture Behavioral of control_unit is
  type control_signals_table is array(0 to 7) of std_logic_vector(0 to 11);
  
  -- RegWr RegDest ExtOp AluOp(2) AluSrc MemWr MemtoReg Jump B L G
  constant cst: control_signals_table := (
    0 => b"1_1_0_00_0_0_0_0_0_0",  -- R type arithmetic operations
    1 => b"1_0_1_10_1_0_0_0_0_0",  -- addi
    2 => b"1_0_1_10_1_0_1_0_0_0",  -- lw
    3 => b"0_0_1_10_1_1_0_0_0_0",  -- sw
    4 => b"0_0_0_11_0_0_0_1_0_0",  -- beq
    5 => b"0_0_0_11_0_0_0_0_1_0",  -- blt
    6 => b"0_0_0_11_0_0_0_0_0_1",  -- bgt
    7 => b"0_0_0_00_0_0_1_0_0_0"   -- jump
  );
begin
  RegWr   <= cst(conv_integer(op_code))(0);
  RegDest <= cst(conv_integer(op_code))(1);

  ExtOp <= cst(conv_integer(op_code))(2);
  
  AluOp(1) <= cst(conv_integer(op_code))(3);
  AluOp(0) <= cst(conv_integer(op_code))(4);
  
  AluSrc   <= cst(conv_integer(op_code))(5);
  MemWr    <= cst(conv_integer(op_code))(6);
  MemtoReg <= cst(conv_integer(op_code))(7);
  
  Jump <= cst(conv_integer(op_code))(8);
  B    <= cst(conv_integer(op_code))(9);
  L    <= cst(conv_integer(op_code))(10);
  G    <= cst(conv_integer(op_code))(11);
  
  debug_row <= x"0" & cst(conv_integer(op_code));
end Behavioral;
