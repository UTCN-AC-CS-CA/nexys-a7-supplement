library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity test_env is
  port (
    clk : in  std_logic;
    btn : in  std_logic_vector(4  downto 0);
    sw  : in  std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0);
    an  : out std_logic_vector(7  downto 0);
    cat : out std_logic_vector(6  downto 0)
  );
end entity test_env;

architecture behavioral of test_env is

  signal s_counter : std_logic_vector(15 downto 0) := x"0000";
  signal s_mpg_out : std_logic_vector(4  downto 0) := b"0_0000";
  
  signal s_counter_5_bit : std_logic_vector(4  downto 0) := b"0_0000";

  component mono_pulse_gener
  port (
    clk    : in  std_logic;
    btn    : in  std_logic_vector(4  downto 0);
    enable : out std_logic_vector(4  downto 0)
  );
  end component;
  
  component seven_seg_disp
  port (
    clk    : in  std_logic;
    digits : in  std_logic_vector(31  downto 0);
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
    digits => x"12345678",
    an     => an,
    cat    => cat
  );
  
  process(clk) 
  begin
    if rising_edge(clk) then
--      if s_mpg_out > 0 then    -- any of the buttons is pressed
      if s_mpg_out(1) = '1' then -- top button is pressed
        s_counter <= s_counter + 1;
      end if;
    end if;
  end process;
  
  led <= s_counter;

end architecture behavioral; 