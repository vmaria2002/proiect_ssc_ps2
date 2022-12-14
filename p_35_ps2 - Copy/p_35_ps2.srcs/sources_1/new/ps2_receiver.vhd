--Are rolul de a captat cate un cod primit, verifica codurile, iar apoi transmite rezultatul obtinut

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity ps2_receiver is
 Port ( ps2_data: in std_logic;	--bitul care vine serial, de la tastatura
        ps2_clk: in std_logic;	--clockul tastaturii
        CLK: in std_logic;	    --clockul placutei
        character_code: out std_logic_vector(7 downto 0); --codul caracterului pe 8 biti
        enable: out std_logic);	 --new code avaible flag );
end ps2_receiver;

architecture Behavioral of ps2_receiver is
component Bistabil_D is
   port(
      DOUT: out std_logic;      
      CLK :in std_logic;       
      D :in  std_logic     
   );
end component Bistabil_D;

signal clk_D: std_logic;
signal data_D: std_logic;
constant clk_freq:INTEGER:=100_000_000;

signal fullCode: std_logic_vector(10 downto 0):=(others=>'0'); --codul de 11 biti transmisi de tastatura
signal error: std_logic;	 	--semnaleaza daca exista eroare in fullCode
signal count_idle: INTEGER range 0 to clk_freq/20_000; --55 nanosecunde (timp in care se verifica daca am primit ce-mi trebuie


begin

--trimit semnalele de clk_ps2 si data_ps2 preluate, acestea se transmit pe clk-ul placutei, care este mai mic decat al ps2

bist_clk: Bistabil_D port map (clk_D, CLK, ps2_clk);
bist_data: Bistabil_D port map (data_D, CLK, ps2_data);
--acum in data_D avem valoarea din ps2_data;

--punem in  cod, valoarea primita pe ps/2
--shiftare dreapta

process (clk_D)
begin
    --citesc pe front descrescator 
    if(falling_edge(clk_D)) then
        fullCode(9 downto 0)<=fullCode(10 downto 1);
        fullCode(10)<=data_D;
    
    end if;
end process;

error <= NOT fullCode(0) AND fullCode(10) AND (fullCode(9) XOR fullCode(8) XOR
       fullCode(7) XOR fullCode(6) XOR fullCode(5) XOR fullCode(4) XOR fullCode(3) XOR 
        fullCode(2) XOR fullCode(1));	  --bitul de start=0, bitul de stop=1,verificarea cu parity bit,  avem paritate impara 
	


process(CLK)
	begin		
		if(rising_edge(CLK)) then		
			if(clk_D='0') then 
				count_idle <= 0; 
			elsif(count_idle /= clk_freq/20_000) then --citim on 5ns, erroaee
				count_idle <= count_idle + 1; --daca nu au trecut deja 55 ns, (110 ns poate fi perioada maxima pentru transmisia datelor)
														--continui 
			end if;
		
			if(count_idle = clk_freq/20_000 and error='1') then --daca au trecut 55 ns si codul nu contine erori
				enable <= '1';	 		   --intreg codul a fost transmis corect
				character_code <= fullCode(8 downto 1); --cei 8 biti din codul transmis
			else	
		    	 enable <= '0';
			end if;	
		end if;
			
	end process;




end Behavioral;
