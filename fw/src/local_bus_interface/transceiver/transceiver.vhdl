library ieee;
use ieee.std_logic_1164.all;

library work;
use work.transceiver_pkg.all;

entity transceiver is
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
         write:                out   std_logic;
         read:                 out   std_logic;
         register_address:     out   std_logic_vector((REGISTER_ADDRESS_WIDTH-1) downto 0);
         register_data_tx:     in    std_logic_vector((REGISTER_DATA_WIDTH-1) downto 0);
         register_data_rx:     out   std_logic_vector((REGISTER_DATA_WIDTH-1) downto 0));
end entity;

architecture rtl of transceiver is
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

    signal request_meta_r:           std_logic;
    signal request_sync_r:           std_logic;

    signal load_instruction_c:       std_logic;
    signal load_instruction_r:       std_logic;
    signal wnr_sync_r:               std_logic;
    signal board_address_meta_r:     std_logic_vector((BOARD_ADDRESS_WIDTH-1) downto 0);
    signal board_address_sync_r:     std_logic_vector((BOARD_ADDRESS_WIDTH-1) downto 0);
    signal board_address_trx_meta_r: std_logic_vector((BOARD_ADDRESS_WIDTH-1) downto 0);
    signal board_address_trx_sync_r: std_logic_vector((BOARD_ADDRESS_WIDTH-1) downto 0);
    signal board_select_sync_u:      std_logic;
    signal acknowledge_c:            std_logic;
    signal acknowledge_r:            std_logic;

    signal state_c:                  transceiver_state;
    signal state_r:                  transceiver_state := TRANSCEIVER_STATE_IDLE;
    signal write_c:                  std_logic;
    signal read_c:                   std_logic;
    signal register_data_tx_r:       std_logic_vector((REGISTER_DATA_WIDTH-1) downto 0);
begin
    process(clk) begin
        if(rising_edge(clk)) then
            if(rst) then
                request_meta_r       <= '0';
                request_sync_r       <= '0';
                board_address_meta_r <= (others => '0');
                board_address_sync_r <= (others => '0');
            else
                request_meta_r       <= request;
                request_sync_r       <= request_meta_r;
                board_address_meta_r <= board_address;
                board_address_sync_r <= board_address_meta_r;
            end if;
        end if;
    end process;

    process(clk) begin
        if(rising_edge(clk)) then
            if(rst) then
                wnr_sync_r               <= '0';
                board_address_trx_meta_r <= (others => '0');
                board_address_trx_sync_r <= (others => '0');
                register_address         <= (others => '0');
                register_data_rx         <= (others => '0');
            elsif(load_instruction_r) then
                wnr_sync_r               <= wnr;
                board_address_trx_meta_r <= board_address_trx;
                board_address_trx_sync_r <= board_address_trx_meta_r;
                register_address         <= register_address_trx;
                register_data_rx         <= register_data_trx;
            end if;
        end if;
    end process;

    board_select_sync_comparator: comparator generic map(OUTPUT_REGISTER  => BOARD_SELECT_SYNC_REGISTER,
                                                         COMPARATOR_WIDTH => BOARD_ADDRESS_WIDTH)
                                             port map(clk => clk,
                                                      rst => rst,
                                                      m   => board_address_trx_sync_r,
                                                      n   => board_address_sync_r,
                                                      mgn => open,
                                                      men => board_select_sync_u,
                                                      mln => open);

    process(all) begin
        state_c                         <= state_r;
        load_instruction_c              <= '0';
        acknowledge_c                   <= '0';
        write_c                         <= '0';
        read_c                          <= '0';
        case state_r is
            when TRANSCEIVER_STATE_IDLE =>
                if(request_sync_r) then
                    state_c             <= TRANSCEIVER_STATE_LOAD_INSTRUCTION;
                    load_instruction_c  <= '1';
                end if;
            when TRANSCEIVER_STATE_LOAD_INSTRUCTION =>
                if(request_sync_r) then
                    state_c             <= TRANSCEIVER_STATE_DECODE_INSTRUCTION_1;
                else
                    state_c             <= TRANSCEIVER_STATE_IDLE;
                end if;
            when TRANSCEIVER_STATE_DECODE_INSTRUCTION_1 =>
                if(request_sync_r) then
                    if(BOARD_SELECT_SYNC_REGISTER) then
                        state_c         <= TRANSCEIVER_STATE_DECODE_INSTRUCTION_2;
                    else
                        if(board_select_sync_u) then
                            state_c     <= TRANSCEIVER_STATE_ACKNOWLEDGE;
                            if(wnr_sync_r) then
                                write_c <= '1';
                            else
                                read_c  <= '1';
                            end if;
                        end if;
                    end if;
                else
                    state_c             <= TRANSCEIVER_STATE_IDLE;
                end if;
            when TRANSCEIVER_STATE_DECODE_INSTRUCTION_2 =>
                if(request_sync_r) then
                    if(board_select_sync_u) then
                        state_c         <= TRANSCEIVER_STATE_ACKNOWLEDGE;
                        if(wnr_sync_r) then
                            write_c     <= '1';
                        else
                            read_c      <= '1';
                        end if;
                    end if;
                else
                    state_c            <= TRANSCEIVER_STATE_IDLE;
                end if;
            when TRANSCEIVER_STATE_ACKNOWLEDGE =>
                acknowledge_c          <= '1';
                if(not (request_sync_r and board_select_sync_u)) then
                    state_c            <= TRANSCEIVER_STATE_IDLE;
                end if;
        end case;
    end process;

    process(clk) begin
        if(rising_edge(clk)) then
            if(rst) then
                state_r            <= TRANSCEIVER_STATE_IDLE;
                load_instruction_r <= '0';
                acknowledge_r      <= '0';
                write              <= '0';
                read               <= '0';
            else
                state_r            <= state_c;
                load_instruction_r <= load_instruction_c;
                acknowledge_r      <= acknowledge_c;
                write              <= write_c;
                read               <= read_c;
            end if;
        end if;
    end process;

    process(clk) begin
        if(rising_edge(clk)) then
            if(rst) then
                register_data_tx_r <= (others => '0');
            elsif(read) then
                register_data_tx_r <= register_data_tx;
            end if;
        end if;
    end process;

    acknowledge       <= acknowledge_r when acknowledge_r else 'Z';
    register_data_trx <= register_data_tx_r when acknowledge_r else (others => 'Z');
end architecture;
