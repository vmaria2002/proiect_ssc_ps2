library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity Bistabil_D is
   port(
      DOUT: out std_logic;      
      CLK :in std_logic;       
      D :in  std_logic     
   );
end Bistabil_D;
architecture Behavioral of Bistabil_D is  
signal rez: std_logic:='0';
begin  

process(CLK) 
begin  
  if ( rising_edge(CLK) ) then  
       rez <= D;      
  end if;

end process;  
DOUT<=rez;
end Behavioral;