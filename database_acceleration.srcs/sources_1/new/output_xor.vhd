----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.03.2016 15:37:52
-- Design Name: 
-- Module Name: output_xor - Behavioral
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

entity output_xor is
    Port ( Din : in STD_LOGIC_VECTOR (511 downto 0);
           Dout : in STD_LOGIC);
end output_xor;

architecture Behavioral of output_xor is

begin

process(Din)
variable tmp:std_logic;
tmp :='0';
begin
for k in 0 to 511 loop
  tmp := tmp XOR Din(k);
end loop;
Dout <= tmp;
end process;
end Behavioral;
