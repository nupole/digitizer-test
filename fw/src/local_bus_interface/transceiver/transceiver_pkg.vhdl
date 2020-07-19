library ieee;
use ieee.std_logic_1164.all;

package transceiver_pkg is
    type transceiver_state is (TRANSCEIVER_STATE_IDLE,
                               TRANSCEIVER_STATE_LOAD_INSTRUCTION,
                               TRANSCEIVER_STATE_DECODE_INSTRUCTION_1,
                               TRANSCEIVER_STATE_DECODE_INSTRUCTION_2,
                               TRANSCEIVER_STATE_ACKNOWLEDGE);
end package;
