library ieee;
use ieee.std_logic_1164.all;

library work;
use work.counter_pkg.all;

entity counter is
    generic(COUNT_WIDTH: positive := 8);
    port(clk:         in  std_logic;
         rst:         in  std_logic;
         instruction: in  counter_instruction(count((COUNT_WIDTH-1) downto 0));
         count:       out std_logic_vector((COUNT_WIDTH-1) downto 0));
end entity;

architecture rtl of counter is
begin
    process(clk) begin
        if(rising_edge(clk)) then
            if(rst) then
                count <= (others => '0');
            else
                count <= generate_next_count(instruction, count);
            end if;
        end if;
    end process;
end architecture;
