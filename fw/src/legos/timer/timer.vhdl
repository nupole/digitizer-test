library ieee;
use ieee.std_logic_1164.all;

library work;
use work.timer_pkg.all;
use work.counter_pkg.all;

entity timer is
    generic(OUTPUT_REGISTER: boolean  := true;
            DURATION_WIDTH:  positive := 8);
    port(clk:         in  std_logic;
         rst:         in  std_logic;
         instruction: in  timer_instruction(duration((DURATION_WIDTH-1) downto 0));
         done:        out std_logic);
end entity;

architecture rtl of timer is
    component counter is
        generic(COUNT_WIDTH: positive);
        port(clk:         in  std_logic;
             rst:         in  std_logic;
             instruction: in  counter_instruction(count((COUNT_WIDTH-1) downto 0));
             count:       out std_logic_vector((COUNT_WIDTH-1) downto 0));
    end component;

    component comparator is
        generic(OUTPUT_REGISTER:  boolean;
                COMPARATOR_WIDTH: positive);
        port(clk: in  std_logic;
             rst: in  std_logic;
             m:   in  std_logic_vector((COMPARATOR_WIDTH-1) downto 0);
             n:   in  std_logic_vector((COMPARATOR_WIDTH-1) downto 0);
             mgn: out std_logic;
             men: out std_logic;
             mln: out std_logic);
    end component;

    constant DURATION_ZERO:                  std_logic_vector((DURATION_WIDTH-1) downto 0) := (others => '0');
    signal   duration_counter_instruction_c: counter_instruction(count((DURATION_WIDTH-1) downto 0));
    signal   duration_r:                     std_logic_vector((DURATION_WIDTH-1) downto 0);
    signal   done_c:                         std_logic;
begin
    duration_counter_instruction_c <= generate_counter_instruction(instruction, done_c);

    duration_counter: counter generic map(COUNT_WIDTH => DURATION_WIDTH)
                              port map(clk         => clk,
                                       rst         => rst,
                                       instruction => duration_counter_instruction_c,
                                       count       => duration_r);

    done_comparator: comparator generic map(OUTPUT_REGISTER  => false,
                                            COMPARATOR_WIDTH => DURATION_WIDTH)
                                port map(clk => clk,
                                         rst => rst,
                                         m   => duration_r,
                                         n   => DURATION_ZERO,
                                         mgn => open,
                                         men => done_c,
                                         mln => open);

    GEN_OUTPUT: if(OUTPUT_REGISTER) generate
        process(clk) begin
            if(rising_edge(clk)) then
                if(rst) then
                    done <= '1';
                else
                    done <= done_c;
                end if;
            end if;
        end process;
    else generate
        done <= done_c;
    end generate;
end architecture;
