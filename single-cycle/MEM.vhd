----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2026 07:16:18 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEM is
    Port ( MemWrite : in STD_LOGIC;
           ALURes_in : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           Clk : in STD_LOGIC;
           EN : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (31 downto 0);
           ALURes_out : out STD_LOGIC_VECTOR (31 downto 0));
end MEM;

architecture Behavioral of MEM is

 type ram_type is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
    signal MEM : ram_type := (
        0 => X"00000010",
        1 => X"00000003",
        4 => X"00000003",
        5 => X"00000005",
        6 => X"0000000A",
        others => X"00000000"
    );

begin
   process (clk)
   begin
     if rising_edge(Clk) then
        if en='1' and MemWrite = '1' then 
           MEM(conv_integer(ALURes_in(7 downto 2))) <= RD2 ;
           end if;
          end if;
         end process;
         
         MemData <= MEM(CONV_INTEGER(ALURes_in(7 downto 2)));
         ALURes_out <= ALURes_in;


end Behavioral;