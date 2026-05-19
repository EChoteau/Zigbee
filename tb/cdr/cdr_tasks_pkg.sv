// ==============================================================
// cdr_tasks_pkg.sv — Package de tasks pour tous les modules CDR
//
// Bus standardisé (identique pour tous les modules) :
//   i_bus_in  [BUS_IN_WIDTH-1:0]  = 22 bits
//   o_bus_out [BUS_OUT_WIDTH-1:0] = 14 bits
//   i_rst_n                       = signal indépendant
//
// Mapping i_bus_in [21:0] par module :
//   CDR TOP       : [7:0]  = i_dphi (signed 8 bits)
//   bascule       : [2:0]  = {i_en, i_rst, i_D}
//   decision      : [5:0]  = i_dphi_in (signed 6 bits)
//   loop_filter   : [2:0]  = {i_ctrl_ack, i_up, i_down}
//   nco           : [7:0]  = i_ctrl (signed 8 bits)
//   phase_detector: [1:0]  = {i_sample_clk, i_decision_in}
//
// Mapping o_bus_out [13:0] par module :
//   CDR TOP       : [1:0]  = {o_enable, o_data}
//   bascule       : [0]    = o_Q
//   decision      : [0]    = o_decision_out
//   loop_filter   : [7:0]  = o_ctrl (signed 8 bits)
//   nco           : [2:0]  = {o_recovered_clk, o_sample_enable, o_ctrl_ack}
//   phase_detector: [2:0]  = {o_decision_out, o_up, o_down}
// ==============================================================

