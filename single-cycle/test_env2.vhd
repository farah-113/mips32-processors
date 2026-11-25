library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in std_logic_vector(4 downto 0);
           sw  : in std_logic_vector (15 downto 0);
           led : out std_logic_vector (15 downto 0);
           an  : out std_logic_vector (7 downto 0);
           cat : out std_logic_vector (6 downto 0));
end test_env;

architecture Behavioral of test_env is

    component SSD is
        Port ( clk : in STD_LOGIC;
               digits : in STD_LOGIC_VECTOR(31 downto 0);
               an : out STD_LOGIC_VECTOR(7 downto 0);
               cat : out STD_LOGIC_VECTOR(6 downto 0));
    end component;

    component MPG is
        Port ( btn : in std_logic;
               clk : in std_logic;
               enable: out std_logic);
    end component;

    component IFetch is
        Port ( clk            : in STD_LOGIC;
               rst            : in STD_LOGIC;
               en             : in STD_LOGIC;
               BranchAddress  : in STD_LOGIC_VECTOR(31 downto 0);
               JumpAddress    : in STD_LOGIC_VECTOR(31 downto 0);
               JRAddress      : in STD_LOGIC_VECTOR(31 downto 0); 
               Jump           : in STD_LOGIC;
               PCSrc          : in STD_LOGIC;
               JmpR           : in STD_LOGIC;                      
               Instruction    : out STD_LOGIC_VECTOR(31 downto 0);
               PC_plus_4      : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component ID is
        Port ( clk      : in STD_LOGIC;
               en       : in STD_LOGIC;
               Instr    : in STD_LOGIC_VECTOR (25 downto 0);
               WD       : in STD_LOGIC_VECTOR (31 downto 0);
               RegWrite : in STD_LOGIC;
               RegDst   : in STD_LOGIC;
               ExtOp    : in STD_LOGIC;
               RD1      : out STD_LOGIC_VECTOR (31 downto 0);
               RD2      : out STD_LOGIC_VECTOR (31 downto 0);
               Ext_Imm  : out STD_LOGIC_VECTOR (31 downto 0);
               func     : out STD_LOGIC_VECTOR (5 downto 0);
               sa       : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

    component UC is
        Port ( Instr    : in STD_LOGIC_VECTOR (5 downto 0);
               RegDst   : out STD_LOGIC;
               ExtOp    : out STD_LOGIC;
               ALUSrc   : out STD_LOGIC;
               Branch   : out STD_LOGIC;
               BranchGTZ: out STD_LOGIC;
               Jump     : out STD_LOGIC;
               JmpR     : out STD_LOGIC;
               ALUOp    : out STD_LOGIC_VECTOR (1 downto 0);
               MemWrite : out STD_LOGIC;
               MemtoReg : out STD_LOGIC;
               RegWrite : out STD_LOGIC);
    end component;
    
    component EX is
       Port( RD1 : in std_logic_vector (31 downto 0);
             ALUSrc: in std_logic;
             RD2 : in std_logic_vector (31 downto 0);
             Ext_Imm : in std_logic_vector (31 downto 0);
             sa : in std_logic_vector (4 downto 0);
             func : in std_logic_vector (5 downto 0);
             AluOp : in std_logic_vector (1 downto 0);
             pcplus4 : in std_logic_vector (31 downto 0);
             GTZ: out std_logic;
             Zero : out std_logic;
             ALURes : out std_logic_vector (31 downto 0);
             B_Add: out std_logic_vector (31 downto 0)
             );
    end component;
    
    component MEM is
        Port ( MemWrite : in STD_LOGIC;
               ALURes_in : in STD_LOGIC_VECTOR (31 downto 0);
               RD2 : in STD_LOGIC_VECTOR (31 downto 0);
               Clk : in STD_LOGIC;
               EN : in STD_LOGIC;
               MemData : out STD_LOGIC_VECTOR (31 downto 0);
               ALURes_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    signal en  : std_logic;
    signal rst : std_logic;
    
    signal instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_4   : STD_LOGIC_VECTOR(31 downto 0);
    
    signal rd1_sig     : STD_LOGIC_VECTOR(31 downto 0);
    signal rd2_sig     : STD_LOGIC_VECTOR(31 downto 0);
    signal ext_imm_sig : STD_LOGIC_VECTOR(31 downto 0);
    signal func_sig    : STD_LOGIC_VECTOR(5 downto 0);
    signal sa_sig      : STD_LOGIC_VECTOR(4 downto 0);
    signal wd_sig      : STD_LOGIC_VECTOR(31 downto 0);

    signal regdst_sig   : STD_LOGIC;
    signal extop_sig    : STD_LOGIC;
    signal alusrc_sig   : STD_LOGIC;
    signal branch_sig   : STD_LOGIC;
    signal branchgtz_sig : STD_LOGIC;
    signal jump_sig     : STD_LOGIC;
    signal jmpr_sig     : STD_LOGIC;
    signal aluop_sig    : STD_LOGIC_VECTOR(1 downto 0);
    signal memwrite_sig : STD_LOGIC;
    signal memtoreg_sig : STD_LOGIC;
    signal regwrite_sig : STD_LOGIC;

    signal zero_sig         : STD_LOGIC;
    signal gtz_sig          : STD_LOGIC;
    signal alures_sig       : STD_LOGIC_VECTOR(31 downto 0);
    signal b_add_sig        : STD_LOGIC_VECTOR(31 downto 0);
    signal memdata_sig      : STD_LOGIC_VECTOR(31 downto 0);
    signal alures_out_sig   : STD_LOGIC_VECTOR(31 downto 0);
    
    signal jump_address_sig : STD_LOGIC_VECTOR(31 downto 0);
    signal pcsrc_sig        : STD_LOGIC;

    signal ssd_data    : STD_LOGIC_VECTOR(31 downto 0);

begin

    monopulse_step: MPG port map (btn => btn(0), clk => clk, enable => en);
    rst <= btn(1); 

    jump_address_sig <= pc_plus_4(31 downto 28) & instruction(25 downto 0) & "00";
    pcsrc_sig <= (branch_sig and zero_sig)
          or (branchgtz_sig and gtz_sig);  

    instruction_fetch_unit: IFetch port map (
        clk           => clk,
        rst           => rst,
        en            => en,
        BranchAddress => b_add_sig, 
        JumpAddress   => jump_address_sig, 
        JRAddress     => rd1_sig,
        Jump          => jump_sig,       
        PCSrc         => pcsrc_sig,      
        JmpR          => jmpr_sig,    
        Instruction   => instruction, 
        PC_plus_4     => pc_plus_4    
    );

    instruction_decode_unit: ID port map (
        clk      => clk,
        en       => en,
        Instr    => instruction(25 downto 0),
        WD       => wd_sig, 
        RegWrite => regwrite_sig,
        RegDst   => regdst_sig,
        ExtOp    => extop_sig,
        RD1      => rd1_sig,
        RD2      => rd2_sig,
        Ext_Imm  => ext_imm_sig,
        func     => func_sig,
        sa       => sa_sig
    );

    control_unit: UC port map (
        Instr    => instruction(31 downto 26),
        RegDst   => regdst_sig,
        ExtOp    => extop_sig,
        ALUSrc   => alusrc_sig,
        Branch   => branch_sig,
        BranchGTZ => branchgtz_sig,
        Jump     => jump_sig,
        JmpR     => jmpr_sig,
        ALUOp    => aluop_sig,
        MemWrite => memwrite_sig,
        MemtoReg => memtoreg_sig,
        RegWrite => regwrite_sig
    );
    
    execution_unit: EX port map (
        RD1      => rd1_sig,
        ALUSrc   => alusrc_sig,
        RD2      => rd2_sig,
        Ext_Imm  => ext_imm_sig,
        sa       => sa_sig,
        func     => func_sig,
        AluOp    => aluop_sig,
        pcplus4  => pc_plus_4,
        GTZ      => gtz_sig,
        Zero     => zero_sig,
        ALURes   => alures_sig,
        B_Add    => b_add_sig
    );
    
    memory_unit: MEM port map (
        MemWrite   => memwrite_sig,
        ALURes_in  => alures_sig,
        RD2        => rd2_sig,
        Clk        => clk,
        EN         => en,
        MemData    => memdata_sig,
        ALURes_out => alures_out_sig
    );

    wd_sig <= memdata_sig when memtoreg_sig = '1' else alures_out_sig;

    with sw(7 downto 5) select
        ssd_data <= instruction    when "000",
                    pc_plus_4      when "001",
                    rd1_sig        when "010",
                    rd2_sig        when "011",
                    ext_imm_sig    when "100",
                    alures_out_sig when "101",
                    memdata_sig    when "110",
                    wd_sig         when "111",
                    X"00000000"    when others;

    display_unit: SSD port map (
        clk => clk,
        digits => ssd_data, 
        an => an,
        cat => cat
    );

    led(0) <= regdst_sig;
    led(1) <= extop_sig;
    led(2) <= alusrc_sig;
    led(3) <= branch_sig;
    led(4) <= jump_sig;
    led(5) <= memwrite_sig;
    led(6) <= memtoreg_sig;
    led(7) <= regwrite_sig;
    led(9 downto 8) <= aluop_sig;
    led(10) <= jmpr_sig;

end Behavioral;