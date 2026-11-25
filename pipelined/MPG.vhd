----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 12:30:30 AM
-- Design Name: 
-- Module Name: MPG - Behavioral
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
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MPG is
  Port ( btn : in std_logic;
         clk : in std_logic;
         enable: out std_logic
         );
end MPG;

architecture Behavioral of MPG is
   signal cnt_int : std_logic_vector (15 downto 0) :=(others=>'0');
   signal en : std_logic_vector (15 downto 0) := (others => '0');
   signal q0 , q1 , q2 : std_logic := '0';
   signal d0 : std_logic := '0';
   
begin
   process(clk)
     begin
        if rising_edge(clk) then cnt_int <= cnt_int + 1 ;
        end if;
        end process;
        
    process(clk)
      begin
        if rising_edge(clk) then
         en <= cnt_int;
         d0<= btn;
        if (en = "1111111111111111") then 
           q0<=d0;
           end if;
         end if;
      end process;
      
     process (clk)
       begin
        if rising_edge(clk) then
          q1<=q0;
          end if;
         end process;
     process (clk)
        begin
           if rising_edge(clk) then
              q2<=q1;
              end if;
           end process;
       
       enable<= (not q2) and q1;

end Behavioral;
