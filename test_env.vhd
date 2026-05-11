library ieee;
 use ieee.std_logic_1164.all;
 use ieee.std_logic_arith.all;
 use ieee.std_logic_unsigned.all;
 
entity test_env is
  port (
    clk : in  std_logic;
    btn : in  std_logic_vector( 4 downto 0);
    sw  : in  std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0);
    an  : out std_logic_vector( 7 downto 0);
    cat : out std_logic_vector( 6 downto 0)
  );
end entity test_env;

architecture behavioral of test_env is

  -- Monopulse Generator
  signal s_mpg_out : std_logic_vector(4  downto 0) := b"0_0000";

  component monopulse
  port (
    clk    : in  std_logic;
    btn    : in  std_logic_vector(4 downto 0);
    enable : out std_logic_vector(4 downto 0)
  );
  end component;

  -- 7-segment display
  signal s_digits       : std_logic_vector(31 downto 0) := x"0000_0000";
  signal s_digits_upper : std_logic_vector(15 downto 0) := x"0000";
  signal s_digits_lower : std_logic_vector(15 downto 0) := x"0000";

  component seven_seg_disp 
  port (
    clk    : in  std_logic;
    digits : in  std_logic_vector(31 downto 0);   
    an     : out std_logic_vector( 7 downto 0);
    cat    : out std_logic_vector( 6 downto 0)
  );
  end component;

  -- IF related signals
  signal s_if_in_jump_address : std_logic_vector(15 downto 0) := x"0000";
  signal s_if_in_pc_src       : std_logic                     := '0';
  signal s_if_out_instruction : std_logic_vector(15 downto 0) := x"0000";
  signal s_if_out_pc_plus_one : std_logic_vector(15 downto 0) := x"0000";

 component inst_fetch
  port (
    clk                   : in  std_logic;
    branch_target_address : in  std_logic_vector(15 downto 0);
    jump_address          : in  std_logic_vector(15 downto 0);
    jump                  : in  std_logic;
    pc_src                : in  std_logic;
    pc_en                 : in  std_logic;
    pc_reset              : in  std_logic;
    instruction           : out std_logic_vector(15 downto 0);
    pc_plus_one           : out std_logic_vector(15 downto 0)
  );
  end component;

  -- ID related signals
  signal s_id_in_wd        : std_logic_vector(15 downto 0);
  signal s_id_in_reg_write : std_logic;
  signal s_id_out_ext_imm  : std_logic_vector(15 downto 0);
  signal s_id_out_func     : std_logic_vector( 2 downto 0);
  signal s_id_out_rd1      : std_logic_vector(15 downto 0);
  signal s_id_out_rd2      : std_logic_vector(15 downto 0);
  signal s_id_out_sa       : std_logic;
  signal s_id_out_wa       : std_logic_vector( 2 downto 0);

  component instr_decode
  port (
    clk       : in  std_logic;
    instr     : in  std_logic_vector(15 downto 0);
    wd        : in  std_logic_vector(15 downto 0);
    wa_in     : in  std_logic_vector( 2 downto 0); 
    ext_op    : in  std_logic;
    reg_dst   : in  std_logic;
    reg_write : in  std_logic;
    ext_imm   : out std_logic_vector(15 downto 0);
    func      : out std_logic_vector( 2 downto 0);
    rd1       : out std_logic_vector(15 downto 0);
    rd2       : out std_logic_vector(15 downto 0);
    sa        : out std_logic;
    wa_out    : out std_logic_vector( 2 downto 0)
  );
  end component;
  
  -- Control Signals
  signal s_ctrl_reg_dst    : std_logic;
  signal s_ctrl_ext_op     : std_logic;
  signal s_ctrl_alu_src    : std_logic;
  signal s_ctrl_branch     : std_logic;
  signal s_ctrl_jump       : std_logic;
  signal s_ctrl_alu_op     : std_logic_vector(2 downto 0);
  signal s_ctrl_mem_write  : std_logic;
  signal s_ctrl_mem_to_reg : std_logic;
  signal s_ctrl_reg_write  : std_logic;

  component control_unit
  port (
    op_code    : in std_logic_vector(2 downto 0);
    reg_dst    : out std_logic;
    ext_op     : out std_logic;
    alu_src    : out std_logic;
    branch     : out std_logic;
    jump       : out std_logic;
    alu_op     : out std_logic_vector(2 downto 0);
    mem_write  : out std_logic;
    mem_to_reg : out std_logic;
    reg_write  : out std_logic
  );
  end component;
  
  -- Execution Unit
  signal s_eu_out_alu_res : std_logic_vector(15 downto 0) := x"0000";
  signal s_eu_out_bta     : std_logic_vector(15 downto 0) := x"0000";
  signal s_eu_out_zero    : std_logic                     := '0';
  
  component exec_unit
  port (
    ext_imm     : in  std_logic_vector(15 downto 0);
    func        : in  std_logic_vector(2  downto 0);
    rd1         : in  std_logic_vector(15 downto 0);
    rd2         : in  std_logic_vector(15 downto 0);
    pc_plus_one : in  std_logic_vector(15 downto 0);
    sa          : in  std_logic;
    alu_op      : in  std_logic_vector(2  downto 0);
    alu_src     : in  std_logic;
    alu_res     : out std_logic_vector(15 downto 0);
    bta         : out std_logic_vector(15 downto 0);
    zero        : out std_logic
  );
  end component;
  
  -- Memory Unit
  signal s_mu_in_mem_write : std_logic                     := '0';
  signal s_mu_out_mem_data : std_logic_vector(15 downto 0) := x"0000";
  signal s_mu_out_alu_res  : std_logic_vector(15 downto 0) := x"0000";

  component mem_unit
  port (
    clk         : in  std_logic;
    alu_res_in  : in  std_logic_vector(15 downto 0);
    rd2         : in  std_logic_vector(15 downto 0);
    mem_write   : in  std_logic;
    mem_data    : out std_logic_vector(15 downto 0);
    alu_res_out : out std_logic_vector(15 downto 0)
  );
  end component; 
 
  -- Write Back unit
  signal s_wb_out_wd : std_logic_vector(15 downto 0) := x"0000";
  
  -- PIPELINE SIGNALS
   
  -- IF/ID Pipeline Register
  -- PC + 1 & INSTR = 16 + 16 = 32  
  signal p_if_id : std_logic_vector(31 downto 0) := x"0000_0000";
  -- 31 - 16 --> s_if_out_pc_plus_one
  -- 15 -  0 --> s_if_out_instruction
 
  -- ID/EX + Control Signals Pipeline Register
  -- WRITE_ADDRESS, EXT_IMM, FUNC, RD1, RD2, SA, PC+1 = 3 + 16 + 3 + 16 + 16 + 1 + 16 = 71
  -- Control Signals: EXT_OP, ALU_SRC, BRANCH, JUMP, ALU_OP, MEM_WRITE, MEM_TO_REG, REG_WRITE = 10
  signal p_id_ex : std_logic_vector(80 downto 0) := (others => '0');
  -- 80 - 78 --> s_id_out_wa   
  -- 77 - 62 --> s_id_out_ext_imm
  -- 61 - 59 --> s_id_out_func
  -- 58 - 43 --> s_id_out_rd1
  -- 42 - 27 --> s_id_out_rd2
  --      26 --> s_id_out_sa
  --      25 --> s_ctrl_ext_op
  --      24 --> s_ctrl_alu_src
  --      23 --> s_ctrl_branch
  --      22 --> s_ctrl_jump
  -- 21 - 19 --> s_ctrl_alu_op
  --      18 --> s_ctrl_mem_write
  --      17 --> s_ctrl_mem_to_reg
  --      16 --> s_ctrl_reg_write
  -- 15 -  0 --> s_if_out_pc_plus_one
  
  -- EX/MU Pipeline Register
  -- WRITE_ADDRESS, ALU_RES, RD2, BTA, ZERO = 3 + 16 + 16 + 16 + 1 = 52
  -- Control Signals: BRANCH, MEM_WRITE, MEM_TO_REG, REG_WRITE = 4
  signal p_ex_mu : std_logic_vector(55 downto 0) := (others => '0');
  -- 55 - 53 --> p_id_ex(80 downto 78) WRITE_ADDRESS
  -- 52 - 37 --> s_eu_out_alu_res      ALU_RES
  -- 36 - 21 --> p_id_ex(42 downto 27) RD2
  -- 20 -  5 --> s_eu_out_bta          BTA
  --       4 --> s_eu_out_zero         ZERO
  --       3 --> p_id_ex(23)           BRANCH
  --       2 --> p_id_ex(18)           MEM_WRITE
  --       1 --> p_id_ex(17)           MEM_TO_REG
  --       0 --> p_id_ex(16)           REG_WRITE
  
  -- MU/WB Pipeline Register
  -- WRITE_ADDRESS, MEM_DATA, ALU_RES_OUT = 3 + 16 + 16 = 35
  -- Control Signals: MEM_TO_REG, REG_WRITE = 2
  signal p_mu_wb : std_logic_vector(36 downto 0) := (others => '0');
  -- 36 - 34 --> p_ex_mu(55 downto 53) WRITE_ADDRESS
  -- 33 - 18 --> s_mu_out_mem_data     MEM_DATA
  -- 17 -  2 --> s_mu_out_alu_res      ALU_RES_OUT
  --       1 --> p_ex_mu(1)            MEM_TO_REG
  --       0 --> p_ex_mu(0)            REG_WRITE

