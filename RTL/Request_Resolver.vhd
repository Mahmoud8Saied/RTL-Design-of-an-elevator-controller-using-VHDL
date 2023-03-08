LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

entity Request_Resolver is 
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
end entity Request_Resolver;

-- Floors_representation is 4 for the 10 may be changed for different floor numbers

-- Inputs Definition

-- Floor_count = FloorN ..... Floor2 Floor1 --- Buttons inside the elevator
-- Up_Floors = UpN ...... Up3 Up2 Up1
-- Dn_Floors = DnN ...... Dn3 Dn2 

architecture rtl of Request_Resolver is
    
    component Up_request is
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
    end component Up_request;

    component Dn_request is
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
    end component Dn_request;
    
    signal No_Dn              : STD_LOGIC;
    signal No_Up              : STD_LOGIC;
    signal Floor_Requested_Dn : unsigned (Floors_representation - 1 DOWNTO 0);
    signal Floor_Requested_Up : unsigned (Floors_representation - 1 DOWNTO 0);
    signal Up_Higher          : std_logic;
    signal Up_Lower           : std_logic;
    signal Dn_Higher          : std_logic;
    signal Dn_Lower           : std_logic;
    signal Control_Signal     : std_logic;


begin
    
    Up_request_Module : Up_request GENERIC MAP (Floors_Number => Floors_Number, Floors_representation => Floors_representation) PORT MAP (
                        
                        Current_Floor   => Current_Floor,
                        Floor_Count     => Floor_Count,
                        Up_Floors       => Up_Floors,
                        
                        No_Up           => No_Up,
                        Floor_Requested => Floor_Requested_Up,
                        Dn_Permision    => Up_Lower,
                        Up_Permision    => Up_Higher
                    );
    Dn_request_Module : Dn_request GENERIC MAP (Floors_Number => Floors_Number, Floors_representation => Floors_representation) PORT MAP (
                        
                        Current_Floor   => Current_Floor,
                        Floor_Count     => Floor_Count,
                        Dn_Floors       => Dn_Floors,

                        No_Dn           => No_Dn,
                        Floor_Requested => Floor_Requested_Dn,
                        Dn_Permision    => Dn_Lower,
                        Up_Permision    => Dn_Higher
                    );
    
   proc_name: process(clk, rst)
   begin
    if rst = '0' then
        Control_Signal <= '0';

    elsif rising_edge(clk) then
        if (((Open_Elevator = '1') and (No_Dn = '1')) or (Up = '1')) then
                Control_Signal <= '0';
        elsif (((Open_Elevator = '1') and (No_Up = '1')) or (Down = '1')) then
                Control_Signal <= '1';
        end if ;
    end if;
   end process proc_name;

    Floor_Requested <= Floor_Requested_Dn when ((No_Up = '1') AND (No_Dn = '1') AND (Dn_Higher = '1'))
               else    Floor_Requested_Up when (((No_Up = '1') AND (No_Dn = '1') AND ( Up_Lower = '1')) or (Control_Signal = '0'))
               else    Floor_Requested_Dn;

    permission <= '1' when ((No_Up = '1') AND (No_Dn = '1') AND (Dn_Higher = '1')) or ((No_Up = '1') AND (No_Dn = '1') AND ( Up_Lower = '1'))
           else    Up_Higher when (Control_Signal = '0')
           else    Dn_Lower;

end architecture rtl;