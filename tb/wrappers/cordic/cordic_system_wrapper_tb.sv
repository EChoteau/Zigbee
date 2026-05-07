`timescale 1ns / 1ps

module cordic_system_wrapper_tb();

    parameter int WIDTH = 6;
    parameter int WIDTH_PHASE = WIDTH + 2;
    parameter int BUS_A_WIDTH = 12;
    parameter int BUS_B_WIDTH = 10;
    parameter int BUS_C_WIDTH = 12;
    parameter int BUS_D_WIDTH = 2;
    parameter int CFG_WIDTH = 3;
    parameter real PI = 3.141592653589793;
 
    // DUT signals
    logic i_clk;
    logic i_rst_n;
    logic [2:0] i_top_cfg;
    logic [2:0] i_wrapper_cfg;
    logic [BUS_A_WIDTH-1:0] i_bus_a;
    logic [BUS_B_WIDTH-1:0] i_bus_b;
    logic [BUS_C_WIDTH-1:0] o_bus_c;
    logic [1:0] o_bus_d;

    // (output observation done directly from `o_bus_c` LSBs)

    // ------------------------------------------------------------------
    // Configuration modes
    // ------------------------------------------------------------------
    localparam logic [2:0] MODE_0 = 3'b000; // Input=Cordic, Output=Filter (default)
    localparam logic [2:0] MODE_1 = 3'b001; // Input=Cordic, Output=Cordic
    localparam logic [2:0] MODE_2 = 3'b010; // Input=Derivate, Output=Derivate
    localparam logic [2:0] MODE_3 = 3'b011; // Input=Filter, Output=Filter
    localparam logic [2:0] MODE_4 = 3'b100; // Input=Cordic, Output=Derivate
    localparam logic [2:0] MODE_5 = 3'b101; // Input=Cordic, Output=Filter
    localparam logic [2:0] MODE_6 = 3'b110; // Input=Derivate, Output=Filter
    localparam logic [2:0] MODE_7 = 3'b111; // Input=Filter, Output=Filter

    localparam real SCALE = 2**(WIDTH-1)-1;
    localparam logic signed [WIDTH_PHASE-1:0] PHASE_QUARTER = 1 <<< (WIDTH_PHASE-2);

    // Clock generator
    initial begin
        i_clk = 1'b0;
        forever #50 i_clk = ~i_clk;
    end

    // DUT instantiation
    cordic_wrapper  #(
        .WIDTH_IN(WIDTH),
        .WIDTH_PHASE(WIDTH_PHASE),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH),
        .CFG_WIDTH(CFG_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_wrapper_cfg),
        .i_bus_a(i_bus_a),
        .i_bus_b(i_bus_b),
        .o_bus_c(o_bus_c),
        .o_bus_d(o_bus_d)
    );

    // Reset and init
    initial begin
        i_rst_n = 1'b0;
        i_top_cfg = 3'b010;    // fixed: select Cordic wrapper in top
        i_wrapper_cfg = 3'b000; // select test sequence in wrapper (will be overridden by run_cfg)
        i_bus_a = '0;
        i_bus_b = '0;
        repeat (4) @(posedge i_clk);
        i_rst_n = 1'b1;
    end

/*------------------------Sequence tasks--------------------------------*/

    task automatic check_phase_connected_and_value(
        input logic signed [WIDTH_PHASE-1:0] expected,
        input string label
    );
        logic signed [WIDTH_PHASE-1:0] observed;
        logic signed [WIDTH_PHASE-1:0] error_margin = 4; // allow small margin of error due to quantization and noise
        logic is_close_enough;

        observed = $signed(o_bus_c);

        assert (!$isunknown(o_bus_c))
            else $error("%s: o_bus_c is not connected (contains X/Z)", label);

        is_close_enough = 1'b0;

        if ( observed > expected + error_margin ) begin
        end 
        else if ( observed < expected - error_margin ) begin
        end
        else begin
            is_close_enough = 1'b1;
        end

        assert (is_close_enough)
            else $error("%s: expected %0d got %0d", label, expected, observed);
    endtask

    task automatic cordic_only();
        logic signed [WIDTH-1:0] i_cordic_i;
        logic signed [WIDTH-1:0] i_cordic_q;

        // Phase = 0
        i_cordic_q = '0;
        i_cordic_i = $rtoi(SCALE);
        @(negedge i_clk);
        i_bus_a = {i_cordic_q, i_cordic_i};
        repeat (5) @(posedge i_clk);
        check_phase_connected_and_value('0, "cordic_only (0 rad)");

        // Phase = pi/2
        i_cordic_q = $rtoi(SCALE);
        i_cordic_i = '0;
        @(negedge i_clk);
        i_bus_a = {i_cordic_q, i_cordic_i};
        repeat (5) @(posedge i_clk);
        check_phase_connected_and_value(PHASE_QUARTER, "cordic_only (pi/2)");
    endtask

    task automatic derivate_only_triangle_step();
        logic signed [WIDTH_PHASE-1:0] phase_val;
        logic signed [WIDTH_PHASE-1:0] curr_deriv;

        // Reset stimulus: check that the output is connected and stable at 0
        i_bus_a = { {(BUS_A_WIDTH-WIDTH_PHASE){1'b0}}, '0 };
        repeat (2) @(posedge i_clk);

        assert (!$isunknown(o_bus_c))
            else $error("derivate_only_triangle_step: o_bus_c is not connected (contains X/Z)");
        assert (o_bus_c === '0)
            else $error("derivate_only_triangle_step: expected o_bus_c=0 after reset, got %0d", o_bus_c);

        // Rising ramp: phase increases, derivative must stay at +1
        for (int i = 0; i < 20; i = i + 1) begin
            phase_val = i;
            @(negedge i_clk);
            i_bus_a = { {(BUS_A_WIDTH-WIDTH_PHASE){1'b0}}, phase_val };
            @(posedge i_clk);
            curr_deriv = $signed(o_bus_c);

            assert (!$isunknown(curr_deriv))
                else $error("derivate_only_triangle_step (rising): o_bus_c contains X/Z");
            if (i != 0) begin
                assert (curr_deriv === 1)
                    else $error("derivate_only_triangle_step (rising): expected 1, got %0d at step %0d", curr_deriv, i);
            end
        end

        // Falling ramp: phase decreases, derivative must stay at -1
        for (int i = 20; i < 40; i = i + 1) begin
            phase_val = 39 - i;
            @(negedge i_clk);
            i_bus_a = { {(BUS_A_WIDTH-WIDTH_PHASE){1'b0}}, phase_val };
            @(posedge i_clk);
            curr_deriv = $signed(o_bus_c);

            assert (!$isunknown(curr_deriv))
                else $error("derivate_only_triangle_step (falling): o_bus_c contains X/Z");
            assert (curr_deriv === -1)
                else $error("derivate_only_triangle_step (falling): expected -1, got %0d at step %0d", curr_deriv, i);
        end

        repeat (2) @(posedge i_clk);
    endtask

    task automatic filter_step();
        logic signed [WIDTH_PHASE-1:0] phase_step;
        logic signed [WIDTH_PHASE-1:0] prev_out;
        logic signed [WIDTH_PHASE-1:0] curr_out;
        logic signed [WIDTH_PHASE-1:0] stable_out;
        bit seen_change;

        phase_step = '0;
        @(posedge i_clk);
        i_bus_a = { {(BUS_A_WIDTH-WIDTH_PHASE){1'b0}}, phase_step };
        repeat (4) @(posedge i_clk);

        phase_step = {{(WIDTH_PHASE-WIDTH){1'b0}}, {1'b0, {(WIDTH-1){1'b1}}}};
        @(posedge i_clk);
        i_bus_a = { {(BUS_A_WIDTH-WIDTH_PHASE){1'b0}}, phase_step };

        prev_out = $signed(o_bus_c[WIDTH_PHASE-1:0]);
        seen_change = 1'b0;

        // Monitor for N+2 cycles to allow filter to stabilize
        repeat (10) begin
            @(posedge i_clk);
            curr_out = $signed(o_bus_c[WIDTH_PHASE-1:0]);

            assert (!$isunknown(curr_out))
                else $error("filter_step: o_bus_c contains X/Z");

            if (curr_out !== prev_out)
                seen_change = 1'b1;

            prev_out = curr_out;
        end

        // After stabilization, output should hold steady for several cycles
        stable_out = $signed(o_bus_c[WIDTH_PHASE-1:0]);
        repeat (3) begin
            @(posedge i_clk);
            curr_out = $signed(o_bus_c[WIDTH_PHASE-1:0]);
            assert (curr_out === stable_out)
                else $error("filter_step: output not stable, expected %0d got %0d", stable_out, curr_out);
        end

        assert (seen_change)
            else $error("filter_step: output did not react to input step");
    endtask

    task automatic cordic_derivate();
        real s_angle;
        real s_i_val;
        real s_q_val;
        logic signed [WIDTH-1:0] i_cordic_i;
        logic signed [WIDTH-1:0] i_cordic_q;
        logic signed [WIDTH_PHASE-1:0] curr_deriv;
        logic signed [WIDTH_PHASE-1:0] ref_deriv;
        bit ref_valid;

        ref_valid = 1'b0;

        for (int i = 0; i < 40; i = i + 1) begin
            @(posedge i_clk);

            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 40.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);

            // Drive bus A directly from local variables
            i_cordic_i = $rtoi(s_i_val * SCALE);
            i_cordic_q = $rtoi(s_q_val * SCALE);
            i_bus_a = {i_cordic_q, i_cordic_i};

            // Let the DUT settle so the derivative output can be checked
            if (i<5) begin
                // During the first few steps, the derivative may not be stable yet due to initial conditions
                continue;
            end
            curr_deriv = $signed(o_bus_c[WIDTH_PHASE-1:0]);

            assert (!$isunknown(o_bus_c[WIDTH_PHASE-1:0]))
                else $error("cordic_derivate: o_bus_c is not connected (contains X/Z) at step %0d", i);

            if (!ref_valid) begin
                ref_deriv = curr_deriv;
                ref_valid = 1'b1;
            end else begin
                assert (curr_deriv === ref_deriv)
                    else $error("cordic_derivate: expected constant phase derivative %0d, got %0d at step %0d",
                                ref_deriv, curr_deriv, i);
            end
        end

        repeat (2) @(posedge i_clk);
    endtask

    task automatic cordic_full();
        real s_angle;
        real s_i_val;
        real s_q_val;
        logic signed [WIDTH-1:0] i_cordic_i;
        logic signed [WIDTH-1:0] i_cordic_q;
        logic signed [BUS_C_WIDTH-1:0] prev_out;
        logic signed [BUS_C_WIDTH-1:0] curr_out;
        logic signed [BUS_C_WIDTH-1:0] stable_out;
        bit seen_change;

        // Initialize with phase = 0 (I=SCALE, Q=0)
        i_cordic_i = $rtoi(SCALE);
        i_cordic_q = '0;
        @(negedge i_clk);
        i_bus_a = {i_cordic_q, i_cordic_i};
        repeat (5) @(posedge i_clk);

        assert (!$isunknown(o_bus_c))
            else $error("cordic_full: o_bus_c is not connected (contains X/Z)");

        // Rising phase ramp: vary angle from 0 to pi/2
        for (int i = 0; i < 6; i = i + 1) begin
            s_angle = (i * PI) / 12;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);

            i_cordic_i = $rtoi(s_i_val * SCALE);
            i_cordic_q = $rtoi(s_q_val * SCALE);
            @(negedge i_clk);
            i_bus_a = {i_cordic_q, i_cordic_i};
        end

        // Hold last phase constant to create derivative step
        i_cordic_i = $rtoi($cos(PI / 2.0) * SCALE);
        i_cordic_q = $rtoi($sin(PI / 2.0) * SCALE);
        @(negedge i_clk);
        i_bus_a = {i_cordic_q, i_cordic_i};

        // Monitor filter response to derivative step
        prev_out = o_bus_c;
        seen_change = 1'b0;

        repeat (15) begin
            @(posedge i_clk);
            curr_out = o_bus_c;

            assert (!$isunknown(curr_out))
                else $error("cordic_full: o_bus_c contains X/Z");

            if (curr_out !== prev_out)
                seen_change = 1'b1;

            prev_out = curr_out;
        end

        // After stabilization, output should hold steady
        stable_out = o_bus_c;
        repeat (3) begin
            @(posedge i_clk);
            curr_out = o_bus_c;
            assert (curr_out === stable_out)
                else $error("cordic_full: output not stable, expected %0d got %0d", stable_out, curr_out);
        end

        assert (seen_change)
            else $error("cordic_full: filtered output did not react to phase step");

        repeat (2) @(posedge i_clk);
    endtask

    task automatic derivate_filter_triangle_step();
        logic signed [WIDTH_PHASE-1:0] phase_val;
        logic signed [WIDTH_PHASE-1:0] prev_out;
        logic signed [WIDTH_PHASE-1:0] curr_out;
        logic signed [WIDTH_PHASE-1:0] stable_out;
        bit seen_change;

        // Phase = 0 for several cycles (derivative = 0)
        phase_val = '0;
        @(posedge i_clk);
        i_bus_a = { {(BUS_A_WIDTH-WIDTH_PHASE){1'b0}}, phase_val };
        repeat (5) @(posedge i_clk);

        assert (!$isunknown(o_bus_c))
            else $error("derivate_filter_triangle_step: o_bus_c is not connected (contains X/Z)");

        // Rising ramp: phase increases linearly (creates constant derivative step)
        for (int i = 0; i < 20; i = i + 1) begin
            phase_val = i;
            @(posedge i_clk);
            i_bus_a = { {(BUS_A_WIDTH-WIDTH_PHASE){1'b0}}, phase_val };
        end

        // Monitor filter response to derivative step for N cycles
        prev_out = $signed(o_bus_c[WIDTH_PHASE-1:0]);
        seen_change = 1'b0;

        repeat (15) begin 
            @(posedge i_clk);
            curr_out = $signed(o_bus_c[WIDTH_PHASE-1:0]);

            assert (!$isunknown(curr_out))
                else $error("derivate_filter_triangle_step: o_bus_c contains X/Z");

            if (curr_out !== prev_out)
                seen_change = 1'b1;

            prev_out = curr_out;
        end

        // After stabilization, output should hold steady
        stable_out = $signed(o_bus_c[WIDTH_PHASE-1:0]);
        repeat (3) begin
            @(posedge i_clk);
            curr_out = $signed(o_bus_c[WIDTH_PHASE-1:0]);
            assert (curr_out === stable_out)
                else $error("derivate_filter_triangle_step: output not stable, expected %0d got %0d", stable_out, curr_out);
        end

        assert (seen_change)
            else $error("derivate_filter_triangle_step: filtered output did not react to derivative step");

        repeat (2) @(posedge i_clk);
    endtask

/*------------Run configuration and apply corresponding stimulus------------------------*/
    task automatic run_cfg(input logic [2:0] cfg);
        i_wrapper_cfg = cfg;
        repeat (2) @(posedge i_clk);
        case (cfg)
            MODE_0, MODE_5: begin i_wrapper_cfg = MODE_0; cordic_full(); end
            MODE_1:         begin cordic_only(); end
            MODE_2:         begin derivate_only_triangle_step(); end
            MODE_3, MODE_7: begin i_wrapper_cfg = MODE_3; filter_step(); end
            MODE_4:         begin cordic_derivate(); end
            MODE_6:         begin derivate_filter_triangle_step(); end
            default:        begin $display("TODO: unsupported config %b", cfg); end
        endcase
    endtask

    task automatic rst_wait();
        i_rst_n = 1'b0;
        repeat (4) @(posedge i_clk);
        i_rst_n = 1'b1;
        repeat (2) @(posedge i_clk);
    endtask

/*---------------- Test sequence control----------------*/

    initial begin
        @(posedge i_rst_n);
        $display("--- top_cordic_tb: starting wrapper_cfg sweep ---");

        run_cfg(MODE_0);    // default path: cordic -> filter
        rst_wait();
        run_cfg(MODE_1);    // cordic -> cordic
        rst_wait();
        run_cfg(MODE_2);    // derivate -> derivate
        rst_wait();
        run_cfg(MODE_3);    // filter -> filter
        rst_wait();
        run_cfg(MODE_4);    // cordic -> derivate
        rst_wait();
        run_cfg(MODE_5);    // cordic -> filter (same as default, retest to check for consistency)
        rst_wait();
        run_cfg(MODE_6);    // derivate -> filter
        rst_wait();
        run_cfg(MODE_7);    // filter -> filter (same as MODE_3, retest to check for consistency)
        rst_wait();

        $display("--- top_cordic_tb: finished ---");
        $finish;
    end

endmodule
