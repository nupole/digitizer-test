library ieee;
use ieee.std_logic_1164.all;

library work;
use work.edge_detector_pkg.all;

entity edge_detector is
    generic(OUTPUT_REGISTER: boolean := true);
    port(clk:         in  std_logic;
         rst:         in  std_logic;
         instruction: in  edge_detector_instruction;
         sig:         in  std_logic;
         edge:        out std_logic);
end entity;

architecture rtl of edge_detector is
    signal sig_r:          std_logic;
    signal falling_edge_c: std_logic;
    signal rising_edge_c:  std_logic;
    signal edge_c:         std_logic;
begin
    process(clk) begin
        if(rising_edge(clk)) then
            sig_r <= sig;
        end if;
    end process;

    falling_edge_c <= (not sig) and sig_r;
    rising_edge_c  <= sig and (not sig_r);
    edge_c         <= (instruction.enable_falling_edge and falling_edge_c) or
                      (instruction.enable_rising_edge  and rising_edge_c);

    GEN_OUTPUT: if(OUTPUT_REGISTER) generate
        process(clk) begin
            if(rising_edge(clk)) then
                if(rst) then
                    edge <= '0';
                else
                    edge <= edge_c;
                end if;
            end if;
        end process;
    else generate
        edge <= edge_c;
    end generate;
end architecture;
