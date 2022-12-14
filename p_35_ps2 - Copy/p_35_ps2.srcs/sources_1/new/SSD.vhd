library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity display_on_leds is 
	port(
	CLK: in std_logic;
	Rst  : in  STD_LOGIC;
	Data : in  STD_LOGIC_VECTOR (7 downto 0);   -- datele pentru 8 cifre (cifra 1 din stanga: biti 31..28)
	An:	out std_logic_vector(7 downto 0);
	Cat: out std_logic_vector(7 downto 0)
	);
	
end display_on_leds;


architecture display_on_leds of display_on_leds is	  


constant CNT_100HZ : integer := 2**20;                  -- divizor pentru rata de reimprospatare de ~100 Hz (cu un ceas de 100 MHz)
signal Num         : integer range 0 to CNT_100HZ - 1 := 0;
signal NumV        : STD_LOGIC_VECTOR (19 downto 0) := (others => '0');    
signal LedSel      : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
signal Hex         : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');


signal cathodes_aux : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

begin

-- Proces pentru divizarea ceasului
divclk: process (Clk)
    begin
    if (Clk'event and Clk = '1') then
        if (Rst = '1') then
            Num <= 0;
        elsif (Num = CNT_100HZ - 1) then
            Num <= 0;
        else
            Num <= Num + 1;
        end if;
    end if;
    end process;

    NumV <= CONV_STD_LOGIC_VECTOR (Num, 20);
    LedSel <= NumV (19 downto 17);




process(CLK, LedSel) 
begin					
	if(rising_edge(CLK)) then
	case LedSel is
		when "000" => An <= "11111110"; cathodes_aux <= Data;
		when "001" => An <= "11111101";cathodes_aux <= Data ;
		when "010" => An <= "11111011"; cathodes_aux <=  Data; 
		when "011" => An <= "11110111"; cathodes_aux <= Data ;
		when "100" => An <= "11101111"; cathodes_aux <= Data;
		--when "101" => An <= "11011111"; cathodes_aux <= Data;
		when "101" => An <= "11011111"; cathodes_aux <= Data;
		when "111" => An <= "10111111"; cathodes_aux <=Data;
		when others => An <= "01111111"; cathodes_aux <= Data;
	end case;  


	end if;

end process;


	
    Cat <= "11111001" when cathodes_aux = x"31" else            -- 1
           "10100100" when cathodes_aux = x"32" else            -- 2
           "10110000" when cathodes_aux = x"33" else            -- 3
           "10011001" when cathodes_aux = x"34" else            -- 4
           "10010010" when cathodes_aux = x"35" else            -- 5
           "10000010" when cathodes_aux = x"36" else            -- 6
           "11111000" when cathodes_aux = x"37" else            -- 7
           "10000000" when cathodes_aux = x"38" else            -- 8
           "10010000" when cathodes_aux = x"39" else            -- 9
           "10001000" when cathodes_aux = x"41" else            -- A
           "10000011" when cathodes_aux = x"62" else            -- b
           "11000110" when cathodes_aux = x"43" else            -- C
	        "10100111" when cathodes_aux =x"63" else            -- c
           "10100001" when cathodes_aux = x"64" else            -- d
           "10000110" when cathodes_aux = x"45" else            -- E
           "10000100" when cathodes_aux = x"65" else            -- e
           "10101111" when cathodes_aux = x"72" else            -- r
           "10001110" when cathodes_aux = x"46" else            -- F
           "11100011" when cathodes_aux = x"75" else            -- u
           "11000001" when cathodes_aux = x"55" else            -- U
           "10100011" when cathodes_aux = x"6F" else            -- o
           "10001100" when cathodes_aux = x"50" else            -- P
           "10001011" when cathodes_aux = x"68" else            -- h
           "10001001" when cathodes_aux = x"48" else            -- H
           "10101011" when cathodes_aux = x"6E" else            -- n
           "11001111" when cathodes_aux = x"6C" else            -- l
           "11000111" when cathodes_aux = x"4C" else            -- L
           "10100100" when cathodes_aux = x"53" else            -- S
           "10111111" when cathodes_aux = x"2D" else            -- -
           "11110111" when cathodes_aux = x"5F" else            -- _
           "01111111" when cathodes_aux = x"2E" else            -- .
           "11011111" when cathodes_aux = x"27" else             --' dreapta(pt cea de langa shift)
           "11111101" when cathodes_aux = x"60" else             --` stanga(pt cea de langa 1)
           "11000110" when cathodes_aux = x"5B" else             --[
           "11110000" when cathodes_aux = x"5D" else             --]
           "10110111" when cathodes_aux = x"3D" else             --=
           "11000000";                                 -- 0
           

end display_on_leds;
