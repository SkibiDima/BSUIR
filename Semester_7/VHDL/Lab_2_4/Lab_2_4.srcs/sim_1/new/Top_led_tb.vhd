library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_led_tb is
end Top_led_tb;

architecture tb of Top_led_tb is
    constant i_clk_period: time := 5 ns;
    constant divider: positive := 200000;
    
    signal i_areset_n: std_logic;
    signal i_clk: std_logic := '0';
    signal i_data: std_logic;
    signal o_leds: std_logic_vector(3 downto 0);
begin
    
    DUT : entity work.Top_leds 
    port map(i_areset_n => i_areset_n, i_clk => i_clk, i_data => i_data, o_leds => o_leds);
    
    i_clk <= not i_clk after i_clk_period/2;
    
    test: process 
    
    begin
    i_areset_n <= '0';
    i_data <= '1';
    wait for 30 ns;
    
    i_areset_n <= '1';
    i_data <= '1';
    
    wait for i_clk_period*divider*400;
    
    std.env.finish;
    end process;


end tb;
