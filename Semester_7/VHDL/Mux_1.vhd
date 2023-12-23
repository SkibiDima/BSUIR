----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.09.2023 14:49:57
-- Design Name: 
-- Module Name: Mux_1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mux_1 is
  port (
       i_data : in std_logic_vector (7 downto 0);
       i_addr : in std_logic_vector (2 downto 0);
       i_oe_n : in std_logic;
       o_out_p : out std_logic;
       o_out_n : out std_logic
  );
end Mux_1;

architecture Concurrent of Mux_1 is
    signal oe_inv: std_logic;
    signal addr_p, addr_n: std_logic_vector (2 downto 0);
    signal and_gates: std_logic_vector (7 downto 0);
    signal or_gate: std_logic;
begin
    
    oe_inv <= not i_oe_n;
    
    addr_p(0) <= i_addr(0);
    addr_p(1) <= i_addr(1);
    addr_p(2) <= i_addr(2);
    
    addr_n(0) <= not i_addr(0);
    addr_n(1) <= not i_addr(1);
    addr_n(2) <= not i_addr(2);
    
    and_gates(0) <= i_data(0) and addr_n(0) and addr_n(1) and addr_n(2);
    and_gates(1) <= i_data(1) and addr_p(0) and addr_n(1) and addr_n(2);
    and_gates(2) <= i_data(2) and addr_n(0) and addr_p(1) and addr_n(2);
    and_gates(3) <= i_data(3) and addr_p(0) and addr_p(1) and addr_n(2);
    and_gates(4) <= i_data(4) and addr_n(0) and addr_n(1) and addr_p(2);
    and_gates(5) <= i_data(5) and addr_p(0) and addr_n(1) and addr_p(2);
    and_gates(6) <= i_data(6) and addr_n(0) and addr_p(1) and addr_p(2);
    and_gates(7) <= i_data(7) and addr_p(0) and addr_p(1) and addr_p(2);

    or_gate <= and_gates(0) or and_gates(1) or and_gates(2) or and_gates(3) 
            or and_gates(4) or and_gates(5) or and_gates(6) or and_gates(7);
            
    o_out_p <= or_gate and oe_inv;
    o_out_n <= not or_gate and oe_inv;
     

end Concurrent;

--    And_4_0 : entity work.And_4(Concurrent) 
--    port map (
--    i_vector(0) => i_data(0), i_vector(1) => addr_n(0), i_vector(2) => addr_n(1), i_vector(3) => addr_n(2), o_and => and_gates(0)
--    );
--    And_4_1 : entity work.And_4(Concurrent) 
--    port map (
--    i_vector(0) => i_data(1), i_vector(1) => addr_p(0), i_vector(2) => addr_n(1), i_vector(3) => addr_n(2), o_and => and_gates(1)
--    );
--    And_4_2 : entity work.And_4(Concurrent) 
--    port map (
--    i_vector(0) => i_data(2), i_vector(1) => addr_n(0), i_vector(2) => addr_p(1), i_vector(3) => addr_n(2), o_and => and_gates(2)
--    );
--    And_4_3 : entity work.And_4(Concurrent) 
--    port map (
--    i_vector(0) => i_data(3), i_vector(1) => addr_p(0), i_vector(2) => addr_p(1), i_vector(3) => addr_n(2), o_and => and_gates(3)
--    );
--    And_4_4 : entity work.And_4(Concurrent) 
--    port map (
--    i_vector(0) => i_data(4), i_vector(1) => addr_n(0), i_vector(2) => addr_n(1), i_vector(3) => addr_p(2), o_and => and_gates(4)
--    );
--    And_4_5 : entity work.And_4(Concurrent) 
--    port map (
--    i_vector(0) => i_data(5), i_vector(1) => addr_p(0), i_vector(2) => addr_n(1), i_vector(3) => addr_p(2), o_and => and_gates(5)
--    );
--    And_4_6 : entity work.And_4(Concurrent) 
--    port map (
--    i_vector(0) => i_data(6), i_vector(1) => addr_n(0), i_vector(2) => addr_p(1), i_vector(3) => addr_p(2), o_and => and_gates(6)
--    );
--    And_4_7 : entity work.And_4(Concurrent) 
--    port map (
--    i_vector(0) => i_data(7), i_vector(1) => addr_p(0), i_vector(2) => addr_p(1), i_vector(3) => addr_p(2), o_and => and_gates(7)
--    );