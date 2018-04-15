--Adapted from PmodGYRO_Demo code provided by Digilent
--Engineer     : Vanessa Su
--Date Created : 11/20/2017
--Name of file : ui2_pkg.vhd
--Description  : contains functions and type definitions for ui2

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package ui2_pkg is

  function binary_to_bcd( unsigned_data : std_logic_vector(15 downto 0) ) return std_logic_vector;
  function to_hexchar(num : std_logic_vector(3 downto 0)) return std_logic_vector;
  function count_sw(sw : std_logic_vector(15 downto 0)) return std_logic_vector;

end ui2_pkg;

package body ui2_pkg is

  function binary_to_bcd( unsigned_data : std_logic_vector(15 downto 0) ) return std_logic_vector is
  	variable i : integer := 0;
  	variable bcd : std_logic_vector(19 downto 0) := (others => '0');
  	variable init_bin : std_logic_vector(15 downto 0) := unsigned_data;
  begin
  	for i in 0 to 15 loop
  		bcd := bcd(18 downto 0) & init_bin(15);
  		init_bin := init_bin(14 downto 0) & '0';

  		if (i < 15 and bcd(3 downto 0) > "0100") then
  			bcd(3 downto 0) := bcd(3 downto 0) + "0011";
  		end if;

  		if (i < 15 and bcd(7 downto 4) > "0100") then
  			bcd(7 downto 4) := bcd(7 downto 4) + "0011";
  		end if;

  		if (i < 15 and bcd(11 downto 8) > "0100") then
  			bcd(11 downto 8) := bcd(11 downto 8) + "0011";
  		end if;

  		if (i < 15 and bcd(15 downto 12) > "0100") then
  			bcd(15 downto 12) := bcd(15 downto 12) + "0011";
  		end if;

  		if (i < 15 and bcd(19 downto 16) > "0100") then
  			bcd(19 downto 16) := bcd(19 downto 16) + "0011";
  		end if;
  	end loop;
  return bcd;
  end binary_to_bcd;

  function to_hexchar(num : std_logic_vector (3 downto 0)) return std_logic_vector is
    variable hexchar : std_logic_vector (7 downto 0);
  begin
    case num is
      when "0000" => -- 0
      hexchar := X"30";
      when "0001" => -- 1
      hexchar := X"31";
      when "0010" => -- 2
      hexchar := X"32";
      when "0011" => -- 3
      hexchar := X"33";
      when "0100" => -- 4
      hexchar := X"34";
      when "0101" => -- 5
      hexchar := X"35";
      when "0110" => -- 6
      hexchar := X"36";
      when "0111" => -- 7
      hexchar := X"37";
      when "1000" => -- 8
      hexchar := X"38";
      when "1001" => -- 9
      hexchar := X"39";
      when "1111" => -- - (minus sign)
      hexchar := X"2D";
      when "1010" => -- + (plus sign)
      hexchar := X"2B";
      when "1100" => -- . (period)
      hexchar := X"2E";
      when others => -- ! (error)
      hexchar := X"21";
    end case;
    return hexchar;
  end to_hexchar;

  function count_sw(sw : std_logic_vector(15 downto 0)) return std_logic_vector is
    variable count : std_logic_vector (7 downto 0) := (others => '0');
  begin
    if (SW(0) = '1') then
      count := count + "00000001";
    end if;
    if (SW(1) = '1') then
      count := count + "00000001";
    end if;
    if (SW(2) = '1') then
      count := count + "00000001";
    end if;
    if (SW(3) = '1') then
      count := count + "00000001";
    end if;
    if (SW(4) = '1') then
      count := count + "00000001";
    end if;
    if (SW(5) = '1') then
      count := count + "00000001";
    end if;
    if (SW(6) = '1') then
      count := count + "00000001";
    end if;
    if (SW(7) = '1') then
      count := count + "00000001";
    end if;
    if (SW(8) = '1') then
      count := count + "00000001";
    end if;
    if (SW(9) = '1') then
      count := count + "00000001";
    end if;
    if (SW(10) = '1') then
      count := count + "00000001";
    end if;
    if (SW(11) = '1') then
      count := count + "00000001";
    end if;
    if (SW(12) = '1') then
      count := count + "00000001";
    end if;
    if (SW(13) = '1') then
      count := count + "00000001";
    end if;
    if (SW(14) = '1') then
      count := count + "00000001";
    end if;
    if (SW(15) = '1') then
      count := count + "00000001";
    end if;
    return count;
  end count_sw;

end ui2_pkg;
