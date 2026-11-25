library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ID is
    Port ( clk          : in STD_LOGIC;
           en           : in STD_LOGIC;
           Instr        : in STD_LOGIC_VECTOR (25 downto 0);
           WD_WB        : in STD_LOGIC_VECTOR (31 downto 0);
           RegWrite_WB  : in STD_LOGIC;                    
           WA_WB        : in STD_LOGIC_VECTOR (4 downto 0); 
           ExtOp        : in STD_LOGIC;
           RD1          : out STD_LOGIC_VECTOR (31 downto 0);
           RD2          : out STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm      : out STD_LOGIC_VECTOR (31 downto 0);
           func         : out STD_LOGIC_VECTOR (5 downto 0);
           sa           : out STD_LOGIC_VECTOR (4 downto 0);
           rt           : out STD_LOGIC_VECTOR (4 downto 0); 
           rd           : out STD_LOGIC_VECTOR (4 downto 0));
end ID;

architecture Behavioral of ID is
    type reg_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal RF : reg_array := (others => X"00000000");
begin
    -- Write process
    process(clk)
    begin
        if falling_edge(clk) then
            if en = '1' and RegWrite_WB = '1' then
                RF(conv_integer(WA_WB)) <= WD_WB;
            end if;
        end if;
    end process;

    -- Read process (Asynchronous)
    RD1 <= RF(conv_integer(Instr(25 downto 21)));
    RD2 <= RF(conv_integer(Instr(20 downto 16)));

    -- Sign Extension
    Ext_Imm(15 downto 0) <= Instr(15 downto 0);
    Ext_Imm(31 downto 16) <= (others => Instr(15)) when ExtOp = '1' else (others => '0');

    func <= Instr(5 downto 0);
    sa   <= Instr(10 downto 6);
    rt   <= Instr(20 downto 16);
    rd   <= Instr(15 downto 11);

end Behavioral;