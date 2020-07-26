library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.math_pkg.all;

package coincidence_pkg is
    type coincidence_opcode is record
        enable_greater_than: std_logic;
        enable_equal_to:     std_logic;
        enable_less_than:    std_logic;
    end record;

    type coincidence_instruction is record
        opcode:            coincidence_opcode;
        coincidence_value: std_logic_vector;
    end record;

    function generate_num_channel_triggers(channel_triggers: std_logic_vector) return std_logic_vector;
    function generate_coincidence_instruction(COINCIDENCE_VALUE_WIDTH:     natural;
                                              coincidence_opcode_register: std_logic_vector;
                                              coincidence_value_register:  std_logic_vector) return coincidence_instruction;
end package;

package body coincidence_pkg is
    function generate_num_channel_triggers(channel_triggers: std_logic_vector) return std_logic_vector is
        constant UPPER_INDEX: natural  := channel_triggers'LEFT;
        constant LOWER_INDEX: natural  := channel_triggers'RIGHT;
        constant AVG_INDEX:   natural  := (UPPER_INDEX + LOWER_INDEX) / 2;
        constant SIZE:        positive := UPPER_INDEX - LOWER_INDEX + 1;
        variable ret:         std_logic_vector((log2(SIZE)-1) downto 0);
    begin
        if(SIZE = 1) then
            ret := channel_triggers;
        else
            ret := std_logic_vector(unsigned(('0' & generate_num_channel_triggers(channel_triggers(UPPER_INDEX downto(AVG_INDEX+1))))) +
                                    unsigned(('0' & generate_num_channel_triggers(channel_triggers(AVG_INDEX downto LOWER_INDEX)))));
        end if;
        return ret;
    end function;

    function generate_coincidence_instruction(COINCIDENCE_VALUE_WIDTH:     natural;
                                              coincidence_opcode_register: std_logic_vector;
                                              coincidence_value_register:  std_logic_vector) return coincidence_instruction is
        variable ret: coincidence_instruction(coincidence_value((COINCIDENCE_VALUE_WIDTH-1) downto 0));
    begin
        ret.opcode.enable_greater_than := coincidence_opcode_register(2);
        ret.opcode.enable_equal_to     := coincidence_opcode_register(1);
        ret.opcode.enable_less_than    := coincidence_opcode_register(0);
        ret.coincidence_value          := coincidence_value_register((COINCIDENCE_VALUE_WIDTH-1) downto 0);
        return ret;
    end function;
end package body;
