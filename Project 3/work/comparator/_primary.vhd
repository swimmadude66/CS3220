library verilog;
use verilog.vl_types.all;
entity comparator is
    generic(
        DATA_BIT_WIDTH  : integer := 32
    );
    port(
        data1           : in     vl_logic_vector;
        data2           : in     vl_logic_vector;
        lt_gt           : out    vl_logic;
        eq              : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_BIT_WIDTH : constant is 1;
end comparator;
