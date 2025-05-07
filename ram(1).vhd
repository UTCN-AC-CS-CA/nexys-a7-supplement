library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity ram is
    port (
      clk  : in  std_logic;
      wen  : in  std_logic;
      addr : in  std_logic_vector(3  downto 0);
      di   : in  std_logic_vector(15 downto 0);
      do   : out std_logic_vector(15 downto 0)
    );
end entity;

  architecture rtl of ram is

    type t_ram is array (0 to 15) of std_logic_vector(15 downto 0);
    signal s_ram : t_ram := (
      (others => '0'),
      x"0001",
      x"0002",
      x"0003",
      others => (others => '0')
    );
  
  begin
  
    process (clk)
    begin
      if rising_edge(clk) then
        if wen = '1' then
          s_ram(conv_integer(addr)) <= di;
          -- do <= di;
        end if;
      end if;
    end process;

    do <= s_ram(conv_integer(addr));
  
  end architecture;