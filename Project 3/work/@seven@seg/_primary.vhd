library verilog;
use verilog.vl_types.all;
entity SevenSeg is
    port(
        dIn             : in     vl_logic_vector(3 downto 0);
        dOut            : out    vl_logic_vector(6 downto 0)
    );
end SevenSeg;
