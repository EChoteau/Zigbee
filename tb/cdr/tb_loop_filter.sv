// ==============================================================
// tb_loop_filter.sv
// i_bus_in[2:0]  = {i_ctrl_ack, i_up, i_down}
// o_bus_out[7:0] = o_ctrl (signed 8 bits)
// ==============================================================
`timescale 1ns/1ps

import cdr_tasks_pkg::*;

module tb_loop_filter;

    logic clk   = 0;
    logic i_rst_n;
    always #10 clk = ~clk;

    logic [21:0] i_bus_in;
    logic [13:0] o_bus_out;

    loop_filter #(.WIDTH(8)) dut (
        .i_clk     (clk),
        .i_rst_n   (i_rst_n),
        .i_ctrl_ack(i_bus_in[2]),
        .i_up      (i_bus_in[1]),
        .i_down    (i_bus_in[0]),
        .o_ctrl    (o_bus_out)
    );

    // Pendant reset -> o_ctrl = 0
    always @(posedge clk)
        if (!i_rst_n)
            assert (o_bus_out === 8'sd0)
                else $error("[LF] o_ctrl non nul pendant reset t=%0t val=%0d",
                            $time, o_bus_out);

    // Pas de X/Z
    always @(posedge clk)
        if (i_rst_n)
            assert (!$isunknown(o_bus_out))
                else $error("[LF] o_ctrl = X/Z à t=%0t", $time);

    // up et down pas simultanément
    always @(posedge clk)
        if (i_rst_n)
            assert (!(i_bus_in[1] & i_bus_in[0]))
                else $error("[LF] UP et DOWN actifs en meme temps t=%0t", $time);

    initial begin

        // Reset
        report_case("RESET");
        lf_reset(i_rst_n, i_bus_in, clk, 4);
        wait_clk(clk, 2);
        lf_check(o_bus_out, 8'sd0, "APRES RESET");

        // Impulsion UP -> o_ctrl = +1
        report_case("IMPULSION UP -> o_ctrl = +1");
        lf_send_up(i_bus_in, clk);
        wait_clk(clk, 2);
        lf_check(o_bus_out, 8'sd1, "APRES UP");

        // ACK -> o_ctrl = 0
        report_case("ACK -> o_ctrl = 0");
        lf_send_ack(i_bus_in, clk);
        wait_clk(clk, 2);
        lf_check(o_bus_out, 8'sd0, "APRES ACK");

        // Impulsion DOWN -> o_ctrl = -1
        report_case("IMPULSION DOWN -> o_ctrl = -1");
        lf_send_down(i_bus_in, clk);
        wait_clk(clk, 2);
        lf_check(o_bus_out, -8'sd1, "APRES DOWN");

        // ACK -> remise à 0
        lf_send_ack(i_bus_in, clk);
        wait_clk(clk, 2);
        lf_check(o_bus_out, 8'sd0, "APRES ACK 2");

        // Double UP sans ACK -> valeur tenue
        report_case("DOUBLE UP SANS ACK -> VALEUR TENUE");
        lf_send_up(i_bus_in, clk);
        wait_clk(clk, 2);
        lf_send_up(i_bus_in, clk);  // 2ème front -> pas d'effet (pas d'edge)
        wait_clk(clk, 2);
        lf_check(o_bus_out, 8'sd1, "VALEUR TENUE A +1");

        // ACK remet à 0
        lf_send_ack(i_bus_in, clk);
        wait_clk(clk, 2);

        // Séquence UP/DOWN alternée
        report_case("SEQUENCE UP/DOWN ALTERNEE");
        for (int i = 0; i < 5; i++) begin
            lf_send_up(i_bus_in, clk);
            wait_clk(clk, 1);
            lf_check(o_bus_out, 8'sd1, $sformatf("UP iter=%0d", i));
            lf_send_ack(i_bus_in, clk);
            wait_clk(clk, 1);
            lf_send_down(i_bus_in, clk);
            wait_clk(clk, 1);
            lf_check(o_bus_out, -8'sd1, $sformatf("DOWN iter=%0d", i));
            lf_send_ack(i_bus_in, clk);
            wait_clk(clk, 1);
        end

        // Reset en cours de fonctionnement
        report_case("RESET EN COURS");
        lf_send_up(i_bus_in, clk);
        wait_clk(clk, 2);
        lf_reset(i_rst_n, i_bus_in, clk, 2);
        lf_check(o_bus_out, 8'sd0, "RESET FORCE 0");

        $display("============================================================");
        $display("TB LOOP FILTER : PASS");
        $display("============================================================");
        $finish;
    end

endmodule
