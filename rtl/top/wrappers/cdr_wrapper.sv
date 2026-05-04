// ============================================================================
// Module      : cdr_wrapper
// Description : Test wrapper for the CDR (Clock & Data Recovery) block.
//               Provides injection via `i_bus_a` and observation via output buses.
//               Supports 8 configs (CFG_WIDTH=3) for selecting different 
//               test points and injection nodes.
// ============================================================================

module cdr_wrapper #(
    parameter int CFG_WIDTH   = 3,
    parameter int BUS_A_WIDTH = 10,
    parameter int BUS_B_WIDTH = 12,
    parameter int BUS_C_WIDTH = 12,
    parameter int BUS_D_WIDTH = 2
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg,

    input  logic [BUS_A_WIDTH-1:0] i_bus_a,
    input  logic [BUS_B_WIDTH-1:0] i_bus_b,
    output logic [BUS_C_WIDTH-1:0] o_bus_c,
    output logic [BUS_D_WIDTH-1:0] o_bus_d
);

    // ------------------------------------------------------------------
    // Configuration modes
    // ------------------------------------------------------------------
    localparam logic [2:0] MODE_0 = 3'b000;
    localparam logic [2:0] MODE_1 = 3'b001;
    localparam logic [2:0] MODE_2 = 3'b010;
    localparam logic [2:0] MODE_3 = 3'b011;
    localparam logic [2:0] MODE_4 = 3'b100;
    localparam logic [2:0] MODE_5 = 3'b101;
    localparam logic [2:0] MODE_6 = 3'b110;
    localparam logic [2:0] MODE_7 = 3'b111;

    // Default assignments - pass input bus A to output bus C
    always_comb begin
        o_bus_c = {{(BUS_C_WIDTH-BUS_A_WIDTH){1'b0}}, i_bus_a};
        o_bus_d = '0;

        unique case (i_cfg)
            MODE_0: begin
                // Default: pass through Bus A to Bus C
                o_bus_c = {{(BUS_C_WIDTH-BUS_A_WIDTH){1'b0}}, i_bus_a};
            end
            MODE_1: begin
                // Route Bus B to Bus C
                o_bus_c = {{(BUS_C_WIDTH-BUS_B_WIDTH){1'b0}}, i_bus_b};
            end
            MODE_2: begin
                o_bus_c = '0;
            end
            MODE_3: begin
                o_bus_c = '1;
            end
            MODE_4: begin
                // Inverted Bus A
                o_bus_c = ~i_bus_a;
            end
            MODE_5: begin
                // Shift Bus A left
                o_bus_c = {i_bus_a[BUS_A_WIDTH-2:0], 1'b0};
            end
            MODE_6: begin
                // Shift Bus A right
                o_bus_c = {{1{1'b0}}, i_bus_a[BUS_A_WIDTH-1:1]};
            end
            MODE_7: begin
                // All zeros
                o_bus_c = '0;
            end
        endcase
    end

endmodule
