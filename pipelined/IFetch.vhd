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
        B"100011_00000_00001_0000000000000000", -- X"8C010000", 00: LW   $1, 0($0)  -- Load array starting address (16) into $1
        B"100011_00000_00010_0000000000000100", -- X"8C020004", 01: LW   $2, 4($0)  -- Load array length (3) into $2 (loop counter)
        B"000000_00000_00000_00000_00000_000000", -- X"00000000", 02: NOP           -- Hazard space for reading $1
        B"001000_00001_00011_1111111111111000", -- X"2023FFF8", 03: ADDI $3, $1, -8 -- Calculate destination array address in $3
        B"000100_00010_00000_0000000000001111", -- X"1040000F", 04: BEQ  $2, $0, 15 -- Jump to end of program (Target: line 20)
        B"000000_00000_00000_00000_00000_000000", -- X"00000000", 05: NOP           -- Conditional jump delay (Branch)
        B"000000_00000_00000_00000_00000_000000", -- X"00000000", 06: NOP           -- Conditional jump delay (Branch)
        B"000000_00000_00000_00000_00000_000000", -- X"00000000", 07: NOP           -- Conditional jump delay (Branch)

        -- Loop Start
        B"100011_00001_00100_0000000000000000", -- X"8C240000", 08: LW   $4, 0($1)  -- Load current element into $4
        B"000000_00000_00000_00000_00000_000000", -- X"00000000", 09: NOP           -- Hazard space for reading $4
        B"000000_00000_00000_00000_00000_000000", -- X"00000000", 10: NOP           -- Hazard space for reading $4
        B"000000_00000_00100_00100_00001_000000", -- X"00042040", 11: SLL  $4, $4, 1  -- Multiply element by 2 (shift left logical)
        B"000000_00000_00000_00000_00000_000000", -- X"00000000", 12: NOP           -- Hazard space for writing $4
        B"000000_00000_00000_00000_00000_000000", -- X"00000000", 13: NOP           -- Hazard space for writing $4
        B"101011_00011_00100_0000000000000000", -- X"AC640000", 14: SW   $4, 0($3)  -- Store result in destination array
        B"001000_00001_00001_0000000000000100", -- X"20210004", 15: ADDI $1, $1, 4  -- Increment source pointer
        B"001000_00011_00011_0000000000000100", -- X"20630004", 16: ADDI $3, $3, 4  -- Increment destination pointer
        B"001000_00010_00010_1111111111111111", -- X"2042FFFF", 17: ADDI $2, $2, -1 -- Decrement loop counter
        B"000010_00000000000000000000001000", -- X"08000008", 18: J 8             -- Jump back to loop start (line 08)
        B"000000_00000_00000_00000_00000_000000", -- X"00000000", 19: NOP           -- Unconditional jump delay (Jump)

        -- End of program
        B"000010_00000000000000000000010100", -- X"08000014", 20: J 20            -- Infinite loop to stop program
        B"000000_00000_00000_00000_00000_000000", -- X"00000000", 21: NOP           -- Unconditional jump delay (Jump)

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