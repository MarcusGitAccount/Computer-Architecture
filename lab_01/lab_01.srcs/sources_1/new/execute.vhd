----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2019 01:20:14 PM
-- Design Name: 
-- Module Name: execute - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Alu control unit, alu and branch logic for execution component
-- of the MIPS 16bit unicycle implementation
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity execute is
  port (
    rd1, rd2, ext_imm: in std_logic_vector(15 downto 0);
    aluop: in std_logic_vector(1 downto 0);
    alusrc: in std_logic;
    sa: in std_logic;
    func: in std_logic_vector(2 downto 0);
    pcnext: in std_logic_vector(15 downto 0);
    
    zero: out std_logic;
    alu_res: out std_logic_vector(15 downto 0);
    branch_addr: out std_logic_vector(15 downto 0)
  );
end execute;

architecture Behavioral of execute is
signal result: std_logic_vector(15 downto 0);
signal aluctrl: std_logic_vector(2 downto 0);
signal aop, bop: std_logic_vector(15 downto 0); -- alu operands
begin
  alu_res <= result;
  zero <= '1' when result = X"0000" else '0';
  aop <= rd1;
  bop <= rd2 when alusrc = '0' else ext_imm;  
  branch_addr <= pcnext + ext_imm;

  control_unit: process(aluop, func)
  begin
    case aluop is
      when b"00"  => aluctrl <= func;   -- R type operations
      when b"10"  => aluctrl <= b"000"; -- addi, lw or sw
      when b"11"  => aluctrl <= b"001"; -- branching operations
      when others => aluctrl <= b"000";
    end case;
  end process;
  
  alu: process(aluctrl, aop, bop, sa)
  begin
    case aluctrl is
      when "000" => result <= aop + bop;  -- add
      when "001" => result <= aop - bop;  -- sub
      when "010" => result <= aop when sa = '0' else aop(14 downto 0) & "0";  -- sll
      when "011" => result <= aop when sa = '0' else "0" & aop(15 downto 1);  -- slr
      when "100" => result <= aop and bop; -- and
      when "101" => result <= aop or  bop; -- or
      when "110" => result <= aop when sa = '0' else aop(15) & aop(15 downto 1); -- sra, use the sign bit
      when "111" => result <= x"0001" when aop < bop else x"0001";  -- slt (set on less then)
    end case;
  end process;
  
end Behavioral;
