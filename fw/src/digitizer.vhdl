library ieee;
use ieee.std_logic_1164.all;

library work;
use work.trigger_manager_pkg.all;
use work.channels_pkg.all;
use work.local_bus_interface_pkg.all;
use work.math_pkg.all;

entity digitizer is
    generic(NUM_CHANNELS:                                    positive := 2;
            CHANNEL_TRIGGER_N_THRESHOLD_COMPARATOR_REGISTER: boolean  := true;
            CHANNEL_TRIGGER_N_EDGE_DETECTOR_REGISTER:        boolean  := true;
            CHANNEL_TRIGGER_N_OUTPUT_REGISTER:               boolean  := true;
            TRIGGER_DURATION_WIDTH:                          positive := 8;
            DATA_WIDTH:                                      positive := 8;
            COINCIDENCE_COMPARATOR_REGISTER:                 boolean  := true;
            COINCIDENCE_OUTPUT_REGISTER:                     boolean  := true;
            TRIGGER_MANAGER_OUTPUT_REGISTER:                 boolean  := true;
            VETO_DURATION_WIDTH:                             positive := 8;
            LOCAL_BUS_INTERFACE_BOARD_SELECT_SYNC_REGISTER:  boolean  := true;
            LOCAL_BUS_INTERFACE_BOARD_ADDRESS_WIDTH:         positive := 2;
            LOCAL_BUS_INTERFACE_REGISTER_ADDRESS_WIDTH:      positive := 6;
            LOCAL_BUS_INTERFACE_REGISTER_DATA_WIDTH:         positive := 8);
    port(clk_25MHz:            in    std_logic;
         pll_lock:             out   std_logic;

         board_address:        in    std_logic_vector((LOCAL_BUS_INTERFACE_BOARD_ADDRESS_WIDTH-1) downto 0);

         data:                 in    channel_datas(0 to (NUM_CHANNELS-1))((DATA_WIDTH-1) downto 0);
         trigger:              out   std_logic;

         request:              in    std_logic;
         wnr:                  in    std_logic;
         acknowledge:          out   std_logic;
         board_address_trx:    in    std_logic_vector((LOCAL_BUS_INTERFACE_BOARD_ADDRESS_WIDTH-1) downto 0);
         register_address_trx: in    std_logic_vector((LOCAL_BUS_INTERFACE_REGISTER_ADDRESS_WIDTH-1) downto 0);
         register_data_trx:    inout std_logic_vector((LOCAL_BUS_INTERFACE_REGISTER_DATA_WIDTH-1) downto 0));
end entity;

architecture rtl of digitizer is
    component clock_manager is
        port(clk_25MHz:   in  std_logic;
             clk_100MHz:  out std_logic;
             lock_100MHz: out std_logic);
    end component;

    component trigger_manager is
        generic(NUM_CHANNELS:                                    positive;
                CHANNEL_TRIGGER_N_THRESHOLD_COMPARATOR_REGISTER: boolean;
                CHANNEL_TRIGGER_N_EDGE_DETECTOR_REGISTER:        boolean;
                CHANNEL_TRIGGER_N_OUTPUT_REGISTER:               boolean;
                TRIGGER_DURATION_WIDTH:                          positive;
                DATA_WIDTH:                                      positive;
                COINCIDENCE_COMPARATOR_REGISTER:                 boolean;
                COINCIDENCE_OUTPUT_REGISTER:                     boolean;
                OUTPUT_REGISTER:                                 boolean;
                VETO_DURATION_WIDTH:                             positive);
        port(clk:         in  std_logic;
             rst:         in  std_logic;
             instruction: in  trigger_manager_instruction(chan_instructions(0 to (NUM_CHANNELS-1))(operands(threshold((DATA_WIDTH-1) downto 0),
                                                                                                            data((DATA_WIDTH-1) downto 0),
                                                                                                            trigger_duration((TRIGGER_DURATION_WIDTH-1) downto 0))),
                                                          coin_instruction(coincidence_value((log2(NUM_CHANNELS)-1) downto 0)),
                                                          veto_duration((VETO_DURATION_WIDTH-1) downto 0));
             trigger:     out std_logic);
    end component;

    component local_bus_interface is
        generic(BOARD_SELECT_SYNC_REGISTER: boolean;
                BOARD_ADDRESS_WIDTH:        positive;
                REGISTER_ADDRESS_WIDTH:     positive;
                REGISTER_DATA_WIDTH:        positive);
        port(board_address:        in    std_logic_vector((BOARD_ADDRESS_WIDTH-1) downto 0);

             request:              in    std_logic;
             wnr:                  in    std_logic;
             acknowledge:          out   std_logic;
             board_address_trx:    in    std_logic_vector((BOARD_ADDRESS_WIDTH-1) downto 0);
             register_address_trx: in    std_logic_vector((REGISTER_ADDRESS_WIDTH-1) downto 0);
             register_data_trx:    inout std_logic_vector((REGISTER_DATA_WIDTH-1) downto 0);

             clk:                  in    std_logic;
             rst:                  in    std_logic;
             regs:                 out   registers(0 to ((2**(REGISTER_ADDRESS_WIDTH))-1))((REGISTER_DATA_WIDTH-1) downto 0));
        end component;

        signal clk_100MHz:                    std_logic;
        signal lock_100MHz:                   std_logic;
        signal rst_100MHz:                    std_logic;
        signal trigger_manager_instruction_u: trigger_manager_instruction(chan_instructions(0 to (NUM_CHANNELS-1))(operands(threshold((DATA_WIDTH-1) downto 0),
                                                                                                                            data((DATA_WIDTH-1) downto 0),
                                                                                                                            trigger_duration((TRIGGER_DURATION_WIDTH-1) downto 0))),
                                                                          coin_instruction(coincidence_value((log2(NUM_CHANNELS)-1) downto 0)),
                                                                          veto_duration((VETO_DURATION_WIDTH-1) downto 0));
        signal regs:                          registers(0 to ((2**LOCAL_BUS_INTERFACE_REGISTER_ADDRESS_WIDTH)-1))((LOCAL_BUS_INTERFACE_REGISTER_DATA_WIDTH-1) downto 0);
