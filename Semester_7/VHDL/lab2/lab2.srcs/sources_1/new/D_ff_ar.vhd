
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity D_ff_ar is
  Port ( 
    i_areset : in STD_LOGIC;
    i_data : in STD_LOGIC;
    i_clk: in STD_LOGIC;
    o_q: out STD_LOGIC := '0'
  );
end D_ff_ar;

architecture Behavioral of D_ff_ar is

begin

    process(i_areset, i_data, i_clk) begin
        if(i_areset = '1') then
            o_q <= '0';
        else
            if(i_clk'event and i_clk = '1') then
                o_q <= i_data;
            end if;
        end if;
    end process;

end Behavioral;
