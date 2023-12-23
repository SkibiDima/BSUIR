library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity D_ff_ar_tb is
end D_ff_ar_tb;

architecture tb of D_ff_ar_tb is

       component D_ff_ar port (
           i_areset : in STD_LOGIC;
           i_data : in STD_LOGIC;
           i_clk: in STD_LOGIC;
           o_q: out STD_LOGIC
       );
       end component;

       constant clk_period: time := 10 ns;

       signal i_areset :  STD_LOGIC := '0';
       signal i_data : STD_LOGIC := '0';
       signal i_clk:  STD_LOGIC := '0';
       signal o_q:  STD_LOGIC := '0';
       
begin

    DUT: D_ff_ar port map (i_areset => i_areset, i_data => i_data, i_clk => i_clk, o_q => o_q);

    i_clk <= not i_clk after clk_period/2;

    test_proc: process begin
    
        report "Simulation D_ff_ar_tb start";
    
        wait until rising_edge(i_clk);
        
        i_data <= '1';
        
        wait until rising_edge(i_clk);
        wait for 1ps;
        assert (o_q = i_data) report "Can't write" severity FAILURE;
        
        wait until rising_edge(i_clk);
        wait for clk_period/10;
        i_areset <= '1';
        wait for 1ps;
        assert (o_q = '0') report "Async reset is not working" severity FAILURE;
        
    
        report "Simulation  D_ff_ar_tb finish";
        std.env.stop;
    end process;

end tb;
