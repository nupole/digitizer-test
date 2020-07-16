library ieee;
use ieee.std_logic_1164.all;

entity clock_manager is
    port(clk_25MHz:   in  std_logic;
         clk_100MHz:  out std_logic;
         lock_100MHz: out std_logic);
end entity;

architecture rtl of clock_manager is
    component pll is
        port(CLKI:  in  std_logic;
             RST:   in  std_logic;
             CLKOP: out std_logic;
             LOCK:  out std_logic);
    end component;

    signal lock_sync_25MHz_r:  std_logic;
    signal lock_meta_100MHz_r: std_logic;
begin
    clk_100MHz_pll: pll port map(CLKI  => clk_25MHz,
                                 RST   => '0',
                                 CLKOP => clk_100MHz,
                                 LOCK  => lock_sync_25MHz_r);

    process(clk_100MHz) begin
        if(rising_edge(clk_100MHz)) then
            lock_meta_100MHz_r <= lock_sync_25MHz_r;
            lock_100MHz        <= lock_meta_100MHz_r;
        end if;
    end process;
end architecture;
