library verilog;
use verilog.vl_types.all;
entity altdpram is
    generic(
        width           : integer := 1;
        widthad         : integer := 1;
        numwords        : integer := 0;
        lpm_file        : string  := "UNUSED";
        lpm_hint        : string  := "USE_EAB=ON";
        use_eab         : string  := "ON";
        lpm_type        : string  := "altdpram";
        indata_reg      : string  := "INCLOCK";
        indata_aclr     : string  := "ON";
        wraddress_reg   : string  := "INCLOCK";
        wraddress_aclr  : string  := "ON";
        wrcontrol_reg   : string  := "INCLOCK";
        wrcontrol_aclr  : string  := "ON";
        rdaddress_reg   : string  := "OUTCLOCK";
        rdaddress_aclr  : string  := "ON";
        rdcontrol_reg   : string  := "OUTCLOCK";
        rdcontrol_aclr  : string  := "ON";
        outdata_reg     : string  := "UNREGISTERED";
        outdata_aclr    : string  := "ON";
        maximum_depth   : integer := 2048;
        intended_device_family: string  := "Stratix";
        ram_block_type  : string  := "AUTO";
        width_byteena   : integer := 1;
        byte_size       : integer := 0;
        read_during_write_mode_mixed_ports: string  := "DONT_CARE";
        i_byte_size     : vl_notype;
        is_lutram       : vl_notype;
        i_width_byteena : vl_notype;
        i_read_during_write: vl_notype
    );
    port(
        wren            : in     vl_logic;
        data            : in     vl_logic_vector;
        wraddress       : in     vl_logic_vector;
        inclock         : in     vl_logic;
        inclocken       : in     vl_logic;
        rden            : in     vl_logic;
        rdaddress       : in     vl_logic_vector;
        wraddressstall  : in     vl_logic;
        rdaddressstall  : in     vl_logic;
        byteena         : in     vl_logic_vector;
        outclock        : in     vl_logic;
        outclocken      : in     vl_logic;
        aclr            : in     vl_logic;
        q               : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
    attribute mti_svvh_generic_type of widthad : constant is 1;
    attribute mti_svvh_generic_type of numwords : constant is 1;
    attribute mti_svvh_generic_type of lpm_file : constant is 1;
    attribute mti_svvh_generic_type of lpm_hint : constant is 1;
    attribute mti_svvh_generic_type of use_eab : constant is 1;
    attribute mti_svvh_generic_type of lpm_type : constant is 1;
    attribute mti_svvh_generic_type of indata_reg : constant is 1;
    attribute mti_svvh_generic_type of indata_aclr : constant is 1;
    attribute mti_svvh_generic_type of wraddress_reg : constant is 1;
    attribute mti_svvh_generic_type of wraddress_aclr : constant is 1;
    attribute mti_svvh_generic_type of wrcontrol_reg : constant is 1;
    attribute mti_svvh_generic_type of wrcontrol_aclr : constant is 1;
    attribute mti_svvh_generic_type of rdaddress_reg : constant is 1;
    attribute mti_svvh_generic_type of rdaddress_aclr : constant is 1;
    attribute mti_svvh_generic_type of rdcontrol_reg : constant is 1;
    attribute mti_svvh_generic_type of rdcontrol_aclr : constant is 1;
    attribute mti_svvh_generic_type of outdata_reg : constant is 1;
    attribute mti_svvh_generic_type of outdata_aclr : constant is 1;
    attribute mti_svvh_generic_type of maximum_depth : constant is 1;
    attribute mti_svvh_generic_type of intended_device_family : constant is 1;
    attribute mti_svvh_generic_type of ram_block_type : constant is 1;
    attribute mti_svvh_generic_type of width_byteena : constant is 1;
    attribute mti_svvh_generic_type of byte_size : constant is 1;
    attribute mti_svvh_generic_type of read_during_write_mode_mixed_ports : constant is 1;
    attribute mti_svvh_generic_type of i_byte_size : constant is 3;
    attribute mti_svvh_generic_type of is_lutram : constant is 3;
    attribute mti_svvh_generic_type of i_width_byteena : constant is 3;
    attribute mti_svvh_generic_type of i_read_during_write : constant is 3;
end altdpram;
