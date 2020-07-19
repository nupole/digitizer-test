library ieee;
use ieee.std_logic_1164.all;

library work;
use work.local_bus_interface_pkg.all;

entity digitizer is
    generic(LOCAL_BUS_INTERFACE_BOARD_SELECT_SYNC_REGISTER: boolean  := true;
            LOCAL_BUS_INTERFACE_BOARD_ADDRESS_WIDTH:        positive := 2;
            LOCAL_BUS_INTERFACE_REGISTER_ADDRESS_WIDTH:     positive := 6;
            LOCAL_BUS_INTERFACE_REGISTER_DATA_WIDTH:        positive := 8);
    port(clk_25MHz:            in    std_logic;
         pll_lock:             out   std_logic;

         board_address:        in    std_logic_vector((LOCAL_BUS_INTERFACE_BOARD_ADDRESS_WIDTH-1) downto 0);

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

        signal clk_100MHz:  std_logic;
        signal lock_100MHz: std_logic;
        signal rst_100MHz:  std_logic;
begin
    clk_manager: clock_manager port map(clk_25MHz   => clk_25MHz,
                                        clk_100MHz  => clk_100MHz,
                                        lock_100MHz => lock_100MHz);

    pll_lock   <= lock_100MHz;
    rst_100MHz <= (not lock_100MHz);

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
                                      regs                 => open);
end architecture;
