library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity reg_file is
  port (
    clk : in  std_logic;
    ra1 : in  std_logic_vector(2 downto 0);
    ra2 : in  std_logic_vector(2 downto 0);
    wa  : in  std_logic_vector(2 downto 0);
    wd  : in  std_logic_vector(15 downto 0);
    wen : in  std_logic;
    rd1 : out std_logic_vector(15 downto 0);
    rd2 : out std_logic_vector(15 downto 0)
  );
end reg_file;

architecture Behavioral of reg_file is
  
  type t_reg_file is array (0 to 7) of std_logic_vector(15 downto 0);
  signal rf : t_reg_file := (
    x"0a01", -- #0
    x"0b02", -- #1
    x"0c03", -- #2
    x"0d04", -- #3
    x"0e05", -- #4
    x"0f06", -- #5
    x"123f", -- #6
    x"faab"  -- #7
  );
  
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if wen = '1' then
        rf(conv_integer(wa)) <= wd;
      end if;
    end if;
  end process;
  
  rd1 <= rf(conv_integer(ra1));
  rd2 <= rf(conv_integer(ra2));
  
end Behavioral;
