library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity ps2_transmiter is
  Port ( 
      clk        : IN  STD_LOGIC;                    
      ps2_clk    : IN  STD_LOGIC;                     --clock pt PS2 
      ps2_data   : IN  STD_LOGIC;                     --datele de pe PS2
      ascii_new  : OUT STD_LOGIC;                     --arata daca avem 
      ascii_code : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --ASCII value
end ps2_transmiter;

architecture Behavioral of ps2_transmiter is

  TYPE machine IS(ready, new_code, translate, output);              --starile in care se afla dispozitivul nostru
  signal state             : machine;         
                        --state machine
  signal ps2_code_new      : STD_LOGIC;                             --Ps2 este ocupat sau nu
  signal ps2_code          : STD_LOGIC_VECTOR(7 DOWNTO 0);          -- codup primit pe PS2 
  signal prev_ps2_code_new : STD_LOGIC := '1';                      --valoarea de pe ceasul precedent
  signal break             : STD_LOGIC := '0';                      --'1'= break code, '0'= face code
  signal e0_code           : STD_LOGIC := '0';                      --1' comezi: multi-code|| '0' pt single code commands
  signal caps_lock         : STD_LOGIC := '0';                      --'1' =lock ii activ, '0'=caps lock e inactiv
  signal control_r         : STD_LOGIC := '0';                      --'1' =right control este apasat, else '0'
  signal control_l         : STD_LOGIC := '0';                      --'1' =left control key  e apasat, else '0'
  signal shift_r           : STD_LOGIC := '0';                      --'1' = right shift apasat, else '0'
  signal shift_l           : STD_LOGIC := '0';                      --'1'=left shift apasat else '0'
  signal ascii             : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF"; --valoarea interna
  signal prev_ps2_code      : STD_LOGIC_VECTOR(7 DOWNTO 0);          -- codup primit pe PS2 
    
component  ps2_receiver is
 Port ( ps2_data: in std_logic;	--bitul care vine serial, de la tastatura
        ps2_clk: in std_logic;	--clockul tastaturii
        CLK: in std_logic;	    --clockul placutei
        character_code: out std_logic_vector(7 downto 0); --codul caracterului pe 8 biti
        enable: out std_logic);	 --new code avaible flag );
end component ps2_receiver;


begin
--semnale auxiliare folosite!!!- in signal ;)
ps2_keyboard: ps2_receiver port map(ps2_data,ps2_clk,clk, ps2_code,ps2_code_new); --

