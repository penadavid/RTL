library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
      possition_y: in std_logic_vector(10 downto 0);
      
      --letterData
      en_letterData, we_letterData: out std_logic;
      addr_letterData_write : out std_logic_vector(LETTER_DATA_ADDR_SIZE - 1  downto 0); 
      addr_letterData_read1 : out std_logic_vector(LETTER_DATA_ADDR_SIZE - 1  downto 0); 
      addr_letterData_read2 : out std_logic_vector(LETTER_DATA_ADDR_SIZE - 1  downto 0);
      data_letterData_out : out std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0);
      data_letterData_in1 : in std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0);
      data_letterData_in2 : in std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0);
    
      --letterMatrix
      en_letterMatrix, we_letterMatrix: out std_logic;
      addr_letterMatrix_write : out std_logic_vector(LETTER_MATRIX_ADDR_SIZE - 1 downto 0); 
      addr_letterMatrix_read : out std_logic_vector(LETTER_MATRIX_ADDR_SIZE - 1  downto 0); 
      data_letterMatrix_out : out std_logic_vector(LETTER_MATRIX_RAM_WIDTH - 1 downto 0);
      data_letterMatrix_in : in std_logic_vector(LETTER_MATRIX_RAM_WIDTH - 1 downto 0);
    
      --possition
      en_possition, we_possition: out std_logic;
      addr_possition_write : out std_logic_vector(POSSITION_ADDR_SIZE - 1  downto 0); 
      addr_possition_read : out std_logic_vector(POSSITION_ADDR_SIZE - 1  downto 0); 
      data_possition_out : out std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);
      data_possition_in : in std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);
      
      --text
      en_text, we_text: out std_logic;
      addr_text_write : out std_logic_vector(TEXT_ADDR_SIZE - 1  downto 0); 
      addr_text_read : out std_logic_vector(TEXT_ADDR_SIZE - 1  downto 0); 
      data_text_out : out std_logic_vector(TEXT_RAM_WIDTH - 1 downto 0);
      data_text_in : in std_logic_vector(TEXT_RAM_WIDTH - 1 downto 0);
    
      --photo
      en_photo, we_photo: out std_logic;
      addr_photo_write : out std_logic_vector(PHOTO_ADDR_SIZE - 1 downto 0); 
      addr_photo_read : out std_logic_vector(PHOTO_ADDR_SIZE - 1  downto 0); 
      data_photo_out : out std_logic_vector(PHOTO_RAM_WIDTH - 1 downto 0);
      data_photo_in : in std_logic_vector(PHOTO_RAM_WIDTH - 1 downto 0);
        
      --AXI_SLAVE_STREAM signals
      axis_s_data_in: in std_logic_vector(AXI_WIDTH - 1 downto 0);
      axis_s_valid:in std_logic;
      axis_s_last:in std_logic;
      axis_s_ready:out std_logic );
end BRAM_LOGIC;

architecture Behavioral of BRAM_LOGIC is
type state is (IDLE, LOAD_BRAMS, RESET_CHARACTER_REGS, PROCESSING, Z_LOOP, GET_STRING_WIDTH_1, GET_STRING_WIDTH_2, CURRENT_Y_X, CURRENT_Y_X_2, CURRENT_Y_X_3, K_LOOP, K_LOOP_2, K_LOOP_3, K_LOOP_4, I_LOOP, I_LOOP_2, J_LOOP, J_LOOP_2, J_LOOP_WRITE_1, J_LOOP_WRITE_2, J_LOOP_WRITE_3);
signal state_reg, state_next: state;

signal addr_reg, addr_next: std_logic_vector(PHOTO_ADDR_SIZE - 1  downto 0); 
signal frame_height_reg, frame_height_next, frame_width_reg, frame_width_next: std_logic_vector(10 downto 0);
signal bram_row_reg, bram_row_next: std_logic_vector(6 downto 0);
--signal command_reg, command_next: std_logic_vector(3 downto 0);
signal number_character_reg, number_character_next : std_logic_vector(TEXT_ADDR_SIZE - 1 downto 0);
signal number_rows_reg, number_rows_next : std_logic_vector(2 downto 0);
signal number_character_row1_reg, number_character_row1_next : std_logic_vector(TEXT_ADDR_SIZE - 1 downto 0);
signal number_character_row2_reg, number_character_row2_next : std_logic_vector(TEXT_ADDR_SIZE - 1 downto 0);
signal number_character_row3_reg, number_character_row3_next : std_logic_vector(TEXT_ADDR_SIZE - 1 downto 0);
signal number_character_row4_reg, number_character_row4_next : std_logic_vector(TEXT_ADDR_SIZE - 1 downto 0);

signal spacing_reg, spacing_next: std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0);
signal y_reg, y_next: std_logic_vector(LETTER_DATA_RAM_WIDTH - 1 downto 0);
signal endCol_reg, endCol_next: std_logic_vector(10 downto 0);
signal startCol_reg, startCol_next: std_logic_vector(10 downto 0);
signal z_reg, z_next: std_logic_vector(2 downto 0);

signal start_reg, start_next: std_logic_vector(TEXT_RAM_WIDTH - 1 downto 0);
signal end_reg, end_next: std_logic_vector(TEXT_RAM_WIDTH - 1 downto 0);

