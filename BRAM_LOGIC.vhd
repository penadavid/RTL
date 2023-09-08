----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/06/2023 02:22:31 PM
-- Design Name: 
-- Module Name: BRAM_LOGIC - Behavioral
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

entity BRAM_LOGIC is
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
      
Port ( clk: in std_logic;
        command: in std_logic_vector(3 downto 0);
        reset: in std_logic;
        ready: out std_logic;
        
        --letterData
        en_letterData, we_letterData: out std_logic;
        addr_letterData_write : out std_logic_vector(LETTER_DATA_ADDR_SIZE-1  downto 0); 
        addr_letterData_read : out std_logic_vector(LETTER_DATA_ADDR_SIZE-1  downto 0); 
        data_letterData_out : out std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0);
        data_letterData_in : in std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0);
        
        --letterMatrix
        en_letterMatrix, we_letterMatrix: out std_logic;
        addr_letterMatrix_write : out std_logic_vector(LETTER_MATRIX_ADDR_SIZE-1  downto 0); 
        --addr_letterMatrix_read : out std_logic_vector(LETTER_MATRIX_ADDR_SIZE-1  downto 0); 
        data_letterMatrix_out : out std_logic_vector(LETTER_MATRIX_RAM_WIDTH - 1 downto 0);
       -- data_letterMatrix_in : in std_logic_vector(LETTER_MATRIX_RAM_WIDTH - 1 downto 0);
       
       --text
        en_text, we_text: out std_logic;
        addr_text_write : out std_logic_vector(TEXT_ADDR_SIZE - 1  downto 0); 
        --addr_possition_read : out std_logic_vector(POSSITION_ADDR_SIZE-1  downto 0); 
        data_text_out : out std_logic_vector(TEXT_RAM_WIDTH - 1 downto 0);
        --data_possition_in : in std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);
        
        --possition
        en_possition, we_possition: out std_logic;
        addr_possition_write : out std_logic_vector(POSSITION_ADDR_SIZE - 1  downto 0); 
        --addr_possition_read : out std_logic_vector(POSSITION_ADDR_SIZE-1  downto 0); 
        data_possition_out : out std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);
        --data_possition_in : in std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);
        
        --photo
        en_photo, we_photo: out std_logic;
        addr_photo_write : out std_logic_vector(PHOTO_ADDR_SIZE-1  downto 0); 
        --addr_possition_read : out std_logic_vector(POSSITION_ADDR_SIZE-1  downto 0); 
        data_photo_out : out std_logic_vector(PHOTO_RAM_WIDTH - 1 downto 0);
        --data_possition_in : in std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);
        
            
        --AXI_SLAVE_STREAM signals
        axis_s_data_in: in std_logic_vector(AXI_WIDTH - 1 downto 0);
        axis_s_valid:in std_logic;
        axis_s_last:in std_logic;
        axis_s_ready:out std_logic );
end BRAM_LOGIC;

architecture Behavioral of BRAM_LOGIC is
type state is (IDLE, LOAD_BRAMS,LOAD_ADDR, LOAD_FRAME_PARAMETERS);
signal state_reg, state_next: state;
signal addr_reg, addr_next: std_logic_vector(PHOTO_ADDR_SIZE-1  downto 0); 
signal frame_height_reg, frame_height_next, frame_width_reg, frame_width_next: std_logic_vector(10 downto 0);
signal bram_row_reg, bram_row_next: std_logic_vector(6 downto 0);
--signal command_reg, command_next: std_logic_vector(3 downto 0);

begin

process(clk, reset)
begin
    if reset='1' then
        state_reg <= IDLE;
        addr_reg<=(others =>'0');
        frame_width_reg<= (others =>'0');
        frame_height_reg<= (others =>'0');
        bram_row_reg<= (others =>'0');
        --command_reg <= (others =>'0');
    elsif rising_edge(clk) then
        state_reg <= state_next;
        addr_reg<=addr_next;
        frame_width_reg <= frame_width_next;
        frame_height_reg <= frame_height_next;
        bram_row_reg <= bram_row_next;
        
       -- command_reg<=command_next;
    end if;   
end process;

process(state_reg,addr_reg,command,frame_width_reg,frame_height_reg,bram_row_reg,
axis_s_valid,axis_s_last,axis_s_data_in)
begin
ready <= '0';
axis_s_ready <= '0';

addr_next<= addr_reg;
frame_width_next <= frame_width_reg;
frame_height_next <= frame_height_reg;
 bram_row_next <= bram_row_reg;

--command_next<=command_reg;

en_letterData<= '0';
we_letterData <= '0';
addr_letterData_write <= (others =>'0');
addr_letterData_read <= (others =>'0');

en_letterMatrix<= '0';
we_letterMatrix <= '0';
addr_letterMatrix_write <= (others =>'0');

