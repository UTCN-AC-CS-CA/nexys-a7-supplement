library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity test_ram is
  port (
    clk : in  std_logic;
    btn : in  std_logic_vector(4  downto 0);
    sw  : in  std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0);
    an  : out std_logic_vector(7  downto 0);
    cat : out std_logic_vector(6  downto 0)
  );
end entity test_ram;

architecture behavioral of test_ram is

  signal s_cnt     : std_logic_vector(3 downto 0) := x"0";
  signal s_mpg_out : std_logic_vector(4 downto 0) := b"0_0000";
  
  signal s_do      : std_logic_vector(31 downto 0) := x"0000_0000";
  signal s_to_digs : std_logic_vector(31 downto 0) := x"0000_0000";  
    
  component mono_pulse_gener
  port (
    clk    : in  std_logic;
    btn    : in  std_logic_vector(4 downto 0);
    enable : out std_logic_vector(4 downto 0)
  );
  end component;
  
  component seven_seg_disp
  port (
    clk    : in  std_logic;
    digits : in  std_logic_vector(31 downto 0);
    an     : out std_logic_vector(7  downto 0);
    cat    : out std_logic_vector(6  downto 0)
  );
  end component;
  
  component ram_write_first
  port (
    clk  : in  std_logic;
    wen  : in  std_logic;
    addr : in  std_logic_vector(3  downto 0);
    di   : in  std_logic_vector(31 downto 0);
    do   : out std_logic_vector(31 downto 0)
  );
  end component;

begin

  mpg : mono_pulse_gener
  port map (
    clk => clk,
    btn => btn,
    enable => s_mpg_out
  );
  
  ssd : seven_seg_disp
  port map (
    clk    => clk,
    digits => s_to_digs,
    an     => an,
    cat    => cat
  );
  
  ram : ram_write_first
  port map (
    clk  => clk,
    wen  => s_mpg_out(3),
    addr => s_cnt,
    di   => s_to_digs,
    do   => s_do
  );
  
  process(clk) 
  begin
    if rising_edge(clk) then
      if s_mpg_out(2) = '1' then
        s_cnt <= (others => '0');
      elsif s_mpg_out(0) = '1' then
        s_cnt <= s_cnt + 1;
      end if;
    end if;
  end process;
  
  led <= x"000" & s_cnt;  
  
  s_to_digs <= s_do(29 downto 0) & "00";

end architecture behavioral;