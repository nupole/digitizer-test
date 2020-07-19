library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.local_bus_interface_pkg.all;
use work.mux_pkg.all;

entity local_bus_interface is
    generic(BOARD_SELECT_SYNC_REGISTER: boolean  := true;
            BOARD_ADDRESS_WIDTH:        positive := 2;
            REGISTER_ADDRESS_WIDTH:     positive := 6;
            REGISTER_DATA_WIDTH:        positive := 8);
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
end entity;

architecture rtl of local_bus_interface is
    component transceiver is
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
             write:                out   std_logic;
             read:                 out   std_logic;
             register_address:     out   std_logic_vector((REGISTER_ADDRESS_WIDTH-1) downto 0);
             register_data_tx:     in    std_logic_vector((REGISTER_DATA_WIDTH-1) downto 0);
             register_data_rx:     out   std_logic_vector((REGISTER_DATA_WIDTH-1) downto 0));
    end component;

    component mux is
        generic(ADDRESS_WIDTH: positive;
                DATA_WIDTH:    positive);
        port(address: in  std_logic_vector((ADDRESS_WIDTH-1) downto 0);
             d:       in  mux_input(0 to ((2**ADDRESS_WIDTH)-1))((DATA_WIDTH-1) downto 0);
             z:       out std_logic_vector((DATA_WIDTH-1) downto 0));
    end component;

    signal write_r:            std_logic;
    signal read_r:             std_logic;
    signal register_address_r: std_logic_vector((REGISTER_ADDRESS_WIDTH-1) downto 0);
    signal register_data_tx_c: std_logic_vector((REGISTER_DATA_WIDTH-1) downto 0);
    signal register_data_rx_r: std_logic_vector((REGISTER_DATA_WIDTH-1) downto 0);
begin
    trx: transceiver generic map(BOARD_SELECT_SYNC_REGISTER => BOARD_SELECT_SYNC_REGISTER,
                                 BOARD_ADDRESS_WIDTH        => BOARD_ADDRESS_WIDTH,
                                 REGISTER_ADDRESS_WIDTH     => REGISTER_ADDRESS_WIDTH,
                                 REGISTER_DATA_WIDTH        => REGISTER_DATA_WIDTH)
                     port map(board_address        => board_address,

                              request              => request,
                              wnr                  => wnr,
                              acknowledge          => acknowledge,
                              board_address_trx    => board_address_trx,
                              register_address_trx => register_address_trx,
                              register_data_trx    => register_data_trx,

                              clk                  => clk,
                              rst                  => rst,
                              write                => write_r,
                              read                 => read_r,
                              register_address     => register_address_r,
                              register_data_tx     => register_data_tx_c,
                              register_data_rx     => register_data_rx_r);

    process(clk) begin
        if(rising_edge(clk)) then
            if(rst) then
                regs <= (others => (others => '0'));
            elsif(write_r) then
                regs(to_integer(unsigned(register_address_r))) <= register_data_rx_r;
            end if;
        end if;
    end process;

    data_tx_mux: mux generic map(ADDRESS_WIDTH => REGISTER_ADDRESS_WIDTH,
                                 DATA_WIDTH    => REGISTER_DATA_WIDTH)
                     port map(address => register_address_r,
                              d       => regs,
                              z       => register_data_tx_c);
end architecture;
