----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2019 01:46:41 PM
-- Design Name: 
-- Module Name: instr_decode - Behavioral
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
use ieee.numeric_std.all;

-- Instruction fetch component for the MIPS 16bit
entity instr_decode is
  port(
    debug_a: in std_logic_vector(2 downto 0);
    debug_d: out std_logic_vector(15 downto 0);
    
    wa: in std_logic_vector(2 downto 0);
    clk, rf_enable: in std_logic;
    instr: in std_logic_vector(15 downto 0);     -- I.F. instruction retrieved from ROM
    RegWrite, RegDest, ExtOp: in std_logic;      -- input control 
    wd: in std_logic_vector(15 downto 0);        -- write data input for rf
    
    rd1, rd2: out std_logic_vector(15 downto 0); -- rf file output(rs and rt registers)
    Ext_imm: out std_logic_vector(15 downto 0);  -- immediate value extended to 16bits
    sa: out std_logic;                           -- shift amount
    func: out std_logic_vector(2 downto 0)       -- function for R type instructions
  );
end instr_decode;

architecture Behavioral of instr_decode is
component  register_file
  port (
    ra1, ra2, ra3: in  std_logic_vector(2 downto 0);   -- read addresses
    rd1, rd2, rd3: out std_logic_vector(15 downto 0);  -- read data
    rt, rd: out  std_logic_vector(2 downto 0); 
    wa: in std_logic_vector(2 downto 0);          -- write address
    wd: in std_logic_vector(15 downto 0);         -- write data
    clk, regwr, enable: in std_logic              -- clock and write enabled
  );
end component;

signal actual_wa: std_logic_vector(2 downto 0);
constant zeroes_ext: std_logic_vector(8 downto 0) := (others => '0');
constant ones_ext:   std_logic_vector(8 downto 0) := (others => '1');
begin
  rf: register_file port map (
    enable => rf_enable,
    rd1 => rd1, rd2 => rd2, rd3 => debug_d,
    ra1 => instr(12 downto 10),
    ra2 => instr(9 downto 7),
    ra3 => debug_a,
    wa => wa,
    clk => clk, regwr => RegWrite,
    wa => actual_wa, wd => wd
  );
  
  -- chose between rt or rd for the destination register
  -- actual_wa <= instr(9 downto 7) when RegDest = '0' else instr(6 downto 4); -- only for MIPS unicycle
  rt <= instr(9 downto 7);
  rd <= instr(6 downto 4);
  func <= instr(2 downto 0);
  sa <= instr(3);
  Ext_imm <= std_logic_vector(resize(signed(instr(6 downto 0)), 16));  
 
-- for some reason this does not work properly as expected
--  sign_ext: process(instr, ExtOp)
--  begin
--    if ExtOp = '0' then
--      Ext_imm <= zeroes_ext & instr(6 downto 0);
--    elsif ExtOp = '1' then
--      if instr(6) = '0' then
--        Ext_imm <= zeroes_ext & instr(6 downto 0);
--      elsif instr(6) = '1' then
--        Ext_imm <= ones_ext   & instr(6 downto 0);
--      end if;    
--    end if;
--  end process;
end Behavioral;
