library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_sequential is
  generic (
    address_size : positive := 3
  );
  port (
    data : in std_logic_vector (2 ** address_size - 1 downto 0);
    address : in std_logic_vector (address_size - 1 downto 0);
    output_enable_n : in std_logic;
    output_p : out std_logic;
    output_n : out std_logic
  );
end mux_sequential;

architecture sequential_arch of mux_sequential is
  signal output_enable : std_logic;
begin
  output_enable <= not output_enable_n;
  process (data, address, output_enable)
  begin
    if output_enable = '1' then
      output_p <= data(to_integer(unsigned(address)));
      output_n <= not data(to_integer(unsigned(address)));
    else
      output_p <= 'Z';
      output_n <= 'Z';
    end if;
  end process;
end sequential_arch;
