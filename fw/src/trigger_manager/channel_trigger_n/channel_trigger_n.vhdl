library ieee;
use ieee.std_logic_1164.all;

library work;
use work.channels_pkg.all;
use work.edge_detector_pkg.all;
use work.timer_pkg.all;

entity channel_trigger_n is
    generic(THRESHOLD_COMPARATOR_REGISTER:  boolean  := true;
            TRIGGER_EDGE_DETECTOR_REGISTER: boolean  := true;
            OUTPUT_REGISTER:                boolean  := true;
            TRIGGER_DURATION_WIDTH:         positive := 8;
            DATA_WIDTH:                     positive := 8);
    port(clk:         in  std_logic;
         rst:         in  std_logic;
         instruction: in  channel_instruction(operands(threshold((DATA_WIDTH-1) downto 0),
                                                       data((DATA_WIDTH-1) downto 0),
                                                       trigger_duration((TRIGGER_DURATION_WIDTH-1) downto 0)));
         trigger_n:   out std_logic);
end entity;

architecture rtl of channel_trigger_n is
    component comparator is
        generic(OUTPUT_REGISTER:  boolean;
                COMPARATOR_WIDTH: positive);
        port(clk: in  std_logic;
             rst: in  std_logic;
             m:   in  std_logic_vector((COMPARATOR_WIDTH-1) downto 0);
             n:   in  std_logic_vector((COMPARATOR_WIDTH-1) downto 0);
             mgn: out std_logic;
             men: out std_logic;
             mln: out std_logic);
    end component;

    component edge_detector is
        generic(OUTPUT_REGISTER: boolean);
        port(clk:         in  std_logic;
             rst:         in  std_logic;
             instruction: in  edge_detector_instruction;
             sig:         in  std_logic;
             edge:        out std_logic);
    end component;

    component timer is
        generic(OUTPUT_REGISTER: boolean;
                DURATION_WIDTH:  positive);
        port(clk:         in  std_logic;
             rst:         in  std_logic;
             instruction: in  timer_instruction(duration((DURATION_WIDTH-1) downto 0));
             done:        out std_logic);
    end component;

    signal above_threshold_u:              std_logic;
    signal below_threshold_u:              std_logic;
    signal trigger_c:                      std_logic;
    signal enable_trigger_edge_detector_c: std_logic;
    signal trigger_edge_u:                 std_logic;
begin
    threshold_comparator: comparator generic map(OUTPUT_REGISTER  => THRESHOLD_COMPARATOR_REGISTER,
                                                 COMPARATOR_WIDTH => DATA_WIDTH)
                                     port map(clk => clk,
                                              rst => rst,
                                              m   => instruction.operands.data,
                                              n   => instruction.operands.threshold,
                                              mgn => above_threshold_u,
                                              men => open,
                                              mln => below_threshold_u);

    trigger_c                      <= above_threshold_u when (instruction.opcode.polarity = CHANNEL_POLARITY_RISING) else
                                      below_threshold_u;
    enable_trigger_edge_detector_c <= '1' when (instruction.opcode.enable = CHANNEL_ENABLE_ON) else
                                      '0';

    trigger_edge_detector: edge_detector generic map(OUTPUT_REGISTER => TRIGGER_EDGE_DETECTOR_REGISTER)
                                         port map(clk                             => clk,
                                                  rst                             => rst,
                                                  instruction.enable_rising_edge  => enable_trigger_edge_detector_c,
                                                  instruction.enable_falling_edge => '0',
                                                  sig                             => trigger_c,
                                                  edge                            => trigger_edge_u);

    trigger_n_timer: timer generic map(OUTPUT_REGISTER => OUTPUT_REGISTER,
                                       DURATION_WIDTH  => TRIGGER_DURATION_WIDTH)
                           port map(clk                  => clk,
                                    rst                  => rst,
                                    instruction.load     => trigger_edge_u,
                                    instruction.duration => instruction.operands.trigger_duration,
                                    done                 => trigger_n);
end architecture;
