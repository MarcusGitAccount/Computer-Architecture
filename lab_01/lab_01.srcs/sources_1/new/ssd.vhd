----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/05/2019 12:18:46 PM
-- Design Name: 
-- Module Name: ssd - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: 7 segments display module
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ssd is
  port (
    digits: in std_logic_vector(15 downto 0);
    clk: in std_logic;
    cat: out std_logic_vector(6 downto 0);
    an: out std_logic_vector(3 downto 0)
  );
 end ssd;

architecture Behavioral of ssd is
signal div_counter: std_logic_vector(15 downto 0) := (others => '0');
signal digit: std_logic_vector(3 downto 0) := (others => '0');
begin
  divider: process(clk)
  begin
    if rising_edge(clk) then
      div_counter <= div_counter + 1;
    end if;
  end process;

  multiplexing_an: process(div_counter)
  begin
    case div_counter(15 downto 14) is
      when "00"   => an <= "0111";
      when "01"   => an <= "1011";
      when "10"   => an <= "1101";
      when "11"   => an <= "1110";
      when others => an <= (others => '0');
    end case;
  end process;

  multiplexig_digit: process(div_counter)
  begin
    case div_counter(15 downto 14) is
      when "00"   => digit <= digits(15 downto 12);
      when "01"   => digit <= digits(11 downto 8);
      when "10"   => digit <= digits(7 downto 4);
      when "11"   => digit <= digits(3 downto 0);
      when others => digit <= (others => '0');
    end case;
  end process;

  hex_to_ssd_decoder: process(digit)
  begin
    case digit is
      when "0000" => cat <= "1000000";
      when "0001" => cat <= "1111001";
      when "0010" => cat <= "0100100";
      when "0011" => cat <= "0110000";
      when "0100" => cat <= "0011001";
      when "0101" => cat <= "0010010";
      when "0110" => cat <= "0000010";
      when "0111" => cat <= "1111000";
      when "1000" => cat <= "0000000";
      when "1001" => cat <= "0010000";
      when "1010" => cat <= "0001000";
      when "1011" => cat <= "0000011";
      when "1100" => cat <= "1000110";
      when "1101" => cat <= "0100001";
      when "1110" => cat <= "0000110";
      when "1111" => cat <= "0001110";
      when others => cat <= "1111111";
    end case;
  end process;

end Behavioral;