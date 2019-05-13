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
    op_code: in std_logic_vector(2 downto 0)
  );
end component;

component instr_decode is
  port(
    wa: in std_logic_vector(2 downto 0);
    debug_a: in std_logic_vector(2 downto 0);
    clk, rf_enable: in std_logic;
    instr: in std_logic_vector(15 downto 0);     -- I.F. instruction retrieved from ROM
    RegWrite, RegDest, ExtOp: in std_logic;      -- input control 
    wd: in std_logic_vector(15 downto 0);        -- write data input for rf
    
    debug_d: out std_logic_vector(15 downto 0);
    rt, rd: out  std_logic_vector(2 downto 0); 
    rd1, rd2: out std_logic_vector(15 downto 0); -- rf file output(rs and rt registers)
    Ext_imm: out std_logic_vector(15 downto 0);  -- immediate value extended to 16bits
    sa: out std_logic;                           -- shift amount
    func: out std_logic_vector(2 downto 0)       -- function for R type instructions
  );
end component;

component execute is
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
end component;

component mem is
  port (
    clk, enable, MemWrite: in std_logic;
    ram_address: in std_logic_vector(15 downto 0);
    ram_wd: in std_logic_vector(15 downto 0);
    rdata: out std_logic_vector(15 downto 0)
  );
end component;

signal RegWr, RegDest, ExtOp, AluSrc, MemWr, MemtoReg, Jump, B, L, G, zero, pcsrc: std_logic;
signal AluOp: std_logic_vector(1 downto 0);
signal func: std_logic_vector(2 downto 0);

signal clk_enable, reset_pc: std_logic;
signal counter: std_logic_vector(7 downto 0) := (others => '0');
signal wd, rd1, rd2: std_logic_vector(15 downto 0);
signal displayed: std_logic_vector(15 downto 0);
signal rom_out, ram_out: std_logic_vector(15 downto 0);

signal reg_clk_enable, ram_clk_enable: std_logic;
signal instruction, pcnext, Ext_imm, AluRes, branch_addr, jump_addr, MemData: std_logic_vector(15 downto 0);
signal clk_if, sa, sign: std_logic;

signal control_flags: std_logic_vector(11 downto 0);
signal debug_counter: std_logic_vector(2 downto 0) := b"000";
signal debugup, debugdw: std_logic;
signal debug_reg: std_logic_vector(15 downto 0);

signal if_id:  std_logic_vector(31 downto 0) := (others => '0');
signal id_ex:  std_logic_vector(83 downto 0) := (others => '0');
signal ex_mem: std_logic_vector(57 downto 0) := (others => '0');
signal mem_wb: std_logic_vector(36 downto 0) := (others => '0');

signal rt, rd, wa: std_logic_vector(2 downto 0) := b"000";