signal k_reg, k_next: std_logic_vector(TEXT_RAM_WIDTH - 1 downto 0);
signal width_reg, width_next: std_logic_vector(10 downto 0); 

signal currX_reg, currX_next: std_logic_vector(10 downto 0);
signal currY_reg, currY_next: std_logic_vector(10 downto 0);

signal letterWidth_reg, letterWidth_next: std_logic_vector(7 downto 0);
signal letterHeight_reg, letterHeight_next: std_logic_vector(7 downto 0);
signal startPos_reg, startPos_next: std_logic_vector(POSSITION_RAM_WIDTH - 1 downto 0);
signal ascii_reg, ascii_next: std_logic_vector(7 downto 0);
signal tmp_currY_reg, tmp_currY_next: std_logic_vector(10 downto 0);
signal startY_reg, startY_next: std_logic_vector(7 downto 0);
signal endY_reg, endY_next: std_logic_vector(7 downto 0);
signal i_reg, i_next: std_logic_vector(7 downto 0);
signal j_reg, j_next: std_logic_vector(7 downto 0);
signal rowIndex_reg, rowIndex_next: std_logic_vector(7 downto 0);
signal idx_reg, idx_next: std_logic_vector(PHOTO_ADDR_SIZE - 1 downto 0);

--neg_adder1
signal en_neg_adder1_s: std_logic;
signal input1_neg_adder1_s: std_logic_vector(10 downto 0);
signal input2_neg_adder1_s: std_logic_vector(10 downto 0);
signal output_neg_adder1_s: std_logic_vector(10 downto 0);

--neg_adder2
signal en_neg_adder2_s: std_logic;
signal input1_neg_adder2_s: std_logic_vector(10 downto 0);
signal input2_neg_adder2_s: std_logic_vector(10 downto 0);
signal output_neg_adder2_s: std_logic_vector(10 downto 0);


--adder1
signal en_adder1_s: std_logic;
signal input1_adder1_s: std_logic_vector(10 downto 0);
signal input2_adder1_s: std_logic_vector(10 downto 0);
signal output_adder1_s: std_logic_vector(11 downto 0);

--adder2
signal en_adder2_s: std_logic;
signal input1_adder2_s: std_logic_vector(17 downto 0);
signal input2_adder2_s: std_logic_vector(17 downto 0);
signal output_adder2_s: std_logic_vector(18 downto 0);

--mul1
signal en_mul1_s: std_logic;
signal input1_mul1_s: std_logic_vector(10 downto 0);
signal input2_mul1_s: std_logic_vector(10 downto 0);
signal output_mul1_s: std_logic_vector(21 downto 0);

--pomocni registari koji su potrebani u k_loop
signal k_loop_reg, k_loop_next: std_logic_vector(10 downto 0);
signal width_spacing_reg, width_spacing_next: std_logic_vector(7 downto 0);

--pomocni registri koji su potrebni u i_loop
signal i_loop_reg, i_loop_next: std_logic_vector(15 downto 0);

--pomocni registar potreban za izracunavanje idx
signal tmp_idx_reg, tmp_idx_next: std_logic_vector(17 downto 0);
signal j_loop_reg, j_loop_next: std_logic_vector(11 downto 0);
--signal temp: std_logic_vector(21 downto 0);
--signal temp_reg, temp_next: std_logic_vector(15 downto 0);

begin
process(clk, reset)
begin
    if reset='1' then
        state_reg <= IDLE;
        addr_reg <= (others =>'0');
        frame_width_reg <= (others =>'0');
        frame_height_reg <= (others =>'0');
        bram_row_reg <= (others =>'0');
        number_character_reg <= (others =>'0');
        number_rows_reg <= (others =>'0');
        number_character_row1_reg <= (others =>'0');
        number_character_row2_reg <= (others =>'0');
        number_character_row3_reg <= (others =>'0');
        number_character_row4_reg <= (others =>'0');       
        spacing_reg <= (others =>'0');
        y_reg <= (others => '0');
        endCol_reg <= (others => '0');
        startCol_reg <= (others => '0');
        z_reg <= (others => '0');
        start_reg <= (others => '0');
        end_reg <= (others => '0');
        k_reg <= (others => '0');
        width_reg <= (others => '0');
        currX_reg <= (others => '0');
        currY_reg <= (others => '0');
        letterWidth_reg <= (others => '0');
        letterHeight_reg <= (others => '0');
        ascii_reg <= (others => '0');
        startPos_reg <= (others => '0'); 
        tmp_currY_reg <= (others => '0'); 
        startY_reg <= (others => '0');
        endY_reg <= (others => '0');
        i_reg <= (others => '0');
        j_reg <= (others => '0');
        rowIndex_reg <= (others => '0');
        idx_reg <= (others => '0');
        k_loop_reg <= (others => '0');
        width_spacing_reg <= (others => '0');
        i_loop_reg <= (others => '0');
        tmp_idx_reg <= (others => '0');
        j_loop_reg <= (others => '0');
        --temp_reg <= (others => '0');
        --command_reg <= (others =>'0');
    elsif rising_edge(clk) then
        state_reg <= state_next;
        addr_reg <= addr_next;
        frame_width_reg <= frame_width_next;
        frame_height_reg <= frame_height_next;
        bram_row_reg <= bram_row_next;
        number_character_reg <= number_character_next;
        number_rows_reg <= number_rows_next;
        number_character_row1_reg <= number_character_row1_next;
        number_character_row2_reg <= number_character_row2_next;
        number_character_row3_reg <= number_character_row3_next;
        number_character_row4_reg <= number_character_row4_next; 
        spacing_reg <= spacing_next;
        y_reg <= y_next;
        endCol_reg <= endCol_next;
        startCol_reg <= startCol_next;
        z_reg <= z_next;
        start_reg <= start_next;
        end_reg <= end_next;
        k_reg <= k_next;
        width_reg <= width_next;
        currX_reg <= currX_next;
        currY_reg <= currY_next;
        letterWidth_reg <= letterWidth_next;
        letterHeight_reg <= letterHeight_next;
        ascii_reg <= ascii_next;
        startPos_reg <= startPos_next;
        tmp_currY_reg <= tmp_currY_next;
        startY_reg <= startY_next;
        endY_reg <= endY_next;
        i_reg <= i_next;
        j_reg <= j_next;
        rowIndex_reg <= rowIndex_next;
        idx_reg <= idx_next;
        k_loop_reg <= k_loop_next;
        width_spacing_reg <= width_spacing_next;
        i_loop_reg <= i_loop_next;
        tmp_idx_reg <= tmp_idx_next;
        j_loop_reg <= j_loop_next;
        --temp_reg <= temp_next;
       -- command_reg<=command_next;
    end if;   
