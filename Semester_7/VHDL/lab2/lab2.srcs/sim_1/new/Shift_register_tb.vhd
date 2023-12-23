
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_textio.all;
use std.textio.all;

entity Shift_register_tb is
end Shift_register_tb;

architecture tb of Shift_register_tb is

    constant REG_SIZE: positive := 5;
    constant srclk_period: time := 10 ns;
    constant rclk_period: time := 30 ns;
    
    signal rclr_n: std_logic := '0';
    signal rclk: std_logic := '0';
    signal srclr_n: std_logic := '0';
    signal srclk: std_logic := '0';
    signal ser: std_logic := '0';
    signal q: std_logic_vector(REG_SIZE downto 0);
begin

    DUT : entity work.Shift_register 
    generic map (REG_SIZE => REG_SIZE)
    port map(rclr_n => rclr_n, rclk => rclk, srclr_n => srclr_n, srclk => srclk, ser => ser, q => q);
    
    srclk <= not srclk after srclk_period/2;
    rclk <= not rclk after rclk_period/2; 
    
    load_proc : process
        constant file_name: string :=  "Shift_register_test_lines.txt";
        file     test_file: text open read_mode is file_name;
        variable read_bool: boolean;
        variable test_line: line;
        variable test_vect: std_logic_vector(REG_SIZE-1 downto 0);
        variable ser_iter : integer := 0;
    begin 
        if(ser_iter = 0) then 
            readline(test_file,test_line);
            read(test_line,test_vect);
            if(endfile(test_file)) then   
                report "End of file " & file_name severity FAILURE;
                --std.env.stop;
            end if;        
        end if;
        ser <= test_vect(ser_iter);    
        wait until rising_edge(srclk);
        if(ser_iter = REG_SIZE-1) then ser_iter := 0;
        else ser_iter := ser_iter + 1; end if; 
    end process;
    
    
    main_proc : process 
        variable prev_q : std_logic_vector(REG_SIZE downto 0);
    begin
        
        rclr_n <= '1';
        srclr_n <= '1';
        
        report "Simulation Shift_register_tb start";
        wait for 1ps;
      
        report "Clear shifter check";
        
        wait until q /= "0";
        wait for srclk_period/10;
        srclr_n <= '0';
        prev_q := q;
         
        wait until rising_edge(rclk);
        wait for srclk_period/10; 
        if(prev_q /= q) then report "sclr is working"; 
        else report "sclr is not working" severity FAILURE;
        end if; 
                    
        wait until rising_edge(srclk);
        wait for srclk_period/10;
        srclr_n <= '1';
  
        
        for i in 0 to REG_SIZE+2 loop wait until rising_edge(srclk); end loop;
      
        report "Clear q check";
                
        wait until q /= "0";
        wait for srclk_period/10;
        rclr_n <= '0';
        prev_q := q;
         
        wait until rising_edge(rclk);
        wait for srclk_period/10; 
        if(prev_q /= q) then report "rclr is working"; 
        else report "rclr is not working" severity FAILURE;
        end if; 
        
        wait until rising_edge(rclk);
        wait for srclk_period/10;
        rclr_n <= '1';
        
        for i in 0 to 5 loop wait until rising_edge(srclk); end loop;
  
        report "Shifter check";
        
        prev_q := q;
        for i in 0 to 2 loop wait until rising_edge(srclk); end loop;
        if(q(3 downto 2) = prev_q(1 downto 0)) then report "shifter is working"; 
        else report "shifter is not working" severity FAILURE;
        end if; 
  
        report "Simulation Shift_register_tb finish";
        std.env.stop;
    end process;

end tb;
