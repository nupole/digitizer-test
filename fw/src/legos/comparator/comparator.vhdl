library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
    generic(OUTPUT_REGISTER:  boolean  := true;
            COMPARATOR_WIDTH: positive := 8);
    port(clk: in  std_logic;
         rst: in  std_logic;
         m:   in  std_logic_vector((COMPARATOR_WIDTH-1) downto 0);
         n:   in  std_logic_vector((COMPARATOR_WIDTH-1) downto 0);
         mgn: out std_logic;
         men: out std_logic;
         mln: out std_logic);
end entity;

architecture rtl of comparator is
    signal mgn_c: std_logic;
    signal men_c: std_logic;
    signal mln_c: std_logic;
begin
    mgn_c <= '1' when (unsigned(m) > unsigned(n)) else '0';
    men_c <= '1' when (unsigned(m) = unsigned(n)) else '0';
    mln_c <= '1' when (unsigned(m) < unsigned(n)) else '0';

    GEN_OUTPUT: if(OUTPUT_REGISTER) generate
        process(clk) begin
            if(rising_edge(clk)) then
                if(rst) then
                    mgn <= '0';
                    men <= '0';
                    mln <= '0';
                else
                    mgn <= mgn_c;
                    men <= men_c;
                    mln <= mln_c;
                end if;
            end if;
        end process;
    else generate
        mgn <= mgn_c;
        men <= men_c;
        mln <= mln_c;
    end generate;
end architecture;
