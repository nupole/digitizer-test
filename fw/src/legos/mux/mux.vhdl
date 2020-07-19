library ieee;
use ieee.std_logic_1164.all;

library work;
use work.mux_pkg.all;

entity mux is
    generic(ADDRESS_WIDTH: positive := 6;
            DATA_WIDTH:    positive := 8);
    port(address: in  std_logic_vector((ADDRESS_WIDTH-1) downto 0);
         d:       in  mux_input(0 to ((2**ADDRESS_WIDTH)-1))((DATA_WIDTH-1) downto 0);
         z:       out std_logic_vector((DATA_WIDTH-1) downto 0));
end mux;

architecture rtl of mux is
begin
    z <= generate_z(address, d);
end architecture;
