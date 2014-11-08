library verilog;
use verilog.vl_types.all;
entity Controller is
    generic(
        INST_BIT_WIDTH  : integer := 32
    );
    port(
        inst            : in     vl_logic_vector;
        aluCmpIn        : in     vl_logic;
        sndOpcode       : out    vl_logic_vector(4 downto 0);
        dRegAddr        : out    vl_logic_vector(3 downto 0);
        s1RegAddr       : out    vl_logic_vector(3 downto 0);
        s2RegAddr       : out    vl_logic_vector(3 downto 0);
        imm             : out    vl_logic_vector(15 downto 0);
        regFileWrtEn    : out    vl_logic;
        s1Sel           : out    vl_logic;
        s2Sel           : out    vl_logic_vector(1 downto 0);
        memOutSel       : out    vl_logic_vector(1 downto 0);
        pcSel           : out    vl_logic_vector(1 downto 0);
        isLoad          : out    vl_logic;
        isStore         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INST_BIT_WIDTH : constant is 1;
end Controller;
