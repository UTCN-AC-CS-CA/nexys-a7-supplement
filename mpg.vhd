library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  
entity mono_pulse_gener is
  port (
    clk    : in  std_logic;
    btn    : in  std_logic_vector(4  downto 0);
    enable : out std_logic_vector(4  downto 0)
  );
end mono_pulse_gener;

architecture Behavioral of mono_pulse_gener is

  signal s_counter_out : std_logic_vector(15 downto 0) := x"0000";
  signal s_en          : std_logic                     := '0';
  signal s_reg1        : std_logic_vector(4  downto 0) := b"0_0000";
  signal s_reg2        : std_logic_vector(4  downto 0) := b"0_0000";
  signal s_reg3        : std_logic_vector(4  downto 0) := b"0_0000";

begin

  up_counter : process(clk) 
  begin
    if rising_edge(clk) then
      s_counter_out <= s_counter_out + 1;
    end if;
  end process up_counter;
  
  s_en <= '1' when s_counter_out = x"000F" else '0';
  
  process(clk)
  begin
    if rising_edge(clk) then
      if s_en = '1' then 
        s_reg1 <= btn;
      end if;
    end if;
  end process;
  
  process(clk) 
  begin
    if rising_edge(clk) then
      s_reg2 <= s_reg1;
    end if;
  end process;
  
  process(clk) 
  begin
    if rising_edge(clk) then
      s_reg3 <= s_reg2;
    end if;
  end process;
  
  enable <= s_reg2 and not s_reg3;

end Behavioral;