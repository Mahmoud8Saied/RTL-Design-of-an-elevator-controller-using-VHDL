LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

entity Up_request is
    generic (Floors_Number         : integer := 10; 
             Floors_representation : integer := 4); 
    port (
        Current_Floor                 :  IN Unsigned (Floors_representation - 1 downto 0);
        Floor_Count                   :  IN Unsigned (Floors_Number - 1 downto 0);
        Up_Floors                     :  IN Unsigned (Floors_Number - 1 downto 0);
        
        No_Up                         : OUT std_logic;
        Floor_Requested               : OUT Unsigned (Floors_representation - 1 downto 0);
        Dn_Permision                  : OUT std_logic;
        Up_Permision                  : OUT std_logic
    );
end entity Up_request;

architecture rtl of Up_request is
    
    SIGNAL Requests_Done      : unsigned (Floors_Number - 1 DOWNTO 0);
    SIGNAL No_Up_Signal       : STD_LOGIC;
    SIGNAL Smallest_Up_Lower  : unsigned (Floors_representation - 1 DOWNTO 0);
    SIGNAL Smallest_Up_Higher : unsigned (Floors_representation - 1 DOWNTO 0);

begin
    
    Requests_Done <= Up_Floors or Floor_Count;

    No_Up_Signal <= '1' when (Smallest_Up_Higher < Current_Floor)
    else '0';
    
    Floor_Requested <= Smallest_Up_Higher when (No_Up_Signal = '0')
    else Smallest_Up_Lower;    
    
    
   proc_name1: process(Requests_Done, Current_Floor, Up_Floors)
   begin

    Smallest_Up_Higher <= (Others => '0');
    Smallest_Up_Lower  <= (Others => '0');
    Dn_Permision       <= '0';
    Up_Permision       <= '0';

        FOR i IN Floors_Number - 1 DOWNTO 0 LOOP

            IF ((Requests_Done(i) = '1') AND (Current_Floor <= to_unsigned(i, Floors_representation))) THEN

                Smallest_Up_Higher <= To_Unsigned(i, Floors_representation);
                Up_Permision       <= '1';

            ELSIF ((Up_Floors(i) = '1') AND (Current_Floor > to_unsigned(i, Floors_representation))) THEN

                Smallest_Up_Lower <= To_Unsigned(i, Floors_representation);
                Dn_Permision      <= '1';

            END IF;

        END LOOP;
     
   end process proc_name1;

   No_Up <= No_Up_Signal;
    
end architecture rtl;