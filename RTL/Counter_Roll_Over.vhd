LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

entity Counter_Roll_Over is
    generic (N: integer := 8; K: integer := 8);
    port (
        clk, rst, rst_sync, En :  IN std_logic;
        
        Roll_Over    : OUT std_logic 
    );
end entity Counter_Roll_Over;

architecture rtl of Counter_Roll_Over is

    signal Roll_Over_temp : std_logic;
    signal   Counter_temp : std_logic_vector(N-1 downto 0);
    
begin
    
   Roll_Over_temp <= '1' when (unsigned(Counter_temp) = to_unsigned(K, N))
                else '0';

   proc_name: process(clk, rst)
   begin
    if rst = '0' then
        
    elsif rising_edge(clk) then

        if (Roll_Over_temp = '1' or rst_sync = '1') then
            
            Counter_temp <= (OTHERS => '0');
        
        elsif (En = '1') then
            
            Counter_temp <= Counter_temp + 1;
            
        end if ;
    end if;
   end process proc_name;

   Roll_Over <= Roll_Over_temp;
    
end architecture rtl;