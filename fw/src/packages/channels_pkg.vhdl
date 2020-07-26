library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types_pkg.all;

package channels_pkg is
    type channel_enable is (CHANNEL_ENABLE_OFF,
                            CHANNEL_ENABLE_ON);

    type channel_polarity is (CHANNEL_POLARITY_FALLING,
                              CHANNEL_POLARITY_RISING);

    type channel_opcode is record
        enable:   channel_enable;
        polarity: channel_polarity;
    end record;

    type channel_operands is record
        threshold:        std_logic_vector;
        data:             std_logic_vector;
        trigger_duration: std_logic_vector;
    end record;

    type channel_instruction is record
        opcode:   channel_opcode;
        operands: channel_operands;
    end record;

    type channel_instructions is array(natural range<>) of channel_instruction;

    alias channel_thresholds is array_std_logic_vector;
    alias channel_datas is array_std_logic_vector;
    alias channel_durations is array_std_logic_vector;

    function generate_channel_instructions(channel_opcode_register:            std_logic_vector;
                                           channel_threshold_registers:        channel_thresholds;
                                           channel_data_registers:             channel_datas;
                                           channel_trigger_duration_registers: channel_durations) return channel_instructions;
end package;

package body channels_pkg is
    function generate_channel_instructions(channel_opcode_register:            std_logic_vector;
                                           channel_threshold_registers:        channel_thresholds;
                                           channel_data_registers:             channel_datas;
                                           channel_trigger_duration_registers: channel_durations) return channel_instructions is
        constant NUM_CHANNELS:           positive := channel_data_registers'LENGTH;
        constant DATA_WIDTH:             positive := channel_data_registers(0)'LENGTH;
        constant TRIGGER_DURATION_WIDTH: positive := channel_trigger_duration_registers(0)'LENGTH;
        variable ret:                    channel_instructions(0 to (NUM_CHANNELS-1))(operands(threshold((DATA_WIDTH-1) downto 0),
                                                                                              data((DATA_WIDTH-1) downto 0),
                                                                                              trigger_duration((TRIGGER_DURATION_WIDTH-1) downto 0)));
    begin
        for i in 0 to (NUM_CHANNELS-1) loop
            ret(i).opcode.enable             := CHANNEL_ENABLE_ON when channel_opcode_register(2*i) else
                                                CHANNEL_ENABLE_OFF;
            ret(i).opcode.polarity           := CHANNEL_POLARITY_RISING when channel_opcode_register(2*i+1) else
                                                CHANNEL_POLARITY_FALLING;
            ret(i).operands.threshold        := channel_threshold_registers(channel_threshold_registers'LEFT + i);
            ret(i).operands.data             := channel_data_registers(channel_data_registers'LEFT + i);
            ret(i).operands.trigger_duration := channel_trigger_duration_registers(channel_trigger_duration_registers'LEFT + i);
        end loop;
        return ret;
    end function;
end package body;
