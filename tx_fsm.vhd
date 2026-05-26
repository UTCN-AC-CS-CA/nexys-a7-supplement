library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity tx_fsm_3_proc is
  port(
    clk     : in  std_logic;
    rst     : in  std_logic;
    baud_en : in  std_logic;
    tx_en   : in  std_logic;
    cts     : in  std_logic;  -- active low ('0' --> OK to send)
    tx_data : in  std_logic_vector(7 downto 0);
    tx_rdy  : out std_logic;
    tx      : out std_logic
  );
end tx_fsm_3_proc;

architecture Behavioral of tx_fsm_3_proc is

  type state_type is (st_idle, st_start, st_bit, st_stop);
  signal state, next_state : state_type := st_idle;
  signal s_bit_cnt         : std_logic_vector(2 downto 0) := "000";

begin

  -- 1.) Process for clocking reset and next state (and bit counter)
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state     <= st_idle;
        s_bit_cnt <= "000";
      else
        state <= next_state;
        if baud_en = '1' then
          if state = st_bit then
            s_bit_cnt <= s_bit_cnt + 1;
          else
            s_bit_cnt <= "000";
          end if;
        end if;
      end if;
    end if;
  end process;

  -- 2.) Process for state transition flow (no clock!)
  process(state, baud_en, tx_en, cts, s_bit_cnt)
  begin
    next_state <= state;
    if baud_en = '1' then
      case state is

      end case;
    end if;
  end process;

  -- 3.) Process for outputs (also no clock)
  process(state, tx_data, s_bit_cnt)
  begin
    case state is

    end case;
  end process;

end Behavioral;
