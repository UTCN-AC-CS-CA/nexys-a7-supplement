library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity ram_write_first is
  port (
    clk  : in  std_logic;
    wen  : in  std_logic;
    addr : in  std_logic_vector(3  downto 0);
    di   : in  std_logic_vector(31 downto 0);
    do   : out std_logic_vector(31 downto 0)
  );
end ram_write_first;

architecture behavioral of ram_write_first is

  type t_ram is array (0 to 15) of std_logic_vector(31 downto 0);
  signal ram : t_ram := (
    (others => '0'),
    x"0000_0001",  
    x"0000_0002",
    x"0000_0003",
    others => (others => '0')
  );

begin

  process (clk)
  begin
    if rising_edge(clk) then
      if wen = '1' then
        ram(conv_integer(addr)) <= di;
        do <= di;
      else
        do <= ram(conv_integer(addr));
      end if;
    end if;
  end process;

end behavioral;