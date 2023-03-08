LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY elevator_ctrl IS
    PORT (

        clk  : IN STD_LOGIC;

        KEY0 : IN STD_LOGIC;
        KEY1 : IN STD_LOGIC;
        KEY2 : IN STD_LOGIC;
        KEY3 : IN STD_LOGIC;
        KEY4 : IN STD_LOGIC;

        LED0 : OUT STD_LOGIC;
        LED1 : OUT STD_LOGIC;
        LED2 : OUT STD_LOGIC;

        HEX0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END elevator_ctrl;

ARCHITECTURE RTL OF elevator_ctrl IS
component Elevator is
    generic (Floors_Number         : integer := 10; 
             Floors_representation : integer := 4); 
    port (

         clk, rst     : IN std_logic;
         Up_Floors    : IN Unsigned (Floors_Number - 1 downto 0);
         Dn_Floors    : IN Unsigned (Floors_Number - 1 downto 0);
         Floor_Count  : IN Unsigned (Floors_Number - 1 downto 0);
 
         Current_Floor : OUT Unsigned (Floors_representation - 1 downto 0);
         Up_Elevator   : OUT std_logic;
         Dn_Elevator   : OUT std_logic;
         Open_Elevator : OUT std_logic
         
         --HEX0          : OUT std_logic_vector(6 downto 0)
    );
end component Elevator;

component Displaying is
    port (
        SW0   : IN std_logic_vector(3 downto 0);

        HEX0  : OUT std_logic_vector(6 downto 0)
    );
end component;

SIGNAL Current_Floor_Display : Unsigned (3 downto 0); 
SIGNAL Elevator_Buttons      : STD_LOGIC_VECTOR (9 DOWNTO 0);
signal Not_key0              :STD_Logic;
signal Not_key1              :STD_Logic;
signal Not_key2              :STD_Logic;
signal Not_key3              :STD_Logic;

BEGIN

Not_key0 <= not KEY0;
Not_key1 <= not KEY1;
Not_key2 <= not KEY2;
Not_key3 <= not KEY3;

    Elevator_Buttons <= "000000" & Not_key3 & Not_key2 & Not_key1 & Not_key0;

    Elevator_Sys : Elevator GENERIC MAP (Floors_Number => 10, Floors_representation => 4) PORT MAP (

                clk => clk, 
                rst => KEY4,   
                Up_Floors => "0000000000",  
                Dn_Floors => "0000000000",
                Floor_Count => Unsigned (Elevator_Buttons),

                Current_Floor => Current_Floor_Display,
                Up_Elevator  => LED0,
                Dn_Elevator  => LED1,
                Open_Elevator => LED2
            );

    Disply_Current_Floor : Displaying PORT MAP (std_logic_vector (Current_Floor_Display), HEX0);

END RTL;

