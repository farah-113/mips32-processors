----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2026 06:15:18 PM
-- Design Name: 
-- Module Name: EX - Behavioral
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
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EX is
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
end EX;

architecture Behavioral of EX is
signal AluCtrl : std_logic_vector (2 downto 0);
signal A , B : std_logic_vector (31 downto 0);
signal ALURes_int : std_logic_vector (31 downto 0);


begin
ALUControl : process (AluOp , func)
   begin
       case AluOp is
         when "10" =>
             case func is
                 when "100000" => ALUCtrl <= "010"; 
                 when "100010" => ALUCtrl <= "110"; 
                 when "000000" => ALUCtrl <= "100";
                 when "000010" => ALUCtrl <= "101";
                 when "100100" => ALUCtrl <= "000";
                 when "100101" => ALUCtrl <= "001";
                 when "100110" => ALUCtrl <= "011";
                 when "101010" => ALUCtrl <= "111";
                 when others   => ALUCtrl <= (others => 'X');
                 end case;
         when "00"   => ALUCtrl <= "010";
         when "01"   => ALUCtrl <= "110";
         when others => ALUCtrl <= (others => 'X');
         end case;
   end process;
   
    A <= RD1;
    B <= Ext_Imm when ALUSrc = '1' else RD2;
    
    process(ALUCtrl, A, B, sa)
    begin
        case ALUCtrl is
            when "010" => ALURes_int <= A + B;                                                 -- ADD
            when "110" => ALURes_int <= A - B;                                                 -- SUB
            when "000" => ALURes_int <= A and B;                                               -- AND
            when "001" => ALURes_int <= A or B;                                                -- OR
            when "011" => ALURes_int <= A xor B;                                               -- XOR
            when "100" => ALURes_int <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa)); -- SLL
            when "101" => ALURes_int <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa)); -- SRL
            when "111" =>                                                                      -- SLT
                if signed(A) < signed(B) then
                    ALURes_int <= X"00000001";
                else
                    ALURes_int <= X"00000000";
                end if;
            when others => ALURes_int <= (others => 'X');
        end case;
    end process;

    Zero <= '1' when ALURes_int = X"00000000" else '0';
    GTZ <= '1' when (RD1(31) = '0' and RD1 /= X"00000000") else '0';
    
    ALURes <= ALURes_int;
    
    B_ADD <= pcplus4 + (Ext_Imm(29 downto 0) & "00");

end Behavioral;
  
