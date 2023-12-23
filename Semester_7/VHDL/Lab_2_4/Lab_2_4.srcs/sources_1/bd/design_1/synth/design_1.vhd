--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
--Date        : Sat Oct 28 14:44:39 2023
--Host        : g14-win10 running 64-bit major release  (build 9200)
--Command     : generate_target design_1.bd
--Design      : design_1
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1 is
  port (
    i_data : in STD_LOGIC;
    o_leds : out STD_LOGIC_VECTOR ( 7 downto 0 );
    reset : in STD_LOGIC;
    sys_diff_clock_clk_n : in STD_LOGIC;
    sys_diff_clock_clk_p : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of design_1 : entity is "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,da_board_cnt=4,synth_mode=Global}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of design_1 : entity is "design_1.hwdef";
end design_1;

architecture STRUCTURE of design_1 is
  component design_1_clk_wiz_0_0 is
  port (
    clk_in1_p : in STD_LOGIC;
    clk_in1_n : in STD_LOGIC;
    reset : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    locked : out STD_LOGIC
  );
  end component design_1_clk_wiz_0_0;
  component design_1_Top_leds_0_0 is
  port (
    i_clk : in STD_LOGIC;
    i_data : in STD_LOGIC;
    i_areset_n : in STD_LOGIC;
    o_leds : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  end component design_1_Top_leds_0_0;
  signal Top_leds_0_o_leds : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal clk_wiz_0_clk_out1 : STD_LOGIC;
  signal i_data_1 : STD_LOGIC;
  signal reset_1 : STD_LOGIC;
  signal sys_diff_clock_1_CLK_N : STD_LOGIC;
  signal sys_diff_clock_1_CLK_P : STD_LOGIC;
  signal NLW_clk_wiz_0_locked_UNCONNECTED : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of i_data : signal is "xilinx.com:signal:data:1.0 DATA.I_DATA DATA";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of i_data : signal is "XIL_INTERFACENAME DATA.I_DATA, LAYERED_METADATA undef";
  attribute X_INTERFACE_INFO of reset : signal is "xilinx.com:signal:reset:1.0 RST.RESET RST";
  attribute X_INTERFACE_PARAMETER of reset : signal is "XIL_INTERFACENAME RST.RESET, INSERT_VIP 0, POLARITY ACTIVE_HIGH";
  attribute X_INTERFACE_INFO of sys_diff_clock_clk_n : signal is "xilinx.com:interface:diff_clock:1.0 sys_diff_clock CLK_N";
  attribute X_INTERFACE_PARAMETER of sys_diff_clock_clk_n : signal is "XIL_INTERFACENAME sys_diff_clock, CAN_DEBUG false, FREQ_HZ 200000000";
  attribute X_INTERFACE_INFO of sys_diff_clock_clk_p : signal is "xilinx.com:interface:diff_clock:1.0 sys_diff_clock CLK_P";
  attribute X_INTERFACE_INFO of o_leds : signal is "xilinx.com:signal:data:1.0 DATA.O_LEDS DATA";
  attribute X_INTERFACE_PARAMETER of o_leds : signal is "XIL_INTERFACENAME DATA.O_LEDS, LAYERED_METADATA undef";
begin
  i_data_1 <= i_data;
  o_leds(7 downto 0) <= Top_leds_0_o_leds(7 downto 0);
  reset_1 <= reset;
  sys_diff_clock_1_CLK_N <= sys_diff_clock_clk_n;
  sys_diff_clock_1_CLK_P <= sys_diff_clock_clk_p;
Top_leds_0: component design_1_Top_leds_0_0
     port map (
      i_areset_n => reset_1,
      i_clk => clk_wiz_0_clk_out1,
      i_data => i_data_1,
      o_leds(7 downto 0) => Top_leds_0_o_leds(7 downto 0)
    );
clk_wiz_0: component design_1_clk_wiz_0_0
     port map (
      clk_in1_n => sys_diff_clock_1_CLK_N,
      clk_in1_p => sys_diff_clock_1_CLK_P,
      clk_out1 => clk_wiz_0_clk_out1,
      locked => NLW_clk_wiz_0_locked_UNCONNECTED,
      reset => reset_1
    );
end STRUCTURE;