begin
    clk_manager: clock_manager port map(clk_25MHz   => clk_25MHz,
                                        clk_100MHz  => clk_100MHz,
                                        lock_100MHz => lock_100MHz);

    pll_lock   <= lock_100MHz;
    rst_100MHz <= (not lock_100MHz);

    trigger_manager_instruction_u <= generate_trigger_manager_instruction(regs(0),
                                                                          regs(1 to 2),
                                                                          data,
                                                                          regs(3 to 4),
                                                                          regs(5),
                                                                          regs(6),
                                                                          regs(7));

    trig_manager: trigger_manager generic map(NUM_CHANNELS                                    => NUM_CHANNELS,
                                              CHANNEL_TRIGGER_N_THRESHOLD_COMPARATOR_REGISTER => CHANNEL_TRIGGER_N_THRESHOLD_COMPARATOR_REGISTER,
                                              CHANNEL_TRIGGER_N_EDGE_DETECTOR_REGISTER        => CHANNEL_TRIGGER_N_EDGE_DETECTOR_REGISTER,
                                              CHANNEL_TRIGGER_N_OUTPUT_REGISTER               => CHANNEL_TRIGGER_N_OUTPUT_REGISTER,
                                              TRIGGER_DURATION_WIDTH                          => TRIGGER_DURATION_WIDTH,
                                              DATA_WIDTH                                      => DATA_WIDTH,
                                              COINCIDENCE_COMPARATOR_REGISTER                 => COINCIDENCE_COMPARATOR_REGISTER,
                                              COINCIDENCE_OUTPUT_REGISTER                     => COINCIDENCE_OUTPUT_REGISTER,
                                              OUTPUT_REGISTER                                 => TRIGGER_MANAGER_OUTPUT_REGISTER,
                                              VETO_DURATION_WIDTH                             => VETO_DURATION_WIDTH)
                                  port map(clk         => clk_100MHz,
                                           rst         => rst_100MHz,
                                           instruction => trigger_manager_instruction_u,
                                           trigger     => trigger);

    lbi: local_bus_interface generic map(BOARD_SELECT_SYNC_REGISTER => LOCAL_BUS_INTERFACE_BOARD_SELECT_SYNC_REGISTER,
                                         BOARD_ADDRESS_WIDTH        => LOCAL_BUS_INTERFACE_BOARD_ADDRESS_WIDTH,
                                         REGISTER_ADDRESS_WIDTH     => LOCAL_BUS_INTERFACE_REGISTER_ADDRESS_WIDTH,
                                         REGISTER_DATA_WIDTH        => LOCAL_BUS_INTERFACE_REGISTER_DATA_WIDTH)
                             port map(board_address        => board_address,

                                      request              => request,
                                      wnr                  => wnr,
                                      acknowledge          => acknowledge,
                                      board_address_trx    => board_address_trx,
                                      register_address_trx => register_address_trx,
                                      register_data_trx    => register_data_trx,

                                      clk                  => clk_100MHz,
                                      rst                  => rst_100MHz,
                                      regs                 => regs);
end architecture;
