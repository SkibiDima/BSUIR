library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mux_2_tb is
end Mux_2_tb;

architecture tb of Mux_2_tb is

    signal i_oe_n: std_logic;
    signal i_data: std_logic_vector(7 downto 0);
    signal i_addr: std_logic_vector(2 downto 0);
    
    signal o_out_p: std_logic;
    signal o_out_n: std_logic;
    
begin

    DUT : entity work.Mux_2 port map (i_data,i_addr,i_oe_n,o_out_p,o_out_n);
    
    tb_proc : process 
    
    begin
        report "Simulation start";
        
        i_oe_n <= '0';
        
        for i in 0 to 1 loop
        
            i_data <= "00000000";
            i_addr <= "000";
            
            
            for j in 0 to 2**3-1 loop
                
                for k in 0 to 2**8-1 loop
                    
                    wait for 5 ns;
                    i_data <= std_logic_vector(unsigned(i_data) + 1); 
                    
                    if (i_oe_n = '0') then
                        assert (o_out_p = i_data(to_integer(unsigned(i_addr))) xor o_out_p = o_out_n)
                            report "Error! Time = " & time'image(now)
                            & " addr = " & integer'image(to_integer(unsigned(i_addr))) 
                            & " data = " & integer'image(to_integer(unsigned(i_data))) 
                            severity FAILURE;
                    else assert (o_out_p = o_out_n) report "Error! o_out_p != o_out_n" severity FAILURE;
                    end if;
                    
                end loop;
            
                i_addr <= std_logic_vector(unsigned(i_addr) + 1);
            
            end loop;
            
            i_oe_n <= '1';
        end loop;
        
        report "Simulation finish";
        std.env.finish;
    end process;
end tb;