--logica pentru masina:

 process(clk)
    begin
    
    if(rising_edge(clk)) THEN
      prev_ps2_code_new <= ps2_code_new;      --vom folosi un semnal care tine minte tranzitia trecuta(util pentru CTRL, Shift)
      prev_ps2_code<=ps2_code;
      case state IS
      
        ----stare gata: astepta si primirea unui nou cod PS2
        when ready =>
          if(prev_ps2_code_new = '0' AND ps2_code_new = '1') THEN --noul cod PS2 primit
            ascii_new <= '0';                                      --reset  indicatorul 
            state <= new_code;                                      --se proceseaza noua stare, generata de cod
          else                                                    --nu s-a primit niciun cod PS2 inca
            state <= ready;                                         --remane in Ready
          end if;
          
          
        --new_code state: determina ce sa faci cu noul cod PS2
        when new_code =>
             if(prev_ps2_code = x"FF") THEN    --codul indica faptul ca urmatoarea comanda este break
                         --se primeste FA--se verifica daca s-a primit 1 de la trensmisie
                          if(ps2_code = x"FA") then
                               --este pregatit pentru transmisie           
                               state <= ready;   
                            else
                                 state <= translate;          --s-a citit tot, se traduce, nu se mai citesc date, se traduce 
                        end if;  
                 end if;    
        
          --se ridica degetul de pe comanda: cheia în sus va trimite un "F0",  -chiar tranzitia
          if(ps2_code = x"F0") THEN    --codul indica faptul ca urmatoarea comanda este break
            break <= '1';                --set break flag
            state <= ready;              --reveniai la starea gata pentru a astepta urmatorul cod PS2
          ELSIF(ps2_code = x"E0") THEN --codul indica o comanda cu mai multe taste
            e0_code <= '1';              --setaai steag de comanda cu mai multe coduri
            state <= ready;              --reveniti la starea gata pentru a aatepta urmatorul cod PS2
          else                         --code is the last PS2 code in the make/break code
            state <= translate;          --translate state
          end if;

        --translate state: traducere cod PS2--> in valoare ASCII
        when translate =>
            --nu se mai asteapta niciun cod, s-au preluat toate 
            break <= '0';    --reset flag
            e0_code <= '0';  --reset comanda multi-code 
            
            -- coduri pt control, shift si caps lock
            case ps2_code IS
              when x"58" =>                   --cod pt CapsLock
                if(break = '0') THEN            --if fac comanda
                  caps_lock <= NOT caps_lock;     --schimb valoarea flag-ului
                end if;
              when x"14" =>                   --code pt CTRL
                if(e0_code = '1') THEN          --CTRL- dreapta
                  control_r <= NOT break;         --update right control flag
                else                            --CTRL - stanga
                  control_l <= NOT break;         --update
                end if;
              when x"12" =>                   --shift-stanga 
                shift_l <= NOT break;           --update left shift flag
              when x"59" =>                   --shift:dreapta
                shift_r <= NOT break;           --update 
               when others=>NULL;
            end case;
        
              
              --traduce literele (acestea depind atât de shift, cât ?i de caps lock)
              if((shift_r = '0' AND shift_l = '0' AND caps_lock = '0') OR
                ((shift_r = '1' OR shift_l = '1') AND caps_lock = '1')) THEN  --letere mici
                case ps2_code IS              
                  when x"1C" => ascii <= x"61"; --a
                  when x"32" => ascii <= x"62"; --b
                  when x"21" => ascii <= x"63"; --c
                  when x"23" => ascii <= x"64"; --d
                  when x"24" => ascii <= x"65"; --e
                  when x"2B" => ascii <= x"66"; --f
                  when x"34" => ascii <= x"67"; --g
                  when x"33" => ascii <= x"68"; --h
                  when x"43" => ascii <= x"69"; --i
                  when x"3B" => ascii <= x"6A"; --j
                  when x"42" => ascii <= x"6B"; --k
                  when x"4B" => ascii <= x"6C"; --l
                  when x"3A" => ascii <= x"6D"; --m
                  when x"31" => ascii <= x"6E"; --n
                  when x"44" => ascii <= x"6F"; --o
                  when x"4D" => ascii <= x"70"; --p
                  when x"15" => ascii <= x"71"; --q
                  when x"2D" => ascii <= x"72"; --r
                  when x"1B" => ascii <= x"73"; --s
                  when x"2C" => ascii <= x"74"; --t
                  when x"3C" => ascii <= x"75"; --u
                  when x"2A" => ascii <= x"76"; --v
                  when x"1D" => ascii <= x"77"; --w
                  when x"22" => ascii <= x"78"; --x
                  when x"35" => ascii <= x"79"; --y
                  when x"1A" => ascii <= x"7A"; --z
                   WHEN OTHERS => NULL;
                end case;
              else                                     --litera mare
                case ps2_code IS            
                  when x"1C" => ascii <= x"41"; --A
                  when x"32" => ascii <= x"42"; --B
                  when x"21" => ascii <= x"43"; --C
                  when x"23" => ascii <= x"44"; --D
                  when x"24" => ascii <= x"45"; --E
                  when x"2B" => ascii <= x"46"; --F
                  when x"34" => ascii <= x"47"; --G
                  when x"33" => ascii <= x"48"; --H
                  when x"43" => ascii <= x"49"; --I
                  when x"3B" => ascii <= x"4A"; --J
                  when x"42" => ascii <= x"4B"; --K
                  when x"4B" => ascii <= x"4C"; --L
                  when x"3A" => ascii <= x"4D"; --M
                  when x"31" => ascii <= x"4E"; --N
                  when x"44" => ascii <= x"4F"; --O
                  when x"4D" => ascii <= x"50"; --P
                  when x"15" => ascii <= x"51"; --Q
                  when x"2D" => ascii <= x"52"; --R
                  when x"1B" => ascii <= x"53"; --S
                  when x"2C" => ascii <= x"54"; --T
                  when x"3C" => ascii <= x"55"; --U
                  when x"2A" => ascii <= x"56"; --V
                  when x"1D" => ascii <= x"57"; --W
                  when x"22" => ascii <= x"58"; --X
                  when x"35" => ascii <= x"59"; --Y
                  when x"1A" => ascii <= x"5A"; --Z
                  WHEN OTHERS => NULL;
                end case;
              end if;
              
              --traduce?i numere ?i simboluri (acestea depind de Shift, de CapsLock, nu)
              if(shift_l = '1' OR shift_r = '1') THEN  --caracter secundar
                case ps2_code IS              
                  when x"16" => ascii <= x"21"; --!
                  when x"52" => ascii <= x"22"; --"
                  when x"26" => ascii <= x"23"; --#
                  when x"25" => ascii <= x"24"; --$
                  when x"2E" => ascii <= x"25"; --%
                  when x"3D" => ascii <= x"26"; --&              
                  when x"46" => ascii <= x"28"; --(
                  when x"45" => ascii <= x"29"; --)
                  when x"3E" => ascii <= x"2A"; --*
                  when x"55" => ascii <= x"2B"; --+
                  when x"4C" => ascii <= x"3A"; --:
                  when x"41" => ascii <= x"3C"; --<
                  when x"49" => ascii <= x"3E"; -->
                  when x"4A" => ascii <= x"3F"; --?
                  when x"1E" => ascii <= x"40"; --@
                  when x"36" => ascii <= x"5E"; --^
                  when x"4E" => ascii <= x"5F"; --_
                  when x"54" => ascii <= x"7B"; --{
                  when x"5D" => ascii <= x"7C"; --|
                  when x"5B" => ascii <= x"7D"; --}
                  when x"0E" => ascii <= x"7E"; --~
                  WHEN OTHERS => NULL;
                end case;
              else                                     --caracterele de dedesupt
                case ps2_code IS  
                  when x"45" => ascii <= x"30"; --0
                  when x"16" => ascii <= x"31"; --1
                  when x"1E" => ascii <= x"32"; --2
                  when x"26" => ascii <= x"33"; --3
                  when x"25" => ascii <= x"34"; --4
                  when x"2E" => ascii <= x"35"; --5
                  when x"36" => ascii <= x"36"; --6
                  when x"3D" => ascii <= x"37"; --7
                  when x"3E" => ascii <= x"38"; --8
                  when x"46" => ascii <= x"39"; --9
                  when x"52" => ascii <= x"27"; --'
                  when x"41" => ascii <= x"2C"; --,
                  when x"4E" => ascii <= x"2D"; ---
                  when x"49" => ascii <= x"2E"; --.
                  when x"4A" => ascii <= x"2F"; --/
                  when x"4C" => ascii <= x"3B"; --;
                  when x"55" => ascii <= x"3D"; --=
                  when x"54" => ascii <= x"5B"; --[
                  when x"5D" => ascii <= x"5C"; --\
                  when x"5B" => ascii <= x"5D"; --]
                  when x"0E" => ascii <= x"60"; --`
                  WHEN OTHERS => NULL;
                end case;
              end if;
                
          if(break = '0') THEN  --s-a procesat codul
            state <= output;      --starea de trimitere pe output
          else                  --code is a break
            state <= ready;       --reveni?i la starea "ready" pentru a a?tepta urm?torul cod PS2
          end if;
        
        --output state: verify the code is valid and output the ASCII value
        when output =>
            ascii_code <= ascii;   --output:valoarea Ascii
            state <= ready;         --gata pt un nou cod
      end case;
    end if;
  end PROCESS; 


end Behavioral;
