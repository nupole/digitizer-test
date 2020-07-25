library ieee;
use ieee.std_logic_1164.all;

library work;
use work.math_pkg.all;
use work.channels_pkg.all;
use work.coincidence_pkg.all;

package trigger_manager_pkg is
    type trigger_manager_instruction is record
        chan_instructions: channel_instructions;
        coin_instruction:  coincidence_instruction;
        veto_duration:     std_logic_vector;
    end record;

    function generate_trigger_manager_instruction(channel_opcode_register:     std_logic_vector;
                                                  channel_threshold_registers: channel_thresholds;
                                                  channel_data_registers:      channel_datas;
                                                  channel_trigger_duration_registers:  channel_durations;
                                                  coincidence_opcode_register: std_logic_vector;
                                                  coincidence_value_register:  std_logic_vector;
                                                  veto_duration:               std_logic_vector) return trigger_manager_instruction;
end package;

package body trigger_manager_pkg is
    function generate_trigger_manager_instruction(channel_opcode_register:     std_logic_vector;
                                                  channel_threshold_registers: channel_thresholds;
                                                  channel_data_registers:      channel_datas;
                                                  channel_trigger_duration_registers:  channel_durations;
                                                  coincidence_opcode_register: std_logic_vector;
                                                  coincidence_value_register:  std_logic_vector;
                                                  veto_duration:               std_logic_vector) return trigger_manager_instruction is
        constant NUM_CHANNELS:            positive := channel_data_registers'LENGTH;
        constant DATA_WIDTH:              positive := channel_data_registers(channel_data_registers'LEFT)'LENGTH;
        constant TRIGGER_DURATION_WIDTH:  positive := channel_trigger_duration_registers(channel_trigger_duration_registers'LEFT)'LENGTH;
        constant COINCIDENCE_VALUE_WIDTH: natural  := log2(NUM_CHANNELS);
        constant VETO_DURATION_WIDTH:     positive :=veto_duration'LENGTH;
        variable ret:                     trigger_manager_instruction(chan_instructions(0 to (NUM_CHANNELS-1))(operands(threshold((DATA_WIDTH-1) downto 0),
                                                                                                                        data((DATA_WIDTH-1) downto 0),
                                                                                                                        trigger_duration((TRIGGER_DURATION_WIDTH-1) downto 0))),
                                                                      coin_instruction(coincidence_value((COINCIDENCE_VALUE_WIDTH-1) downto 0)),
                                                                      veto_duration((VETO_DURATION_WIDTH-1) downto 0));
    begin
        ret.chan_instructions := generate_channel_instructions(channel_opcode_register,
                                                               channel_threshold_registers,
                                                               channel_data_registers,
                                                               channel_trigger_duration_registers);
        ret.coin_instruction  := generate_coincidence_instruction(COINCIDENCE_VALUE_WIDTH,
                                                                  coincidence_opcode_register,
                                                                  coincidence_value_register);
        ret.veto_duration     := veto_duration;
        return ret;
    end function;
end package body;
