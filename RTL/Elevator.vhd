LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

entity Elevator is
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
end entity Elevator;

architecture rtl of Elevator is

    component Request_Resolver is 
    generic (Floors_Number : integer := 10; 
             Floors_representation : integer := 4); 
    port (
         Up, Down, Open_Elevator, clk, rst :  IN std_logic;
         Current_Floor                     :  IN Unsigned (Floors_representation - 1 downto 0);
         Up_Floors                         :  IN Unsigned (Floors_Number - 1 downto 0);
         Dn_Floors                         :  IN Unsigned (Floors_Number - 1 downto 0);
         Floor_Count                       :  IN Unsigned (Floors_Number - 1 downto 0);
 
         permission                         : OUT std_logic;
         Floor_Requested                    : OUT Unsigned (Floors_representation - 1 downto 0)
    );
    end component Request_Resolver;

    component Control_Unit is
        generic (Floors_Number : integer := 10; 
                 Floors_representation : integer := 4); 
        port (
            clk, rst        :  IN std_logic;
            permission      :  IN std_logic;         
            Floor_Requested :  IN Unsigned (Floors_representation - 1 downto 0);
    
            Current_Floor   : OUT Unsigned (Floors_representation - 1 downto 0);
            Open_Elevator   : OUT std_logic;
            Up              : OUT std_logic;
            Down            : OUT std_logic
        );
    end component Control_Unit;

    component Displaying is
        port (
            SW0   : IN std_logic_vector(3 downto 0);
    
            HEX0  : OUT std_logic_vector(6 downto 0)
        );
    end component Displaying;

    signal Current_Floor_Temp : Unsigned (Floors_representation - 1 downto 0);

    signal Up_Temp, Dn_Temp, Open_Elevator_Temp, permission_Temp : std_logic;

    signal Floor_Requested_Temp : Unsigned (Floors_representation - 1 downto 0);

    
begin
    
    RR_Block : Request_Resolver GENERIC MAP (Floors_Number => Floors_Number, Floors_representation => Floors_representation) PORT MAP (
               
            Up => Up_Temp, 
            Down => Dn_Temp, 
            Open_Elevator => Open_Elevator_Temp, 
            clk => clk, 
            rst => rst,
            Current_Floor => Current_Floor_Temp,                   
            Up_Floors => Up_Floors,                        
            Dn_Floors => Dn_Floors,                       
            Floor_Count => Floor_Count, 
               
            permission => permission_Temp,    
            Floor_Requested => Floor_Requested_Temp
    );

    CU_Block : Control_Unit GENERIC MAP (Floors_Number => Floors_Number, Floors_representation => Floors_representation) PORT MAP (

            clk => clk, 
            rst => rst,       
            permission => permission_Temp,
            Floor_Requested => Floor_Requested_Temp,

            Current_Floor => Current_Floor_Temp,
            Open_Elevator => Open_Elevator_Temp,
            Up => Up_Temp,
            Down => Dn_Temp        
    );
    
    Current_Floor <= Current_Floor_Temp;
    Up_Elevator   <= Up_Temp;
    Dn_Elevator   <= Dn_Temp;
    Open_Elevator <= Open_Elevator_Temp;

    --Disply_Current_Floor : Displaying PORT MAP (std_logic_vector (Current_Floor_Temp), HEX0);

end architecture rtl;

