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
  
  -- RX path
  signal s_rx_data      : std_logic_vector(7 downto 0);
  signal s_rx_rdy       : std_logic;
  signal s_rx_rdy_d     : std_logic := '0';
  signal s_rx_rdy_pulse : std_logic;

  -- ASCII -> hex nibble
  signal s_hex_nibble : std_logic_vector(3 downto 0);
  signal s_hex_valid  : std_logic;
  
  signal s_uart_cts : std_logic;
  
  -- Finite State Machine for Receive
  component rx_fsm_3_proc
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    baud_en : in  std_logic;
    rx      : in  std_logic;
    rx_data : out std_logic_vector(7 downto 0);
    rx_rdy  : out std_logic;
    rts     : out std_logic
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
  generic map ( DIVISOR => 651 )
  port map (
    clk     => clk,
    rst     => s_mpg_out(1),
    baud_en => s_brg_out_baud_en
  );  
  
  rx_inst : rx_fsm_3_proc
  port map (
    clk     => clk,
    rst     => s_mpg_out(1),
    baud_en => s_brg_out_baud_en,
    rx      => uart_txd_in,
    rx_data => s_rx_data,
    rx_rdy  => s_rx_rdy,
    rts     => s_uart_cts
  );

  uart_rxd_out <= '1';   -- TX line idle high; we're not transmitting

  -- Rising-edge detect on rx_rdy: one-cycle pulse per received byte
  process(clk)
  begin
    if rising_edge(clk) then
      s_rx_rdy_d <= s_rx_rdy;
    end if;
  end process;
  s_rx_rdy_pulse <= s_rx_rdy and not s_rx_rdy_d;

  -- ASCII -> 4-bit hex nibble, with validity flag
  process(s_rx_data)
  begin
    s_hex_valid  <= '0';
    s_hex_nibble <= (others => '0');
    if    s_rx_data >= x"30" and s_rx_data <= x"39" then        -- '0'..'9'
      s_hex_nibble <= s_rx_data(3 downto 0);
      s_hex_valid  <= '1';
    elsif s_rx_data >= x"41" and s_rx_data <= x"46" then        -- 'A'..'F'
      s_hex_nibble <= s_rx_data(3 downto 0) + "1001";
      s_hex_valid  <= '1';
    elsif s_rx_data >= x"61" and s_rx_data <= x"66" then        -- 'a'..'f'
      s_hex_nibble <= s_rx_data(3 downto 0) + "1001";
      s_hex_valid  <= '1';
    end if;
  end process;

  -- 8-digit hex shift register: new nibble enters at the right,
  -- leftmost nibble falls off after 8 valid characters
  process(clk)
  begin
    if rising_edge(clk) then
      if s_mpg_out(1) = '1' then
        s_digits <= (others => '0');
      elsif s_rx_rdy_pulse = '1' and s_hex_valid = '1' then
        s_digits <= s_digits(27 downto 0) & s_hex_nibble;
      end if;
    end if;
  end process;
  
  uart_cts <= s_uart_cts;

  led(0)  <= s_rx_rdy;
  led(1)  <= s_hex_valid;
  led(15) <= s_uart_cts;

end Behavioral;
