## Assignment 1

Complete the FSM, display the message in a terminal

## Assignment 2

Analyze, create the flow diagram

```vhdl
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity top_level is
  port (
    clk : in  std_logic;
    btn : in  std_logic_vector( 4 downto 0);
    sw  : in  std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0);
    an  : out std_logic_vector( 7 downto 0);
    cat : out std_logic_vector( 6 downto 0);
    -- UART related
    uart_txd_in  : in  std_logic;
    uart_rxd_out : out std_logic;
    uart_cts     : out std_logic;
    uart_rts     : in  std_logic
  );
end top_level;

architecture Behavioral of top_level is    

  -- MPG
  signal s_mpg_out : std_logic_vector(4  downto 0) := b"0_0000";
  
  component mono_pulse_gen
  port (
    clk    : in  std_logic;
    btn    : in  std_logic_vector(4  downto 0);
    enable : out std_logic_vector(4  downto 0)
  );
  end component;
  
  -- 7-segment display
  signal s_digits       : std_logic_vector(31 downto 0) := x"0000_0000";
  signal s_digits_upper : std_logic_vector(15 downto 0) := x"0000";
  signal s_digits_lower : std_logic_vector(15 downto 0) := x"0000";
  
  component seven_seg_disp
  port (
    clk    : in  std_logic;
    digits : in  std_logic_vector(31  downto 0);
    an     : out std_logic_vector(7  downto 0);
    cat    : out std_logic_vector(6  downto 0)
  );
  end component;
  
  -- Baud rate generator  
  signal s_brg_out_baud_en : std_logic;
  
  component baud_rate_gen
  generic ( DIVISOR : integer );
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    baud_en : out std_logic
  );
  end component;
  
  -- Message controller
  signal s_index     : std_logic_vector(1 downto 0)  := (others => '0');
  signal s_sending   : std_logic                     := '0';
  signal s_last_sent : std_logic_vector(15 downto 0) := (others => '0');

  -- TX path
  signal s_tx_data  : std_logic_vector(7 downto 0);
  signal s_tx_rdy   : std_logic;
  signal s_tx_rdy_d : std_logic := '1'; -- previous value of s_tx_rdy
  signal s_tx_line  : std_logic;
  
  -- Finite State Machine for Transmit
  component tx_fsm_3_proc
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    baud_en : in  std_logic;
    tx_en   : in  std_logic;
    cts     : in  std_logic;
    tx_data : in  std_logic_vector(7 downto 0);
    tx_rdy  : out std_logic;
    tx      : out std_logic
  );
  end component;

begin

  mpg_inst : mono_pulse_gen
  port map (
    clk => clk,
    btn => btn,
    enable => s_mpg_out
  );
  
  ssd_inst : seven_seg_disp
  port map (
    clk    => clk,
    digits => s_digits,
    an     => an,
    cat    => cat
  );
  
  brg_inst : baud_rate_gen
  generic map ( DIVISOR => 10416 )
  port map (
    clk     => clk,
    rst     => s_mpg_out(1),
    baud_en => s_brg_out_baud_en
  );  
  
  tx_inst : tx_fsm_3_proc
  port map (
    clk     => clk,
    rst     => s_mpg_out(1),
    baud_en => s_brg_out_baud_en,
    tx_en   => s_sending,
    cts     => uart_rts, -- '0' from PC = OK to send
    tx_data => s_tx_data,
    tx_rdy  => s_tx_rdy,
    tx      => s_tx_line
  );

  uart_rxd_out <= s_tx_line;
  uart_cts     <= '0';

  -- Pick which byte to send based on the current index
  process(s_index, s_last_sent)
  begin
    case s_index is
      when "00" => s_tx_data <= s_last_sent(15 downto 8);  -- first ASCII char
      when "01" => s_tx_data <= s_last_sent( 7 downto 0);  -- second ASCII char
      when "10" => s_tx_data <= x"0D";                     -- CR
      when "11" => s_tx_data <= x"0A";                     -- LF
    end case;
  end process;

  -- SSD: upper 4 digits = last sent value, lower 4 digits = current switches
  s_digits <= s_last_sent & sw;

  -- Controller
  process(clk)
  begin
    if rising_edge(clk) then
      if s_mpg_out(1) = '1' then
        s_sending   <= '0';
        s_index     <= "00";
        s_tx_rdy_d  <= '1';
        s_last_sent <= (others => '0');
      else
        s_tx_rdy_d <= s_tx_rdy;

        if s_mpg_out(0) = '1' and s_sending = '0' then
          s_sending   <= '1';
          s_index     <= "00";
          s_last_sent <= sw;
        elsif s_sending = '1' and s_tx_rdy = '1' and s_tx_rdy_d = '0' then
          if s_index = 3 then
            s_sending <= '0';
          else
            s_index <= s_index + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  led(0)  <= s_sending;
  led(1)  <= s_tx_rdy;
  led(15) <= uart_rts;

end Behavioral;
```
