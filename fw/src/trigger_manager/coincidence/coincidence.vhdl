library ieee;
use ieee.std_logic_1164.all;

library work;
use work.coincidence_pkg.all;
use work.math_pkg.all;

entity coincidence is
    generic(COINCIDENCE_COMPARATOR_REGISTER: boolean  := true;
            OUTPUT_REGISTER:                 boolean  := true;
            NUM_CHANNELS:                    positive := 2);
    port(clk:                in  std_logic;
         rst:                in  std_logic;
         instruction:        in  coincidence_instruction(coincidence_value((log2(NUM_CHANNELS)-1) downto 0));
         channel_triggers_n: in  std_logic_vector((NUM_CHANNELS-1) downto 0);
         coincident:         out std_logic);
end entity;

architecture rtl of coincidence is
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

    constant LOG_NUM_CHANNELS:     natural := log2(NUM_CHANNELS);

    signal channel_triggers_u:     std_logic_vector((NUM_CHANNELS-1) downto 0);
    signal num_channel_triggers_c: std_logic_vector((LOG_NUM_CHANNELS-1) downto 0);

    signal greater_than_u: std_logic;
    signal equal_to_u:     std_logic;
    signal less_than_u:    std_logic;
    signal coincident_c:   std_logic;
begin
    GEN_CHANNEL_TRIGGERS: for i in 0 to (NUM_CHANNELS-1) generate
        channel_triggers_u(i) <= not channel_triggers_n(i);
    end generate;

    num_channel_triggers_c <= generate_num_channel_triggers(channel_triggers_u);

    coincidence_comparator: comparator generic map(OUTPUT_REGISTER  => COINCIDENCE_COMPARATOR_REGISTER,
                                                   COMPARATOR_WIDTH => LOG_NUM_CHANNELS)
                                       port map(clk => clk,
                                                rst => rst,
                                                m   => num_channel_triggers_c,
                                                n   => instruction.coincidence_value,
                                                mgn => greater_than_u,
                                                men => equal_to_u,
                                                mln => less_than_u);

    coincident_c <= (instruction.opcode.enable_greater_than and greater_than_u) or
                    (instruction.opcode.enable_less_than and less_than_u) or
                    (instruction.opcode.enable_equal_to and equal_to_u);

    GEN_OUTPUT: if(OUTPUT_REGISTER) generate
        process(clk) begin
            if(rising_edge(clk)) then
                if(rst) then
                    coincident <= '0';
                else
                    coincident <= coincident_c;
                end if;
            end if;
        end process;
    else generate
        coincident <= coincident_c;
    end generate;
end architecture;
