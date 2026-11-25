----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2026 04:20:55 PM
-- Design Name: 
-- Module Name: UC - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

----------------------------------------------------------------------------------
-- Module Name: UC - Behavioral (Control Unit)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    Port ( Instr    : in STD_LOGIC_VECTOR (5 downto 0); -- Opcode
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
end UC;

architecture Behavioral of UC is
begin

    process(Instr)
    begin
        RegDst   <= '0';
        ExtOp    <= '0';
        ALUSrc   <= '0';
        Branch   <= '0';
        Jump     <= '0';
        JmpR     <= '0';
        ALUOp    <= "00";
        MemWrite <= '0';
        MemtoReg <= '0';
        RegWrite <= '0';

        case Instr is
            when "000000" => -- R-type 
                RegDst   <= '1';
                RegWrite <= '1';
                ALUOp    <= "10";
                
            when "001000" => -- ADDI
                ExtOp    <= '1';
                ALUSrc   <= '1';
                RegWrite <= '1';
                ALUOp    <= "00";
                
            when "100011" => -- LW
                ExtOp    <= '1';
                ALUSrc   <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                ALUOp    <= "00";
                
            when "101011" => -- SW
                ExtOp    <= '1';
                ALUSrc   <= '1';
                MemWrite <= '1';
                ALUOp    <= "00";
                
            when "000100" => -- BEQ
                ExtOp    <= '1';
                Branch   <= '1';
                ALUOp    <= "01";
                
            when "000111" => -- BGTZ
                ExtOp    <= '1';
                Branch   <= '1'; 
                ALUOp    <= "00";
                
            when "011000" => -- JR 
                JmpR     <= '1';
                
            when "000010" => -- JUMP
                Jump     <= '1';
                
            when others =>
        end case;
    end process;

end Behavioral;