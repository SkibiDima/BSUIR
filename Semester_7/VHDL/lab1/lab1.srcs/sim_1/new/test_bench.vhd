library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_bench is
end test_bench;

architecture test_bench_arch of test_bench is
    constant address_size : positive := 3;

    signal output_enable_n : std_logic;
    signal data : std_logic_vector(2 ** address_size - 1 downto 0);
    signal address : std_logic_vector(address_size - 1 downto 0);
    signal output_p : std_logic;
    signal output_n : std_logic;
begin
    test : entity work.mux_sequential
        generic map(address_size => address_size)
        port map(
            data => data, address => address, output_enable_n => output_enable_n,
            output_p => output_p, output_n => output_n);
    test_process : process
    begin
        report "Simulation start";

        output_enable_n <= '1';
                wait for 5 ns;
        assert (output_p = output_n and output_p = 'Z')
                report "Invalid result: output_p != output_n != Z" severity FAILURE;
                
        output_enable_n <= '0';
        address <= (others => '0');
        data <= (others => '0');
        for j in 0 to 2 ** address_size - 1 loop
            for k in 0 to 2 ** (2 ** address_size) - 1 loop
                wait for 5 ns;
                assert (output_p = data(to_integer(unsigned(address))) xor (output_p = output_n and output_p = 'Z'))
                report "Invalid result: time = " & time'image(now)
                    & ", address = " & integer'image(to_integer(unsigned(address)))
                    & ", data = " & integer'image(to_integer(unsigned(data)))
                    severity FAILURE;
--                wait for 5 ns;
                data <= std_logic_vector(unsigned(data) + 1);
            end loop;
            wait for 5 ns;
            data <= (others => '0');
            address <= std_logic_vector(unsigned(address) + 1);
        end loop;
        
        output_enable_n <= '1';
        address <= (others => '0');
        data <= (others => '0');
        for j in 0 to 2 ** address_size - 1 loop
            for k in 0 to 2 ** (2 ** address_size) - 1 loop
                wait for 5 ns;
                assert (output_p = output_n and output_p = 'Z')
                report "Invalid result: output_p != output_n != Z" severity FAILURE;
                data <= std_logic_vector(unsigned(data) + 1);
            end loop;
            wait for 5 ns;
            data <= (others => '0');
            address <= std_logic_vector(unsigned(address) + 1);
        end loop;
        
        report "Simulation finish";
        std.env.finish;
    end process;
end test_bench_arch;
