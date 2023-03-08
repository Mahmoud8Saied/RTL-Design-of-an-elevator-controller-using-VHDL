LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

entity Dn_request is
    generic (Floors_Number         : integer := 10; 
             Floors_representation : integer := 4); 
    port (
        Current_Floor                 :  IN Unsigned (Floors_representation - 1 downto 0);
        Floor_Count                   :  IN Unsigned (Floors_Number - 1 downto 0);
        Dn_Floors                     :  IN Unsigned (Floors_Number - 1 downto 0);
        
        No_Dn                         : OUT std_logic;
        Floor_Requested               : OUT Unsigned (Floors_representation - 1 downto 0);
        Dn_Permision                  : OUT std_logic;
        Up_Permision                  : OUT std_logic
    );
end entity Dn_request;
architecture rtl of Dn_request is
    
    SIGNAL Requests_Done     : unsigned (Floors_Number - 1 DOWNTO 0);
    SIGNAL No_Dn_Signal      : STD_LOGIC;
    SIGNAL Largest_Dn_Lower  : unsigned (Floors_representation - 1 DOWNTO 0);
    SIGNAL Largest_Dn_Higher : unsigned (Floors_representation - 1 DOWNTO 0);

begin
    
    Requests_Done <= Dn_Floors or Floor_Count;

    No_Dn_Signal <= '1' when (Largest_Dn_Lower > Current_Floor)
    else '0';
    
    Floor_Requested <= Largest_Dn_Lower when (No_Dn_Signal = '0')
    else Largest_Dn_Higher;    
    
    
   proc_name1: process(Requests_Done, Current_Floor, Dn_Floors)
   begin

    Largest_Dn_Lower  <= (Others => '1');
    Largest_Dn_Higher <= (Others => '1');
    Dn_Permision      <= '0';
    Up_Permision      <= '0';

        FOR i IN Floors_Number - 1 DOWNTO 0 LOOP

            IF ((Requests_Done(i) = '1') AND (Current_Floor >= to_unsigned(i, Floors_representation))) THEN

                Largest_Dn_Lower <= To_Unsigned(i, Floors_representation);
                Dn_Permision     <= '1';

            ELSIF ((Dn_Floors(i) = '1') AND (Current_Floor < to_unsigned(i, Floors_representation))) THEN

                Largest_Dn_Higher <= To_Unsigned(i, Floors_representation);
                Up_Permision      <= '1';

            END IF;

        END LOOP;
     
   end process proc_name1;

   No_Dn <= No_Dn_Signal;
    
end architecture rtl;