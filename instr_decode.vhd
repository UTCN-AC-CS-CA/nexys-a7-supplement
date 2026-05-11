library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity instr_decode is
  port (
    -- inputs
    clk       : in  std_logic;
    instr     : in  std_logic_vector(15 downto 0);
    wd        : in  std_logic_vector(15 downto 0);
    wa_in     : in  std_logic_vector(2  downto 0);
    -- control signal based inputs
    ext_op    : in  std_logic;
    reg_dst   : in  std_logic;
    reg_write : in  std_logic;
    -- outputs
    ext_imm   : out std_logic_vector(15 downto 0);
    func      : out std_logic_vector(2  downto 0);
    rd1       : out std_logic_vector(15 downto 0);
    rd2       : out std_logic_vector(15 downto 0);        
    sa        : out std_logic;
    wa_out    : out std_logic_vector(2  downto 0)
  );
end instr_decode;

architecture behavioral of instr_decode is

  component reg_file_16bit
  port (
    clk : in  std_logic;
    ra1 : in  std_logic_vector(2  downto 0);
    ra2 : in  std_logic_vector(2  downto 0);
    wa  : in  std_logic_vector(2  downto 0);
    wd  : in  std_logic_vector(15 downto 0);
    wen : in  std_logic;
    rd1 : out std_logic_vector(15 downto 0);
    rd2 : out std_logic_vector(15 downto 0)
  );
  end component;
  
  signal s_mux_out: std_logic_vector(2 downto 0);
  signal s_ext_out: std_logic_vector(8 downto 0);

begin

  s_mux_out <= instr(9 downto 7) when reg_dst = '0' else instr(6 downto 4);

  inst_rf : reg_file_16bit
  port map (
    clk => clk,
    ra1 => instr(12 downto 10),
    ra2 => instr(9 downto 7),
    wa  => wa_in,
    wd  => wd,
    wen => reg_write,
    rd1 => rd1,
    rd2 => rd2
  );

  sa        <= instr(3);
  func      <= instr(2 downto 0);
  s_ext_out <= b"1111_1111_1" when instr(6) = '1' and ext_op = '1' else b"0000_0000_0";
  ext_imm   <= s_ext_out & instr(6 downto 0);
  wa_out    <= s_mux_out;

end behavioral;