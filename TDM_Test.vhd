library ieee;
use ieee.std_logic_1164.all;

entity TDM_test is
	port(
		clk, reset : in std_logic;
		m_clk, b_clk, dac_lr_clk, adc_lr_clk: out std_logic;
		dacdat : out std_logic;
		adcdat : in std_logic
	);
end TDM_test;

architecture arch of TDM_test is
	signal adc_data_out : std_logic_vector(31 downto 0);
	signal load_done_tick : std_logic;
	signal reset_n : std_logic;
begin

	reset_n <= not reset;
	dac_adc_unit: entity work.adc_dac(arch)
		port map(
			clk=>clk, reset=>reset_n,
			stereo_in_1=> x"AAA1AAA2",
			stereo_in_2=> x"AAA3AAA4",
			stereo_in_3=> x"AAA5AAA6",
			stereo_in_4=> x"AAA7AAA8",
			adc_data_out=>adc_data_out,
			m_clk=>m_clk, b_clk=>b_clk, 
			dac_lr_clk=>dac_lr_clk, adc_lr_clk=>adc_lr_clk,
			dacdat=>dacdat,
			adcdat=>adcdat,
			load_done_tick=>load_done_tick
		);
		
end arch;
	