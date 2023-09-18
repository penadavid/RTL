----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/06/2023 01:23:36 PM
-- Design Name: 
-- Module Name: BRAM_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BRAM_2READ_PORTS_tb is
generic (
        RAM_WIDTH : integer := 8;
        RAM_DEPTH : integer := 214;
        ADDR_SIZE : integer := 8);
--  Port ( );
end BRAM_2READ_PORTS_tb;

architecture Behavioral of BRAM_2READ_PORTS_tb is
signal clk : std_logic;
signal we : std_logic;
signal en : std_logic;
signal addr_read1, addr_read2 : std_logic_vector(ADDR_SIZE - 1  downto 0);
signal addr_write : std_logic_vector(ADDR_SIZE-1  downto 0);         
signal data_in : std_logic_vector(RAM_WIDTH - 1 downto 0);  
signal data_out1, data_out2 : std_logic_vector(RAM_WIDTH - 1 downto 0);

begin

letterData_bram: entity work.BRAM_2READ_PORTS 
    generic map(RAM_WIDTH=>RAM_WIDTH, RAM_DEPTH=>RAM_DEPTH, ADDR_SIZE=>ADDR_SIZE)
    port map(clk=>clk,
             en=>en, 
             we=>we,
             addr_read1=>addr_read1,
             addr_read2=>addr_read2,
             addr_write=>addr_write,
             data_in=>data_in,
             data_out1=>data_out1,
             data_out2=>data_out2);

clk_gen: process is
begin
    clk <= '0', '1' after 10 ns;
    wait for 20ns;
end process;

stim_gen: process is
begin
--inicijslizacija
addr_write <= (others => '0');
data_in <= (others => '0');
we <= '0';
en <= '0';

wait for 20 ns;

en <= '1';
we <= '1';

for i in 0 to 213 
loop
    addr_write <= std_logic_vector(to_unsigned(i,ADDR_SIZE));
    data_in <= std_logic_vector(to_unsigned(i,RAM_WIDTH));
    wait for 20 ns;
end loop;

we <= '0';

wait for 20 ns;

for i in 0 to 213
loop
    addr_read1 <= std_logic_vector(to_unsigned(i,ADDR_SIZE));
    addr_read2 <= std_logic_vector(to_unsigned(213-i,ADDR_SIZE));
    wait for 20 ns;
end loop;
wait;

end process;
end Behavioral;
