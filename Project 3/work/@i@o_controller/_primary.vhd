library verilog;
use verilog.vl_types.all;
entity IO_controller is
    port(
        dataAddr        : in     vl_logic_vector(31 downto 0);
        isLoad          : in     vl_logic;
        isStore         : in     vl_logic;
        dataWrtEn       : out    vl_logic;
        dataMemOutSel   : out    vl_logic_vector(1 downto 0);
        swEn            : out    vl_logic;
        keyEn           : out    vl_logic;
        ledrEn          : out    vl_logic;
        ledgEn          : out    vl_logic;
        hexEn           : out    vl_logic
    );
end IO_controller;
