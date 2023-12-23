
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Counter_tb is
end Counter_tb;

architecture tb of Counter_tb is

--    component Counter 
--    port (
--           i_areset : in STD_LOGIC;
--           i_clk: in STD_LOGIC;
--           o_clk: out STD_LOGIC
--       );
--    end component;

    constant DIVIDER: positive := 10;
    constant clk_period: time := 10 ns;
    
    signal i_areset : std_logic := '0';
    signal i_clk : std_logic := '0';
    signal o_clk : std_logic;
begin

    DUT: entity work.Counter 
    generic map (DIVIDER => DIVIDER) 
    port map (i_areset => i_areset, i_clk => i_clk, o_clk => o_clk);

    i_clk <= not i_clk after clk_period/2;

    test_proc: process begin
    
        report "Simulation Counter start";
    
        for i in 0 to DIVIDER loop wait until rising_edge(i_clk); end loop;
        wait for 1ps;
        assert (o_clk = '1') report "Counter can't count" severity FAILURE;
        
        for i in 0 to DIVIDER loop wait until rising_edge(i_clk); end loop;
        for i in 0 to DIVIDER loop wait until rising_edge(i_clk); end loop;
        for i in 0 to DIVIDER loop wait until rising_edge(i_clk); end loop;
        
        wait until rising_edge(i_clk);
        wait until rising_edge(i_clk);
        
        i_areset <= '1';
        
        for i in 0 to DIVIDER loop 
            wait until rising_edge(i_clk); 
            assert(o_clk = '0') report "Counter can't reset" severity FAILURE;
        end loop;
    
        report "Simulation Counter finish";
        std.env.stop;
    end process;
    
end tb;
