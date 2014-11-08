library verilog;
use verilog.vl_types.all;
entity ClkDivider is
    generic(
        divider         : integer := 2500000;
        len             : integer := 31
    );
    port(
        clkIn           : in     vl_logic;
        clkOut          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of divider : constant is 1;
    attribute mti_svvh_generic_type of len : constant is 1;
end ClkDivider;
