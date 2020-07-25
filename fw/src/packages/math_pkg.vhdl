library ieee;
use ieee.std_logic_1164.all;

package math_pkg is
    function log2(m: positive) return natural;
end package;

package body math_pkg is
    function log2(m: positive) return natural is
        variable ret:  natural;
    begin
        ret := 1;
        if(m /= 1) then
            ret := ret + log2(m/2);
        end if;
        return ret;
    end function;
end package body;
