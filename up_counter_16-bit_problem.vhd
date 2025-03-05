library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity proba1 is
  port (
    clk : in  std_logic;
    btn : in  std_logic_vector(4  downto 0);
    sw  : in  std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0);
    an  : out std_logic_vector(7  downto 0);
    cat : out std_logic_vector(6  downto 0)
  );
end entity proba1;

architecture behavioral of proba1 is

  signal en  : std_logic                     := '0';
  signal cnt : std_logic_vector(15 downto 0) := (others => '0');

begin

  en <= btn(0);

  process(clk) 
  begin
    if rising_edge(clk) then
      if en = '1' then 
        cnt <= cnt + 1; 
      end if;
    end if;
  end process;
  
  led <= cnt;

end behavioral; 
