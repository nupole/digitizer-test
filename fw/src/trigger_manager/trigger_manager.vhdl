library ieee;
use ieee.std_logic_1164.all;

library work;
use work.trigger_manager_pkg.all;
use work.channels_pkg.all;
use work.coincidence_pkg.all;
use work.edge_detector_pkg.all;
use work.timer_pkg.all;
use work.math_pkg.all;

entity trigger_manager is
    generic(NUM_CHANNELS:                                    positive := 2;
            CHANNEL_TRIGGER_N_THRESHOLD_COMPARATOR_REGISTER: boolean  := true;
            CHANNEL_TRIGGER_N_EDGE_DETECTOR_REGISTER:        boolean  := true;
            CHANNEL_TRIGGER_N_OUTPUT_REGISTER:               boolean  := true;
            TRIGGER_DURATION_WIDTH:                          positive := 8;
            DATA_WIDTH:                                      positive := 8;
            COINCIDENCE_COMPARATOR_REGISTER:                 boolean  := true;
            COINCIDENCE_OUTPUT_REGISTER:                     boolean  := true;
            OUTPUT_REGISTER:                                 boolean  := true;
            VETO_DURATION_WIDTH:                             positive := 8);
    port(clk:         in  std_logic;
         rst:         in  std_logic;
         instruction: in  trigger_manager_instruction(chan_instructions(0 to (NUM_CHANNELS-1))(operands(threshold((DATA_WIDTH-1) downto 0),
                                                                                                        data((DATA_WIDTH-1) downto 0),
                                                                                                        trigger_duration((TRIGGER_DURATION_WIDTH-1) downto 0))),
                                                      coin_instruction(coincidence_value((log2(NUM_CHANNELS)-1) downto 0)),
                                                      veto_duration((VETO_DURATION_WIDTH-1) downto 0));
         trigger:     out std_logic);
end entity;

architecture rtl of trigger_manager is
    component channel_trigger_n is
        generic(THRESHOLD_COMPARATOR_REGISTER:  boolean;
                TRIGGER_EDGE_DETECTOR_REGISTER: boolean;
                OUTPUT_REGISTER:                boolean;
                TRIGGER_DURATION_WIDTH:         positive;
                DATA_WIDTH:                     positive);
        port(clk:         in  std_logic;
             rst:         in  std_logic;
             instruction: in  channel_instruction(operands(threshold((DATA_WIDTH-1) downto 0),
                                                           data((DATA_WIDTH-1) downto 0),
                                                           trigger_duration((TRIGGER_DURATION_WIDTH-1) downto 0)));
             trigger_n:   out std_logic);
    end component;

    component coincidence is
        generic(COINCIDENCE_COMPARATOR_REGISTER: boolean;
                OUTPUT_REGISTER:                 boolean;
                NUM_CHANNELS:                    positive);
        port(clk:                in  std_logic;
             rst:                in  std_logic;
             instruction:        in  coincidence_instruction(coincidence_value((log2(NUM_CHANNELS)-1) downto 0));
             channel_triggers_n: in  std_logic_vector((NUM_CHANNELS-1) downto 0);
             coincident:         out std_logic);
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

    signal channel_triggers_n_u: std_logic_vector((NUM_CHANNELS-1) downto 0);
    signal coincident_u:         std_logic;
    signal veto_n_c:             std_logic;
begin
    GEN_CHANNEL_TRIGGER_N: for i in 0 to (NUM_CHANNELS-1) generate
    begin
        channel_x_trigger_n: channel_trigger_n generic map(THRESHOLD_COMPARATOR_REGISTER  => CHANNEL_TRIGGER_N_THRESHOLD_COMPARATOR_REGISTER,
                                                           TRIGGER_EDGE_DETECTOR_REGISTER => CHANNEL_TRIGGER_N_EDGE_DETECTOR_REGISTER,
                                                           OUTPUT_REGISTER                => CHANNEL_TRIGGER_N_OUTPUT_REGISTER,
                                                           TRIGGER_DURATION_WIDTH         => TRIGGER_DURATION_WIDTH,
                                                           DATA_WIDTH                     => DATA_WIDTH)
                                               port map(clk         => clk,
                                                        rst         => rst,
                                                        instruction => instruction.chan_instructions(i),
                                                        trigger_n   => channel_triggers_n_u(i));
    end generate;

    coincidence_manager: coincidence generic map(NUM_CHANNELS                    => NUM_CHANNELS,
                                                 COINCIDENCE_COMPARATOR_REGISTER => COINCIDENCE_COMPARATOR_REGISTER,
                                                 OUTPUT_REGISTER                 => COINCIDENCE_OUTPUT_REGISTER)
                                     port map(clk                => clk,
                                              rst                => rst,
                                              instruction        => instruction.coin_instruction,
                                              channel_triggers_n => channel_triggers_n_u,
                                              coincident         => coincident_u);

    trigger_edge_detector: edge_detector generic map(OUTPUT_REGISTER => OUTPUT_REGISTER)
                                         port map(clk                             => clk,
                                                  rst                             => rst,
                                                  instruction.enable_rising_edge  => veto_n_c,
                                                  instruction.enable_falling_edge => '0',
                                                  sig                             => coincident_u,
                                                  edge                            => trigger);

    veto_n_timer: timer generic map(OUTPUT_REGISTER => false,
                                    DURATION_WIDTH  => VETO_DURATION_WIDTH)
                        port map(clk                  => clk,
                                 rst                  => rst,
                                 instruction.load     => trigger,
                                 instruction.duration => instruction.veto_duration,
                                 done                 => veto_n_c);
end architecture;
