library verilog;
use verilog.vl_types.all;
entity Bubbler is
    port(
        clk             : in     vl_logic;
        isLoad          : in     vl_logic;
        isBranch        : in     vl_logic;
        isJAL           : in     vl_logic;
        cmpIn           : in     vl_logic;
        s1Addr          : in     vl_logic_vector(3 downto 0);
        s2Addr          : in     vl_logic_vector(3 downto 0);
        s1used          : in     vl_logic;
        s2used          : in     vl_logic;
        dAddr           : in     vl_logic_vector(3 downto 0);
        regWrtEn        : in     vl_logic;
        bubbleOut       : out    vl_logic
    );
end Bubbler;
