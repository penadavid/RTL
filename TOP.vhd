library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP is
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
      command: in std_logic_vector(3 downto 0);
      reset: in std_logic;
      ready: out std_logic;
      axis_s_data_in: in std_logic_vector(AXI_WIDTH-1 downto 0);
      axis_s_valid:in std_logic;
      axis_s_last:in std_logic;
      axis_s_ready:out std_logic;
      possition_y: in std_logic_vector(10 downto 0));
end TOP;

architecture Behavioral of TOP is
signal en_letterData_s, we_letterData_s: std_logic;
signal addr_letterData_write_s: std_logic_vector(LETTER_DATA_ADDR_SIZE - 1 downto 0);
signal addr_letterData_read_s1: std_logic_vector(LETTER_DATA_ADDR_SIZE - 1 downto 0);
signal addr_letterData_read_s2: std_logic_vector(LETTER_DATA_ADDR_SIZE - 1 downto 0);
signal data_letterData_out_s: std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0); 
signal data_letterData_in_s1: std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0);
signal data_letterData_in_s2: std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0);  

signal en_letterMatrix_s, we_letterMatrix_s: std_logic;
signal addr_letterMatrix_write_s: std_logic_vector(LETTER_MATRIX_ADDR_SIZE - 1 downto 0);
signal addr_letterMatrix_read_s: std_logic_vector(LETTER_MATRIX_ADDR_SIZE-1 downto 0);
signal data_letterMatrix_out_s: std_logic_vector(LETTER_MATRIX_RAM_WIDTH - 1  downto 0);
signal data_letterMatrix_in_s: std_logic_vector(LETTER_MATRIX_RAM_WIDTH-1  downto 0);  

--possition
signal en_possition_s, we_possition_s: std_logic;
signal addr_possition_write_s : std_logic_vector(POSSITION_ADDR_SIZE - 1  downto 0); 
signal addr_possition_read_s : std_logic_vector(POSSITION_ADDR_SIZE-1  downto 0); 
signal data_possition_out_s : std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);
signal data_possition_in_s : std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);

--text
signal en_text_s, we_text_s: std_logic;
signal addr_text_write_s: std_logic_vector(TEXT_ADDR_SIZE - 1 downto 0);
signal addr_text_read_s: std_logic_vector(TEXT_ADDR_SIZE - 1 downto 0);
signal data_text_out_s: std_logic_vector(TEXT_RAM_WIDTH - 1  downto 0);
signal data_text_in_s: std_logic_vector(TEXT_RAM_WIDTH - 1  downto 0);
        
--photo
signal en_photo_s, we_photo_s: std_logic;
signal addr_photo_write_s : std_logic_vector(PHOTO_ADDR_SIZE - 1  downto 0); 
signal addr_photo_read_s : std_logic_vector(PHOTO_ADDR_SIZE - 1  downto 0); 
signal data_photo_out_s : std_logic_vector(PHOTO_RAM_WIDTH - 1 downto 0);
signal data_photo_in_S : std_logic_vector(PHOTO_RAM_WIDTH - 1 downto 0);

begin

bram_letterData: entity work.BRAM_2READ_PORTS
generic map(RAM_WIDTH=>LETTER_DATA_RAM_WIDTH, RAM_DEPTH=>LETTER_DATA_RAM_DEPTH, ADDR_SIZE=>LETTER_DATA_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_letterData_s,                                     
         we => we_letterData_s,                                     
         addr_read1 => addr_letterData_read_s1,
         addr_read2 => addr_letterData_read_s2,                 
         addr_write => addr_letterData_write_s,      
         data_in => data_letterData_out_s, 
         data_out1 => data_letterData_in_s1,
         data_out2 => data_letterData_in_s2);
 
bram_letterMatrix: entity work.BRAM
generic map(RAM_WIDTH=>LETTER_MATRIX_RAM_WIDTH, RAM_DEPTH=>LETTER_MATRIX_RAM_DEPTH, ADDR_SIZE=>LETTER_MATRIX_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_letterMatrix_s,                                     
         we => we_letterMatrix_s,                                     
         addr_read => addr_letterMatrix_read_s,                
         addr_write => addr_letterMatrix_write_s,      
         data_in => data_letterMatrix_out_s, 
         data_out => data_letterMatrix_in_s);
 
bram_possition: entity work.BRAM
generic map(RAM_WIDTH=>POSSITION_RAM_WIDTH, RAM_DEPTH=>POSSITION_RAM_DEPTH, ADDR_SIZE=>POSSITION_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_possition_s,                                     
         we => we_possition_s,                                     
         addr_read => addr_possition_read_s,                
         addr_write => addr_possition_write_s,      
         data_in => data_possition_out_s, 
         data_out => data_possition_in_s);
 
bram_photo: entity work.BRAM
generic map(RAM_WIDTH=>PHOTO_RAM_WIDTH, RAM_DEPTH=>PHOTO_RAM_DEPTH, ADDR_SIZE=>PHOTO_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_photo_s,                                     
         we => we_photo_s,                                     
         addr_read => addr_photo_read_s,                
         addr_write => addr_photo_write_s,      
         data_in => data_photo_out_s, 
         data_out => data_photo_in_s);
         
bram_text: entity work.BRAM
generic map(RAM_WIDTH=>TEXT_RAM_WIDTH, RAM_DEPTH=>TEXT_RAM_DEPTH, ADDR_SIZE=>TEXT_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_text_s,                                     
         we => we_text_s,                                     
         addr_read => addr_text_read_s,                
         addr_write => addr_text_write_s,      
         data_in => data_text_out_s, 
         data_out => data_text_in_s);
 
 bram_logic: entity work.BRAM_LOGIC
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
          possition_y => possition_y,                    
                  
          en_letterData => en_letterData_s,                                     
          we_letterData => we_letterData_s,                                     
          addr_letterData_write => addr_letterData_write_s,
          addr_letterData_read1 => addr_letterData_read_s1,
          addr_letterData_read2 => addr_letterData_read_s2,                      
          data_letterData_out => data_letterData_out_s,
          data_letterData_in1 => data_letterData_in_s1,
          data_letterData_in2 => data_letterData_in_s2,
 
          en_letterMatrix => en_letterMatrix_s,                                     
          we_letterMatrix => we_letterMatrix_s,                                     
          addr_letterMatrix_write => addr_letterMatrix_write_s,
          addr_letterMatrix_read => addr_letterMatrix_read_s,                      
          data_letterMatrix_out => data_letterMatrix_out_s,
          data_letterMatrix_in => data_letterMatrix_in_s,
 
          en_possition => en_possition_s,                                     
          we_possition => we_possition_s,                                     
          addr_possition_write => addr_possition_write_s, 
          addr_possition_read => addr_possition_read_s,                     
          data_possition_out => data_possition_out_s,
          data_possition_in => data_possition_in_s,
          
          en_text => en_text_s,                                     
          we_text => we_text_s,                                     
          addr_text_write => addr_text_write_s,
          addr_text_read => addr_text_read_s,                      
          data_text_out => data_text_out_s,
          data_text_in => data_text_in_s,
 
          en_photo => en_photo_s,                                     
          we_photo => we_photo_s,                                     
          addr_photo_write => addr_photo_write_s,
          addr_photo_read => addr_photo_read_s,                      
          data_photo_out => data_photo_out_s,
          data_photo_in => data_photo_in_s,
 
          axis_s_data_in => axis_s_data_in,
          axis_s_valid => axis_s_valid,
          axis_s_last => axis_s_last,
          axis_s_ready => axis_s_ready);
 
end Behavioral;