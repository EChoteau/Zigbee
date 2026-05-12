// ============================================================================
// Package     : tb_pkg
// Description : Utilitaires de testbench mutualisés pour le projet Zigbee.
//               Inclut la gestion du Reset et du Bus avec sécurité negedge.
// ============================================================================

package tb_pkg;

    // --- Configuration des largeurs par défaut ---
    localparam int CFG_WIDTH     = 3;
    localparam int BUS_IN_WIDTH  = 22;
    localparam int BUS_OUT_WIDTH = 14;

    // Tâche : Appliquer un Reset synchronisé
    task automatic apply_reset(
        ref logic i_clk, 
        ref logic i_rst_n, 
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in, 
        input int cycles
    );
    begin
        @(negedge i_clk);
        i_rst_n = 1'b0;
        i_bus_in = '0;
        repeat(cycles) @(posedge i_clk);
        @(negedge i_clk); 
        i_rst_n = 1'b1;
        repeat(2) @(posedge i_clk);
    end
    endtask

    // Tâche : Piloter le bus de données (Sécurité Negedge)
    task automatic set_bus(
        ref logic i_clk, 
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in, 
        input logic [BUS_IN_WIDTH-1:0] val
    );
    begin
        @(negedge i_clk);
        i_bus_in = val;
        @(posedge i_clk);
    end
    endtask

    // Tâche : Piloter la configuration (Sécurité Negedge)
    task automatic set_config(
        ref logic i_clk, 
        ref logic [CFG_WIDTH-1:0] i_cfg_local, 
        input logic [CFG_WIDTH-1:0] cfg
    );
    begin
        @(negedge i_clk);
        i_cfg_local = cfg;
        @(posedge i_clk);
    end
    endtask

endpackage