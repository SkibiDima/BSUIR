library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_parallel is
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
end mux_parallel;

architecture parallel_arch of mux_parallel is
  signal output_enable : std_logic;
  signal address_p : std_logic_vector (address_size - 1 downto 0);
  signal address_n : std_logic_vector (address_size - 1 downto 0);
  signal and_gates : std_logic_vector (2 ** address_size - 1 downto 0);
  signal or_gate : std_logic;
begin
  output_enable <= not output_enable_n;

  address_p(0) <= address(0);
  address_p(1) <= address(1);
  address_p(2) <= address(2);

  address_n(0) <= not address(0);
  address_n(1) <= not address(1);
  address_n(2) <= not address(2);

  and_gates(0) <= data(0) and address_n(0) and address_n(1) and address_n(2);
  and_gates(1) <= data(1) and address_p(0) and address_n(1) and address_n(2);
  and_gates(2) <= data(2) and address_n(0) and address_p(1) and address_n(2);
  and_gates(3) <= data(3) and address_p(0) and address_p(1) and address_n(2);
  and_gates(4) <= data(4) and address_n(0) and address_n(1) and address_p(2);
  and_gates(5) <= data(5) and address_p(0) and address_n(1) and address_p(2);
  and_gates(6) <= data(6) and address_n(0) and address_p(1) and address_p(2);
  and_gates(7) <= data(7) and address_p(0) and address_p(1) and address_p(2);

  or_gate <= and_gates(0) or and_gates(1) or and_gates(2) or and_gates(3)
    or and_gates(4) or and_gates(5) or and_gates(6) or and_gates(7);

  output_p <= or_gate when output_enable = '1' else 'Z';
  output_n <= not or_gate when output_enable = '1' else 'Z';
end parallel_arch;
