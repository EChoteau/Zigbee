//////////////////////////////////////////////////////////////////////////////////
// Module Name:    apb_slave_regs
// Description:    Contrôleur de registres esclave sur bus APB (Advanced Peripheral Bus).
//                 Fait le pont entre le processeur et la logique matérielle (FIFOs, Control).
//////////////////////////////////////////////////////////////////////////////////

module apb_slave_regs #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    // --- 1. Horloge et Reset ---
    input  logic                    i_clk,
    input  logic                    i_rst_n,

    // --- 2. Bus APB Standard ---
    input  logic                    i_psel,
    input  logic                    i_penable,
    input  logic                    i_pwrite,
    input  logic [ADDR_WIDTH-1:0]   i_paddr,
    input  logic [DATA_WIDTH-1:0]   i_pwdata,
    output logic [DATA_WIDTH-1:0]   o_prdata,
    output logic                    o_pready,
    output logic                    o_pslverr,

    // --- 3. Interface vers FIFO TX ---
    output logic [7:0]              o_tx_data,
    output logic                    o_tx_push,
    input  logic                    i_tx_full,
    input  logic                    i_tx_busy,
    input  logic                    i_tx_und_err, // Erreur Underrun remontée par le TX

    // --- 4. Interface vers FIFO RX ---
    input  logic [7:0]              i_rx_data,
    output logic                    o_rx_pop,
    input  logic                    i_rx_empty,
    input  logic                    i_rx_ovf_err, // Erreur Overflow remontée par le RX

    // --- 5. Signaux de Contrôle sortants ---
    output logic                    o_global_en,
    output logic                    o_sw_reset,
    output logic                    o_clear_err,
    output logic                    o_tx_start,
    output logic                    o_rx_enable,
    output logic [7:0]              o_div_val
);

    // ==========================================
    // CARTE MÉMOIRE (Memory Map)
    // ==========================================
    localparam ADDR_DATA    = 8'h00; // Accès FIFOs
    localparam ADDR_STATUS  = 8'h04; // Lecture de l'état (Read-Only)
    localparam ADDR_CONTROL = 8'h08; // Commandes (Read/Write)
    localparam ADDR_DIVIDER = 8'h0C; // Configuration vitesse (Read/Write)

    // ==========================================
    // SIGNAUX INTERNES
    // ==========================================
    // Registres physiques (ceux qui stockent vraiment une valeur)
    logic [4:0] s_reg_control; 
    logic [7:0] s_reg_divider;
    logic [4:0] s_reg_control_n;
    logic [7:0] s_reg_divider_n;
    logic [7:0] s_tx_data_n;
    logic       s_tx_push_n;

    // Détection des phases du protocole APB
    logic w_write_en;
    logic w_read_setup;

    // ==========================================
    // LOGIQUE DE DÉCODAGE APB
    // ==========================================
    // L'écriture est validée uniquement pendant la phase d'accès APB (penable = 1)
    assign w_write_en = i_psel & i_penable & i_pwrite;
    
    // Le Setup de lecture s'active AVANT penable. 
    // Cela laisse 1 cycle d'horloge à la FIFO Synchrone pour préparer sa donnée en sortie.
    assign w_read_setup = i_psel & ~i_penable & ~i_pwrite; 

    // Réponses APB (Fixes pour simplifier : Pas de temps d'attente, pas d'erreur bus)
    assign o_pready  = 1'b1; 
    assign o_pslverr = 1'b0; 

    // Routage continu des bits de contrôle vers le reste du design
    assign o_global_en = s_reg_control[0];
    assign o_sw_reset  = s_reg_control[1];
    assign o_clear_err = s_reg_control[2];
    assign o_tx_start  = s_reg_control[3];
    assign o_rx_enable = s_reg_control[4];
    assign o_div_val   = (s_reg_divider == 8'h00) ? 8'h01 : s_reg_divider;

    // ==========================================
    // PROCESSUS COMBINATOIRE : NEXT-STATE ÉCRITURE
    // ==========================================
    always_comb begin
        s_reg_control_n = s_reg_control;
        s_reg_divider_n = s_reg_divider;
        s_tx_data_n     = o_tx_data;
        s_tx_push_n     = 1'b0;

        // Auto-clear SW_RESET et CLEAR_ERR au cycle suivant
        if (s_reg_control[1]) s_reg_control_n[1] = 1'b0;
        if (s_reg_control[2]) s_reg_control_n[2] = 1'b0;

        if (w_write_en) begin
            case (i_paddr)
                ADDR_DATA: begin
                    if (!i_tx_full) begin
                        s_tx_data_n = i_pwdata[7:0];
                        s_tx_push_n = 1'b1;
                    end
                end
                ADDR_CONTROL: begin
                    s_reg_control_n = i_pwdata[4:0];
                end
                ADDR_DIVIDER: begin
                    if (i_pwdata[7:0] == 8'h00) begin
                        s_reg_divider_n = 8'h01;
                    end else begin
                        s_reg_divider_n = i_pwdata[7:0];
                    end
                end
                default: ;
            endcase
        end
    end

    // ==========================================
    // PROCESSUS SÉQUENTIEL : ÉCRITURE
    // ==========================================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Reset asynchrone actif bas [cite: 102]
            s_reg_control <= '0;
            s_reg_divider <= '0;
            o_tx_data     <= '0;
            o_tx_push     <= 1'b0;
        end else begin
            s_reg_control <= s_reg_control_n;
            s_reg_divider <= s_reg_divider_n;
            o_tx_data     <= s_tx_data_n;
            o_tx_push     <= s_tx_push_n;
        end
    end

    // ==========================================
    // PROCESSUS COMBINATOIRE : LECTURE
    // ==========================================
    
    // Le "POP" de la FIFO RX est déclenché dynamiquement dès le setup de lecture.
    assign o_rx_pop = (w_read_setup && (i_paddr == ADDR_DATA) && !i_rx_empty);

    always_comb begin
        // Valeur par défaut pour empêcher l'inférence de Latch 
        o_prdata = '0; 

        if (i_psel) begin
            case (i_paddr)
                ADDR_DATA: begin
                    o_prdata[7:0] = i_rx_data; // Donnée venant de la FIFO RX
                end
                ADDR_STATUS: begin
                    // Construction du tableau de bord (Status Reg)
                    o_prdata[0] = i_rx_empty;
                    o_prdata[1] = i_tx_full;
                    o_prdata[2] = i_tx_busy;
                    o_prdata[3] = i_rx_ovf_err;
                    o_prdata[4] = i_tx_und_err;
                end
                ADDR_CONTROL: begin
                    o_prdata[4:0] = s_reg_control; // Relecture de la conf actuelle
                end
                ADDR_DIVIDER: begin
                    o_prdata[7:0] = o_div_val; // Relecture de la vitesse (clamp min=1)
                end
                default: o_prdata = '0;
            endcase
        end
    end

endmodule