end process;

process(state_reg, addr_reg, command, frame_width_reg, frame_height_reg, bram_row_reg, axis_s_valid, axis_s_last, axis_s_data_in, number_character_reg, number_rows_reg, 
number_character_row1_reg, number_character_row2_reg, number_character_row3_reg, number_character_row4_reg, number_rows_next, spacing_reg, y_reg, endCol_reg, endCol_next, startCol_reg, z_reg, z_next, start_reg, end_reg, start_next, possition_y, 
k_reg, k_next, width_reg, currX_reg, currY_reg, currY_next, data_text_in, data_letterData_in1, data_letterData_in2, 
data_possition_in, data_letterMatrix_in, letterWidth_reg, letterWidth_next, letterHeight_reg, letterHeight_next, ascii_reg, 
ascii_next, startPos_reg, tmp_currY_reg, tmp_currY_next, startY_reg, startY_next, endY_reg,i_reg, i_next, j_reg, j_next, idx_reg, idx_next, rowIndex_next, rowIndex_reg, output_neg_adder1_s, output_neg_adder2_s, output_adder1_s, output_adder2_s, output_mul1_s, k_loop_reg, width_spacing_reg, i_loop_reg, tmp_idx_reg, j_loop_reg)
begin
    ready <= '0';
    axis_s_ready <= '0';

    addr_next<= addr_reg;
    frame_width_next <= frame_width_reg;
    frame_height_next <= frame_height_reg;
    bram_row_next <= bram_row_reg;
    number_character_next <= number_character_reg;
    number_rows_next <= number_rows_reg;
    number_character_row1_next <= number_character_row1_reg;
    number_character_row2_next <= number_character_row2_reg;
    number_character_row3_next <= number_character_row3_reg;
    number_character_row4_next <= number_character_row4_reg;
    --command_next<=command_reg;
    
    en_letterData <= '0';
    we_letterData <= '0';
    addr_letterData_write <= (others =>'0');
    addr_letterData_read1 <= (others =>'0');
    addr_letterData_read2 <= (others =>'0');

    en_letterMatrix <= '0';
    we_letterMatrix <= '0';
    addr_letterMatrix_write <= (others =>'0');
    addr_letterMatrix_read <= (others =>'0');

    en_possition <= '0';
    we_possition <= '0';
    addr_possition_write <= (others =>'0');
    addr_possition_read <= (others =>'0');
    
    en_text <= '0';
    we_text <= '0';
    addr_text_write <= (others =>'0');
    addr_text_read <= (others =>'0');

    en_photo <= '0';
    we_photo <= '0';
    addr_photo_write <= (others =>'0');
    addr_photo_read <= (others =>'0');
    
    spacing_next <= spacing_reg;
    y_next <= y_reg;
    endCol_next <= endCol_reg;
    startCol_next <= startCol_reg;
    z_next <= z_reg;
    end_next <= end_reg;
    start_next <= start_reg;
    
    k_next <= k_reg;
    width_next <= width_reg;
    currX_next <= currX_reg;
    currY_next <= currY_reg;
    
    --temp <= (others => '0');
    
    --neg_adder1
    en_neg_adder1_s <= '0';
    input1_neg_adder1_s <= (others => '0');
    input2_neg_adder1_s <= (others => '0');
    
     --neg_adder2
    en_neg_adder2_s <= '0';
    input1_neg_adder2_s <= (others => '0');
    input2_neg_adder2_s <= (others => '0');
    
    --adder1
    en_adder1_s <= '0';
    input1_adder1_s <= (others => '0');
    input2_adder1_s <= (others => '0');
    
    --adder2
    en_adder2_s <= '0';
    input1_adder2_s <= (others => '0');
    input2_adder2_s <= (others => '0');
    
    --mul1
    en_mul1_s <= '0';
    input1_mul1_s <= (others => '0');
    input2_mul1_s <= (others => '0');
    
    letterWidth_next <= letterWidth_reg;
    letterHeight_next <= letterHeight_reg;
    ascii_next <= ascii_reg;
    startPos_next <= startPos_reg;
    tmp_currY_next <= tmp_currY_reg;
    startY_next <= startY_reg;
    endY_next <= endY_reg;
    i_next <= i_reg;
    j_next <= j_reg;
    rowIndex_next <= rowIndex_reg;
    idx_next <= idx_reg;
    --temp_next <= temp_reg;
    
    k_loop_next <= (others => '0');
    width_spacing_next <= width_spacing_reg;
    i_loop_next <= i_loop_reg;
    tmp_idx_next <= tmp_idx_reg;
    j_loop_next <= j_loop_reg;

    case state_reg is
        when IDLE =>
            ready<= '1';
            addr_next <= (others=> '0');     
            --command_next <= command;
            if(command = "0001" or command ="0010" or command = "0100" or command = "0101") then
                state_next <= LOAD_BRAMS;
            elsif(command = "0011") then
                state_next <= RESET_CHARACTER_REGS;
            elsif(command = "0110") then
                state_next <= PROCESSING;
                en_letterData <= '1';
                addr_letterData_read1 <= std_logic_vector(to_unsigned(212,LETTER_DATA_ADDR_SIZE));
            else
                state_next <= IDLE;
            end if;
            
        when RESET_CHARACTER_REGS =>
            number_character_next <= (others => '0');
            number_rows_next <= (others => '0');
            number_character_row1_next <= (others => '0');
            number_character_row2_next <= (others => '0');
            number_character_row3_next <= (others => '0');
            number_character_row4_next <= (others => '0');
            
            state_next <= LOAD_BRAMS;
            
        when LOAD_BRAMS =>
            axis_s_ready <= '1';
            --determine next state
            if(axis_s_valid = '1') then 
                if(axis_s_last = '0') then
                    state_next <=LOAD_BRAMS;
                else
                    if(command = "0001") then
                        spacing_next <= std_logic_vector(unsigned(axis_s_data_in(LETTER_DATA_RAM_WIDTH - 1 downto 0)) + to_unsigned(1, LETTER_DATA_RAM_WIDTH));
                        if( unsigned(axis_s_data_in) = to_unsigned(0, AXI_WIDTH)) then
                            frame_width_next<= std_logic_vector(to_unsigned(640, 11));
                            frame_height_next<= std_logic_vector(to_unsigned(360, 11));
                            bram_row_next <= std_logic_vector(to_unsigned(104, 7));
                        elsif( unsigned(axis_s_data_in) = to_unsigned(1, AXI_WIDTH)) then
                            frame_width_next<= std_logic_vector(to_unsigned(960, 11));
                            frame_height_next<= std_logic_vector(to_unsigned(540, 11));
                            bram_row_next <= std_logic_vector(to_unsigned(69, 7));
                         elsif( unsigned(axis_s_data_in) = to_unsigned(2, AXI_WIDTH)) then
                            frame_width_next<= std_logic_vector(to_unsigned(1280, 11));
                            frame_height_next<= std_logic_vector(to_unsigned(720, 11));
                            bram_row_next <= std_logic_vector(to_unsigned(52, 7));
                         elsif( unsigned(axis_s_data_in) = to_unsigned(3, AXI_WIDTH)) then
                            frame_width_next<= std_logic_vector(to_unsigned(1600, 11));
                            frame_height_next<= std_logic_vector(to_unsigned(900, 11));
                            bram_row_next <= std_logic_vector(to_unsigned(41, 7));
                         else
                            frame_width_next<= std_logic_vector(to_unsigned(1920, 11));
                            frame_height_next<= std_logic_vector(to_unsigned(1080, 11));
                            bram_row_next <= std_logic_vector(to_unsigned(34, 7));  
                        end if;
                        state_next<= IDLE;
                    else
                        state_next <= IDLE;
                    end if;
                end if;
                
                
                addr_next <= std_logic_vector(UNSIGNED(addr_reg) + to_unsigned(1, LETTER_MATRIX_ADDR_SIZE));
                
                if(command = "0001") then
                    en_letterData <= '1';
                    we_letterData <= '1';
                    addr_letterData_write <= addr_reg(LETTER_DATA_ADDR_SIZE - 1  downto 0);
                elsif(command = "0010") then
                    en_letterMatrix <= '1';
                    we_letterMatrix <= '1';
                    addr_letterMatrix_write <= addr_reg(LETTER_MATRIX_ADDR_SIZE - 1  downto 0);
                elsif(command = "0100") then
                    en_possition <= '1';
                    we_possition <= '1';
                    addr_possition_write <= addr_reg(POSSITION_ADDR_SIZE - 1  downto 0);
                elsif(command = "0011") then
                    en_text <= '1';
                    we_text <= '1';
                    addr_text_write <= addr_reg(TEXT_ADDR_SIZE - 1  downto 0);
                    
                    number_character_next <= std_logic_vector(UNSIGNED(number_character_reg) + to_unsigned(1, TEXT_ADDR_SIZE));
                    if( unsigned(axis_s_data_in) = to_unsigned(255, AXI_WIDTH)) then
                        number_rows_next <= std_logic_vector(UNSIGNED(number_rows_reg) + to_unsigned(1, 3)); 
                    end if;
                    if (unsigned(number_rows_next) = to_unsigned(1,3)) then
                        number_character_row1_next <= std_logic_vector(UNSIGNED(number_character_row1_reg) + to_unsigned(1, TEXT_ADDR_SIZE));
                    elsif (unsigned(number_rows_next) = to_unsigned(2,3)) then
                        number_character_row2_next <= std_logic_vector(UNSIGNED(number_character_row2_reg) + to_unsigned(1, TEXT_ADDR_SIZE));
                    elsif (unsigned(number_rows_next) = to_unsigned(3,3)) then
                        number_character_row3_next <= std_logic_vector(UNSIGNED(number_character_row3_reg) + to_unsigned(1, TEXT_ADDR_SIZE));
                    elsif (unsigned(number_rows_next) = to_unsigned(4,3)) then
                        number_character_row4_next <= std_logic_vector(UNSIGNED(number_character_row4_reg) + to_unsigned(1, TEXT_ADDR_SIZE));
                    end if;
                             
                elsif(command = "0101") then
                    en_photo <= '1';
                    we_photo <= '1';
                    addr_photo_write <= addr_reg(PHOTO_ADDR_SIZE - 1  downto 0);
                end if;
                
            else
                state_next <= LOAD_BRAMS;
            end if;
            
            
        when PROCESSING =>
            y_next <= data_letterData_in1;          
            endCol_next <= possition_y;
            --oduzimamo pomocu komponente koja se mapira na dsp
            en_neg_adder1_s <= '1';
            input1_neg_adder1_s <= endCol_next;
            input2_neg_adder1_s <= "0000" & bram_row_reg;
            startCol_next <= output_neg_adder1_s;
 
            z_next <= "000";
            start_next <= (others => '0');
            end_next <= (others => '0');
            state_next <= Z_LOOP;
            
        when Z_LOOP =>
            if(z_reg = "000") then
                input1_adder1_s <= std_logic_vector(to_unsigned(1, 11));
                input1_adder2_s <= "0000000000" & number_character_row1_reg;
            elsif(z_reg = "001") then
                input1_adder1_s <= "000" & number_character_row1_reg;
                input1_adder2_s <= "0000000000" & number_character_row2_reg;
            elsif(z_reg = "010") then
                input1_adder1_s <= "000" & number_character_row2_reg;
                input1_adder2_s <= "0000000000" & number_character_row3_reg;
            elsif(z_reg = "011") then
                input1_adder1_s <= "000" & number_character_row3_reg;
                input1_adder2_s <= "0000000000" & number_character_row4_reg;
            end if;
            
            en_adder1_s <= '1';
            en_adder2_s <= '1';
            input2_adder1_s <= "000" & start_reg;
            input2_adder2_s <= "0000000000" & end_reg;
            
            start_next <= output_adder1_s(7 downto 0);
            end_next <= output_adder2_s(7 downto 0);
            
            k_next <= start_next;
            width_next <= std_logic_vector(TO_UNSIGNED(0, 11));
            addr_text_read <= start_next;
            en_text <= '1';
            
            state_next <= GET_STRING_WIDTH_1;
            
        when GET_STRING_WIDTH_1 =>
            addr_letterData_read2 <=  data_text_in(6 downto 0) & '0';
            en_letterData <= '1';

            en_adder1_s <= '1';            
            input1_adder1_s <= width_reg;
            input2_adder1_s <= "000" & spacing_reg;            
            width_next <=  output_adder1_s(10 downto 0);
            
            state_next <= GET_STRING_WIDTH_2;
        
        when GET_STRING_WIDTH_2 =>
            en_adder1_s <= '1';            
            input1_adder1_s <= width_reg;
            input2_adder1_s <= "000" & data_letterData_in2;            
            width_next <=  output_adder1_s(10 downto 0);
            
            k_next <= std_logic_vector(unsigned(k_reg) + TO_UNSIGNED(1, TEXT_ADDR_SIZE));                    
            if(unsigned(k_next) = unsigned(end_reg)) then
               state_next <= CURRENT_Y_X;    
            else
                state_next <= GET_STRING_WIDTH_1;
                addr_text_read <= k_next;
                en_text <= '1';
            end if;
        
        when CURRENT_Y_X =>
            en_neg_adder1_s <= '1';
            input1_neg_adder1_s <= frame_width_reg;
            input2_neg_adder1_s <= width_reg;
            currX_next <= '0' & output_neg_adder1_s(10 downto 1);
            
            en_mul1_s <= '1';
            input1_mul1_s <= "00000000" & z_reg;
            input2_mul1_s <= "000" & y_reg;
            currY_next <= output_mul1_s(10 downto 0);
            
            state_next <= CURRENT_Y_X_2;
           
        when CURRENT_Y_X_2 =>    
            en_adder1_s <= '1';            
            input1_adder1_s <= currY_reg;
            input2_adder1_s <= "0000" & y_reg(LETTER_DATA_RAM_WIDTH - 1 downto 1);            
            currY_next <=  output_adder1_s(10 downto 0); 
            
            state_next <= CURRENT_Y_X_3;
               
        when CURRENT_Y_X_3 =>    
            en_adder1_s <= '1';            
            input1_adder1_s <= currY_reg;
            input2_adder1_s <= "000" & y_reg(LETTER_DATA_RAM_WIDTH - 1 downto 0);            
    
            if(unsigned(currY_reg) >= unsigned(endCol_reg)) then
                z_next <= std_logic_vector(unsigned(z_reg) + TO_UNSIGNED(1, 3));
                if(z_next = number_rows_reg) then
                    state_next <= IDLE;    
                else
                    state_next <= Z_LOOP;
                end if;
            elsif(unsigned(output_adder1_s) <= unsigned(startCol_reg)) then
                z_next <= std_logic_vector(unsigned(z_reg) + TO_UNSIGNED(1, 3));
                if(unsigned(z_next) = unsigned(number_rows_reg)) then
                    state_next <= IDLE;    
                else
                    state_next <= Z_LOOP;
                end if;
            else
                k_next <= start_reg;
                addr_text_read <= start_reg;
                en_text <= '1';
                state_next <= K_LOOP;
            end if;
            
        when K_LOOP =>
            if(unsigned(data_text_in) >= to_unsigned(106, 8)) then
                ascii_next <= std_logic_vector(to_unsigned(31,8));
            else
                ascii_next <= data_text_in;
            end if;
                     
            addr_possition_read <= ascii_next(6 downto 0);
            en_possition <= '1';
            addr_letterData_read1 <= ascii_next(TEXT_RAM_WIDTH - 2 downto 0) & '0';
            addr_letterData_read2 <= std_logic_vector(unsigned(ascii_next(TEXT_RAM_WIDTH - 2 downto 0) & '0') + to_unsigned(1,TEXT_RAM_WIDTH));            
            en_letterData <= '1';
                     
            state_next <= K_LOOP_2;
            
