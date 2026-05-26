library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity baud_rate_gen is
  generic (
    DIVISOR : integer := 1
  );
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    baud_en : out std_logic
  );
end baud_rate_gen;

architecture Behavioral of baud_rate_gen is

  signal s_cnt : std_logic_vector(13 downto 0); -- You need to fit 10416

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s_cnt   <= (others => '0');
        baud_en <= '0';
      elsif s_cnt = conv_integer(DIVISOR) then
        s_cnt   <= (others => '0');
        baud_en <= '1';
      else
        s_cnt   <= s_cnt + 1;
        baud_en <= '0';
      end if;
    end if;
  end process;

end Behavioral;
