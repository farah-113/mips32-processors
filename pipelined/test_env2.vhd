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
    component ID is
        Port ( clk : in STD_LOGIC; en : in STD_LOGIC; Instr : in STD_LOGIC_VECTOR (25 downto 0);
               WD_WB : in STD_LOGIC_VECTOR (31 downto 0);
               RegWrite_WB : in STD_LOGIC;
               WA_WB : in STD_LOGIC_VECTOR (4 downto 0);
               ExtOp : in STD_LOGIC;
               RD1 : out STD_LOGIC_VECTOR (31 downto 0); 
               RD2 : out STD_LOGIC_VECTOR (31 downto 0);
               Ext_Imm : out STD_LOGIC_VECTOR (31 downto 0);
               func : out STD_LOGIC_VECTOR (5 downto 0);
               sa : out STD_LOGIC_VECTOR (4 downto 0); rt : out STD_LOGIC_VECTOR (4 downto 0); rd : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

    component EX is
       Port( RD1 : in std_logic_vector(31 downto 0); 
             ALUSrc: in std_logic; 
             RD2 : in std_logic_vector(31 downto 0);
             Ext_Imm : in std_logic_vector(31 downto 0);
             sa : in std_logic_vector(4 downto 0); 
             func : in std_logic_vector(5 downto 0);
             AluOp : in std_logic_vector(1 downto 0); 
             pcplus4 : in std_logic_vector(31 downto 0);
             rt : in std_logic_vector(4 downto 0); 
             rd : in std_logic_vector(4 downto 0); 
             RegDst : in std_logic;
             GTZ: out std_logic; Zero : out std_logic; 
             ALURes : out std_logic_vector(31 downto 0);
             B_Add: out std_logic_vector(31 downto 0); 
             WA : out std_logic_vector(4 downto 0));
    end component;
    
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
  component UC is
        Port ( Instr    : in STD_LOGIC_VECTOR (5 downto 0);
               RegDst   : out STD_LOGIC;
               ExtOp    : out STD_LOGIC;
               ALUSrc   : out STD_LOGIC;
               Branch   : out STD_LOGIC;
               Jump     : out STD_LOGIC;
               JmpR     : out STD_LOGIC;
               ALUOp    : out STD_LOGIC_VECTOR (1 downto 0);
               MemWrite : out STD_LOGIC;
               MemtoReg : out STD_LOGIC;
               RegWrite : out STD_LOGIC);
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

    -- Base Signals
    signal en, rst : std_logic;
    signal instruction, pc_plus_4 : STD_LOGIC_VECTOR(31 downto 0);
    signal rd1_sig, rd2_sig, ext_imm_sig : STD_LOGIC_VECTOR(31 downto 0);
    signal func_sig : STD_LOGIC_VECTOR(5 downto 0);
    signal sa_sig, rt_sig, rd_sig : STD_LOGIC_VECTOR(4 downto 0);
    signal regdst_sig, extop_sig, alusrc_sig, branch_sig, jump_sig, jmpr_sig : STD_LOGIC;
    signal aluop_sig : STD_LOGIC_VECTOR(1 downto 0);
    signal memwrite_sig, memtoreg_sig, regwrite_sig : STD_LOGIC;
    
    signal zero_sig, gtz_sig : STD_LOGIC;
    signal alures_sig, b_add_sig, memdata_sig, alures_out_sig : STD_LOGIC_VECTOR(31 downto 0);
    signal wa_ex_sig : STD_LOGIC_VECTOR(4 downto 0);
    signal jump_address_sig : STD_LOGIC_VECTOR(31 downto 0);
    signal pcsrc_sig : STD_LOGIC;
    signal wd_sig, ssd_data : STD_LOGIC_VECTOR(31 downto 0);

    -- IF/ID
    signal IF_ID_PC4, IF_ID_Instr : std_logic_vector(31 downto 0);
    -- ID/EX
    signal ID_EX_PC4, ID_EX_RD1, ID_EX_RD2, ID_EX_Ext_Imm : std_logic_vector(31 downto 0);
    signal ID_EX_func : std_logic_vector(5 downto 0);
    signal ID_EX_sa, ID_EX_rt, ID_EX_rd : std_logic_vector(4 downto 0);
    signal ID_EX_RegDst, ID_EX_ALUSrc, ID_EX_Branch, ID_EX_MemWrite, ID_EX_MemtoReg, ID_EX_RegWrite : std_logic;
    signal ID_EX_ALUOp : std_logic_vector(1 downto 0);
    -- EX/MEM
    signal EX_MEM_BranchAdd, EX_MEM_ALURes, EX_MEM_RD2 : std_logic_vector(31 downto 0);
    signal EX_MEM_WA : std_logic_vector(4 downto 0);
    signal EX_MEM_Zero, EX_MEM_Branch, EX_MEM_MemWrite, EX_MEM_MemtoReg, EX_MEM_RegWrite : std_logic;
    -- MEM/WB
    signal MEM_WB_MemData, MEM_WB_ALURes : std_logic_vector(31 downto 0);
    signal MEM_WB_WA : std_logic_vector(4 downto 0);
    signal MEM_WB_MemtoReg, MEM_WB_RegWrite : std_logic;

begin

    monopulse_step: MPG port map (btn => btn(0), clk => clk, enable => en);
    rst <= btn(1); 

    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                -- IF/ID
                IF_ID_PC4 <= pc_plus_4;
                IF_ID_Instr <= instruction;

                -- ID/EX
                ID_EX_PC4 <= IF_ID_PC4;
                ID_EX_RD1 <= rd1_sig;
                ID_EX_RD2 <= rd2_sig;
                ID_EX_Ext_Imm <= ext_imm_sig;
                ID_EX_func <= func_sig;
                ID_EX_sa <= sa_sig;
                ID_EX_rt <= rt_sig;
                ID_EX_rd <= rd_sig;
                ID_EX_RegDst <= regdst_sig;
                ID_EX_ALUOp <= aluop_sig;
                ID_EX_ALUSrc <= alusrc_sig;
                ID_EX_Branch <= branch_sig;
                ID_EX_MemWrite <= memwrite_sig;
                ID_EX_MemtoReg <= memtoreg_sig;
                ID_EX_RegWrite <= regwrite_sig;

                -- EX/MEM
                EX_MEM_BranchAdd <= b_add_sig;
                EX_MEM_Zero <= zero_sig;
                EX_MEM_ALURes <= alures_sig;
                EX_MEM_RD2 <= ID_EX_RD2;
                EX_MEM_WA <= wa_ex_sig;
                EX_MEM_Branch <= ID_EX_Branch;
                EX_MEM_MemWrite <= ID_EX_MemWrite;
                EX_MEM_MemtoReg <= ID_EX_MemtoReg;
                EX_MEM_RegWrite <= ID_EX_RegWrite;

                -- MEM/WB
                MEM_WB_MemData <= memdata_sig;
                MEM_WB_ALURes <= alures_out_sig;
                MEM_WB_WA <= EX_MEM_WA;
                MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
                MEM_WB_RegWrite <= EX_MEM_RegWrite;
            end if;
        end if;
    end process;

    -- Branch Logic
    pcsrc_sig <= EX_MEM_Branch and EX_MEM_Zero; 
    jump_address_sig <= IF_ID_PC4(31 downto 28) & IF_ID_Instr(25 downto 0) & "00";

    instruction_fetch_unit: IFetch port map (
        clk => clk, rst => rst, en => en,
        BranchAddress => EX_MEM_BranchAdd, 
        JumpAddress => jump_address_sig, JRAddress => rd1_sig,
        Jump => jump_sig, PCSrc => pcsrc_sig, JmpR => jmpr_sig,
        Instruction => instruction, PC_plus_4 => pc_plus_4
    );

    instruction_decode_unit: ID port map (
        clk => clk,
        en => en,
        Instr => IF_ID_Instr(25 downto 0),  
        WD_WB => wd_sig,                   
        RegWrite_WB => MEM_WB_RegWrite,    
        WA_WB => MEM_WB_WA,                 
        ExtOp => extop_sig,
        RD1 => rd1_sig, 
        RD2 => rd2_sig, 
        Ext_Imm => ext_imm_sig,
        func => func_sig, 
        sa => sa_sig, 
        rt => rt_sig, 
        rd => rd_sig
    );

    control_unit: UC port map (
        Instr => IF_ID_Instr(31 downto 26),  -- Input from IF/ID
        RegDst => regdst_sig, 
        ExtOp => extop_sig, 
        ALUSrc => alusrc_sig,
        Branch => branch_sig, 
        Jump => jump_sig, 
        JmpR => jmpr_sig,
        ALUOp => aluop_sig, 
        MemWrite => memwrite_sig, 
        MemtoReg => memtoreg_sig,
        RegWrite => regwrite_sig
    );
    
    execution_unit: EX port map (
        RD1 => ID_EX_RD1, 
        ALUSrc => ID_EX_ALUSrc, 
        RD2 => ID_EX_RD2,
        Ext_Imm => ID_EX_Ext_Imm, 
        sa => ID_EX_sa, func => 
        ID_EX_func,
        AluOp => ID_EX_ALUOp, 
        pcplus4 => ID_EX_PC4,
        rt => ID_EX_rt, 
        rd => ID_EX_rd, 
        RegDst => ID_EX_RegDst,
        GTZ => gtz_sig, 
        Zero => zero_sig, 
        ALURes => alures_sig,
        B_Add => b_add_sig, 
        WA => wa_ex_sig
    );
    
    memory_unit: MEM port map (
        MemWrite => EX_MEM_MemWrite, 
        ALURes_in => EX_MEM_ALURes,
        RD2 => EX_MEM_RD2, 
        Clk => clk, 
        EN => en,
        MemData => memdata_sig, 
        ALURes_out => alures_out_sig
    );

    wd_sig <= MEM_WB_MemData when MEM_WB_MemtoReg = '1' else MEM_WB_ALURes;

    with sw(7 downto 5) select
        ssd_data <= instruction      when "000",
                    IF_ID_Instr      when "001",
                    ID_EX_RD1        when "010",
                    ID_EX_RD2        when "011",
                    EX_MEM_ALURes    when "100",
                    MEM_WB_ALURes    when "101",
                    MEM_WB_MemData   when "110",
                    wd_sig           when "111",
                    X"00000000"      when others;

    display_unit: SSD port map ( clk => clk, digits => ssd_data, an => an, cat => cat );

    led(0) <= ID_EX_RegDst;
    led(1) <= extop_sig; 
    led(2) <= ID_EX_ALUSrc;
    led(3) <= ID_EX_Branch;
    led(4) <= jump_sig;
    led(5) <= ID_EX_MemWrite;
    led(6) <= ID_EX_MemtoReg;
    led(7) <= ID_EX_RegWrite;
    led(9 downto 8) <= ID_EX_ALUOp;
    led(10) <= jmpr_sig;

end Behavioral;