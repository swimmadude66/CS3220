library verilog;
use verilog.vl_types.all;
entity PipelineRegister is
    generic(
        PC_BIT_WIDTH    : integer := 32;
        IWORD_BIT_WIDTH : integer := 32;
        PC_RESET_VALUE  : integer := 40;
        IWORD_RESET_VALUE: integer := 0
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        wrtEn           : in     vl_logic;
        nxtPCin         : in     vl_logic_vector;
        iwordin         : in     vl_logic_vector;
        nxtPCout        : out    vl_logic_vector;
        iwordout        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PC_BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of IWORD_BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of PC_RESET_VALUE : constant is 1;
    attribute mti_svvh_generic_type of IWORD_RESET_VALUE : constant is 1;
end PipelineRegister;
