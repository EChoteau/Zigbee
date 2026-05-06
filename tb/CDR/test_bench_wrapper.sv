`timescale 1ns/1ps

module tb_cdr_wrapper;

    //---------------------------------
    // Clock 10 MHz
    //---------------------------------
    reg clk = 0;
    always #50 clk = ~clk;  // 100ns period → 10 MHz

    //---------------------------------
    // Reset
    //---------------------------------
    reg rst;

    //---------------------------------
    // Inputs wrapper
    //---------------------------------
    reg  signed [7:0]  dphi;
    reg  [2:0]         cfg;
    reg  [9:0]         bus_b;      // i_bus_b (unused mais piloté)

    //---------------------------------
    // Outputs wrapper
    //---------------------------------
    wire [11:0] bus_c;
    wire [1:0]  bus_d;

    //---------------------------------
    // Signaux observés selon CFG
    //---------------------------------
    // CFG0 : mode normal
    wire        w_data       = bus_c[1];
    wire        w_enable     = bus_c[0];
    // CFG1 : debug décodeur
    wire        w_dec_sig    = bus_c[0];
    // CFG2 : test phase detector
    wire        w_up         = bus_c[1];
    wire        w_down       = bus_c[0];
    // CFG3 : test loop filter
    wire [1:0]  w_ctrl       = bus_c[1:0];
    // CFG4 : test NCO
    wire        w_nco_data   = bus_c[3];
    wire        w_nco_enable = bus_c[2];
    wire        w_nco_ack    = bus_c[1];
    reg [7:0] dphi_t;
    reg [7:0] dphi_i;
    //---------------------------------
    // Instanciation DUT
    //---------------------------------
    CDR_wrapper #(
        .CFG_WIDTH  (3),
        .BUS_A_WIDTH(12),
        .BUS_B_WIDTH(10),
        .BUS_C_WIDTH(12),
        .BUS_D_WIDTH(2)
    ) dut (
        .i_clk   (clk),
        .i_rst_n (rst),
        .i_cfg   (cfg),
        .i_bus_a ({{6{1'b0}}, dphi_t}),  // dphi sur les 6 LSB
        .i_bus_b (bus_b),
        .o_bus_c (bus_c),
        .o_bus_d (bus_d)
    );

    //---------------------------------
    // Génération des bits à 2 MHz
    // cnt = 0..4 → 5 cycles de 10MHz = 2MHz
    //---------------------------------
    reg  data_bit   = 0;
    reg  data_bit_p = 0;
    reg  new_data;
    reg  [2:0] same_count = 0;
    integer cnt     = 0;
    int nb_data_t   = 0;

    always @(posedge clk) begin
        if (cnt == 2) begin
            new_data = $random;

            if (new_data == data_bit)
                same_count <= same_count + 1;
            else
                same_count <= 0;

            if (same_count >= 7) begin
                data_bit   <= ~data_bit;
                same_count <= 0;
            end else begin
                data_bit   <= new_data;
            end

            data_bit_p  <= data_bit;
            if (cfg==0) nb_data_t   <= nb_data_t + 1;
        end

        if (cnt == 4) cnt <= 0;
        else          cnt <= cnt + 1;
    end

    //---------------------------------
    // Modèle dphi MSK : ±8 selon le bit
    //---------------------------------
    logic ck_fast=0;
    always #2 ck_fast=~ck_fast;
    always @(posedge clk) begin
        if (data_bit) dphi_t <= 8'sd8;
        else          dphi_t <= -8'sd8;
        if (cfg==0) bus_b = {{2{1'b0}}, dphi};
    end

    //---------------------------------
    // Reset
    //---------------------------------
    initial begin
        rst   = 0;
        cfg   = 0;
        bus_b = 0;
        #500;
        rst = 1;
    end

    //---------------------------------
    // Comptage et vérification CFG0
    //---------------------------------
    int nb_data = 0;
    int nb_err  = 0;

    always @(posedge clk) begin
        if (rst && w_enable && cfg == 0) begin
            nb_data = nb_data + 1;
            if (w_data !== data_bit_p) nb_err = nb_err + 1;
        end
    end

    //---------------------------------
    // Séquence de test
    //---------------------------------
    assign dphi =( cfg==0) ? dphi_t:dphi_i;
    initial begin
        @(posedge rst);

        //------------------------------
        // CFG1 : test decision_block
        // vérifie que s_decision_sig = 1 quand dphi=+8
        //------------------------------
        $display("=== CFG1 : test decision_block ===");
        cfg = 1;
        dphi_i = 8'sd8;
        bus_b = {{4{1'b0}}, dphi_i};
        repeat(5) @(posedge clk);
        #10
        assert(bus_c[0] == 1'b1)
            else $error("CFG1 KO : dphi=+8 devrait donner decision=1");
        dphi_i = -8'sd8;
        bus_b = {{4{1'b0}}, dphi_i};
        repeat(5) @(posedge clk);
        #10
        assert(bus_c[0] == 1'b0)
            else $error("CFG1 KO : dphi=-8 devrait donner decision=0");
        $display("CFG1 OK");

        //------------------------------
        // CFG2 : test phase_detector isolé
        // injecte decision_in et sample_clk via bus_b[9:8]
        //------------------------------
        $display("=== CFG2 : test phase_detector ===");
        cfg   = 2;
        bus_b = 10'b00_00000000;  // decision=0, sample_clk=0
        repeat(5) @(posedge clk);
        bus_b = 10'b10_00000000;  // decision=1, sample_clk=0 → transition
        repeat(2) @(posedge clk);
        bus_b = 10'b11_00000000;  // decision=1, sample_clk=1
        repeat(2) @(posedge clk);
        $display("CFG2 : up=%0b down=%0b (attendre up=1 si clock en retard)", w_up, w_down);

        //------------------------------
        // CFG3 : test loop_filter isolé
        // injecte u../top/wrappers/CDR_wrapper.svp/down/ack via bus_b[9:7]
        //------------------------------
        $display("=== CFG3 : test loop_filter ===");
        cfg   = 3;
        bus_b = 10'b000_0000000;   // up=0, down=0, ack=0
        repeat(5) @(posedge clk);
        bus_b = 10'b100_0000000;   // up=1
        repeat(2) @(posedge clk);
        bus_b = 10'b000_0000000;
        repeat(2) @(posedge clk);
        $display("CFG3 : ctrl=%0d (attendu +1)", $signed(w_ctrl));
        assert($signed(w_ctrl) == 1)
            else $error("CFG3 KO : ctrl devrait etre +1 apres up");
        bus_b = 10'b001_0000000;   // ack=1 → reset ctrl
        repeat(2) @(posedge clk);
        bus_b = 10'b000_0000000;
        repeat(2) @(posedge clk);
        $display("CFG3 : ctrl=%0d (attendu 0 apres ack)", $signed(w_ctrl));

        //------------------------------
        // CFG4 : test NCO isolé
        // injecte ctrl directement via bus_b[1:0]
        //------------------------------
        $display("=== CFG4 : test NCO ===");
        cfg   = 4;
        bus_b = 10'b00_00000000;   // ctrl=0 → période nominale
        repeat(50) @(posedge clk);
        $display("CFG4 : enable=%0b ack=%0b (ctrl=0, periode nominale)", w_nco_enable, w_nco_ack);
        bus_b[1:0] = 2'b01;        // ctrl=+1 → accélère
        repeat(50) @(posedge clk);
        $display("CFG4 : enable=%0b ack=%0b (ctrl=+1, acceleration)", w_nco_enable, w_nco_ack);

        //------------------------------
        // CFG0 : mode normal CDR
        // run 20ms et vérifie le comptage
        //------------------------------
        bus_b = {{4{1'b0}}, dphi_t};
        $display("=== CFG0 : mode normal CDR ===");
        cfg  = 0;
        bus_b = {{2{1'b0}}, dphi_t};
        #20000000;
        $display("Transmis=%0d  Reçus=%0d  Erreurs=%0d  TEB=%0f",
                  nb_data_t, nb_data, nb_err,
                  (nb_data > 0) ? real'(nb_err)/real'(nb_data) : 0.0);

        $stop;
    end

endmodule
