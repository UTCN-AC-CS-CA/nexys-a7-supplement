library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity test_reg_file is
  port (
    clk : in  std_logic;
    btn : in  std_logic_vector(4  downto 0);
    sw  : in  std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0);
    an  : out std_logic_vector(7  downto 0);
    cat : out std_logic_vector(6  downto 0)
  );
end entity test_reg_file;

architecture behavioral of test_reg_file is

  signal s_cnt     : std_logic_vector(3 downto 0) := x"0";
  signal s_mpg_out : std_logic_vector(4 downto 0) := b"0_0000";
  
  signal s_rd1 : std_logic_vector(31 downto 0) := x"0000_0000";
  signal s_rd2 : std_logic_vector(31 downto 0) := x"0000_0000";
  
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
  
  component reg_file
  port (
    clk : in  std_logic;
    ra1 : in  std_logic_vector(3 downto 0);
    ra2 : in  std_logic_vector(3 downto 0);
    wa  : in  std_logic_vector(3 downto 0);
    wd  : in  std_logic_vector(31 downto 0);
    wen : in  std_logic;
    rd1 : out std_logic_vector(31 downto 0);
    rd2 : out std_logic_vector(31 downto 0)
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
  
  rf : reg_file
  port map (
    clk => clk,
    ra1 => s_cnt,
    ra2 => s_cnt,
    wa  => s_cnt,
    wd  => s_to_digs,
    wen => s_mpg_out(3),
    rd1 => s_rd1,
    rd2 => s_rd2
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
  
  s_to_digs <= s_rd1 + s_rd2;

end architecture behavioral;