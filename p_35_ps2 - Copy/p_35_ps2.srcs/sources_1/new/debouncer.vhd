--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_arith.ALL;
--use IEEE.STD_LOGIC_unsigned.ALL;

--entity debouncer is
--  Port (Reste:in std_logic;
--        Clk,D_IN:in std_logic;
--        Q_OUT: out std_logic);
--end debouncer;

--architecture Behavioral of debouncer is
--signal Q1, Q2, Q3 : std_logic;
--begin

--process(Clk)
--begin
--   if (rising_edge(Clk)) then
--      if (Reste = '1') then
--         Q1 <= '0';
--         Q2 <= '0';
--         Q3 <= '0';
--      else
--         Q1 <= D_IN;
--         Q2 <= Q1;
--         Q3 <= Q2;
--      end if;
--   end if;
--end process;

--Q_OUT <= Q1 and Q2 and (not Q3);

--end Behavioral;
