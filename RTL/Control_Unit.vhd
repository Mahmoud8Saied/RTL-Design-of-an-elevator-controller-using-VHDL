LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

entity Control_Unit is
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
end entity Control_Unit;

architecture rtl of Control_Unit is
    
    component Counter_Roll_Over is
        generic (N: integer := 8; K: integer := 8);
        port (
            clk, rst, rst_sync, En :  IN std_logic;
            
            Roll_Over    : OUT std_logic 
        );
    end component Counter_Roll_Over;

    component Counter_Sync_Async_Reset is
        GENERIC (N: Integer := 8;
                 K: Integer := 8);
        port (
            clk, rst, sync_rst, En : IN std_logic;
            
            Roll_Over   : OUT std_logic
        );
    end component Counter_Sync_Async_Reset;

    -- FSM States
    type state_type is (IDLE, Up_Movement, Down_Movement, Open_Door);
    
    signal Current_State, Next_State : state_type;

    signal rst_sync, Counter1_Roll_Over, Counter2_Roll_Over : std_logic;

    signal Current_Floor_temp : Unsigned (Floors_representation - 1 downto 0);

    signal Floor_Lower, Floor_Higher, Permision_temp : std_logic;

    Signal Floor_Requested_Temp : Unsigned (Floors_representation - 1 downto 0);

    signal Open_Done : std_logic;

    signal Temp : std_logic;

begin
    -- State Transition Logic

    State_Process: process(clk, rst)
   begin
    if rst = '0' then
        Current_State <= IDLE;
    elsif rising_edge(clk) then
        Current_State <= Next_State;
    end if;
   end process State_Process;

   -- Outputs and next state Logic

   Output_Process: process(Current_State, Open_Done, permission, Permision_temp, Floor_Requested_Temp, Floor_Requested, Current_Floor_temp)
  begin
    case Current_State is
        when IDLE => 

            Up <= '0';
            Down <= '0';
            Open_Elevator <= '0';

            if (Permision_temp = '1') and (Floor_Requested = Current_Floor_temp) then

                Next_State <= Open_Door;
                rst_sync <= '1';

            elsif (Permision_temp = '1') and (Floor_Requested_Temp > Current_Floor_temp) then
                
                Next_State <= Up_Movement;
                rst_sync <= '1';
            
            else 
                Next_State <= IDLE;
                rst_sync <= '0';
                
            end if ;

        when Up_Movement => 

            Up <= '1';
            Down <= '0';
            Open_Elevator <= '0';

            if (Current_Floor_temp = Floor_Requested_Temp) then
                
                Next_State <= Open_Door;
                rst_sync <= '1';
            
            else 
                Next_State <= Up_Movement;
                rst_sync <= '0';

            end if ;

        when Down_Movement => 

            Up <= '0';
            Down <= '1';
            Open_Elevator <= '0';

            if (Current_Floor_temp = Floor_Requested_Temp) then
                
                Next_State <= Open_Door;
                rst_sync <= '1';

            else
                
                Next_State <= Down_Movement;
                rst_sync <= '0';

            end if ;


        when Open_Door => 
            Up <= '0';
            Down <= '0';
            Open_Elevator <= '1';

            if (Open_Done = '1') and (permission = '1') and (Current_Floor_temp > Floor_Requested_Temp) then

                Next_State <= Down_Movement;
                rst_sync <= '1';
            
            elsif (Open_Done = '1') and (permission = '1') and (Current_Floor_temp < Floor_Requested_Temp) then
                
                Next_State <= Up_Movement;
                rst_sync <= '1';
            
            else 
                
                Next_State <= Open_Door;
                rst_sync <= '0';

            end if ;
            
        when others => Next_State <= IDLE;
                       Up <= '0';
                       Down <= '0';
                       Open_Elevator <= '0';
                       rst_sync <= '0';
    end case;

    end process Output_Process;


    -- Current floor output logic 

   Current_Floor_Process: process(clk, rst)
   begin
    if rst = '0' then

        Current_Floor_temp <= (Others => '0');

    elsif rising_edge(clk) then
        if Floor_Lower = '1' then

            Current_Floor_temp <= Current_Floor_temp - 1;
        
        elsif Floor_Higher = '1' then

            Current_Floor_temp <= Current_Floor_temp + 1;
            
        end if ;
        
    end if;
   end process Current_Floor_Process;

   Current_Floor <= Current_Floor_temp;    


    -- Counters

     Second_Counter : Counter_Roll_Over GENERIC MAP (N => 26, K => 50000000) PORT MAP (
                      clk => clk, 
                      rst => rst, 
                      rst_sync => rst_sync, 
                      En => '1',
                      Roll_Over => Counter1_Roll_Over
                    );

    Two_Sec_Counter : Counter_Sync_Async_Reset GENERIC MAP (N => 1, K => 1) PORT MAP (
                      clk => clk, 
                      rst => rst, 
                      sync_rst => rst_sync,
                      En => Counter1_Roll_Over,
                      Roll_Over => Counter2_Roll_Over
                    );

    Temp <= Counter1_Roll_Over and Counter2_Roll_Over;

    -- Higher and Lower Floor Logic

    Floor_Higher <= '1' when (Current_State = Up_Movement) and (Temp = '1')
             else   '0'; 

    Floor_Lower <= '1' when (Current_State = Down_Movement) and (Temp = '1')
             else   '0'; 

    -- Timing

    Timing_Process: process(clk, rst)
    begin
     if rst = '0' then

         Open_Done <= '0';

     elsif rising_edge(clk) then

         if (Current_State = Open_Door) and (Temp = '1') then

             Open_Done <= '1';

         elsif  (Current_State /= Open_Door) then

             Open_Done <= '0';

         end if ;
            
     end if;
    end process Timing_Process;

    proc_name: process(clk, rst)
    begin
       if rst = '0' then

        Permision_temp <= '0';

       elsif rising_edge(clk) then

        Permision_temp <= permission;

       end if;
    end process proc_name;

    Floor_Process: process(clk, rst)
    begin
      if rst = '0' then

          Floor_Requested_Temp <= (Others => '0');

      elsif rising_edge(clk) then

          if (permission = '1') then

              Floor_Requested_Temp <= Floor_Requested;

          end if ;

      end if;
    end process Floor_Process;
    
end architecture rtl;