begin

  mpg_inst : monopulse
  port map (
    clk    => clk, 
    btn    => btn,
    enable => s_mpg_out
  );
 
  seven_seg_inst: seven_seg_disp 
  port map(
    clk    => clk, 
    digits => s_digits, 
    an     => an, 
    cat    => cat
  );
  
  s_if_in_jump_address <= b"000" & p_if_id(12 downto 0);
  s_if_in_pc_src       <= p_ex_mu(3) and p_ex_mu(4);
  
  inst_infe : inst_fetch
  port map (
    clk                    => clk,
    branch_target_address  => p_ex_mu(20 downto 5),
    jump_address           => s_if_in_jump_address,
    jump                   => s_ctrl_jump,
    pc_src                 => s_if_in_pc_src,
    pc_en                  => s_mpg_out(0),
    pc_reset               => s_mpg_out(1),
    instruction            => s_if_out_instruction,
    pc_plus_one            => s_if_out_pc_plus_one
  );  
 
  s_id_in_reg_write <= s_mpg_out(0) and p_mu_wb(0);
  
  inst_indcd : instr_decode
  port map (
    clk       => clk,
    instr     => p_if_id(15 downto 0),
    wd        => s_wb_out_wd,
    wa_in     => p_mu_wb(36 downto 34),
    ext_op    => s_ctrl_ext_op,
    reg_dst   => s_ctrl_reg_dst,
    reg_write => s_id_in_reg_write,
    ext_imm   => s_id_out_ext_imm,
    func      => s_id_out_func,
    rd1       => s_id_out_rd1,
    rd2       => s_id_out_rd2,
    sa        => s_id_out_sa,
    wa_out    => s_id_out_wa
  );
  
  inst_cu : control_unit
  port map (
    op_code    => p_if_id(15 downto 13),
    reg_dst    => s_ctrl_reg_dst,
    ext_op     => s_ctrl_ext_op,
    alu_src    => s_ctrl_alu_src,
    branch     => s_ctrl_branch,
    jump       => s_ctrl_jump,
    alu_op     => s_ctrl_alu_op,
    mem_write  => s_ctrl_mem_write,
    mem_to_reg => s_ctrl_mem_to_reg,
    reg_write  => s_ctrl_reg_write
  );
  
  exec_unit_inst : exec_unit
  port map (
    ext_imm     => p_id_ex(77 downto 62),
    func        => p_id_ex(61 downto 59),
    rd1         => p_id_ex(58 downto 43),
    rd2         => p_id_ex(42 downto 27),
    pc_plus_one => p_id_ex(15 downto 0),
    sa          => p_id_ex(26),
    alu_op      => p_id_ex(21 downto 19),
    alu_src     => p_id_ex(24),
    alu_res     => s_eu_out_alu_res,
    bta         => s_eu_out_bta,
    zero        => s_eu_out_zero
  );
  
  s_mu_in_mem_write <= p_ex_mu(2) and s_mpg_out(0);
  
  mem_unit_inst : mem_unit
  port map (
    clk         => clk,
    alu_res_in  => p_ex_mu(52 downto 37),
    rd2         => p_ex_mu(36 downto 21),
    mem_write   => s_mu_in_mem_write,
    mem_data    => s_mu_out_mem_data,
    alu_res_out => s_mu_out_alu_res
  );
  
  -- WB related behavioral code
  s_wb_out_wd <= p_mu_wb(33 downto 18) when p_mu_wb(1) = '1' else p_mu_wb(17 downto 2);
  
  -- MUX for 7-segment display left side (31 downto 16)
  process (sw(11 downto 9), s_if_out_pc_plus_one, s_if_out_instruction, s_id_out_rd1, s_id_out_rd2, s_id_in_wd)
  begin
    case sw(11 downto 9) is
      when "000"  => s_digits_upper <= s_if_out_instruction;
      when "001"  => s_digits_upper <= s_if_out_pc_plus_one;
      when "010"  => s_digits_upper <= s_id_out_rd1;
      when "011"  => s_digits_upper <= s_id_out_rd2;
      when "100"  => s_digits_upper <= s_id_out_ext_imm;
      when "101"  => s_digits_upper <= s_eu_out_alu_res;
      when "110"  => s_digits_upper <= s_mu_out_mem_data;
      when "111"  => s_digits_upper <= s_wb_out_wd;
    end case;
  end process;

  -- MUX for 7-segment display right side (15 downto 0)
  process (sw(6 downto 4), s_if_out_pc_plus_one, s_if_out_instruction, s_id_out_rd1, s_id_out_rd2, s_id_in_wd)
  begin
    case sw(6 downto 4) is
      when "000"  => s_digits_lower <= s_if_out_instruction;
      when "001"  => s_digits_lower <= s_if_out_pc_plus_one;
      when "010"  => s_digits_lower <= s_id_out_rd1;
      when "011"  => s_digits_lower <= s_id_out_rd2;
      when "100"  => s_digits_lower <= s_id_out_ext_imm;
      when "101"  => s_digits_lower <= s_eu_out_alu_res;
      when "110"  => s_digits_lower <= s_mu_out_mem_data;
      when "111"  => s_digits_lower <= s_wb_out_wd;
    end case;
  end process;

  s_digits <= s_digits_upper & s_digits_lower;

  -- LED with signals from Main Control Unit
  led <= s_ctrl_alu_op     & -- ALU operation        15:13
         b"0000_0"         & -- Unused               12:8
         s_ctrl_reg_dst    & -- Register destination 7
         s_ctrl_ext_op     & -- Extend operation     6
         s_ctrl_alu_src    & -- ALU source           5
         s_ctrl_branch     & -- Branch               4
         s_ctrl_jump       & -- Jump                 3
         s_ctrl_mem_write  & -- Memory write         2
         s_ctrl_mem_to_reg & -- Memory to register   1
         s_ctrl_reg_write;   -- Register write       0

  -- PIPELINE
  reg_if_id : process(clk)
  begin
    if rising_edge(clk) then
      if s_mpg_out(0) = '1' then
        p_if_id <= s_if_out_pc_plus_one & s_if_out_instruction;
      elsif s_mpg_out(1) = '1' then
        p_if_id <= (others => '0');
      end if;
    end if;
  end process reg_if_id;
        
  reg_id_ex : process(clk)
  begin
    if rising_edge(clk) then
      if s_mpg_out(0) = '1' then
        p_id_ex(80 downto 78) <= s_id_out_wa;           -- WRITE_ADDRESS
        p_id_ex(77 downto 62) <= s_id_out_ext_imm;      -- EXT_IMM
        p_id_ex(61 downto 59) <= s_id_out_func;         -- FUNC
        p_id_ex(58 downto 43) <= s_id_out_rd1;          -- RD1
        p_id_ex(42 downto 27) <= s_id_out_rd2;          -- RD2
        p_id_ex(26)           <= s_id_out_sa;           -- SA
        p_id_ex(25)           <= s_ctrl_ext_op;         -- EXT_OP
        p_id_ex(24)           <= s_ctrl_alu_src;        -- ALU_SRC
        p_id_ex(23)           <= s_ctrl_branch;         -- BRANCH
        p_id_ex(22)           <= s_ctrl_jump;           -- JUMP
        p_id_ex(21 downto 19) <= s_ctrl_alu_op;         -- ALU_OP
        p_id_ex(18)           <= s_ctrl_mem_write;      -- MEM_WRITE
        p_id_ex(17)           <= s_ctrl_mem_to_reg;     -- MEM_TO_REG
        p_id_ex(16)           <= s_ctrl_reg_write;      -- REG_WRITE
        p_id_ex(15 downto 0)  <= p_if_id(31 downto 16); -- PC + 1
      elsif s_mpg_out(1) = '1' then
        p_id_ex <= (others => '0');
      end if;
    end if;
  end process reg_id_ex;
    
  reg_ex_mu : process(clk)
  begin
    if rising_edge(clk) then
      if s_mpg_out(0) = '1' then
        p_ex_mu(55 downto 53) <= p_id_ex(80 downto 78); -- WRITE_ADDRESS
        p_ex_mu(52 downto 37) <= s_eu_out_alu_res;      -- ALU_RES
        p_ex_mu(36 downto 21) <= p_id_ex(42 downto 27); -- RD2
        p_ex_mu(20 downto  5) <= s_eu_out_bta;          -- BTA
        p_ex_mu(4)            <= s_eu_out_zero;         -- ZERO
        p_ex_mu(3)            <= p_id_ex(23);           -- BRANCH
        p_ex_mu(2)            <= p_id_ex(18);           -- MEM_WRITE
        p_ex_mu(1)            <= p_id_ex(17);           -- MEM_TO_REG
        p_ex_mu(0)            <= p_id_ex(16);           -- REG_WRITE
      elsif s_mpg_out(1) = '1' then
        p_ex_mu <= (others => '0');
      end if;
    end if;
  end process reg_ex_mu;
  
  reg_mu_wb : process(clk)
    begin
      if rising_edge(clk) then
        if s_mpg_out(0) = '1' then
          p_mu_wb(36 downto 34) <= p_ex_mu(55 downto 53); -- WRITE_ADDRESS
          p_mu_wb(33 downto 18) <= s_mu_out_mem_data;     -- MEM_DATA
          p_mu_wb(17 downto  2) <= s_mu_out_alu_res;      -- ALU_RES_OUT
          p_mu_wb(1)            <= p_ex_mu(1);            -- MEM_TO_REG
          p_mu_wb(0)            <= p_ex_mu(0);            -- REG_WRITE
        elsif s_mpg_out(1) = '1' then
          p_mu_wb <= (others => '0');
        end if;
      end if;
    end process reg_mu_wb;  

end architecture behavioral;
