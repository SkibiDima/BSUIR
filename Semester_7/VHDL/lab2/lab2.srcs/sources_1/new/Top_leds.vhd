
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Top_leds is
  Port ( 
        i_clk : in std_logic;
        i_data: in std_logic;
        i_a_reset: in std_logic;
        o_leds : out std_logic_vector(3 downto 0)
  );
end Top_leds;

architecture Behavioral of Top_leds is

    constant REG_SIZE : positive := 4;
    constant DIVIDER : positive := 1000000;

    component Counter 
    port (
        i_areset : in STD_LOGIC;
        i_clk: in STD_LOGIC;
        o_clk: out STD_LOGIC
    );
    end component;

    component Shift_register 
    port(
        rclr_n: in std_logic;
        rclk: in std_logic;
        srclr_n: in std_logic;
        srclk: in std_logic;
        ser: in std_logic;
        q: out std_logic_vector(REG_SIZE downto 0)
    );
    end component;

    signal divider_clk : std_logic;
    signal shift_out: std_logic_vector(4 downto 0);
    
    signal stable_data: std_logic;
    signal stable_shift_out: std_logic_vector(4 downto 0);
begin

    Counter_divider: Counter 
    port map (i_areset => i_a_reset, i_clk => i_clk, o_clk => divider_clk);

    Shift_reg: Shift_register
    port map(rclr_n => i_a_reset, rclk => divider_clk, srclr_n => i_a_reset, srclk => divider_clk, ser => stable_data, q => shift_out);

    Antirattle_data: Shift_register
    port map(rclr_n => i_a_reset, rclk => i_clk, srclr_n => i_a_reset, srclk => i_clk, ser => i_data, q => stable_shift_out);

    stable_data <= stable_shift_out(0) and stable_shift_out(1) and stable_shift_out(2) and stable_shift_out(3);
    o_leds <= shift_out(3 downto 0);

end Behavioral;
