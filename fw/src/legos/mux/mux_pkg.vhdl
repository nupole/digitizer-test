library ieee;
use ieee.std_logic_1164.all;

library work;
use work.types_pkg.all;

package mux_pkg is
    alias mux_input is array_std_logic_vector;

    function generate_z(address: std_logic_vector;
                        data:    mux_input) return std_logic_vector;
end package;

package body mux_pkg is
    function generate_z(address: std_logic_vector;
                        data:    mux_input) return std_logic_vector is
        constant ADDRESS_UPPER_INDEX: natural := address'LEFT;
        constant ADDRESS_LOWER_INDEX: natural := address'RIGHT;
        constant DATA_UPPER_INDEX:    natural := data'RIGHT;
        constant DATA_LOWER_INDEX:    natural := data'LEFT;
        constant DATA_AVERAGE_INDEX:  natural := (DATA_UPPER_INDEX + DATA_LOWER_INDEX) / 2;
        variable ret:                 std_logic_vector(data(DATA_LOWER_INDEX)'RANGE(1));
    begin
        if(ADDRESS_UPPER_INDEX = ADDRESS_LOWER_INDEX) then
            ret := data(DATA_UPPER_INDEX) when (address(ADDRESS_LOWER_INDEX) = '1') else
                   data(DATA_LOWER_INDEX);
        else
            ret := generate_z(address((ADDRESS_UPPER_INDEX - 1) downto 0), data((DATA_AVERAGE_INDEX + 1) to DATA_UPPER_INDEX)) when (address(ADDRESS_UPPER_INDEX) = '1') else
                   generate_z(address((ADDRESS_UPPER_INDEX - 1) downto 0), data(DATA_LOWER_INDEX to DATA_AVERAGE_INDEX));
        end if;
        return ret;
    end function;
end package body;
