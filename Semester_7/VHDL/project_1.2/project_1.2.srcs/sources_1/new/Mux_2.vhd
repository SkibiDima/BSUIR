library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mux_2 is
  generic(
    Addr_size: positive := 4
  );
  port (
       i_data : in std_logic_vector (2 ** (Addr_size) - 1 downto 0);
       i_addr : in std_logic_vector (Addr_size-1 downto 0);
       i_oe_n : in std_logic;
       o_out_p : out std_logic;
       o_out_n : out std_logic
  );
end Mux_2;

architecture Type2 of Mux_2 is
begin
    
    process(i_data, i_addr, i_oe_n) 
    begin
        if i_oe_n = '1' then
            o_out_n <= 'Z';
            o_out_p <= 'Z';
        else 
            o_out_p <= i_data(to_integer(unsigned(i_addr)));
            o_out_n <= not i_data(to_integer(unsigned(i_addr)));
        end if;
    end process;
    
end Type2;
