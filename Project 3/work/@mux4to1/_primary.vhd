library verilog;
use verilog.vl_types.all;
entity Mux4to1 is
    generic(
        DATA_BIT_WIDTH  : integer := 32
    );
    port(
        sel             : in     vl_logic_vector(1 downto 0);
        dIn0            : in     vl_logic_vector;
        dIn1            : in     vl_logic_vector;
        dIn2            : in     vl_logic_vector;
        dIn3            : in     vl_logic_vector;
        dOut            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_BIT_WIDTH : constant is 1;
end Mux4to1;
