library ieee;
use ieee.std_logic_1164.all;

library work;
use work.counter_pkg.all;

package timer_pkg is
    type timer_instruction is record
        load:     std_logic;
        duration: std_logic_vector;
    end record;

    function generate_counter_instruction(instruction: timer_instruction;
                                          done:        std_logic) return counter_instruction;
end package;

package body timer_pkg is
    function generate_counter_instruction(instruction: timer_instruction;
                                          done:        std_logic) return counter_instruction is
        variable ret:     counter_instruction(count(instruction.duration'LEFT downto instruction.duration'RIGHT));
        variable control: std_logic_vector(1 downto 0);
    begin
        ret.count := instruction.duration;
        control   := instruction.load & done;
        case control is
            when "00"   => ret.opcode := COUNTER_OPCODE_DECR;
            when "01"   => ret.opcode := COUNTER_OPCODE_NOOP;
            when "10" |
                 "11"   => ret.opcode := COUNTER_OPCODE_LOAD;
            when others => ret.opcode := COUNTER_OPCODE_NOOP;
        end case;
        return ret;
    end function;
end package body;
