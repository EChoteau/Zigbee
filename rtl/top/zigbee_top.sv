module zigbee_top #(
    parameter int BUS_A_WIDTH = 10,
    parameter int BUS_B_WIDTH = 12,
    parameter int BUS_C_WIDTH = 12,
    parameter int BUS_D_WIDTH = 2
)(
    input   logic         i_clk,
    input   logic         i_rst_n,

    // 4 dedicated configuration pins (outside the configurable IO bank).
    input   logic [2:0]   i_cfg_mode_block,
    input   logic [2:0]    i_cfg_mode_wrapper,
    input   logic [BUS_A_WIDTH-1:0] i_bus_a,
    input   logic [BUS_B_WIDTH-1:0] i_bus_b,
    output  logic [BUS_C_WIDTH-1:0] o_bus_c,
    output  logic [BUS_D_WIDTH-1:0] o_bus_d,
);

localparam logic [2:0] mode1 = 3'b000;
localparam logic [2:0] mode2 = 3'b001;
localparam logic [2:0] mode3 = 3'b010;
localparam logic [2:0] mode4 = 3'b011;
localparam logic [2:0] mode5 = 3'b100;
localparam logic [2:0] mode6 = 3'b101;
localparam logic [2:0] mode7 = 3'b110;
localparam logic [2:0] mode8 = 3'b111;

logic [BUS_A_WIDTH-1:0] w_bus_a_interface;
logic [BUS_B_WIDTH-1:0] w_bus_b_interface;
logic [BUS_C_WIDTH-1:0] w_bus_c_interface;
logic [BUS_D_WIDTH-1:0] w_bus_d_interface;

logic [BUS_A_WIDTH-1:0] w_bus_a_cordic;
logic [BUS_B_WIDTH-1:0] w_bus_b_cordic;
logic [BUS_C_WIDTH-1:0] w_bus_c_cordic;
logic [BUS_D_WIDTH-1:0] w_bus_d_cordic;

logic [BUS_A_WIDTH-1:0] w_bus_a_demod;
logic [BUS_B_WIDTH-1:0] w_bus_b_demod;
logic [BUS_C_WIDTH-1:0] w_bus_c_demod;
logic [BUS_D_WIDTH-1:0] w_bus_d_demod;

logic [BUS_A_WIDTH-1:0] w_bus_a_cdr;
logic [BUS_B_WIDTH-1:0] w_bus_b_cdr;
logic [BUS_C_WIDTH-1:0] w_bus_c_cdr;
logic [BUS_D_WIDTH-1:0] w_bus_d_cdr;

logic [BUS_A_WIDTH-1:0] w_bus_a_msk;
logic [BUS_B_WIDTH-1:0] w_bus_b_msk;
logic [BUS_C_WIDTH-1:0] w_bus_c_msk;
logic [BUS_D_WIDTH-1:0] w_bus_d_msk;

// ============================================================================
// Wrappers Instances
// ============================================================================

interface_wrapper #(
    .BUS_A_WIDTH(BUS_A_WIDTH),
    .BUS_B_WIDTH(BUS_B_WIDTH),
    .BUS_C_WIDTH(BUS_C_WIDTH),
    .BUS_D_WIDTH(BUS_D_WIDTH)
) u_wrapper_example (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_cfg_local(i_cfg_mode_wrapper),
    
    .i_bus_a(w_bus_a_interface),
    .i_bus_b(w_bus_b_interface),
    .o_bus_c(w_bus_c_interface),
    .o_bus_d(w_bus_d_interface)
);

cordic_system_wrapper #(
    .WIDTH_IN(6),
    .FILTER_N(5),
    .WIDTH_PHASE(8),
    .CFG_WIDTH(3),
    .BUS_A_WIDTH(BUS_A_WIDTH),
    .BUS_B_WIDTH(BUS_B_WIDTH),
    .BUS_C_WIDTH(BUS_C_WIDTH),
    .BUS_D_WIDTH(BUS_D_WIDTH)
) u_cordic_wrapper (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_cfg(i_cfg_mode_block),

    .i_bus_a(w_bus_a_cordic),
    .i_bus_b(w_bus_b_cordic),
    .o_bus_c(w_bus_c_cordic),
    .o_bus_d(w_bus_d_cordic)
);

msk_test_wrapper #(
    .SAMPLES_PER_HALF_SINE(10),
    .MSK_RES(6),
    .CFG_WIDTH(3),
    .BUS_A_WIDTH(BUS_A_WIDTH),
    .BUS_B_WIDTH(BUS_B_WIDTH),
    .BUS_C_WIDTH(BUS_C_WIDTH),
    .BUS_D_WIDTH(BUS_D_WIDTH)
) u_msk_wrapper (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_cfg(i_cfg_mode_block),

    .i_bus_a(w_bus_a_msk),
    .i_bus_b(w_bus_b_msk),
    .o_bus_c(w_bus_c_msk),
    .o_bus_d(w_bus_d_msk)
);


// ============================================================================
// Configuration Routing Logic
// ============================================================================

always_comb begin
    unique case (i_cfg_mode_block)
        mode1: begin
            // Example: Connect msk wrapper to interface wrapper
            w_bus_a_interface = i_bus_a; // Directly use top-level input
            w_bus_b_interface = i_bus_b; // Directly use top-level input
            w_bus_c_interface = w_bus_a_msk; // Connect MSK output to interface output
            w_bus_d_interface = w_bus_b_msk; // Connect MSK output to interface
            o_bus_c = w_bus_c_msk;
            o_bus_d = w_bus_d_msk;

            // Outputs from cordic go to top-level outputs
            o_cfg_bus_c = w_bus_c_cordic;
            o_cfg_bus_d = w_bus_d_cordic;
        end

        mode2: begin
            // Example: Connect interface wrapper to MSK wrapper
            w_bus_a_interface = w_bus_a_msk;
            w_bus_b_interface = w_bus_b_msk;
            w_bus_c_interface = w_bus_c_msk;
            w_bus_d_interface = w_bus_d_msk;

            // Cordic wrapper is isolated
            w_bus_a_cordic = '0;
            w_bus_b_cordic = '0;
            w_bus_c_cordic = '0;
            w_bus_d_cordic = '0;

            // Outputs from MSK go to top-level outputs
            o_cfg_bus_c = w_bus_c_msk;
            o_cfg_bus_d = w_bus_d_msk;
        end

        default: begin
            // Default configuration (all isolated)
            w_bus_a_interface = '0;
            w_bus_b_interface = '0;
            w_bus_c_interface = '0;
            w_bus_d_interface = '0;

            w_bus_a_cordic = '0;
            w_bus_b_cordic = '0;
            w_bus_c_cordic = '0;
            w_bus_d_cordic = '0;

            w_bus_a_msk = '0;
            w_bus_b_msk = '0;
            w_bus_c_msk = '0';
            w_bus_d_msk = '0';

            o_cfg_bus_c = '0';
            o_cfg_bus_d = '0';
        end
    
end