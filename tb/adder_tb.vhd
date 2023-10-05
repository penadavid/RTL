
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity adder_tb is
generic(
        WIDTH : positive := 8
        );
--  Port ( );
end adder_tb;

architecture Behavioral of adder_tb is
signal en_s : std_logic;
signal input1_s, input2_s : std_logic_vector(WIDTH - 1 downto 0);
signal output_s: std_logic_vector(WIDTH - 1 downto 0);

begin

add: entity work.adder
    generic map (WIDTH => WIDTH)
    port map(
            en => en_s,
            input_1 => input1_s,
            input_2 => input2_s,
            output => output_s
            );


stim_gen: process is
begin 
en_s <= '0', '1' after 50ns;
input1_s <= "00010101";
input2_s <= "00001011";
wait for 200ns;
input1_s <= "00010011";
input2_s <= "00000111";
wait for 200ns;
wait;

end process;

end Behavioral;
