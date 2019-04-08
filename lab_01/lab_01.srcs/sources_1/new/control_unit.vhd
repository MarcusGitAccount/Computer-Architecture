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
    op_code: in std_logic_vector(2 downto 0)
  );
end control_unit;

architecture Behavioral of control_unit is
begin
  process(op_code)
  begin
    RegWr <= '0'; 
    RegDest <= '0'; 
    ExtOp <= '0'; 
    AluSrc <= '0';
    MemWr <= '0'; 
    MemtoReg <= '0'; 
    Jump <= '0'; 
    B <= '0'; 
    L <= '0'; 
    G <= '0';
    AluOp <= "00";
    
    case op_code is
      when "000" => -- R
        RegWr <= '1';
        RegDest <= '1';
      when "001" => -- addi
        RegWr <= '1';
        ExtOp <= '1';
        AluOp <= "10";
        AluSrc <= '1';
      when "010" => -- lw
        RegWr <= '1';
        ExtOp <= '1';
        AluOp <= "10";
        AluSrc <= '1';
        MemtoReg <= '1';
      when "011" => -- sw
        RegWr <= '1';
        ExtOp <= '1';
        AluOp <= "10";
        AluSrc <= '1';
        MemWr <= '1';
      when "100" => -- beq
        AluOp <= "11";
        B <= '1';
      when "101" => -- blt
        AluOp <= "11";
        L <= '1';
      when "110" => -- bgt
        AluOp <= "11";
        G <= '1';
      when "111" => -- jumo
        Jump <= '1';
    end case ;
  end process;
end Behavioral;