package cdr_tasks_pkg;

    parameter int CFG_WIDTH     = 3;
    parameter int BUS_IN_WIDTH  = 22;
    parameter int BUS_OUT_WIDTH = 14;

    // ==========================================================
    // UTILITAIRES GÉNÉRAUX
    // ==========================================================

    task automatic wait_clk(
        ref   logic clk,
        input int   n
    );
        int i;
        for (i = 0; i < n; i++)
            @(posedge clk);
    endtask

    task automatic wait_cycles(
        ref   logic clk,
        input int   n
    );
        wait_clk(clk, n);
    endtask

    task automatic report_case(input string name);
        $display(" ");
        $display("============================================================");
        $display("CASE : %0s", name);
        $display("============================================================");
    endtask

    // ==========================================================
    // CDR TOP
    // i_bus_in[7:0]  = i_dphi (signed 8 bits)
    // o_bus_out[1:0] = {o_enable, o_data}
    // ==========================================================

    task automatic apply_reset(
        ref   logic                        i_rst_n,
        ref   logic [BUS_IN_WIDTH-1:0]     i_bus_in,
        input int                          duration_ns
    );
        i_rst_n  = 1'b1;
        #(duration_ns);
        i_rst_n          = 1'b0;
        i_bus_in[7:0]    = 8'sd0;
        #(duration_ns);
        i_rst_n  = 1'b1;
        $display("[RESET] Reset relâché à t=%0t", $time);
    endtask

    task automatic send_dphi(
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        input logic                    data_in
    );
        if (data_in) i_bus_in[7:0] =  ($random % 89);
        else         i_bus_in[7:0] = -($random % 89);
    endtask

    task automatic read_output(
        ref   logic [BUS_OUT_WIDTH-1:0] o_bus_out,
        ref   logic                     clk,
        output logic                    data_out,
        output logic                    clk_out
    );
        @(posedge clk);
        data_out = o_bus_out[0];   // o_data
        clk_out  = o_bus_out[1];   // o_enable
    endtask

    task automatic run_random_sequence(
        ref   logic [BUS_IN_WIDTH-1:0]  i_bus_in,
        ref   logic [BUS_OUT_WIDTH-1:0] o_bus_out,
        ref   logic                     clk,
        input int                       n_bits,
        output int                      errors
    );
        logic [2:0] same_count = 0;
        logic       data_bit   = 0;
        logic       data_bit_p = 0;
        logic       new_data;
        logic       cap_data, cap_clk;
        int         sent = 0;
        int         cnt  = 0;

        errors = 0;

        while (sent < n_bits) begin
            @(posedge clk);

            if (cnt == 2) begin
                new_data = $random;

                if (new_data == data_bit) same_count = same_count + 1;
                else                      same_count = 0;

                if (same_count >= 7) begin
                    data_bit   = ~data_bit;
                    same_count = 0;
                end else begin
                    data_bit = new_data;
                end

                data_bit_p = data_bit;
                sent       = sent + 1;
                send_dphi(i_bus_in, data_bit);
            end

            if (cnt == 4) cnt = 0;
            else          cnt = cnt + 1;
        end

        read_output(o_bus_out, clk, cap_data, cap_clk);
        if (cap_data !== data_bit_p) begin
            errors = errors + 1;
            $display("[ERR] decision=%0b attendu=%0b", cap_data, data_bit_p);
        end
    endtask

    // ==========================================================
    // BASCULE
    // i_bus_in[2:0] = {i_en, i_rst, i_D}
    // o_bus_out[0]  = o_Q
    // ==========================================================

    task automatic bascule_reset(
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref   logic                    clk,
        input int                      n_cycles
    );
        i_bus_in[1] = 1'b0;   // i_rst actif bas
        wait_clk(clk, n_cycles);
        i_bus_in[1] = 1'b1;   // release
        $display("[BASCULE] Reset relâché à t=%0t", $time);
    endtask

    task automatic bascule_send(
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref   logic                    clk,
        input logic                    d_val,
        input logic                    en_val
    );
        @(negedge clk);
        i_bus_in[0] = d_val;    // i_D
        i_bus_in[2] = en_val;   // i_en
    endtask

    task automatic bascule_check(
        input logic  q_out,
        input logic  expected,
        input string ctx
    );
        assert (q_out === expected)
            else $error("[BASCULE][%s] o_Q=%0b attendu=%0b à t=%0t",
                        ctx, q_out, expected, $time);
    endtask

    // ==========================================================
    // DECISION BLOCK
    // i_bus_in[5:0] = i_dphi_in (signed 6 bits)
    // o_bus_out[0]  = o_decision_out
    // ==========================================================

    task automatic decision_apply(
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        input logic signed [5:0]       dphi
    );
        i_bus_in[5:0] = dphi;
        #2;
    endtask

    task automatic decision_check(
        input logic  out_val,
        input logic  expected,
        input string ctx
    );
        assert (out_val === expected)
            else $error("[DECISION][%s] out=%0b attendu=%0b à t=%0t",
                        ctx, out_val, expected, $time);
    endtask

    // ==========================================================
    // LOOP FILTER
    // i_bus_in[2:0]  = {i_ctrl_ack, i_up, i_down}
    // o_bus_out[7:0] = o_ctrl (signed 8 bits)
    // ==========================================================

    task automatic lf_reset(
        ref   logic                    i_rst_n,
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref   logic                    clk,
        input int                      n_cycles
    );
        i_rst_n     = 1'b0;
        i_bus_in[2:0] = 3'b000;
        wait_clk(clk, n_cycles);
        @(negedge clk);
        i_rst_n = 1'b1;
        $display("[LF] Reset relâché à t=%0t", $time);
    endtask

    task automatic lf_send_up(
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref   logic                    clk
    );
        @(negedge clk); i_bus_in[2:0] = 3'b010;   // up=1
        wait_clk(clk, 1);
        @(negedge clk); i_bus_in[2:0] = 3'b000;
    endtask

    task automatic lf_send_down(
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref   logic                    clk
    );
        @(negedge clk); i_bus_in[2:0] = 3'b001;   // down=1
        wait_clk(clk, 1);
        @(negedge clk); i_bus_in[2:0] = 3'b000;
    endtask

    task automatic lf_send_ack(
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref   logic                    clk
    );
        @(negedge clk); i_bus_in[2:0] = 3'b100;   // ctrl_ack=1
        wait_clk(clk, 1);
        @(negedge clk); i_bus_in[2:0] = 3'b000;
    endtask

    task automatic lf_check(
        input logic signed [7:0] out_val,
        input logic signed [7:0] expected,
        input string             ctx
    );
        assert (out_val === expected)
            else $error("[LF][%s] o_ctrl=%0d attendu=%0d à t=%0t",
                        ctx, out_val, expected, $time);
    endtask

    // ==========================================================
    // NCO
    // i_bus_in[7:0]  = i_ctrl (signed 8 bits)
    // o_bus_out[2:0] = {o_recovered_clk, o_sample_enable, o_ctrl_ack}
    // ==========================================================

    task automatic nco_reset(
        ref   logic i_rst_n,
        ref   logic clk,
        input int   n_cycles
    );
        i_rst_n = 1'b0;
        wait_clk(clk, n_cycles);
        @(negedge clk);
        i_rst_n = 1'b1;
        $display("[NCO] Reset relâché à t=%0t", $time);
    endtask

    task automatic nco_set_ctrl(
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        input logic signed [7:0]       ctrl_val
    );
        i_bus_in[7:0] = ctrl_val;
    endtask

    task automatic nco_count_pulses(
        ref   logic [BUS_OUT_WIDTH-1:0] o_bus_out,
        ref   logic                     clk,
        input int                       n_clk,
        output int                      count
    );
        count = 0;
        for (int i = 0; i < n_clk; i++) begin
            @(posedge clk);
            if (o_bus_out[1]) count++;   // o_sample_enable
        end
    endtask

    task automatic nco_check_no_xz(
        input logic [BUS_OUT_WIDTH-1:0] o_bus_out,
        input string                    ctx
    );
        assert (!$isunknown(o_bus_out[2:0]))
            else $error("[NCO][%s] Sortie X/Z : %03b à t=%0t",
                        ctx, o_bus_out[2:0], $time);
    endtask

    // ==========================================================
    // PHASE DETECTOR
    // i_bus_in[1:0]  = {i_sample_clk, i_decision_in}
    // o_bus_out[2:0] = {o_decision_out, o_up, o_down}
    // ==========================================================

    task automatic pd_reset(
        ref   logic                    i_rst_n,
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref   logic                    clk,
        input int                      n_cycles
    );
        i_rst_n     = 1'b0;
        i_bus_in[1:0] = 2'b00;
        wait_clk(clk, n_cycles);
        @(negedge clk);
        i_rst_n = 1'b1;
        $display("[PD] Reset relâché à t=%0t", $time);
    endtask

    task automatic pd_send(
        ref   logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref   logic                    clk,
        input logic                    decision
    );
        @(negedge clk);
        i_bus_in[0] = decision;   // i_decision_in
        i_bus_in[1] = 1'b1;       // i_sample_clk
        wait_clk(clk, 1);
        @(negedge clk);
        i_bus_in[1] = 1'b0;
    endtask

    task automatic pd_check_no_conflict(
        input logic [BUS_OUT_WIDTH-1:0] o_bus_out,
        input string                    ctx
    );
        assert (!(o_bus_out[1] & o_bus_out[0]))
            else $error("[PD][%s] UP et DOWN actifs en même temps à t=%0t", ctx, $time);
    endtask

    task automatic pd_check_up(
        input logic [BUS_OUT_WIDTH-1:0] o_bus_out,
        input string                    ctx
    );
        assert (o_bus_out[1] === 1'b1)
            else $error("[PD][%s] UP attendu mais non actif à t=%0t", ctx, $time);
    endtask

    task automatic pd_check_down(
        input logic [BUS_OUT_WIDTH-1:0] o_bus_out,
        input string                    ctx
    );
        assert (o_bus_out[0] === 1'b1)
            else $error("[PD][%s] DOWN attendu mais non actif à t=%0t", ctx, $time);
    endtask

endpackage
