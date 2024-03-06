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

  signal s_counter : std_logic_vector(15  downto 0) := x"0000";
  signal s_mpg_out : std_logic_vector(4  downto 0)  := b"0_0000";
  
--  signal s_counter_5_bit : std_logic_vector(4  downto 0)  := b"0_0000";
--  signal s_bcd           : std_logic_vector(15  downto 0) := x"0000";

  component mono_pulse_gener
  port (
    clk    : in  std_logic;
    btn    : in  std_logic_vector(4  downto 0);
    enable : out std_logic_vector(4  downto 0)
  );
  end component;

begin

  mpg : mono_pulse_gener
  port map (
    clk => clk,
    btn => btn,
    enable => s_mpg_out
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
  
--  process(clk) 
--  begin
--    if rising_edge(clk) then
----      if s_mpg_out > 0 then -- any of the buttons is pressed
--      if s_mpg_out(1) = '1' then -- one of the five buttons is pressed
--        if s_counter_5_bit = b"1_0000" then
--          s_counter_5_bit <= (others => '0');
--        else
--          s_counter_5_bit <= s_counter_5_bit + 1;
--        end if;
--      end if;
--    end if;
--  end process;  
  
--  process(s_counter_5_bit)
--  begin
--    case s_counter_5_bit is
--      when b"0_0000" => s_bcd <= b"0000_0000_0000_0000";
--      when b"0_0001" => s_bcd <= b"0000_0000_0000_0001";
--      when b"0_0010" => s_bcd <= b"0000_0000_0000_0010";
--      when b"0_0011" => s_bcd <= b"0000_0000_0000_0100";
--      when b"0_0100" => s_bcd <= b"0000_0000_0000_1000";
--      when b"0_0101" => s_bcd <= b"0000_0000_0001_0000";
--      when b"0_0110" => s_bcd <= b"0000_0000_0010_0000";
--      when b"0_0111" => s_bcd <= b"0000_0000_0100_0000";
--      when b"0_1000" => s_bcd <= b"0000_0000_1000_0000";
--      when b"0_1001" => s_bcd <= b"0000_0001_0000_0000";
--      when b"0_1010" => s_bcd <= b"0000_0010_0000_0000";
--      when b"0_1011" => s_bcd <= b"0000_0100_0000_0000";
--      when b"0_1100" => s_bcd <= b"0000_1000_0000_0000";
--      when b"0_1101" => s_bcd <= b"0001_0000_0000_0000";
--      when b"0_1110" => s_bcd <= b"0010_0000_0000_0000";
--      when b"0_1111" => s_bcd <= b"0100_0000_0000_0000";
--      when others    => s_bcd <= b"1000_0000_0000_0000";
--    end case;
--  end process;

--  led <= s_bcd;

end architecture behavioral; 