en_text<= '0';
we_text <= '0';
addr_text_write <= (others =>'0');

en_possition<= '0';
we_possition <= '0';
addr_possition_write <= (others =>'0');

en_photo <= '0';
we_photo <= '0';
addr_photo_write <= (others =>'0');

    case state_reg is
        when idle =>
            ready<= '1';
            addr_next <= (others=>'0');     
            --command_next <= command;
            if(command = "0001" or command ="0010" or command = "0100" or command = "0101" or command = "0011") then
                state_next <= LOAD_BRAMS;
            else
                state_next<= IDLE;
            end if;
        when LOAD_BRAMS =>
            axis_s_ready <= '1';
            --determine next state
            if(axis_s_valid = '1')then
                if(axis_s_last ='0') then
                    state_next <=LOAD_BRAMS;
                else
                    if(command = "0010") then         
                        state_next <= LOAD_ADDR;
                    else
                        state_next <= IDLE;
                    end if;
                end if;
                --outputs
                
                addr_next <= std_logic_vector(UNSIGNED(addr_reg)+to_unsigned(1,LETTER_MATRIX_ADDR_SIZE));
                
                if(command = "0001") then
                    en_letterData <= '1';
                    we_letterData <= '1';
                    addr_letterData_write <= addr_reg(LETTER_DATA_ADDR_SIZE-1  downto 0);
                elsif(command = "0010") then
                    en_letterMatrix <= '1';
                    we_letterMatrix <= '1';
                    addr_letterMatrix_write <= addr_reg(LETTER_MATRIX_ADDR_SIZE-1  downto 0);
                elsif(command = "0011") then
                    en_text <= '1';
                    we_text <= '1';
                    addr_text_write <= addr_reg(TEXT_ADDR_SIZE-1  downto 0);
                elsif(command = "0100") then
                    en_possition <= '1';
                    we_possition <= '1';
                    addr_possition_write <= addr_reg(POSSITION_ADDR_SIZE-1  downto 0);
                elsif(command = "0101") then
                    en_photo <= '1';
                    we_photo <= '1';
                    addr_photo_write <= addr_reg(PHOTO_ADDR_SIZE-1  downto 0);
                end if;
                
           else
                state_next <= LOAD_BRAMS;
           end if;
       
        when LOAD_ADDR =>
            en_letterData <= '1';            
            addr_letterData_read <= std_logic_vector(to_unsigned(213,LETTER_DATA_ADDR_SIZE));
            state_next <= LOAD_FRAME_PARAMETERS;
        when LOAD_FRAME_PARAMETERS =>
            
            if( unsigned(data_letterData_in) = to_unsigned(0,LETTER_DATA_RAM_WIDTH)) then
                frame_width_next<= std_logic_vector(to_unsigned(640,11));
                frame_height_next<= std_logic_vector(to_unsigned(360,11));
                bram_row_next <= std_logic_vector(to_unsigned(104,7));
            elsif( unsigned(data_letterData_in) = to_unsigned(1,LETTER_DATA_RAM_WIDTH)) then
                frame_width_next<= std_logic_vector(to_unsigned(960,11));
                frame_height_next<= std_logic_vector(to_unsigned(540,11));
                bram_row_next <= std_logic_vector(to_unsigned(69,7));
             elsif( unsigned(data_letterData_in) = to_unsigned(2,LETTER_DATA_RAM_WIDTH)) then
                frame_width_next<= std_logic_vector(to_unsigned(1280,11));
                frame_height_next<= std_logic_vector(to_unsigned(720,11));
                bram_row_next <= std_logic_vector(to_unsigned(52,7));
             elsif( unsigned(data_letterData_in) = to_unsigned(3,LETTER_DATA_RAM_WIDTH)) then
                frame_width_next<= std_logic_vector(to_unsigned(1600,11));
                frame_height_next<= std_logic_vector(to_unsigned(900,11));
                bram_row_next <= std_logic_vector(to_unsigned(41,7));
             else
                frame_width_next<= std_logic_vector(to_unsigned(1920,11));
                frame_height_next<= std_logic_vector(to_unsigned(1080,11));
                bram_row_next <= std_logic_vector(to_unsigned(34,7));  
            end if;
            
            state_next <= IDLE;
                
                        
      end case;

data_letterData_out <= axis_s_data_in(LETTER_DATA_RAM_WIDTH - 1 downto 0);
data_letterMatrix_out <= axis_s_data_in(LETTER_MATRIX_RAM_WIDTH - 1 downto 0);
data_text_out <= axis_s_data_in(TEXT_RAM_WIDTH - 1 downto 0);
data_possition_out <= axis_s_data_in(POSSITION_RAM_WIDTH - 1 downto 0);
data_photo_out <= axis_s_data_in(PHOTO_RAM_WIDTH - 1 downto 0);

end process;


end Behavioral;
