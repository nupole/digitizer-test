library ieee;
use ieee.std_logic_1164.all;

package edge_detector_pkg is
    type edge_detector_instruction is record
        enable_falling_edge: std_logic;
        enable_rising_edge:  std_logic;
    end record;
end package;
