library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Shift_register is
generic(
    REG_SIZE : positive := 4
);
port(
    rclr_n: in std_logic;
    rclk: in std_logic;
    srclr_n: in std_logic;
    srclk: in std_logic;
    ser: in std_logic;
    q: out std_logic_vector(REG_SIZE downto 0)
);
end Shift_register;

architecture shift_register_arch of Shift_register is
    
    component D_ff_ar is
        port(i_areset : in STD_LOGIC;
            i_data : in STD_LOGIC;
            i_clk: in STD_LOGIC;
            o_q: out STD_LOGIC);
    end component;

    signal rclr_p : std_logic;
    signal srclr_p : std_logic;
    signal shift_out : std_logic_vector(REG_SIZE-1 downto 0);
begin
    rclr_p <= not rclr_n;
    srclr_p <= not srclr_n;
     
    
    Gen_shift: for i in 0 to REG_SIZE-1 generate
        gen_shift_0: if (i = 0) generate
            shifter: D_ff_ar port map(i_areset => srclr_p,
                                    i_data => ser,
                                    i_clk => srclk,
                                    o_q => shift_out(0));
        end generate gen_shift_0;
        gen_shift_other: if (i /= 0) generate
            shifter: D_ff_ar port map(i_areset => srclr_p,
                                      i_data => shift_out(i-1),
                                      i_clk => srclk,
                                      o_q => shift_out(i));
        end generate gen_shift_other;
    end generate Gen_shift;
    
    Gen_stor: for i in 0 to REG_SIZE-1 generate
    begin
        storage: D_ff_ar port map(i_areset => rclr_p,
                                  i_data => shift_out(i),
                                  i_clk => rclk,
                                  o_q => q(i));
    end generate Gen_stor;
    
    q(REG_SIZE) <= shift_out(REG_SIZE-1);
end shift_register_arch;
