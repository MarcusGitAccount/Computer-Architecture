----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/21/2019 12:49:30 PM
-- Design Name: 
-- Module Name: uart - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity tx_comp is
  port (
    rst, tx_en: in std_logic;
    tx, tx_rdy: out std_logic;
    clk, baud_enable: in std_logic; -- basically baud enable
    tx_data: in std_logic_vector(7 downto 0)
  );
end tx_comp;

architecture Behavioral of tx_comp is

signal bit_cnt: std_logic_vector(2 downto 0) := b"000";
type state_type is(idle, start, bits, stop);
signal state: state_type := idle;

begin
  states_changing: process(clk, rst, tx_en, state, baud_enable)
  begin
    if rst = '1' then
      state <= idle;
    elsif rising_edge(clk) then
      case state is
        when idle   =>
          if tx_en = '1' then
            if baud_enable = '1' then
              state <= start;
              bit_cnt <= b"000";
            end if;
          end if;
        when start  =>
          if baud_enable = '1' then
            state <= bits;
          end if;
        when bits   =>
          if bit_cnt = b"111" then
            if baud_enable = '1' then
              bit_cnt <= b"000";
              state <= stop;
            end if;
          elsif bit_cnt < b"111" then
            if baud_enable = '1' then
              bit_cnt <= bit_cnt + 1;
              state <= bits;
            end if;
          end if;
        when stop   =>
          if baud_enable = '1' then
            state <= idle;
          end if;
        when others =>
          state <= idle;
      end case;
    end if;
  end process;  

  output_changing: process(state)
  begin
    case state is
      when idle   =>
        tx <= '1';
        tx_rdy <= '1';
      when start  =>
        tx <= '0';
        tx_rdy <= '0';
      when bits   =>
        tx <= tx_data(conv_integer(bit_cnt));
        tx_rdy <= '0';
      when stop   =>
        tx <= '1';
        tx_rdy <= '0';
      when others =>
        tx <= '0';
        tx_rdy <= '0';
    end case;
  end process;

end Behavioral;