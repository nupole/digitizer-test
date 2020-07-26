library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package counter_pkg is
    type counter_opcode is (COUNTER_OPCODE_NOOP,
                            COUNTER_OPCODE_DECR,
                            COUNTER_OPCODE_INCR,
                            COUNTER_OPCODE_LOAD);

    type counter_instruction is record
        opcode: counter_opcode;
        count:  std_logic_vector;
    end record;

    function generate_next_count(instruction:   counter_instruction;
                                 current_count: std_logic_vector) return std_logic_vector;
end package;

package body counter_pkg is
    function generate_next_count(instruction:   counter_instruction;
                                 current_count: std_logic_vector) return std_logic_vector is
        variable ret: std_logic_vector(current_count'LEFT downto current_count'RIGHT);
    begin
        case instruction.opcode is
            when COUNTER_OPCODE_NOOP => ret := current_count;
            when COUNTER_OPCODE_DECR => ret := std_logic_vector(unsigned(current_count) - '1');
            when COUNTER_OPCODE_INCR => ret := std_logic_vector(unsigned(current_count) + '1');
            when COUNTER_OPCODE_LOAD => ret := instruction.count;
        end case;
        return ret;
    end function;
end package body;
