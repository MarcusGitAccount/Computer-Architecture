----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/28/2019 09:26:21 AM
-- Design Name: 
-- Module Name: rx_comp - Behavioral
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

entity rx_comp is
  port (
    clk, rst: in std_logic;
    rx, baud_en: in std_logic;
    rx_rdy: out std_logic;
    rx_data: out std_logic_vector(7 downto 0)
  );
end rx_comp;

architecture Behavioral of rx_comp is
type state_type is(idle, start, bits, stop, waits);
signal bit_cnt:  std_logic_vector(7 downto 0) := x"00";
signal baud_cnt: std_logic_vector(15 downto 0):= x"0000";
signal state: state_type := idle;
begin
 fsm_states: process(rst, rx, baud_en, clk)
 begin
  if rst = '1' then
    state <= idle;
  elsif rising_edge(clk) then
    if baud_en = '1' then
      baud_cnt <= baud_cnt + 1;
      case state is
        when idle => 
          baud_cnt <= x"0000";
          bit_cnt <= x"00";
          if rx = '0' then
            state <= start;
          else
            state <= idle;
          end if;
        
        when start => 
          if rx = '1' then
            state <= idle;
          elsif baud_cnt < x"7" then
            state <= start;
          elsif baud_cnt = x"7" and rx = '0' then
            state <= bits;
            baud_cnt <= x"0000";
          end if;
          
        when bits =>
          if baud_cnt = x"F" then
            rx_data(conv_integer(bit_cnt)) <= rx;
            baud_cnt <= x"0000";
            bit_cnt <= bit_cnt + 1;
            if bit_cnt = b"111" then
              state <= stop;
            elsif bit_cnt < b"111" then
              state <= bits;
            end if;
          end if;
          
        when stop => 
          if baud_cnt < x"F" then
            state <= stop;
          elsif baud_cnt = x"F" then
            state <= waits;
          end if;
          
        when waits =>
          baud_cnt <= baud_cnt + 1;
          if baud_cnt < x"7" then
            state <= waits;
          elsif baud_cnt = x"7" then
            state <= idle;
          end if;
      end case;
    end if;
  end if;
 end process;
 
 fsm_outputs: process(state)
 begin
  case state is
    when idle  => rx_rdy <= '0';
    when start => rx_rdy <= '0';
    when bits  => rx_rdy <= '0';
    when stop  => rx_rdy <= '0';
    when waits => rx_rdy <= '1';
  end case;
 end process;
 
end Behavioral;
