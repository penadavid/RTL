----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/06/2023 04:06:31 PM
-- Design Name: 
-- Module Name: TOP_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP_tb is
generic (           
      --uvek saljemo primamo 16stobitne podatke pa ih rasporedjujemo posle           
       AXI_WIDTH: integer := 16;     
      --letterData   
      LETTER_DATA_RAM_WIDTH : integer := 8;
      LETTER_DATA_RAM_DEPTH : integer := 214;
      LETTER_DATA_ADDR_SIZE : integer := 8;
      --letterMatrix    
      LETTER_MATRIX_RAM_WIDTH : integer := 1;
      LETTER_MATRIX_RAM_DEPTH : integer := 46423;
      LETTER_MATRIX_ADDR_SIZE : integer := 16;
      --text
      TEXT_RAM_WIDTH : integer := 8;
      TEXT_RAM_DEPTH : integer := 200;
      TEXT_ADDR_SIZE : integer := 8;
      --photo    
      PHOTO_RAM_WIDTH : integer := 8;
      PHOTO_RAM_DEPTH : integer := 200000;
      PHOTO_ADDR_SIZE : integer := 18;
      --possition  
      POSSITION_RAM_WIDTH : integer := 16;
      POSSITION_RAM_DEPTH : integer := 106;
      POSSITION_ADDR_SIZE : integer := 7);
--  Port ( );
end TOP_tb;

architecture Behavioral of TOP_tb is
signal clk, reset, ready: std_logic;
signal command: std_logic_vector(3 downto 0);
signal axis_s_data_in:  std_logic_vector(AXI_WIDTH-1 downto 0);
signal axis_s_valid, axis_s_last, axis_s_ready: std_logic;
begin

tb: entity work.TOP
  generic map(AXI_WIDTH=>AXI_WIDTH,
              LETTER_DATA_RAM_WIDTH=>LETTER_DATA_RAM_WIDTH, 
             LETTER_DATA_RAM_DEPTH=>LETTER_DATA_RAM_DEPTH,
             LETTER_DATA_ADDR_SIZE =>LETTER_DATA_ADDR_SIZE,
             LETTER_MATRIX_RAM_WIDTH=>LETTER_MATRIX_RAM_WIDTH, 
             LETTER_MATRIX_RAM_DEPTH=>LETTER_MATRIX_RAM_DEPTH,
             LETTER_MATRIX_ADDR_SIZE =>LETTER_MATRIX_ADDR_SIZE,
             TEXT_RAM_WIDTH=> TEXT_RAM_WIDTH, 
             TEXT_RAM_DEPTH=>TEXT_RAM_DEPTH,
             TEXT_ADDR_SIZE =>TEXT_ADDR_SIZE,
             PHOTO_RAM_WIDTH => PHOTO_RAM_WIDTH, 
             PHOTO_RAM_DEPTH => PHOTO_RAM_DEPTH,
             PHOTO_ADDR_SIZE => PHOTO_ADDR_SIZE,
             POSSITION_RAM_WIDTH => POSSITION_RAM_WIDTH,
             POSSITION_RAM_DEPTH => POSSITION_RAM_DEPTH,
             POSSITION_ADDR_SIZE => POSSITION_ADDR_SIZE)
 port map(clk => clk,
 command => command,
 reset => reset,
 ready => ready,                                     
 axis_s_data_in => axis_s_data_in,
axis_s_valid => axis_s_valid,
axis_s_last => axis_s_last,
axis_s_ready => axis_s_ready
 );
 
 clk_gen: process
 begin
    clk <= '0', '1' after 10 ns;
    wait for 20 ns;
 end process;
 
 stim_gen: process
 begin
 reset<= '1';
 command <= "0000";
 wait for 40 ns;
 reset<= '0';
 
 command <= "0001";
 wait for 30 ns;
 axis_s_valid <= '1';
 axis_s_last<= '0';
 for i in 0 to 213
 loop
 axis_s_data_in <= std_logic_vector(to_unsigned(1,AXI_WIDTH));
 wait for 20 ns;
 end loop;
 axis_s_last<= '1';
 
 
 command <= "0010";
 wait for 50 ns;
 axis_s_valid <= '1';
 axis_s_last<= '0';
 for i in 0 to 3999
 loop
 axis_s_data_in <= std_logic_vector(to_unsigned(0,AXI_WIDTH));
 wait for 20 ns;
 axis_s_data_in <= std_logic_vector(to_unsigned(0,AXI_WIDTH));
 wait for 20 ns;
 axis_s_data_in <= std_logic_vector(to_unsigned(1,AXI_WIDTH));
 wait for 20 ns;
 axis_s_data_in <= std_logic_vector(to_unsigned(1,AXI_WIDTH));
 wait for 20 ns;
 end loop;
 axis_s_last<= '1';
 
 command <= "0011";
 wait for 30 ns;
 axis_s_valid <= '1';
 axis_s_last<= '0';
 for i in 0 to 99
 loop
 axis_s_data_in <= std_logic_vector(to_unsigned(10,AXI_WIDTH));
 wait for 20 ns;
 axis_s_data_in <= std_logic_vector(to_unsigned(5,AXI_WIDTH));
 wait for 20 ns;
 end loop;
 axis_s_last<= '1';
 command <= "0000";
 
 command <= "0101";
 wait for 30 ns;
 axis_s_valid <= '1';
 axis_s_last<= '0';
 for i in 0 to 1000
 loop
 axis_s_data_in <= std_logic_vector(to_unsigned(5,AXI_WIDTH));
 wait for 20 ns;
 end loop;
 axis_s_last<= '1';
 command <= "0000";
 
 command <= "0100";
 wait for 30 ns;
 axis_s_valid <= '1';
 axis_s_last<= '0';
 for i in 0 to 106
 loop
 axis_s_data_in <= std_logic_vector(to_unsigned(i*i,AXI_WIDTH));
 wait for 20 ns;
 end loop;
 axis_s_last<= '1';
 
 wait;
 
 
 end process;


end Behavioral;
