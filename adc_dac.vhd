library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_dac is
	port(
		clk, reset : in std_logic;
		stereo_in_1 : in std_logic_vector(31 downto 0);
		stereo_in_2 : in std_logic_vector(31 downto 0);
		stereo_in_3 : in std_logic_vector(31 downto 0);
		stereo_in_4 : in std_logic_vector(31 downto 0);
		adc_data_out : out std_logic_vector(31 downto 0);
		m_clk, b_clk, dac_lr_clk, adc_lr_clk : out std_logic;
		dacdat : out std_logic;
		adcdat : in std_logic;
		load_done_tick : out std_logic
	);
end adc_dac;

architecture arch of adc_dac is
	constant M_DVSR : integer := 1;
	constant B_DVSR : integer := 2;
	constant LR_DVSR : integer := 7;
	
	signal m_reg, m_next : unsigned(M_DVSR-1 downto 0);
	signal b_reg, b_next : unsigned(B_DVSR-1 downto 0);
	signal lr_reg, lr_next : unsigned(LR_DVSR-1 downto 0);
	signal dac_buf_reg, dac_buf_next : std_logic_vector(128 downto 0);
	signal adc_buf_reg, adc_buf_next : std_logic_vector(127 downto 0);
	signal lr_delayed_reg, lr_delayed_next, b_delayed_reg : std_logic;
	signal m_12_5m_tick, load_tick, b_neg_tick, b_pos_tick : std_logic;
	
	signal m_clk_delayed_reg, m_clk_delayed_reg2 ,m_clk_delayed_next : std_logic;
	signal b_clk_delayed_reg, b_clk_delayed_next : std_logic;
begin

process (clk, reset)
begin
	if (reset = '1') then
		m_reg <= (others =>'0');
		b_reg <= (others => '0');
		lr_reg <= (others => '0');
		dac_buf_reg <= (others => '0');
		adc_buf_reg <= (others => '0');
		b_delayed_reg <= '0';
		lr_delayed_reg <= '0';
		m_clk_delayed_reg <= '0';
		m_clk_delayed_reg2 <= '0';
		b_clk_delayed_reg <= '0';
	elsif (clk'event and clk='1') then
		m_reg <= m_next;
		b_reg <= b_next;
		lr_reg <= lr_next;
		dac_buf_reg <= dac_buf_next;
		adc_buf_reg <= adc_buf_next;
		b_delayed_reg <= b_reg(B_DVSR-1);
		lr_delayed_reg <= lr_reg(LR_DVSR-1);
		
		m_clk_delayed_reg <= m_clk_delayed_next;
		m_clk_delayed_reg2 <= m_clk_delayed_reg;
		b_clk_delayed_reg <= b_clk_delayed_next;
	end if;
end process;

m_next <= m_reg + 1;
m_clk_delayed_next <= m_reg(M_DVSR-1);
m_clk <= m_clk_delayed_reg2;
m_12_5m_tick <= '1' when m_reg = 0 else '0';

b_next <= 	b_reg + 1 when m_12_5m_tick = '1' else
				b_reg;
b_clk_delayed_next <= b_reg(B_DVSR-1);
b_clk <= b_clk_delayed_reg;
b_neg_tick <= b_delayed_reg and (not b_reg(B_DVSR-1));

b_pos_tick <= (not b_delayed_reg) and b_reg(B_DVSR-1);

lr_next <= 	lr_reg + 1 when b_neg_tick='1' else
				lr_reg;
dac_lr_clk <= lr_reg(LR_DVSR-1);
adc_lr_clk <= lr_reg(LR_DVSR-1);
load_tick <= lr_delayed_reg and (not lr_reg(LR_DVSR-1));
load_done_tick <= load_tick;

dac_buf_next <= 	'0' & stereo_in_1 & stereo_in_2 & stereo_in_3 & stereo_in_4 when load_tick='1' else
						dac_buf_reg(127 downto 0) & '0' when b_neg_tick = '1' else
						dac_buf_reg;
dacdat <= dac_buf_reg(128);
adc_buf_next <= adc_buf_reg(126 downto 0) & adcdat when b_pos_tick='1' else
					adc_buf_reg;
adc_data_out <= adc_buf_reg(127 downto 96);
end arch;