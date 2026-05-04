// ============================================================================
// CUSTOM WRAPPER EXAMPLE: Multi-Bus Test Wrapper Template
// ============================================================================
// Purpose: Template demonstrating how to build a test wrapper with multiple
//          custom buses, parameterized widths, and flexible configurations.
//
// This example shows 4 buses (A, B, C, D) with different widths:
// - Bus A: 10 bits (e.g., data + control)
// - Bus B: 12 bits (e.g., extended data)
// - Bus C: 12 bits (e.g., extended control)
// - Bus D: 8 bits (e.g., status + flags)
//
// All widths are parameterizable for easy reuse.
// ============================================================================

module custom_wrapper_example #(
    parameter int BUS_A_WIDTH = 10,
    parameter int BUS_B_WIDTH = 12,
    parameter int BUS_C_WIDTH = 12,
    parameter int BUS_D_WIDTH = 2,
    parameter int CFG_WIDTH  = 3      // Configuration selector width
)(
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg_local,
    
    // ========================================================================
    // BUS A: inout (bidirectional)
    // ========================================================================
    input  logic [BUS_A_WIDTH-1:0] i_bus_a,
    
    // ========================================================================
    // BUS B: inout (bidirectional)
    // ========================================================================
    input  logic [BUS_B_WIDTH-1:0] i_bus_b,
    
    // ========================================================================
    // BUS C: output only
    // ========================================================================
    output logic [BUS_C_WIDTH-1:0] o_bus_c,
    
    // ========================================================================
    // BUS D: output only
    // ========================================================================
    output logic [BUS_D_WIDTH-1:0] o_bus_d
);

    // ==========================================================================
    // Configuration modes
    // ==========================================================================
    localparam logic [2:0] CFG_CLASSIC      = 3'b000;  // All buses nominal
    localparam logic [2:0] CFG__A_ONLY   = 3'b001;  // Test bus A isolation
    localparam logic [2:0] CFG__B_ONLY   = 3'b010;  // Test bus B isolation
    localparam logic [2:0] CFG__C_ONLY   = 3'b011;  // Test bus C isolation
    localparam logic [2:0] CFG__D_ONLY   = 3'b100;  // Test bus D isolation
    localparam logic [2:0] CFG_CHAIN_AB     = 3'b101;  // A -> B chaining
    localparam logic [2:0] CFG_CHAIN_CD     = 3'b110;  // C -> D chaining
    localparam logic [2:0] CFG_    = 3'b111;  // All buses with override

    logic w_a;
    logic w_b;
    logic w_c;
    logic w_d;
    // ==========================================================================
    // Configuration routing: Mux buses based on i_cfg_local
    // ==========================================================================
    always_comb begin
        
        unique case (i_cfg_local)
            // ====================================================================
            // CFG_CLASSIC (0x0): All nominal operation
            // ====================================================================
            CFG_CLASSIC: begin
                w_a = i_bus_a[0];
                w_b = i_bus_b[0];
                o_bus_c[0] = w_c;
                o_bus_d[0] = w_d;
            end
            default: begin
                w_a = 1'b0;
                w_b = 1'b0;
                w_c = 1'b0;
                w_d = 1'b0;
            end

        endcase
    end

    // ==========================================================================
    // DUT INSTANTIATION (Placeholder)
    // ==========================================================================

    // No DUT in this example; provide a safe placeholder comment and close the
    // module to avoid EOF / unterminated-block parser errors.

    // End of example wrapper

endmodule