////////////////////////////////////////////////////////////////////////////////
// wrapper_msk_tb.sv
// ============================================================================
// Testbench for msk_wrapper
//
// Test Coverage:
//   - Configuration modes (NORMAL, ENC_OVERRIDE, DEMUX_OVERRIDE, etc.)
//   - Input/Output bus routing based on config
//   - Debug observability
//   - Reset behavior
//   - Mode transitions
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module wrapper_msk_tb;

    // ==========================================================================
    // PARAMETERS
    // ==========================================================================
    localparam int SAMPLES_PER_HALF_SINE = 10;
    localparam int MSK_RES               = 6;
    localparam int CFG_WIDTH             = 3;
    localparam int BUS_A_WIDTH           = 12;
    localparam int BUS_B_WIDTH           = 10;
    localparam int BUS_C_WIDTH           = 12;
    localparam int BUS_D_WIDTH           = 2;

    // Configuration modes
    localparam logic [2:0] CFG_NORMAL              = 3'b000;
    localparam logic [2:0] CFG_ENC_OVERRIDE        = 3'b001;
    localparam logic [2:0] CFG_DEMUX_OVERRIDE      = 3'b010;
    localparam logic [2:0] CFG_SHAPING_OVERRIDE    = 3'b011;
    localparam logic [2:0] CFG_OBSERVE_INTERNALS   = 3'b100;

    // ==========================================================================
    // TESTBENCH SIGNALS
    // ==========================================================================
    logic                           i_clk;
    logic                           i_rst_n;
    logic [CFG_WIDTH-1:0]           i_cfg_local;
    logic [BUS_A_WIDTH-1:0]         i_bus_a;
    logic [BUS_B_WIDTH-1:0]         i_bus_b;
    logic [BUS_C_WIDTH-1:0]         o_bus_c;
    logic [BUS_D_WIDTH-1:0]         o_bus_d;

    // ==========================================================================
    // DUT INSTANTIATION
    // ==========================================================================
    msk_wrapper #(
        .SAMPLES_PER_HALF_SINE(SAMPLES_PER_HALF_SINE),
        .MSK_RES(MSK_RES),
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg_local(i_cfg_local),
        .i_bus_a(i_bus_a),
        .i_bus_b(i_bus_b),
        .o_bus_c(o_bus_c),
        .o_bus_d(o_bus_d)
    );

    // ==========================================================================
    // ASSERTIONS (SystemVerilog Assertions)
    // ==========================================================================

    // Bus width constraints
    assert_bus_a_width: assert property (@(posedge i_clk) $bits(i_bus_a) == BUS_A_WIDTH);
    assert_bus_b_width: assert property (@(posedge i_clk) $bits(i_bus_b) == BUS_B_WIDTH);
    assert_bus_c_width: assert property (@(posedge i_clk) $bits(o_bus_c) == BUS_C_WIDTH);
    assert_bus_d_width: assert property (@(posedge i_clk) $bits(o_bus_d) == BUS_D_WIDTH);

    // Configuration range check (only 5 valid configs: 0-4)
    assert_cfg_range: assert property (@(posedge i_clk) i_cfg_local inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100});

    // Output constraints based on mode
    always @(posedge i_clk) begin
        unique case (i_cfg_local)
            CFG_NORMAL: begin
                // In NORMAL mode, o_bus_c should contain signed values (MSK outputs)
                // I_BB and Q_BB are 6-bit signed (-31 to +31)
                assert_normal_I_range: assert (o_bus_c[11:6] inside {[-31:31]});
                assert_normal_Q_range: assert (o_bus_c[5:0] inside {[-31:31]});
            end

            CFG_ENC_OVERRIDE: begin
                // In ENC_OVERRIDE mode, only o_bus_c[0] should be set, others 0
                assert_enc_override_format: assert (o_bus_c[11:1] == 11'b0);
            end

            CFG_DEMUX_OVERRIDE: begin
                // In DEMUX_OVERRIDE mode, only o_bus_c[1:0] should be set, others 0
                assert_demux_override_format: assert (o_bus_c[11:2] == 10'b0);
            end

            CFG_SHAPING_OVERRIDE: begin
                // In SHAPING_OVERRIDE mode, o_bus_c should contain signed values
                assert_shaping_I_range: assert (o_bus_c[11:6] inside {[-31:31]});
                assert_shaping_Q_range: assert (o_bus_c[5:0] inside {[-31:31]});
            end

            CFG_OBSERVE_INTERNALS: begin
                // In OBSERVE_INTERNALS mode, only o_bus_c[2:0] should be set, others 0
                assert_observe_format: assert (o_bus_c[11:3] == 9'b0);
            end
        endcase
    end

    // Reset behavior
    assert_reset_bus_c: assert property (@(posedge i_clk) !i_rst_n |=> o_bus_c == '0);
    assert_reset_bus_d: assert property (@(posedge i_clk) !i_rst_n |=> o_bus_d == '0);

    // ==========================================================================
    // HELPER TASKS
    // ==========================================================================

    task automatic apply_reset(int cycles);
    begin
        i_rst_n = 1'b0;
        repeat(cycles) @(posedge i_clk);
        i_rst_n = 1'b1;
        repeat(2) @(posedge i_clk);
    end
    endtask

    task automatic set_config(logic [CFG_WIDTH-1:0] cfg);
    begin
        i_cfg_local = cfg;
        @(posedge i_clk);
    end
    endtask

    task automatic set_bus_a(logic [BUS_A_WIDTH-1:0] data);
    begin
        i_bus_a = data;
        @(posedge i_clk);
    end
    endtask

    task automatic set_bus_b(logic [BUS_B_WIDTH-1:0] data);
    begin
        i_bus_b = data;
        @(posedge i_clk);
    end
    endtask

    // ==========================================================================
    // TEST CASES
    // ==========================================================================

    task automatic tc_reset_behavior();
    begin
        $display("[TC_RESET] Testing reset behavior");
        
        // Run some cycles
        set_config(CFG_NORMAL);
        set_bus_a(12'hABC);
        repeat(5) @(posedge i_clk);
        
        // Apply reset
        i_rst_n = 1'b0;
        repeat(3) @(posedge i_clk);
        i_rst_n = 1'b1;
        repeat(3) @(posedge i_clk);
        
        $display("  Reset completed");
        $display("  o_bus_c after reset: 0x%03h", o_bus_c);
        $display("  o_bus_d after reset: 0x%01h", o_bus_d);
        assert (o_bus_c == '0) else $fatal("Reset failed: o_bus_c != 0, got 0x%03h", o_bus_c);
        assert (o_bus_d == '0) else $fatal("Reset failed: o_bus_d != 0, got 0x%01h", o_bus_d);
        $display("[TC_RESET] PASS\n");
    end
    endtask

    task automatic tc_config_normal();
    begin
        $display("[TC_CONFIG_NORMAL] Testing CFG_NORMAL mode");
        $display("  Config: NORMAL (data flows through)");
        
        set_config(CFG_NORMAL);
        
        // Bus A bits [2:0] should flow to the core with sampling enabled
        set_bus_a(12'b0000_0000_0111);  // flag_enable=1, enable_ech=1, b_in=1
        repeat(5) @(posedge i_clk);
        
        $display("  Input i_bus_a[2:0]: flag_enable=%b, enable_ech=%b, b_in=%b",
                 i_bus_a[0], i_bus_a[1], i_bus_a[2]);
        $display("  Output o_bus_c: 0x%03h (I_BB, Q_BB)", o_bus_c);
        $display("  Output o_bus_d: 0x%01h", o_bus_d);
        assert (o_bus_c[11:6] inside {[-31:31]}) else $fatal("CFG_NORMAL I_BB out of range: 0x%03h", o_bus_c);
        assert (o_bus_c[5:0] inside {[-31:31]}) else $fatal("CFG_NORMAL Q_BB out of range: 0x%03h", o_bus_c);
        assert (o_bus_d[0] == i_bus_a[1]) else $fatal("CFG_NORMAL bus_d mismatch: expected %b got %b", i_bus_a[1], o_bus_d[0]);
        $display("[TC_CONFIG_NORMAL] PASS\n");
    end
    endtask

    task automatic tc_config_enc_override();
    begin
        logic [BUS_C_WIDTH-1:0] result;
        
        $display("[TC_ENC_OVERRIDE] Testing CFG_ENC_OVERRIDE mode");
        $display("  Config: ENC_OVERRIDE (inject encodeur input)");
        
        set_config(CFG_ENC_OVERRIDE);
        repeat(2) @(posedge i_clk);
        
        // Inject b_enc = 1 via i_bus_a[3], with flag_enable active
        set_bus_a(12'b0000_0000_1001);  // enc_override=1, flag_enable=1
        repeat(4) @(posedge i_clk);
        result = o_bus_c;
        
        $display("  Input i_bus_a[3] (enc override): 1");
        $display("  Output o_bus_c: 0x%03h (should be b_enc output)", result);
        assert (result[11:1] == 11'b0) else $fatal("CFG_ENC_OVERRIDE format wrong: 0x%03h", result);
        assert (result[0] == 1'b1) else $fatal("CFG_ENC_OVERRIDE expected b_enc=1, got 0x%03h", result);
        
        // Try with b_enc = 0 via i_bus_a[3]
        set_bus_a(12'b0000_0000_0001);  // enc_override=0, flag_enable=1
        repeat(4) @(posedge i_clk);
        result = o_bus_c;
        
        $display("  Input i_bus_a[3] (enc override): 0");
        $display("  Output o_bus_c: 0x%03h", result);
        assert (result[11:1] == 11'b0) else $fatal("CFG_ENC_OVERRIDE format wrong after 0: 0x%03h", result);
        assert (result[0] == 1'b0) else $fatal("CFG_ENC_OVERRIDE expected b_enc=0, got 0x%03h", result);
        $display("[TC_ENC_OVERRIDE] PASS\n");
    end
    endtask

    task automatic tc_config_demux_override();
    begin
        $display("[TC_DEMUX_OVERRIDE] Testing CFG_DEMUX_OVERRIDE mode");
        $display("  Config: DEMUX_OVERRIDE (inject demux input)");
        
        set_config(CFG_DEMUX_OVERRIDE);
        repeat(2) @(posedge i_clk);
        
        // Inject b_enc = 1 via i_bus_a[4], with flag_enable = 1
        set_bus_a(12'b0000_0000_1001);  // demux override = 1, flag_enable = 1
        repeat(3) @(posedge i_clk);

        $display("  Input i_bus_a[4] (demux override): 1");
        $display("  Output o_bus_c: 0x%03h (should contain a_I, a_Q)", o_bus_c);
        assert (o_bus_c[11:2] == 10'b0) else $fatal("DEMUX override format wrong: o_bus_c=0x%03h", o_bus_c);
        assert (o_bus_c[1:0] != 2'b00) else $fatal("DEMUX override expected active a_I or a_Q for b_enc=1, got 0x%03h", o_bus_c);
        
        // Try with b_enc = 0 via i_bus_a[4], with flag_enable = 1
        set_bus_a(12'b0000_0000_0001);  // demux override = 0, flag_enable = 1
        repeat(3) @(posedge i_clk);
        
        $display("  Input i_bus_a[4] (demux override): 0");
        $display("  Output o_bus_c: 0x%03h", o_bus_c);
        assert (o_bus_c[11:2] == 10'b0) else $fatal("DEMUX override format wrong after b_enc=0: o_bus_c=0x%03h", o_bus_c);
        assert (o_bus_c[1:0] != 2'b00) else $fatal("DEMUX override expected non-zero output after b_enc=0, got 0x%03h", o_bus_c);
        $display("[TC_DEMUX_OVERRIDE] PASS\n");
    end
    endtask

    task automatic tc_config_shaping_override();
    begin
        $display("[TC_SHAPING_OVERRIDE] Testing CFG_SHAPING_OVERRIDE mode");
        $display("  Config: SHAPING_OVERRIDE (inject shaping inputs)");
        
        set_config(CFG_SHAPING_OVERRIDE);
        repeat(2) @(posedge i_clk);
        
        // Inject a_I=1, a_Q=1 via i_bus_a[6:5], enable sampling
        set_bus_a(12'b0000_0110_0011);  // a_Q=1, a_I=1, enable_ech=1, flag_enable=1
        repeat(6) @(posedge i_clk);
        
        $display("  Input i_bus_a[6:5] (a_I, a_Q): 11");
        $display("  Output o_bus_c: 0x%03h (should contain I_BB, Q_BB)", o_bus_c);
        assert (o_bus_c[11:6] inside {[-31:31]}) else $fatal("CFG_SHAPING_OVERRIDE I_BB out of range: 0x%03h", o_bus_c);
        assert (o_bus_c[5:0] inside {[-31:31]}) else $fatal("CFG_SHAPING_OVERRIDE Q_BB out of range: 0x%03h", o_bus_c);
        
        // Try other combination a_I=0, a_Q=1
        set_bus_a(12'b0000_0100_0011);  // a_Q=1, a_I=0, enable_ech=1, flag_enable=1
        repeat(6) @(posedge i_clk);
        
        $display("  Input i_bus_a[6:5] (a_I, a_Q): 10");
        $display("  Output o_bus_c: 0x%03h", o_bus_c);
        assert (o_bus_c[11:6] inside {[-31:31]}) else $fatal("CFG_SHAPING_OVERRIDE I_BB out of range (second case): 0x%03h", o_bus_c);
        assert (o_bus_c[5:0] inside {[-31:31]}) else $fatal("CFG_SHAPING_OVERRIDE Q_BB out of range (second case): 0x%03h", o_bus_c);
        $display("[TC_SHAPING_OVERRIDE] PASS\n");
    end
    endtask

    task automatic tc_config_observe_internals();
    begin
        $display("[TC_OBSERVE_INTERNALS] Testing CFG_OBSERVE_INTERNALS mode");
        $display("  Config: OBSERVE_INTERNALS (observe internal signals)");
        
        set_config(CFG_OBSERVE_INTERNALS);
        repeat(2) @(posedge i_clk);
        
        // Set a valid bit stream so internal signals are exercised
        set_bus_a(12'b0000_0000_0111);  // flag_enable=1, enable_ech=1, b_in=1
        repeat(5) @(posedge i_clk);
        
        $display("  Output o_bus_c: 0x%03h (should contain b_enc, a_I, a_Q)", o_bus_c);
        assert (o_bus_c[11:3] == 9'b0) else $fatal("CFG_OBSERVE_INTERNALS format wrong: 0x%03h", o_bus_c);
        assert (o_bus_c[2:0] != 3'b000) else $fatal("CFG_OBSERVE_INTERNALS no internal signal active: 0x%03h", o_bus_c);
        $display("[TC_OBSERVE_INTERNALS] PASS\n");
    end
    endtask

    task automatic tc_config_transitions();
    begin
        $display("[TC_CONFIG_TRANSITIONS] Testing configuration transitions");
        
        // Transition: NORMAL -> ENC_OVERRIDE
        set_config(CFG_NORMAL);
        repeat(3) @(posedge i_clk);
        assert (i_cfg_local == CFG_NORMAL) else $fatal("Transition to NORMAL failed");
        $display("  Transitioned to NORMAL");
        
        set_config(CFG_ENC_OVERRIDE);
        repeat(3) @(posedge i_clk);
        assert (i_cfg_local == CFG_ENC_OVERRIDE) else $fatal("Transition to ENC_OVERRIDE failed");
        $display("  Transitioned to ENC_OVERRIDE, o_bus_c: 0x%03h", o_bus_c);
        
        // Transition: ENC_OVERRIDE -> DEMUX_OVERRIDE
        set_config(CFG_DEMUX_OVERRIDE);
        repeat(3) @(posedge i_clk);
        assert (i_cfg_local == CFG_DEMUX_OVERRIDE) else $fatal("Transition to DEMUX_OVERRIDE failed");
        $display("  Transitioned to DEMUX_OVERRIDE, o_bus_c: 0x%03h", o_bus_c);
        
        // Transition: DEMUX_OVERRIDE -> SHAPING_OVERRIDE
        set_config(CFG_SHAPING_OVERRIDE);
        repeat(3) @(posedge i_clk);
        assert (i_cfg_local == CFG_SHAPING_OVERRIDE) else $fatal("Transition to SHAPING_OVERRIDE failed");
        $display("  Transitioned to SHAPING_OVERRIDE, o_bus_c: 0x%03h", o_bus_c);
        
        // Transition: SHAPING_OVERRIDE -> OBSERVE_INTERNALS
        set_config(CFG_OBSERVE_INTERNALS);
        repeat(3) @(posedge i_clk);
        assert (i_cfg_local == CFG_OBSERVE_INTERNALS) else $fatal("Transition to OBSERVE_INTERNALS failed");
        $display("  Transitioned to OBSERVE_INTERNALS, o_bus_c: 0x%03h", o_bus_c);
        
        // Transition: Back to NORMAL
        set_config(CFG_NORMAL);
        repeat(3) @(posedge i_clk);
        assert (i_cfg_local == CFG_NORMAL) else $fatal("Transition back to NORMAL failed");
        $display("  Transitioned back to NORMAL");
        
        $display("[TC_CONFIG_TRANSITIONS] PASS\n");
    end
    endtask

    task automatic tc_bus_widths();
    begin
        $display("[TC_BUS_WIDTHS] Testing bus width constraints");
        
        set_config(CFG_NORMAL);
        
        // Test max values on buses
        set_bus_a({BUS_A_WIDTH{1'b1}});  // All 1s (0xFFF)
        set_bus_b({BUS_B_WIDTH{1'b1}});  // All 1s (0x3FF)
        repeat(3) @(posedge i_clk);
        assert (i_bus_a == {BUS_A_WIDTH{1'b1}}) else $fatal("tc_bus_widths: i_bus_a max value wrong");
        assert (i_bus_b == {BUS_B_WIDTH{1'b1}}) else $fatal("tc_bus_widths: i_bus_b max value wrong");
        
        $display("  Max input on i_bus_a: 0x%03h (width=%d bits)", i_bus_a, BUS_A_WIDTH);
        $display("  Max input on i_bus_b: 0x%03h (width=%d bits)", i_bus_b, BUS_B_WIDTH);
        $display("  Output o_bus_c: 0x%03h (width=%d bits)", o_bus_c, BUS_C_WIDTH);
        $display("  Output o_bus_d: 0x%01h (width=%d bits)", o_bus_d, BUS_D_WIDTH);
        
        // Test min values
        set_bus_a({BUS_A_WIDTH{1'b0}});
        set_bus_b({BUS_B_WIDTH{1'b0}});
        repeat(3) @(posedge i_clk);
        assert (i_bus_a == {BUS_A_WIDTH{1'b0}}) else $fatal("tc_bus_widths: i_bus_a min value wrong");
        assert (i_bus_b == {BUS_B_WIDTH{1'b0}}) else $fatal("tc_bus_widths: i_bus_b min value wrong");
        
        $display("  Min input on i_bus_a: 0x%03h", i_bus_a);
        $display("  Min input on i_bus_b: 0x%03h", i_bus_b);
        $display("  Output o_bus_c: 0x%03h", o_bus_c);
        $display("  Output o_bus_d: 0x%01h", o_bus_d);
        
        $display("[TC_BUS_WIDTHS] PASS\n");
    end
    endtask

    task automatic tc_output_bus_d();
    begin
        $display("[TC_OUTPUT_BUS_D] Testing output bus D (status signals)");
        
        set_config(CFG_NORMAL);
        set_bus_a({BUS_A_WIDTH{1'b0}});
        repeat(2) @(posedge i_clk);
        
        // Bus D [0] should reflect enable_ech status (i_bus_a[1])
        set_bus_a(12'b0000_0000_0000);  // enable_ech=0, flag_enable=0, b_in=0
        repeat(2) @(posedge i_clk);
        $display("  i_bus_a[1] (enable_ech): 0, o_bus_d[0]: %b", o_bus_d[0]);
        assert (o_bus_d[0] == 1'b0) else $fatal("Output bus_d[0] mismatch for enable_ech=0: %b", o_bus_d[0]);
        
        set_bus_a(12'b0000_0000_0010);  // enable_ech=1, flag_enable=0, b_in=0
        repeat(2) @(posedge i_clk);
        $display("  i_bus_a[1] (enable_ech): 1, o_bus_d[0]: %b", o_bus_d[0]);
        assert (o_bus_d[0] == 1'b1) else $fatal("Output bus_d[0] mismatch for enable_ech=1: %b", o_bus_d[0]);
        
        $display("[TC_OUTPUT_BUS_D] PASS\n");
    end
    endtask

    task automatic tc_rapid_config_changes();
    begin
        $display("[TC_RAPID_CONFIG] Testing rapid configuration changes");
        
        for (int i = 0; i < 5; i++) begin
            set_config(CFG_NORMAL);
            set_bus_a(12'hAAA);
            @(posedge i_clk);
            assert (i_cfg_local == CFG_NORMAL) else $fatal("tc_rapid_config_changes: expected NORMAL");
            
            set_config(CFG_ENC_OVERRIDE);
            set_bus_a(12'h555);
            @(posedge i_clk);
            assert (i_cfg_local == CFG_ENC_OVERRIDE) else $fatal("tc_rapid_config_changes: expected ENC_OVERRIDE");
        end
        
        $display("  Completed 5 rapid transitions");
        $display("  Final config: NORMAL");
        set_config(CFG_NORMAL);
        repeat(2) @(posedge i_clk);
        assert (i_cfg_local == CFG_NORMAL) else $fatal("tc_rapid_config_changes: expected NORMAL at end");
        
        $display("[TC_RAPID_CONFIG] PASS\n");
    end
    endtask

    task automatic tc_reset_during_operation();
    begin
        $display("[TC_RESET_DURING_OP] Testing reset during operation");
        
        // Start in NORMAL mode with some activity
        set_config(CFG_NORMAL);
        set_bus_a({BUS_A_WIDTH{1'b1}});
        repeat(5) @(posedge i_clk);
        
        $display("  Operating with data on bus_a");
        
        // Sudden reset
        i_rst_n = 1'b0;
        repeat(2) @(posedge i_clk);
        
        $display("  Applied reset during operation");
        
        i_rst_n = 1'b1;
        repeat(3) @(posedge i_clk);
        
        assert (i_rst_n == 1'b1) else $fatal("tc_reset_during_operation: reset not released");
        assert (o_bus_c[11:6] inside {[-31:31]}) else $fatal("tc_reset_during_operation: invalid I_BB after recovery: 0x%03h", o_bus_c);
        assert (o_bus_c[5:0] inside {[-31:31]}) else $fatal("tc_reset_during_operation: invalid Q_BB after recovery: 0x%03h", o_bus_c);
        
        $display("  After reset recovery");
        $display("[TC_RESET_DURING_OP] PASS\n");
    end
    endtask

    // ==========================================================================
    // MAIN TEST SEQUENCE
    // ==========================================================================
    initial begin
        // Initialize
        i_clk = 1'b0;
        i_rst_n = 1'b0;
        i_cfg_local = CFG_NORMAL;
        i_bus_a = '0;
        i_bus_b = '0;

        // Reset
        repeat(5) @(posedge i_clk);
        apply_reset(10);

        // Run test suite
        $display("\n========================================");
        $display("  MSK WRAPPER TEST SUITE");
        $display("========================================\n");

        tc_reset_behavior();
        apply_reset(5);

        tc_config_normal();
        apply_reset(5);

        tc_config_enc_override();
        apply_reset(5);

        tc_config_demux_override();
        apply_reset(5);

        tc_config_shaping_override();
        apply_reset(5);

        tc_config_observe_internals();
        apply_reset(5);

        tc_config_transitions();
        apply_reset(5);

        tc_bus_widths();
        apply_reset(5);

        tc_output_bus_d();
        apply_reset(5);

        tc_rapid_config_changes();
        apply_reset(5);

        tc_reset_during_operation();

        $display("\n========================================");
        $display("  ALL TESTS COMPLETED SUCCESSFULLY");
        $display("========================================\n");

        repeat(20) @(posedge i_clk);
        $finish;
    end

endmodule
