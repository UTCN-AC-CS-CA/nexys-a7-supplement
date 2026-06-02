library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity rx_fsm_3_proc is
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    baud_en : in  std_logic;
    rx      : in  std_logic;
    rx_data : out std_logic_vector(7 downto 0);
    rx_rdy  : out std_logic;
    rts     : out std_logic                       -- active low ('0' --> ready)
  );
end rx_fsm_3_proc;

architecture Behavioral of rx_fsm_3_proc is
  type state_type is (st_idle, st_start, st_bit, st_stop, st_wait);
  signal state, next_state : state_type := st_idle;

  signal s_baud_cnt : std_logic_vector(3 downto 0) := "0000";   -- 0..15
  signal s_bit_cnt  : std_logic_vector(2 downto 0) := "000";    -- 0..7
  signal s_shift    : std_logic_vector(7 downto 0) := (others => '0');
begin

  -- 1.) Clocked process: state register, counters, shift register
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state      <= st_idle;
        s_baud_cnt <= "0000";
        s_bit_cnt  <= "000";
        s_shift    <= (others => '0');
      else
        state <= next_state;

        if baud_en = '1' then
          -- BAUD_CNT: reset on state transition, increment otherwise
          if next_state /= state then
            s_baud_cnt <= "0000";
          else
            s_baud_cnt <= s_baud_cnt + 1;
          end if;

          -- BIT_CNT: increments only in bit state at the sample point;
          --          reset everywhere else
          if state = st_bit then
            if s_baud_cnt = "1111" then
              s_bit_cnt <= s_bit_cnt + 1;
            end if;
          else
            s_bit_cnt <= "000";
          end if;

          -- Shift register: sample RX in the middle of each data bit
          if state = st_bit and s_baud_cnt = "1111" then
            s_shift <= rx & s_shift(7 downto 1);    -- LSB first
          end if;
        end if;
      end if;
    end if;
  end process;

  -- 2.) Next-state logic (combinational, no clock)
  process(state, baud_en, rx, s_baud_cnt, s_bit_cnt)
  begin
    next_state <= state;
    if baud_en = '1' then
      case state is
        when st_idle =>
          if rx = '0' then
            next_state <= st_start;
          end if;

        when st_start =>
          if s_baud_cnt = "0111" then
            next_state <= st_bit;
          end if;

        when st_bit =>
          if s_bit_cnt = "111" and s_baud_cnt = "1111" then
            next_state <= st_stop;
          end if;

        when st_stop =>
          if s_baud_cnt = "1111" then
            next_state <= st_wait;
          end if;

        when st_wait =>
          if s_baud_cnt = "0111" then
            next_state <= st_idle;
          end if;
      end case;
    end if;
  end process;

  -- 3.) Output logic (combinational, no clock)
  process(state, s_shift)
  begin
    case state is
      when st_idle  => rx_rdy <= '0'; rts <= '0';   -- ready
      when st_start => rx_rdy <= '0'; rts <= '1';   -- busy
      when st_bit   => rx_rdy <= '0'; rts <= '1';
      when st_stop  => rx_rdy <= '0'; rts <= '1';
      when st_wait  => rx_rdy <= '1'; rts <= '1';
    end case;
    rx_data <= s_shift;
  end process;  

end Behavioral;