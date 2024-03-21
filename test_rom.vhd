library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity test_rom is
  port (
    clk : in  std_logic;
    btn : in  std_logic_vector(4  downto 0);
    sw  : in  std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0);
    an  : out std_logic_vector(7  downto 0);
    cat : out std_logic_vector(6  downto 0)
  );
end entity test_rom;

architecture behavioral of test_rom is

  signal s_cnt     : std_logic_vector(7 downto 0) := x"00";
  signal s_mpg_out : std_logic_vector(4 downto 0) := b"0_0000";
  
  signal s_data    : std_logic_vector(15 downto 0) := x"0000";
  signal s_to_digs : std_logic_vector(31 downto 0) := x"0000_0000";
  
  type t_rom is array (0 to 255) of std_logic_vector(15 downto 0);
  signal rom : t_rom := (
    x"0000",  
    x"1234",
    x"abcd",
    x"1337",
    others => (others => '1')
  );
    
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
  
  led <= x"00" & s_cnt;
  
  s_data <= rom(conv_integer(s_cnt));
  
  s_to_digs <= x"0000" & s_data;

end architecture behavioral;