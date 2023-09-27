library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DATA_BRAM is
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
      --photo    
      PHOTO_RAM_WIDTH : integer := 8;
      PHOTO_RAM_DEPTH : integer := 200000;
      PHOTO_ADDR_SIZE : integer := 18;
      --text
      TEXT_RAM_WIDTH : integer := 8;
      TEXT_RAM_DEPTH : integer := 200;
      TEXT_ADDR_SIZE : integer := 8;
      --possition  
      POSSITION_RAM_WIDTH : integer := 16;
      POSSITION_RAM_DEPTH : integer := 106;
      POSSITION_ADDR_SIZE : integer := 7);
Port ( 
        clk: in std_logic;
            
        en_letterData, we_letterData: in  std_logic;
        addr_letterData_write: in std_logic_vector(LETTER_DATA_ADDR_SIZE - 1 downto 0);
        addr_letterData_read_1: in std_logic_vector(LETTER_DATA_ADDR_SIZE - 1 downto 0);
        addr_letterData_read_2: in std_logic_vector(LETTER_DATA_ADDR_SIZE - 1 downto 0);
        data_letterData_in: in  std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0);
        data_letterData_out_1: out  std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0); 
        data_letterData_out_2: out  std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0); 
        
    
        en_letterMatrix, we_letterMatrix:in  std_logic;
        addr_letterMatrix_write: in  std_logic_vector(LETTER_MATRIX_ADDR_SIZE - 1 downto 0);
        addr_letterMatrix_read:in  std_logic_vector(LETTER_MATRIX_ADDR_SIZE-1 downto 0);
        data_letterMatrix_in: in  std_logic_vector(LETTER_MATRIX_RAM_WIDTH - 1  downto 0);
        data_letterMatrix_out: out  std_logic_vector(LETTER_MATRIX_RAM_WIDTH - 1  downto 0);
        
        --possition
        en_possition, we_possition: in  std_logic;
        addr_possition_write: in  std_logic_vector(POSSITION_ADDR_SIZE - 1  downto 0); 
        addr_possition_read: in  std_logic_vector(POSSITION_ADDR_SIZE-1  downto 0); 
        data_possition_in: in  std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);         
        data_possition_out: out  std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);         
        
        --text
        en_text, we_text: in  std_logic;
        addr_text_write: in  std_logic_vector(TEXT_ADDR_SIZE - 1 downto 0);
        addr_text_read: in  std_logic_vector(TEXT_ADDR_SIZE - 1 downto 0);
        data_text_in: in  std_logic_vector(TEXT_RAM_WIDTH - 1  downto 0);
        data_text_out: out  std_logic_vector(TEXT_RAM_WIDTH - 1  downto 0);
         
            
        --photo
        en_photo, we_photo: in  std_logic;
        addr_photo_write: in  std_logic_vector(PHOTO_ADDR_SIZE - 1  downto 0); 
        addr_photo_read: in  std_logic_vector(PHOTO_ADDR_SIZE - 1  downto 0); 
        data_photo_in: in  std_logic_vector(PHOTO_RAM_WIDTH - 1 downto 0);
        data_photo_out: out  std_logic_vector(PHOTO_RAM_WIDTH - 1 downto 0)
     );
end DATA_BRAM;


architecture Behavioral of DATA_BRAM is
begin   
bram_letterData: entity work.BRAM_2READ_PORTS
generic map(RAM_WIDTH => LETTER_DATA_RAM_WIDTH, RAM_DEPTH => LETTER_DATA_RAM_DEPTH, ADDR_SIZE => LETTER_DATA_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_letterData,                                     
         we => we_letterData,                                     
         addr_read1 => addr_letterData_read_1,
         addr_read2 => addr_letterData_read_2,                 
         addr_write => addr_letterData_write,      
         data_in => data_letterData_in, 
         data_out1 =>  data_letterData_out_1,
         data_out2 =>  data_letterData_out_2);
 
bram_letterMatrix: entity work.BRAM
generic map(RAM_WIDTH => LETTER_MATRIX_RAM_WIDTH, RAM_DEPTH => LETTER_MATRIX_RAM_DEPTH, ADDR_SIZE => LETTER_MATRIX_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_letterMatrix,                                     
         we => we_letterMatrix,                                     
         addr_read => addr_letterMatrix_read,                
         addr_write => addr_letterMatrix_write,      
         data_in => data_letterMatrix_in, 
         data_out => data_letterMatrix_out);
 
bram_possition: entity work.BRAM
generic map(RAM_WIDTH => POSSITION_RAM_WIDTH, RAM_DEPTH => POSSITION_RAM_DEPTH, ADDR_SIZE => POSSITION_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_possition,                                     
         we => we_possition,                                     
         addr_read => addr_possition_read,                
         addr_write => addr_possition_write,      
         data_in => data_possition_in, 
         data_out => data_possition_out);
 
bram_photo: entity work.BRAM
generic map(RAM_WIDTH => PHOTO_RAM_WIDTH, RAM_DEPTH => PHOTO_RAM_DEPTH, ADDR_SIZE => PHOTO_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_photo,                                     
         we => we_photo,                                     
         addr_read => addr_photo_read,                
         addr_write => addr_photo_write,      
         data_in => data_photo_in, 
         data_out => data_photo_out);
         
bram_text: entity work.BRAM
generic map(RAM_WIDTH => TEXT_RAM_WIDTH, RAM_DEPTH => TEXT_RAM_DEPTH, ADDR_SIZE => TEXT_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_text,                                     
         we => we_text,                                     
         addr_read => addr_text_read,                
         addr_write => addr_text_write,      
         data_in => data_text_in, 
         data_out => data_text_out);

end Behavioral;