----            width_next <= std_logic_vector(unsigned(endCol_reg) - to_unsigned(1,11));
       
        when K_LOOP_2 =>
            startPos_next <= data_possition_in;
            letterWidth_next <= data_letterData_in1;
            letterHeight_next <= data_letterData_in2;
            
            if(unsigned(ascii_reg) = to_unsigned(71,8) or unsigned(ascii_reg) = to_unsigned(74,8) or unsigned(ascii_reg) = to_unsigned(80,8) or unsigned(ascii_reg) = to_unsigned(81,8) or unsigned(ascii_reg) = to_unsigned(89,8)) then
                en_neg_adder1_s <= '1';
                input1_neg_adder1_s <= currY_reg;
                input2_neg_adder1_s <= "00000" & letterHeight_next(7 downto 2);
                tmp_currY_next <= output_neg_adder1_s;
            else
                tmp_currY_next <= currY_reg;
            end if;
            
            --LOGIKA ZA GENERISANJE IDX-a
            ----------------------------------------
            en_neg_adder2_s <= '1';
            input1_neg_adder2_s <= endCol_reg;
            input2_neg_adder2_s <=  std_logic_vector(to_unsigned(1,11));
            tmp_idx_next <= "0000000" & output_neg_adder2_s;
            -----------------------------------------
            
            state_next <= K_LOOP_3;

        when K_LOOP_3 =>
            en_adder1_s <= '1';            
            input1_adder1_s <= tmp_currY_reg;
            input2_adder1_s <= "000" & letterHeight_reg;            
            k_loop_next <=  output_adder1_s(10 downto 0); 
            
            en_adder2_s <= '1';            
            input1_adder2_s <= "0000000000" & letterWidth_reg;
            input2_adder2_s <= "0000000000" & spacing_reg;            
            width_spacing_next <=  output_adder2_s(7 downto 0); 
            
            --LOGIKA ZA GENERISANJE IDX-a
            ----------------------------------------
            en_neg_adder1_s <= '1';
            input1_neg_adder1_s <= tmp_idx_reg(10 downto 0);
            input2_neg_adder1_s <=  tmp_currY_reg;
            tmp_idx_next <= "0000000" & output_neg_adder1_s;
            
            -----------------------------------------
            
            state_next <= K_LOOP_4;
        
        when K_LOOP_4 =>    
            en_neg_adder1_s <= '1';
            input1_neg_adder1_s <= k_loop_reg;
            input2_neg_adder1_s <= startCol_reg;           
            
            en_neg_adder2_s <= '1';
            input1_neg_adder2_s <= k_loop_reg;
            input2_neg_adder2_s <= endCol_reg;

            state_next <= I_LOOP;
                
            if(unsigned(tmp_currY_reg)) < unsigned(startCol_reg) then
                if(unsigned(k_loop_reg) > unsigned(startCol_reg) and unsigned(k_loop_reg) <= unsigned(endCol_reg)) then
                    startY_next <= (others  => '0');
                    endY_next <= output_neg_adder1_s(7 downto 0);
                elsif(unsigned(k_loop_reg) > unsigned(endCol_reg)) then
                    startY_next <= output_neg_adder2_s(7 downto 0);
                    endY_next <= output_neg_adder1_s(7 downto 0);
                else
                    startY_next <= (others  => '0');
                    endY_next <= letterHeight_next;
                    
                    en_adder1_s <= '1';            
                    input1_adder1_s <= currX_reg;
                    input2_adder1_s <= "000" & width_spacing_reg;            
                    currX_next <= output_adder1_s(10 downto 0); 
                  
                    k_next <= std_logic_vector(unsigned(k_reg) + TO_UNSIGNED(1, TEXT_RAM_WIDTH));
                    if(unsigned(k_next) = unsigned(end_reg)) then
                        z_next <= std_logic_vector(unsigned(z_reg) + TO_UNSIGNED(1, 3));
                        if(unsigned(z_next) = unsigned(number_rows_reg)) then
                            state_next <= IDLE;    
                        else
                            state_next <= Z_LOOP;
                        end if;                       
                    else
                        state_next <= K_LOOP;
                    end if;
                end if;
            else 
                if(unsigned(k_loop_reg) > unsigned(endCol_reg)) then
                    startY_next <= output_neg_adder2_s(7 downto 0);
                    endY_next <= letterHeight_next;
                else
                    startY_next <= (others  => '0');
                    endY_next <= letterHeight_next;
                end if;
            end if;
            
            i_next <= startY_next;
                                   
            --width_next <= std_logic_vector(unsigned(width_reg) - unsigned(tmp_currY_next));
            
        when I_LOOP =>          
            rowIndex_next <= std_logic_vector(unsigned(letterHeight_reg) - to_unsigned(1,8));
            en_neg_adder2_s <= '1';
            input1_neg_adder2_s <= "000" & rowIndex_next;
            input2_neg_adder2_s <= "000" & i_reg;
            rowIndex_next <= output_neg_adder2_s(7 downto 0);
            
            en_mul1_s <= '1';
            input1_mul1_s <= "000" & i_reg;
            input2_mul1_s <= "000" & letterWidth_reg;
            i_loop_next <= output_mul1_s(15 downto 0);
                        
                                    
            state_next <= I_LOOP_2;
                     
        when I_LOOP_2 =>
            en_adder2_s <= '1';            
            input1_adder2_s <= "00" & startPos_reg;
            input2_adder2_s <= "00" & i_loop_reg;            
            i_loop_next <=  output_adder2_s(15 downto 0); 
            
             --LOGIKA ZA GENERISANJE IDX-a
            ----------------------------------------
            en_neg_adder1_s <= '1';
            input1_neg_adder1_s <= tmp_idx_reg(10 downto 0);
            input2_neg_adder1_s <=  "000" & rowIndex_next;
            tmp_idx_next <= "0000000" & output_neg_adder1_s;
          
            -----------------------------------------
              
            addr_letterMatrix_read <= i_loop_next;           
            en_letterMatrix <= '1';
            
            
            j_next <= (others => '0');
            

            state_next <= J_LOOP;
            
            --temp <= std_logic_vector((unsigned(width_reg) - unsigned(rowIndex_next)) * unsigned(frame_width_reg));
            --temp_next <= temp(15 downto 0);
       
        when J_LOOP =>
            if(unsigned(data_letterMatrix_in) = to_unsigned(1, LETTER_MATRIX_RAM_WIDTH)) then
                
                --LOGIKA ZA GENERISANJE IDX-a
                ----------------------------------------
                en_mul1_s <= '1';
                input1_mul1_s <= tmp_idx_reg(10 downto 0);
                input2_mul1_s <= frame_width_reg;
                tmp_idx_next <= output_mul1_s(17 downto 0);
                
                en_adder1_s <= '1';            
                input1_adder1_s <= currX_reg;
                input2_adder1_s <= "000" & j_reg;            
                j_loop_next <= output_adder1_s;
                              
                ----------------------------------------
                 
                state_next <= J_LOOP_2;
            else
                j_next <= std_logic_vector(unsigned(j_reg) + TO_UNSIGNED(1, 8));
                if(unsigned(j_next) = unsigned(letterWidth_reg)) then
                    i_next <= std_logic_vector(unsigned(i_reg) + to_unsigned(1, 8));
                    if(unsigned(i_next) = unsigned(endY_reg)) then
                        en_adder1_s <= '1';            
                        input1_adder1_s <= currX_reg;
                        input2_adder1_s <= "000" & width_spacing_reg;            
                        currX_next <= output_adder1_s(10 downto 0);
             
                        k_next <= std_logic_vector(unsigned(k_reg) + to_unsigned(1, 8));
                        if(unsigned(k_next) = unsigned(end_reg)) then
                           z_next <= std_logic_vector(unsigned(z_reg) + to_unsigned(1, 3));
                            if(unsigned(z_next) = unsigned(number_rows_reg)) then
                                state_next <= IDLE;
                            else
                                state_next <= Z_LOOP;
                            end if;
                        else
                            state_next <= K_LOOP;
                        end if;
                    else
                        state_next <= I_LOOP;
                    end if;
                else                     
                    en_adder2_s <= '1';            
                    input1_adder2_s <= "0000000000" & j_next;
                    input2_adder2_s <= "00" & i_loop_reg; 
                               
                    addr_letterMatrix_read <= output_adder2_s(15 downto 0);                    
                    en_letterMatrix <= '1';
                    
                    state_next <= J_LOOP;
                end if;
                
            end if;        
        when J_LOOP_2 =>
            --LOGIKA ZA GENERISANJE IDX-a
            ----------------------------------------
            en_adder2_s <= '1';            
            input1_adder2_s <= tmp_idx_reg;
            input2_adder2_s <= "000000" & j_loop_reg;            
            tmp_idx_next <=  output_adder2_s(16 downto 0) & '0';
            --------------------------------------------
            
            state_next <= J_LOOP_WRITE_1;
            
        when J_LOOP_WRITE_1 =>
            --LOGIKA ZA GENERISANJE IDX-a
            ----------------------------------------
            en_adder2_s <= '1';            
            input1_adder2_s <= tmp_idx_reg;
            input2_adder2_s <= tmp_idx_reg;            
            idx_next <=  output_adder2_s(17 downto 0);
            ----------------------------------------
             en_photo <= '1';
             addr_photo_write <= idx_next;
             data_photo_out <= std_logic_vector(to_unsigned(255, PHOTO_RAM_WIDTH));
            
            
            state_next <= J_LOOP_WRITE_2;
        when J_LOOP_WRITE_2 =>
            en_photo <= '1';
            addr_photo_write <= std_logic_vector(unsigned(idx_reg) + to_unsigned(1,18));
            data_photo_out <= std_logic_vector(to_unsigned(255,PHOTO_RAM_WIDTH));      
        
            state_next <= J_LOOP_WRITE_3;
          
        when J_LOOP_WRITE_3 => 
            en_photo <= '1';
            addr_photo_write <= std_logic_vector(unsigned(idx_reg) + to_unsigned(2,18));
            data_photo_out <= std_logic_vector(to_unsigned(255,PHOTO_RAM_WIDTH));
            
            j_next <= std_logic_vector(unsigned(j_reg) + TO_UNSIGNED(1, 8));
                if(unsigned(j_next) = unsigned(letterWidth_reg)) then
                    i_next <= std_logic_vector(unsigned(i_reg) + to_unsigned(1, 8));
                    if(unsigned(i_next) = unsigned(endY_reg)) then
                        en_adder1_s <= '1';            
                        input1_adder1_s <= currX_reg;
                        input2_adder1_s <= "000" & width_spacing_reg;            
                        currX_next <= output_adder1_s(10 downto 0);
             
                        k_next <= std_logic_vector(unsigned(k_reg) + to_unsigned(1, 8));
                        if(unsigned(k_next) = unsigned(end_reg)) then
                           z_next <= std_logic_vector(unsigned(z_reg) + to_unsigned(1, 3));
                            if(unsigned(z_next) = unsigned(number_rows_reg)) then
                                state_next <= IDLE;
                            else
                                state_next <= Z_LOOP;
                            end if;
                        else
                            state_next <= K_LOOP;
                        end if;
                    else
                        state_next <= I_LOOP;
                    end if;
                else                     
                    en_adder2_s <= '1';            
                    input1_adder2_s <= "0000000000" & j_next;
                    input2_adder2_s <= "00" & i_loop_reg; 
                               
                    addr_letterMatrix_read <= output_adder2_s(15 downto 0);                    
                    en_letterMatrix <= '1';
                    
                    state_next <= J_LOOP;
                end if;
                        
    end case;

    data_letterData_out <= axis_s_data_in(LETTER_DATA_RAM_WIDTH - 1 downto 0);
    data_letterMatrix_out <= axis_s_data_in(LETTER_MATRIX_RAM_WIDTH - 1 downto 0);
    data_possition_out <= axis_s_data_in(POSSITION_RAM_WIDTH - 1 downto 0);
    data_photo_out <= axis_s_data_in(PHOTO_RAM_WIDTH - 1 downto 0);
    data_text_out <= axis_s_data_in(TEXT_RAM_WIDTH - 1 downto 0);

end process;

neg_adder1: entity work.neg_adder
    generic map (WIDTH => 11)
    port map(
            en => en_neg_adder1_s,
            input_1 => input1_neg_adder1_s,
            input_2 => input2_neg_adder1_s,
            output => output_neg_adder1_s
            );
            
neg_adder2: entity work.neg_adder
    generic map (WIDTH => 11)
    port map(
            en => en_neg_adder2_s,
            input_1 => input1_neg_adder2_s,
            input_2 => input2_neg_adder2_s,
            output => output_neg_adder2_s
            );
            
adder1: entity work.adder
    generic map (WIDTH => 11)
    port map(
            en => en_adder1_s,
            input_1 => input1_adder1_s,
            input_2 => input2_adder1_s,
            output => output_adder1_s
            );
            
adder2: entity work.adder
    generic map (WIDTH => 18)
    port map(
            en => en_adder2_s,
            input_1 => input1_adder2_s,
            input_2 => input2_adder2_s,
            output => output_adder2_s
            );
        
mul1: entity work.multiplier
    generic map (WIDTH => 11)
    port map(
            en => en_mul1_s,
            input_1 => input1_mul1_s,
            input_2 => input2_mul1_s,
            output => output_mul1_s
            );

end Behavioral;