begin  
  first_button: mpg port map(
    btn => btn(0), 
    clk => clk, 
    enable => clk_enable);
  
  second_button: mpg port map(
    btn => btn(1),
    clk => clk,
    enable => reset_pc);
  
  leftbtn: mpg port map(
    btn => btn(2),
    clk => clk,
    enable => debugdw);
  
  rightbtn: mpg port map(
    btn => btn(3),
    clk => clk,
    enable => debugup);
  
  ssd_comp: ssd port map(
    clk => clk,
    digits => displayed,
    an => an,
    cat => cat);
  
 
  instrfetch: instr_fetch port map (
    -- in ports
    clk         => clk,
    branch_addr => branch_addr,
    jmp_addr    => jump_addr,
    jmp         => Jump,
    pcsrc       => pcsrc,
    reset       => reset_pc,
    enable      => clk_enable,
    -- out ports
    instr           => instruction,
    next_instr_addr => pcnext,
  );
  
  jump_addr <= if_id(31 downto 29) & if_id(12 downto 0);

  if_id_input: process(clk, instruction, pcnext)
  begin
    if rising_edge(clk) then
      if_id(31 downto 16) <= pcnext;
      if_id(15 downto  0) <= instruction;
    end if;
  end process;

  uc: control_unit port map(
    -- out port(s)
    RegWr    => RegWr, 
    RegDest  => RegDest, 
    ExtOp    => ExtOp, 
    AluSrc   => AluSrc, 
    MemWr    => MemWr, 
    MemtoReg => MemtoReg, 
    Jump     => Jump, 
    B        => B, 
    L        => L, 
    G        => G,
    AluOp    => AluOp, 
    -- in port(s)
    op_code => if_id(15 downto 13) -- function code
  );
  
  id: instr_decode port map(
    -- in ports
    debug_a   => debug_counter,
    clk       =>  clk,
    rf_enable => clk_enable,
    instr     => if_id(15 downto  0),
    RegWrite  => mem_wb(35),
    RegDest   => RegDest,
    ExtOp     => ExtOp,      
    wd        => wd,
    wa        => wa
    -- out ports
    rd1     => rd1, 
    rd2      => rd2,
    debug_d => debug_reg,
    Ext_imm => Ext_imm, 
    sa      => sa,                          
    rt      => rd, 
    rd      => rd, 
    func    => func
  );

  id_ex_input: process(clk)
  begin
    if rising_edge(clk) then
      id_ex(83)           <= sa;
      id_ex(82 downto 67) <= rd1;
      id_ex(66 downto 51) <= rd2;
      id_ex(50 downto 35) <= Ext_imm;
      id_ex(34 downto 32) <= func;
      id_ex(31 downto 29) <= rt;
      id_ex(28 downto 26) <= rd;
      id_ex(25 downto 10) <= if_id(31 downto 16); -- pc + 1
      id_ex( 9 downto  8) <= AluOp;
      id_ex(7)            <= AluSrc;
      id_ex(6)            <= RegDest;
      id_ex(5)            <= B;
      id_ex(4)            <= L;
      id_ex(3)            <= G;
      id_ex(2)            <= MemWr;
      id_ex(1)            <= MemtoReg;
      id_ex(0)            <= RegWr;
    end if;
  end process;
  
  ex: execute port map (
    -- in ports
    rd1     => id_ex(82 downto 67), 
    rd2     => id_ex(66 downto 51), 
    ext_imm => id_ex(50 downto 35),
    aluop   => id_ex( 9 downto  8), 
    alusrc  => id_ex(7),
    sa      => id_ex(83),
    func    => id_ex(34 downto 32),
    pcnext  => id_ex(25 downto 10),
    -- out ports
    zero        => zero,
    alu_res     => AluRes,    
    branch_addr => branch_addr
  );

  ex_mem_input: process(clk)
  begin
    if rising_edge(clk) then
      ex_mem(57 downto 56) <= id_ex(1 downto 0); -- M signals
      ex_mem(55 downto 52) <= id_ex(5 downto 2); -- WB signals
      ex_mem(51 downto 36) <= branch_addr;
      ex_mem(35)           <= zero;
      ex_mem(34 downto 19) <= AluRes;
      ex_mem(18 downto  3) <= id_ex(66 downto 51); -- rd2
      ex_mem( 2 downto  0) <= id_ex(31 downto 29) when id_ex(6) = '0' else id_ex(28 downto 26); 
         -- RegDest MUX, choosing between rt and rd
    end if;
  end process;

  mem_comp: mem port map (
    -- in port(s)
    clk         => clk, 
    enable      => clk_enable, 
    MemWrite    => ex_mem(52),
    ram_address => ex_mem(34 downto 19),
    ram_wd      => ex_mem(18 downto  3),
    -- out port(s)
    rdata => MemData
  );
  
  -- B    <=> ex_mem(55)
  -- L    <=> ex_mem(54)
  -- G    <=> ex_mem(53)
  -- zero <=> ex_mem(35)
  sign <= ex_mem(34); -- sign bit (AluRes(15))
  wa <=  mem_wb(2 downto 0); -- write address for RF
  pcsrc <= (ex_mem(55) and zero) 
    or ((not ex_mem(55)) and ex_mem(54) and sign and (not ex_mem(35))) 
    or ((not ex_mem(55)) and (not sign) and (not ex_mem(54)) and ex_mem(53) and (not ex_mem(35)));

  mem_input: process(clk)
  begin
    if rising_edge(clk) then
      mem_wb(36 downto 35) <= ex_mem(57 downto 56);
      mem_wb(34 downto 19) <= MemData;             -- RAM output data
      mem_wb(18 downto  3) <= ex_mem(34 downto 19) -- AluRes
      mem_wb( 2 downto  0) <= ex_mem( 2 downto  0) -- rt vs rd choice
    end if;
  end process;

  -- write back component
  -- wd <= MemData when MemtoReg = '1' else AluRes;
  wd <= mem_wb(34 downto 19) when mem_wb(36) = '1' else mem_wb(18 downto 3);

  debugging_count: process(clk, debugup, debugdw)
  begin
    if rising_edge(clk) then
      if debugdw = '1' then
        debug_counter <= debug_counter - 1;
      elsif debugup = '1' then
        debug_counter <= debug_counter + 1;
      end if;
    end if;
  end process;
  
  mux_leds: process(sw(3 downto 0), instruction, pcnext, rd1, rd2, wd, ext_imm, AluRes, MemData)
  begin
    case sw(3 downto 0) is 
      when "0000"    => displayed <= instruction;
      when "0001"    => displayed <= pcnext;
      when "0010"    => displayed <= rd1;
      when "0011"    => displayed <= rd2;
      when "0100"    => displayed <= ext_imm;
      when "0101"    => displayed <= AluRes;
      when "0110"    => displayed <= MemData;
      when "0111"    => displayed <= wd;
      when "1000"    => displayed <= debug_reg;
      when others   => displayed <= (others => 'X');
    end case;
  end process; 
    
  control_flags <= RegWr & RegDest & ExtOp & AluOp & AluSrc & MemWr & MemtoReg & Jump & B & L & G;
  led(11 downto 0) <= control_flags;
  led(15 downto 13) <= debug_counter;
end Behavioral;   