----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 01:51:21 PM
-- Design Name: 
-- Module Name: top - Behavioral
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

entity test_env is
  port(
    sw: in std_logic_vector(15 downto 0);
    btn: in std_logic_vector(4 downto 0);
    clk: in std_logic;
    led: out std_logic_vector(15 downto 0);
    cat: out std_logic_vector(6 downto 0);
    an: out std_logic_vector  (3 downto 0)
  );
end test_env;

architecture Behavioral of test_env is
component mpg
  port (
    clk: in std_logic;
    btn: in std_logic;
    enable: out std_logic
  );
end component;

component ssd
  port (
    digits: in std_logic_vector(15 downto 0);
    clk: in std_logic;
    cat: out std_logic_vector(6 downto 0);
    an: out std_logic_vector(3 downto 0)
  );
end component;

component  register_file
  port (
    ra1, ra2: in  std_logic_vector(3 downto 0);   -- read addresses
    rd1, rd2: out std_logic_vector(15 downto 0);  -- read data
    wa: in std_logic_vector(3 downto 0);          -- write address
    wd: in std_logic_vector(15 downto 0);         -- write data
    clk, regwr: in std_logic                      -- clock and write enabled
  );
end component;

component rom
  port (
    addr: in std_logic_vector(7 downto 0);
    rout: out std_logic_vector(15 downto 0);
    ce: in std_logic
  );
end component;

component ram
  port(
    we: in std_logic; -- write enable
    data_in: in std_logic_vector(15 downto 0);
    data_out: out std_logic_vector(15 downto 0);
    addr: in std_logic_vector(3 downto 0);
    clk: in std_logic
  );
end component;

component instr_fetch is
  port (
    branch_addr, jmp_addr: in std_logic_vector(15 downto 0);
    clk, jmp, pcsrc: in std_logic;
    next_instr_addr: out std_logic_vector(15 downto 0);
    instr: out std_logic_vector(15 downto 0);
    enable, reset: in std_logic
  );
end component;

component control_unit is
  port (
    RegWr, RegDest,ExtOp, AluSrc, MemWr, MemtoReg, Jump, B, L, G: out std_logic;
    AluOp: out std_logic_vector(1 downto 0);
    op_code: in std_logic_vector(2 downto 0);
    debug_row: out std_logic_vector(0 to 15)
  );
end component;

component instr_decode is
  port(
    clk, rf_enable: in std_logic;
    instr: in std_logic_vector(15 downto 0);     -- I.F. instruction retrieved from ROM
    RegWrite, RegDest, ExtOp: in std_logic;      -- input control 
    wd: in std_logic_vector(15 downto 0);        -- write data input for rf
    
    rd1, rd2: out std_logic_vector(15 downto 0); -- rf file output(rs and rt registers)
    Ext_imm: out std_logic_vector(15 downto 0);  -- immediate value extended to 16bits
    sa: out std_logic;                           -- shift amount
    func: out std_logic_vector(2 downto 0)       -- function for R type instructions
  );
end component;

signal RegWr, RegDest, ExtOp, AluSrc, MemWr, MemtoReg, Jump, B, L, G: std_logic;
signal AluOp: std_logic_vector(1 downto 0);
signal func: std_logic_vector(2 downto 0);

signal clk_enable, reset_pc: std_logic;
signal counter: std_logic_vector(7 downto 0) := (others => '0');
signal wd, rd1, rd2: std_logic_vector(15 downto 0);
signal displayed: std_logic_vector(15 downto 0);
signal rom_out, ram_out: std_logic_vector(15 downto 0);

signal reg_clk_enable, ram_clk_enable: std_logic;
signal instruction, pc, Ext_imm, control_flags: std_logic_vector(15 downto 0);
signal clk_if, sa: std_logic;

begin  
  first_button: mpg port map(
    btn => btn(0), 
    clk => clk, 
    enable => clk_enable);
  
  second_button: mpg port map(
    btn => btn(1),
    clk => clk,
    enable => reset_pc
  );
  
  ssd_comp: ssd port map(
    clk => clk,
    digits => displayed,
    an => an,
    cat => cat);
  
  instrfetch: instr_fetch port map (
    clk => clk,
    branch_addr => x"0002",
    jmp_addr => x"0000",
    instr => instruction,
    next_instr_addr => pc,
    jmp => sw(0),
    pcsrc => sw(1),
    reset => reset_pc,
    enable => clk_enable
  );
  
  uc: control_unit port map(
    RegWr => RegWr, RegDest => RegDest, 
    ExtOp => ExtOp, AluSrc => AluSrc, MemWr => MemWr, MemtoReg => MemtoReg, 
    Jump => Jump, B => B, L => L, G => G,
    AluOp => AluOp, op_code => instruction(15 to 13),
    debug_row => control_flags
  );
  
  id: instr_decode port map(
    clk =>  clk,
    rf_enable => clk_enable,
    instr => instruction,
    RegWrite => RegWr,
    RegDest => RegDest,
    ExtOp => ExtOp,      
    wd => wd,
    rd1 => rd1, rd2 => rd2,
    Ext_imm => Ext_imm, 
    sa => sa,                          
    func => func   
  );
  
  mux_leds: process(sw(7 downto 5), instruction, pc, rd1, rd2, wd, control_flags)
  begin
    case sw(7 downto 5) is
      when "000"    => displayed <= instruction;
      when "001"    => displayed <= pc;
      when "010"    => displayed <= rd1;
      when "011"    => displayed <= rd2;
      when "100"    => displayed <= wd;
      when "101"    => displayed <= control_flags;
      when others => displayed <= (others => 'X');
    end case;
  end process; 
  
  wd <= rd1 + rd2;
  led <= sw;
end Behavioral;   