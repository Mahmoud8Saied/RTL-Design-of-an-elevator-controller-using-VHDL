LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

entity Counter_Sync_Async_Reset is
    GENERIC (N: Integer := 8;
             K: Integer := 8);
    port (
        clk, rst, sync_rst, En : IN std_logic;
        
        Roll_Over   : OUT std_logic
    );
end entity Counter_Sync_Async_Reset;

architecture rtl of Counter_Sync_Async_Reset is
    
    signal Count_temp : std_logic_vector(N-1 downto 0);
    signal Roll_Over_temp : std_logic;

begin
    
   proc_name: process(clk, rst)
   begin
    if rst = '0' then

        Count_temp <= (OTHERS => '0');
        
    elsif rising_edge(clk) then

        if sync_rst = '1' then

            Count_temp <= (OTHERS => '0');
        elsif (En = '1') then
            
            Count_temp <= Count_temp + 1;
            
        end if ;
    end if;
   end process proc_name;

   Roll_Over_temp <= '1' when (unsigned(Count_temp) = to_unsigned(K, N))
   else '0';

   Roll_Over <= Roll_Over_temp;

end architecture rtl;