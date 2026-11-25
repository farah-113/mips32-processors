library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port ( clk           : in STD_LOGIC;
           rst           : in STD_LOGIC;
           en            : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
           JumpAddress   : in STD_LOGIC_VECTOR(31 downto 0);
           JRAddress     : in STD_LOGIC_VECTOR(31 downto 0); 
           Jump          : in STD_LOGIC;
           PCSrc         : in STD_LOGIC;
           JmpR          : in STD_LOGIC;             
           Instruction   : out STD_LOGIC_VECTOR(31 downto 0);
           PC_plus_4     : out STD_LOGIC_VECTOR(31 downto 0));
end IFetch;

architecture Behavioral of IFetch is

    signal PC             : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal next_PC        : STD_LOGIC_VECTOR(31 downto 0);
    signal PC4            : STD_LOGIC_VECTOR(31 downto 0);
    signal branch_mux_out : STD_LOGIC_VECTOR(31 downto 0);
    signal jump_mux_out   : STD_LOGIC_VECTOR(31 downto 0);

    type tROM is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal ROM : tROM := (
        -- Initialization Stage
        B"100011_00000_00001_0000000000000000", -- X"8C010000", 00: LW   $1, 0($0) ,Loads array starting address (16) into $1
        B"100011_00000_00010_0000000000000100", -- X"8C020004", 01: LW   $2, 4($0) ,Loads array length (3) into $2 (loop counter)
        B"001000_00001_00011_1111111111111000", -- X"2023FFF8", 02: ADDI $3, $1, -8 ,Calculates destination array address (16-8=8) into $3

        -- Loop Start
        B"000100_00010_00000_0000000000000111", -- X"10400007", 03: BEQ  $2, $0, 7 ,branch to end of program
        
        B"100011_00001_00100_0000000000000000", -- X"8C240000", 04: LW   $4, 0($1) ,Load current array element into $4
        B"000000_00000_00100_00100_00001_000000", -- X"00042040", 05: SLL  $4, $4, 1 ,Multiply element by 2 (shift left logical)
        B"101011_00011_00100_0000000000000000", -- X"AC640000", 06: SW   $4, 0($3) ,Store multiplied result into destination array
        B"001000_00001_00001_0000000000000100", -- X"20210004", 07: ADDI $1, $1, 4 ,Increment source pointer to next element
        B"001000_00011_00011_0000000000000100", -- X"20630004", 08: ADDI $3, $3, 4 ,Increment destination pointer to next element
        B"001000_00010_00010_1111111111111111", -- X"2042FFFF", 09: ADDI $2, $2, -1 ,Decrement loop counter by 1
        B"000010_00000000000000000000000011",   -- X"08000003", 10: J 3 ,Jump back to start of loop (BEQ instruction)
        
        -- End of program
        B"000010_00000000000000000000001011",   -- X"0800000B", 11: J 11 ,Infinite loop to end program

        others => X"00000000"
    );

begin

    -- PC Register
    process(clk, rst)
    begin
        if rst = '1' then
            PC <= (others => '0');      
        elsif rising_edge(clk) then
            if en = '1' then
                PC <= next_PC;          
            end if;
        end if;
    end process;

    -- PC + 4 Adder
    PC4 <= PC + 4;
    PC_plus_4 <= PC4; 

    -- Multiplexers 
    branch_mux_out <= BranchAddress when PCSrc = '1' else PC4;
    jump_mux_out   <= JumpAddress when Jump = '1' else branch_mux_out;
    next_PC        <= JRAddress when JmpR = '1' else jump_mux_out;

    -- Instruction Memory
    Instruction <= ROM(conv_integer(PC(6 downto 2)));

end Behavioral;