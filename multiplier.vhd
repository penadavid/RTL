
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier is
generic(
          WIDTH : positive := 8
          );
  Port (
        input_1 : in std_logic_vector(WIDTH - 1 downto 0);
        input_2 : in std_logic_vector(WIDTH - 1 downto 0);
        en : in std_logic;
        output : out std_logic_vector(WIDTH*2 - 1 downto 0)
         );
end multiplier;

architecture Behavioral of multiplier is
attribute use_dsp : string;
attribute use_dsp of Behavioral : architecture is "yes";

begin
process(en, input_1, input_2) is
begin
    if (en = '0') then
        output <= (others => '0');
    else        
        output <= std_logic_vector(unsigned(input_1) * unsigned(input_2));
    end if;

end process;

end Behavioral;
