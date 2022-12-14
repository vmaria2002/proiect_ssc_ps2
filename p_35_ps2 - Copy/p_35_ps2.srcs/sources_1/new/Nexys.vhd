library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Nexys is
 Port ( Clk:in std_logic;
 BTNR:in std_logic;
 PS2_CLK:in std_logic;
 PS2_DATA: in std_logic;
 LED: out std_logic_vector(15 downto 0);
 Seg: out std_logic_vector(7 downto 0);
  An: out std_logic_vector(7 downto 0)
 );
end Nexys;

architecture Behavioral of Nexys is
component display_on_leds is 
	port(
	CLK: in std_logic;
	Rst  : in  STD_LOGIC;
	Data : in  STD_LOGIC_VECTOR (7 downto 0);   -- datele pentru 8 cifre (cifra 1 din stanga: biti 31..28)
	An:	out std_logic_vector(7 downto 0);
	Cat: out std_logic_vector(7 downto 0)
	);
	
end component display_on_leds;

component ps2_transmiter is
  Port ( 
      clk        : IN  STD_LOGIC;                    
      ps2_clk    : IN  STD_LOGIC;                     --clock pt PS2 
      ps2_data   : IN  STD_LOGIC;                     --datele de pe PS2
      ascii_new  : OUT STD_LOGIC;                     --arata daca avem 
      ascii_code : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --ASCII value
end component ps2_transmiter;

signal aux: std_logic_vector(7 downto 0):=(others=>'0');
begin

receptir: ps2_transmiter port map (clk, ps2_clk, ps2_data,led(0), aux);
viz: display_on_leds port map (clk, BTNR, aux, An, Seg);

end Behavioral;
