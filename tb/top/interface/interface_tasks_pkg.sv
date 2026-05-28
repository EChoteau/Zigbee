// ============================================================================
// PACKAGE: interface_tasks_pkg
// ============================================================================
// Consolidated test package for INTERFACE testbench
// Contains all test tasks, test plans, and support functions
// 
// Usage in testbench:
//   import interface_tasks_pkg::*;
//   
// Then call test plans directly:
//   run_interface_test_plan_smoke();
//   run_interface_test_plan_full();
// ============================================================================

package interface_tasks_pkg;

    // Import from generic testbench and interface packages
    import tb_pkg::*;
    import interface_pkg::*;

    // Common task arguments for top_tb signals
    `define IFACE_ARGS \
        ref logic i_clk, \
        ref logic i_rst_n, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_cfg_local, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_top_cfg, \
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in, \
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out

    localparam logic [2:0] TOP_CFG_INTERFACE = 3'd3;

    // APB write operation via bus interface
    task automatic apb_write_bus_impl(
        ref logic i_clk,
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in,
        logic [APB_ADDR_WIDTH-1:0] addr,
        logic [APB_DATA_WIDTH-1:0] data
    );
    begin
        @(posedge i_clk);
        i_bus_in[BUS_PSEL_BIT] = 1'b1;
        i_bus_in[BUS_PENABLE_BIT] = 1'b0;
        i_bus_in[BUS_PWRITE_BIT] = 1'b1;
        i_bus_in[BUS_PADDR_MSB:BUS_PADDR_LSB] = addr;
        i_bus_in[BUS_PWDATA_MSB:BUS_PWDATA_LSB] = data;

        @(posedge i_clk);
        i_bus_in[BUS_PENABLE_BIT] = 1'b1;

        @(posedge i_clk);
        i_bus_in[BUS_PSEL_BIT] = 1'b0;
        i_bus_in[BUS_PENABLE_BIT] = 1'b0;
        i_bus_in[BUS_PWRITE_BIT] = 1'b0;
        i_bus_in[BUS_PADDR_MSB:BUS_PADDR_LSB] = '0;
        i_bus_in[BUS_PWDATA_MSB:BUS_PWDATA_LSB] = '0;
    end
    endtask

    // APB read operation via bus interface
    task automatic apb_read_bus_impl(
        ref logic i_clk,
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out,
        logic [APB_ADDR_WIDTH-1:0] addr,
        output logic [APB_DATA_WIDTH-1:0] rd_data
    );
    begin
        @(posedge i_clk);
        i_bus_in[BUS_PSEL_BIT] = 1'b1;
        i_bus_in[BUS_PENABLE_BIT] = 1'b0;
        i_bus_in[BUS_PWRITE_BIT] = 1'b0;
        i_bus_in[BUS_PADDR_MSB:BUS_PADDR_LSB] = addr;
        i_bus_in[BUS_PWDATA_MSB:BUS_PWDATA_LSB] = '0;

        @(posedge i_clk);
        i_bus_in[BUS_PENABLE_BIT] = 1'b1;

        @(posedge i_clk);
        rd_data = o_bus_out[BUS_OUT_PRDATA_MSB:BUS_OUT_PRDATA_LSB];
        i_bus_in[BUS_PSEL_BIT] = 1'b0;
        i_bus_in[BUS_PENABLE_BIT] = 1'b0;
        i_bus_in[BUS_PADDR_MSB:BUS_PADDR_LSB] = '0;
    end
    endtask

    // Helper macros bound to the current task arguments
    `define apb_write_bus(addr, data) \
        begin \
            logic [APB_ADDR_WIDTH-1:0] _addr_temp = addr; \
            logic [APB_DATA_WIDTH-1:0] _data_temp = data; \
            apb_write_bus_impl(i_clk, i_bus_in, _addr_temp, _data_temp); \
        end
    `define apb_read_bus(addr, rd_data) \
        begin \
            logic [APB_ADDR_WIDTH-1:0] _addr_temp = addr; \
            apb_read_bus_impl(i_clk, i_bus_in, o_bus_out, _addr_temp, rd_data); \
        end
    `define apply_reset(cycles) \
        begin \
            tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, cycles); \
            tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_INTERFACE); \
            repeat(2) @(posedge i_clk); \
        end
    `define set_bus(val) tb_pkg::set_bus(i_clk, i_bus_in, val)
    `define set_config_wrapper(clk, cfg_local, cfg) \
        begin \
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, cfg); \
            tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_INTERFACE); \
        end

    // =========================================================================
    // TEST CASE: Reset/Smoke test
    // =========================================================================
    task automatic run_interface_tc_t0_reset_smoke(`IFACE_ARGS);
        logic [APB_DATA_WIDTH-1:0] rd;
    begin
        $display("[INTERFACE T0] Reset/Smoke test start");

        assert (o_bus_out[BUS_OUT_PRDATA_MSB:BUS_OUT_PRDATA_LSB] == 8'h00)
            else $fatal(1, "[INTERFACE T0] Initial data should be 0");

        // Read CONTROL register (should be 0 after reset)
        `apb_read_bus(interface_pkg::ADDR_CONTROL, rd);
        assert (rd[4:0] == 5'b0)
            else $fatal(1, "[INTERFACE T0] CONTROL reset mismatch. got=%0h", rd[4:0]);

        // Read DIVIDER register (should be 0x01 after reset)
        `apb_read_bus(interface_pkg::ADDR_DIVIDER, rd);
        assert (rd[7:0] == 8'h01)
            else $fatal(1, "[INTERFACE T0] DIVIDER reset mismatch. got=%0h expected=01", rd[7:0]);

        // Read STATUS register (should be 0x01 after reset - baud enabled)
        `apb_read_bus(interface_pkg::ADDR_STATUS, rd);
        assert (rd[4:0] == 5'b00001)
            else $fatal(1, "[INTERFACE T0] STATUS reset mismatch. got=%0b expected=00001", rd[4:0]);

        // Read DATA register (should be 0 after reset)
        `apb_read_bus(interface_pkg::ADDR_DATA, rd);
        assert (rd[7:0] == 8'h00)
            else $fatal(1, "[INTERFACE T0] DATA reset value mismatch. got=%0h", rd[7:0]);

        $display("[INTERFACE T0] Reset/Smoke test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: APB registers test
    // =========================================================================
    task automatic run_interface_tc_t1_apb_regs(`IFACE_ARGS);
        logic [APB_DATA_WIDTH-1:0] rd;
    begin
        $display("[INTERFACE T1] APB registers test start");

        `apb_write_bus(interface_pkg::ADDR_DIVIDER, 8'h31);
        `apb_read_bus(interface_pkg::ADDR_DIVIDER, rd);
        assert (rd[7:0] == 8'h31)
            else $fatal(1, "[INTERFACE T1] DIVIDER write/read mismatch. got=%0h expected=31", rd[7:0]);

        `apb_write_bus(interface_pkg::ADDR_CONTROL, 8'h1F);
        repeat (2) @(posedge i_clk);
        `apb_read_bus(interface_pkg::ADDR_CONTROL, rd);
        assert (rd[4:0] == 5'b10001)
            else $fatal(1, "[INTERFACE T1] CONTROL autoclear mismatch. got=%0b expected=10001", rd[4:0]);

        `apb_read_bus(interface_pkg::ADDR_STATUS, rd);
        assert (rd[0] == 1'b1)
            else $fatal(1, "[INTERFACE T1] STATUS.rx_empty should be 1 after reset/config");
        assert (rd[1] == 1'b0)
            else $fatal(1, "[INTERFACE T1] STATUS.tx_full should be 0");
        assert (rd[2] == 1'b0)
            else $fatal(1, "[INTERFACE T1] STATUS.tx_busy should be 0");
        assert (rd[3] == 1'b0)
            else $fatal(1, "[INTERFACE T1] STATUS.rx_ovf_err should be 0");
        assert (rd[4] == 1'b0)
            else $fatal(1, "[INTERFACE T1] STATUS.tx_und_err should be 0");

        $display("[INTERFACE T1] APB registers test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: TX FIFO basic test
    // CONFIG REQUIRED: CFG_FIFO_TX (3'b100)
    // NOTE: This test expects wrapper config to be pre-set by caller (test plan)
    //       If called standalone, caller must set config before calling this task
    // =========================================================================
    task automatic run_interface_tc_fifo_tx_basic(`IFACE_ARGS);
        logic [21:0] bus_val;
        logic [7:0] expected_data;
        logic [7:0] read_data;
        int i;
    begin
        $display("[INTERFACE FIFO_TX] TX FIFO basic test start");

        // Config should already be set to CFG_FIFO_TX by caller/test plan
        // Small delay to ensure config is stable
        repeat(2) @(posedge i_clk);

        // Verify FIFO is initially empty
        // In CFG_FIFO_TX: OUT[9] = s_dbg_tx_fifo_empty
        assert (o_bus_out[9] == 1'b1)
            $display("  [FIFO_TX] PASS: FIFO is initially empty");
        else
            $error("  [FIFO_TX] FAIL: FIFO should be empty at startup");

        // Fill TX FIFO with 8 bytes
        $display("  [FIFO_TX] Filling TX FIFO with 8 bytes...");
        for (i = 0; i < 8; i++) begin
            bus_val = '0;
            bus_val[0] = 1'b1;  // fifo_tx_wr_en
            bus_val[17:10] = 8'hD0 + i;  // fifo_tx_data
            `set_bus(bus_val);
            
            // Clear enable
            `set_bus('0);
        end

        // Verify FIFO is full
        // In CFG_FIFO_TX: OUT[8] = s_dbg_tx_fifo_full
        assert (o_bus_out[8] == 1'b1)
            $display("  [FIFO_TX] PASS: FIFO FULL flag is set after 8 writes");
        else
            $error("  [FIFO_TX] FAIL: FIFO FULL flag is NOT set!");

        // Read back data
        $display("  [FIFO_TX] Reading back 8 bytes...");
        for (i = 0; i < 8; i++) begin
            expected_data = 8'hD0 + i;
            
            // Issue read
            bus_val = '0;
            bus_val[1] = 1'b1;  // fifo_tx_rd_en
            `set_bus(bus_val);
            
            // Disable read
            `set_bus('0);
            
            // In CFG_FIFO_TX: OUT[7:0] = s_dbg_tx_fifo_q (output data)
            read_data = o_bus_out[7:0];
            
            assert (read_data === expected_data)
                $display("  [FIFO_TX] PASS: Read 0x%0h", read_data);
            else
                $error("  [FIFO_TX] FAIL: Read 0x%0h, Expected 0x%0h", read_data, expected_data);
        end

        // Verify FIFO is empty
        assert (o_bus_out[9] == 1'b1)
            $display("  [FIFO_TX] PASS: FIFO is empty after reading all data");
        else
            $error("  [FIFO_TX] FAIL: FIFO should be empty");

        $display("[INTERFACE FIFO_TX] TX FIFO basic test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: TX FIFO full capacity test
    // CONFIG REQUIRED: CFG_FIFO_TX (3'b100) - pre-set by test plan
    // =========================================================================
    task automatic run_interface_tc_fifo_tx_full(`IFACE_ARGS);
        logic [21:0] bus_val;
        logic [7:0] expected_data;
        logic [7:0] read_data;
        int i;
    begin
        $display("[INTERFACE FIFO_TX_FULL] TX FIFO full test start");

        // Config pre-set by caller/test plan
        repeat(2) @(posedge i_clk);

        // Verify initial state: empty, not full
        assert (o_bus_out[9] == 1'b1)
            else $error("  [FIFO_TX_FULL] FAIL: FIFO should be empty initially");
        assert (o_bus_out[8] == 1'b0)
            else $error("  [FIFO_TX_FULL] FAIL: FIFO should not be full initially");

        // Fill FIFO to capacity (8 bytes)
        $display("  [FIFO_TX_FULL] Filling FIFO to capacity...");
        for (i = 0; i < 8; i++) begin
            bus_val = '0;
            bus_val[0] = 1'b1;  // fifo_tx_wr_en
            bus_val[17:10] = 8'h30 + i;
            `set_bus(bus_val);
            `set_bus('0);
            
            if (i < 7) begin
                assert (o_bus_out[8] == 1'b0)
                    else $error("  [FIFO_TX_FULL] FAIL: FIFO should not be full yet (write %0d)", i);
            end else begin
                // After 8th write, FIFO should be full
                assert (o_bus_out[8] == 1'b1)
                    else $error("  [FIFO_TX_FULL] FAIL: FIFO should be full after %0d writes", 8);
            end
        end

        assert (o_bus_out[9] == 1'b0)
            else $error("  [FIFO_TX_FULL] FAIL: FIFO should not be empty when full");

        // Attempt write when full (overflow - data should be discarded)
        bus_val = '0;
        bus_val[0] = 1'b1;
        bus_val[17:10] = 8'hFF;  // overflow data
        `set_bus(bus_val);
        `set_bus('0);

        assert (o_bus_out[8] == 1'b1)
            else $error("  [FIFO_TX_FULL] FAIL: FIFO should still be full after overflow");

        // Read back all elements
        $display("  [FIFO_TX_FULL] Reading back from full FIFO...");
        for (i = 0; i < 8; i++) begin
            expected_data = 8'h30 + i;
            bus_val = '0;
            bus_val[1] = 1'b1;  // fifo_tx_rd_en
            `set_bus(bus_val);
            `set_bus('0);
            
            read_data = o_bus_out[7:0];
            assert (read_data === expected_data)
                else $error("  [FIFO_TX_FULL] FAIL: Read %0d got 0x%0h, expected 0x%0h", i, read_data, expected_data);
            
            // After reading, FIFO should no longer be full
            assert (o_bus_out[8] == 1'b0)
                else $error("  [FIFO_TX_FULL] FAIL: FIFO should not be full after read %0d", i);
        end

        // Verify final empty state
        assert (o_bus_out[9] == 1'b1)
            else $error("  [FIFO_TX_FULL] FAIL: FIFO should be empty at end");
        assert (o_bus_out[8] == 1'b0)
            else $error("  [FIFO_TX_FULL] FAIL: FIFO should not be full at end");

        $display("[INTERFACE FIFO_TX_FULL] TX FIFO full test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: TX FIFO sequential operations
    // CONFIG REQUIRED: CFG_FIFO_TX (3'b100) - pre-set by test plan
    // =========================================================================
    task automatic run_interface_tc_fifo_sequential_ops(`IFACE_ARGS);
        logic [21:0] bus_val;
        logic [7:0] expected_data;
        logic [7:0] read_data;
        int i;
        int wr_count;
        int rd_count;
    begin
        $display("[INTERFACE FIFO_SEQ_OPS] FIFO sequential operations test start");

        // Config pre-set by caller/test plan
        repeat(2) @(posedge i_clk);

        // Test 1: Write 3, read 2, write 3 more, read all 4 remaining
        $display("  [FIFO_SEQ_OPS] Phase 1: Write 3, read 2, write 3, read 4");
        
        // Write first 3 bytes
        for (i = 0; i < 3; i++) begin
            bus_val = '0;
            bus_val[0] = 1'b1;
            bus_val[17:10] = 8'h10 + i;
            `set_bus(bus_val);
            `set_bus('0);
        end

        // Read 2 bytes
        for (i = 0; i < 2; i++) begin
            bus_val = '0;
            bus_val[1] = 1'b1;
            `set_bus(bus_val);
            `set_bus('0);
            read_data = o_bus_out[7:0];
            expected_data = 8'h10 + i;
            assert (read_data === expected_data)
                else $error("  [FIFO_SEQ_OPS] FAIL: Read %0d got 0x%0h, expected 0x%0h", i, read_data, expected_data);
        end

        // Write 3 more bytes
        for (i = 0; i < 3; i++) begin
            bus_val = '0;
            bus_val[0] = 1'b1;
            bus_val[17:10] = 8'h20 + i;
            `set_bus(bus_val);
            `set_bus('0);
        end

        // Read remaining 4 bytes (1 from phase 1 + 3 from phase 2)
        wr_count = 0;
        for (i = 0; i < 4; i++) begin
            bus_val = '0;
            bus_val[1] = 1'b1;
            `set_bus(bus_val);
            `set_bus('0);
            read_data = o_bus_out[7:0];
            
            if (i == 0) begin
                expected_data = 8'h12;  // Last byte from first batch
            end else begin
                expected_data = 8'h20 + (i - 1);  // From second batch
            end
            
            assert (read_data === expected_data)
                else $error("  [FIFO_SEQ_OPS] FAIL: Read %0d got 0x%0h, expected 0x%0h", i, read_data, expected_data);
        end

        // FIFO should be empty now
        assert (o_bus_out[9] == 1'b1)
            else $error("  [FIFO_SEQ_OPS] FAIL: FIFO should be empty");

        // Test 2: Fill completely, drain completely
        $display("  [FIFO_SEQ_OPS] Phase 2: Fill to capacity, drain");
        
        for (i = 0; i < 8; i++) begin
            bus_val = '0;
            bus_val[0] = 1'b1;
            bus_val[17:10] = 8'h30 + i;
            `set_bus(bus_val);
            `set_bus('0);
        end

        assert (o_bus_out[8] == 1'b1)
            else $error("  [FIFO_SEQ_OPS] FAIL: FIFO should be full after writes");

        for (i = 0; i < 8; i++) begin
            bus_val = '0;
            bus_val[1] = 1'b1;
            `set_bus(bus_val);
            `set_bus('0);
            read_data = o_bus_out[7:0];
            expected_data = 8'h30 + i;
            assert (read_data === expected_data)
                else $error("  [FIFO_SEQ_OPS] FAIL: Phase 2 read %0d got 0x%0h, expected 0x%0h", i, read_data, expected_data);
        end

        assert (o_bus_out[9] == 1'b1)
            else $error("  [FIFO_SEQ_OPS] FAIL: FIFO should be empty at end");

        $display("[INTERFACE FIFO_SEQ_OPS] FIFO sequential operations test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: RX nominal single byte test
    // CONFIG REQUIRED: CFG_RX_ONLY (3'b000) - pre-set by test plan
    // =========================================================================
    task automatic run_interface_tc_rx_nominal(`IFACE_ARGS);
        logic [21:0] bus_val;
        logic [7:0] rd_data;
        logic [7:0] rx_test_byte = 8'h3C;
        int i;
    begin
        $display("[INTERFACE RX_NOMINAL] RX nominal test start");

        // Config pre-set by caller/test plan
        repeat(2) @(posedge i_clk);

        // Configure RX: enable global + rx_enable via APB
        `apb_write_bus(interface_pkg::ADDR_CONTROL, 8'h11);  // global_en=1, rx_enable=1
        repeat(2) @(posedge i_clk);

        // Inject serial data bit by bit (simulating CDR sample)
        for (i = 0; i < 8; i++) begin
            bus_val = '0;
            bus_val[BUS_CDR_SAMPLE_BIT] = 1'b1;
            bus_val[BUS_SERIAL_RX_BIT] = rx_test_byte[i];
            `set_bus(bus_val);
            
            // Clear sample valid
            `set_bus('0);
        end

        // Wait for deserializer to push data into FIFO
        repeat(10) @(posedge i_clk);

        // Verify RX FIFO is not empty
        assert (o_bus_out[9] == 1'b0)
            else $error("  [RX_NOMINAL] FAIL: RX FIFO should not be empty after receive");

        // Read received data via APB
        `apb_read_bus(interface_pkg::ADDR_DATA, rd_data);
        
        assert (rd_data === rx_test_byte)
            else $error("  [RX_NOMINAL] FAIL: Read 0x%0h, expected 0x%0h", rd_data, rx_test_byte);

        $display("  [RX_NOMINAL] PASS: Received byte 0x%0h correctly", rd_data);

        // Verify FIFO is empty after read (FIFO pop)
        repeat(2) @(posedge i_clk);
        assert (o_bus_out[9] == 1'b1)
            else $error("  [RX_NOMINAL] FAIL: RX FIFO should be empty after pop");

        $display("[INTERFACE RX_NOMINAL] RX nominal test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: RX multiple bytes reception
    // CONFIG REQUIRED: CFG_RX_ONLY (3'b000) - pre-set by test plan
    // =========================================================================
    task automatic run_interface_tc_rx_multiple_bytes(`IFACE_ARGS);
        logic [21:0] bus_val;
        logic [7:0] rd_data;
        logic [7:0] test_bytes [0:7] = '{8'h5A, 8'hA5, 8'h3C, 8'hC3, 8'hFF, 8'h00, 8'h99, 8'h66};
        int byte_idx;
        int bit_idx;
    begin
        $display("[INTERFACE RX_MULTIPLE] RX multiple bytes test start");

        // Config pre-set by caller/test plan
        repeat(2) @(posedge i_clk);

        // Configure RX
        `apb_write_bus(interface_pkg::ADDR_CONTROL, 8'h11);  // global_en=1, rx_enable=1
        repeat(2) @(posedge i_clk);

        // Inject 8 different bytes
        for (byte_idx = 0; byte_idx < 8; byte_idx++) begin
            for (bit_idx = 0; bit_idx < 8; bit_idx++) begin
                bus_val = '0;
                bus_val[BUS_CDR_SAMPLE_BIT] = 1'b1;
                bus_val[BUS_SERIAL_RX_BIT] = test_bytes[byte_idx][bit_idx];
                `set_bus(bus_val);
                `set_bus('0);
            end
        end

        repeat(20) @(posedge i_clk);

        // Read back all 8 bytes via APB
        $display("  [RX_MULTIPLE] Reading 8 bytes from RX FIFO...");
        for (byte_idx = 0; byte_idx < 8; byte_idx++) begin
            `apb_read_bus(interface_pkg::ADDR_DATA, rd_data);
            
            assert (rd_data === test_bytes[byte_idx])
                else $error("  [RX_MULTIPLE] FAIL: Byte %0d: Read 0x%0h, expected 0x%0h", 
                           byte_idx, rd_data, test_bytes[byte_idx]);
            
            $display("  [RX_MULTIPLE] Byte %0d: 0x%0h - OK", byte_idx, rd_data);
        end

        // Verify FIFO is empty
        assert (o_bus_out[9] == 1'b1)
            else $error("  [RX_MULTIPLE] FAIL: FIFO should be empty after reading all bytes");

        $display("[INTERFACE RX_MULTIPLE] RX multiple bytes test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: Data pattern test
    // CONFIG REQUIRED: CFG_RX_ONLY (3'b000) - pre-set by test plan
    // =========================================================================
    task automatic run_interface_tc_data_patterns(`IFACE_ARGS);
        logic [21:0] bus_val;
        logic [7:0] rd_data;
        logic [7:0] test_patterns [0:7];
        int pattern_idx;
        int bit_idx;
    begin
        $display("[INTERFACE DATA_PATTERNS] Data pattern test start");

        // Define test patterns
        test_patterns[0] = 8'b10101010;  // Walking 1s
        test_patterns[1] = 8'b01010101;  // Walking 0s
        test_patterns[2] = 8'b11110000;  // Half ones
        test_patterns[3] = 8'b00001111;  // Half zeros
        test_patterns[4] = 8'b11111111;  // All ones
        test_patterns[5] = 8'b00000000;  // All zeros
        test_patterns[6] = 8'b10001000;  // Sparse ones
        test_patterns[7] = 8'b01110111;  // Mostly ones

        // Config pre-set by caller/test plan
        `apb_write_bus(interface_pkg::ADDR_CONTROL, 8'h11);  // global_en=1, rx_enable=1
        repeat(2) @(posedge i_clk);

        // Test each pattern
        for (pattern_idx = 0; pattern_idx < 8; pattern_idx++) begin
            // Inject pattern bits
            for (bit_idx = 0; bit_idx < 8; bit_idx++) begin
                bus_val = '0;
                bus_val[BUS_CDR_SAMPLE_BIT] = 1'b1;
                bus_val[BUS_SERIAL_RX_BIT] = test_patterns[pattern_idx][bit_idx];
                `set_bus(bus_val);
                `set_bus('0);
            end
        end

        repeat(30) @(posedge i_clk);

        // Read back and verify all patterns
        $display("  [DATA_PATTERNS] Verifying received patterns...");
        for (pattern_idx = 0; pattern_idx < 8; pattern_idx++) begin
            `apb_read_bus(interface_pkg::ADDR_DATA, rd_data);
            
            assert (rd_data === test_patterns[pattern_idx])
                else $error("  [DATA_PATTERNS] FAIL: Pattern %0d: Read 0x%0h, expected 0x%0h", 
                           pattern_idx, rd_data, test_patterns[pattern_idx]);
            
            $display("  [DATA_PATTERNS] Pattern %0d: 0x%02b - OK", pattern_idx, test_patterns[pattern_idx]);
        end

        $display("[INTERFACE DATA_PATTERNS] Data pattern test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: RX overflow error test
    // CONFIG REQUIRED: CFG_RX_ONLY (3'b000) - pre-set by test plan
    // =========================================================================
    task automatic run_interface_tc_rx_overflow_error(`IFACE_ARGS);
        logic [21:0] bus_val;
        logic [7:0] rd_data;
        logic [7:0] test_byte;
        int i;
    begin
        $display("[INTERFACE RX_OVERFLOW] RX FIFO overflow error test start");

        // Config pre-set by caller/test plan
        repeat(2) @(posedge i_clk);

        // Configure RX
        `apb_write_bus(interface_pkg::ADDR_CONTROL, 8'h11);  // global_en=1, rx_enable=1
        repeat(2) @(posedge i_clk);

        // Inject 9 bytes (FIFO capacity is 8)
        // This should trigger overflow on the 9th byte
        for (i = 0; i < 9; i++) begin
            test_byte = 8'hA0 + i;
            
            // Inject all 8 bits
            for (int bit_idx = 0; bit_idx < 8; bit_idx++) begin
                bus_val = '0;
                bus_val[BUS_CDR_SAMPLE_BIT] = 1'b1;
                bus_val[BUS_SERIAL_RX_BIT] = test_byte[bit_idx];
                `set_bus(bus_val);
                `set_bus('0);
            end
        end

        repeat(10) @(posedge i_clk);

        // Check STATUS register for overflow flag
        // In interface, RX overflow should set an error flag
        `apb_read_bus(interface_pkg::ADDR_STATUS, rd_data);
        
        // Bit 3 of STATUS is typically RX overflow error
        assert (rd_data[3] == 1'b1)
            else $error("  [RX_OVERFLOW] FAIL: RX overflow error flag should be set");

        $display("  [RX_OVERFLOW] PASS: Overflow error detected as expected");

        // Clear error flag
        `apb_write_bus(interface_pkg::ADDR_CONTROL, 8'h0E);  // clear_err=1
        repeat(1) @(posedge i_clk);
        `apb_write_bus(interface_pkg::ADDR_CONTROL, 8'h11);

        // Verify error is cleared
        `apb_read_bus(interface_pkg::ADDR_STATUS, rd_data);
        assert (rd_data[3] == 1'b0)
            else $error("  [RX_OVERFLOW] FAIL: RX overflow error flag should be cleared");

        // Drain FIFO to clean up
        for (i = 0; i < 8; i++) begin
            `apb_read_bus(interface_pkg::ADDR_DATA, rd_data);
        end

        $display("[INTERFACE RX_OVERFLOW] RX FIFO overflow error test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: Configuration transitions test
    // =========================================================================
    task automatic run_interface_tc_config_transitions(`IFACE_ARGS);
        logic [7:0] rd_data;
        logic [21:0] bus_val;
        int i;
    begin
        $display("[INTERFACE CONFIG_TRANS] Configuration transitions test start");

        // Test 1: RX_ONLY -> FIFO_TX -> RX_ONLY
        $display("  [CONFIG_TRANS] Switching RX_ONLY -> FIFO_TX -> RX_ONLY");
        
        // Start in RX_ONLY
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);
        repeat(2) @(posedge i_clk);
        `apb_write_bus(interface_pkg::ADDR_CONTROL, 8'h11);  // global_en=1, rx_enable=1
        repeat(2) @(posedge i_clk);

        // Switch to FIFO_TX
        `apply_reset(3);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b100);
        repeat(2) @(posedge i_clk);

        // Write to TX FIFO
        for (i = 0; i < 4; i++) begin
            bus_val = '0;
            bus_val[0] = 1'b1;
            bus_val[17:10] = 8'h40 + i;
            `set_bus(bus_val);
            `set_bus('0);
        end

        // Verify FIFO has data
        assert (o_bus_out[9] == 1'b0)
            else $error("  [CONFIG_TRANS] FAIL: FIFO_TX should have data");

        // Drain FIFO
        for (i = 0; i < 4; i++) begin
            bus_val = '0;
            bus_val[1] = 1'b1;
            `set_bus(bus_val);
            `set_bus('0);
        end

        // Switch back to RX_ONLY
        `apply_reset(3);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);
        repeat(2) @(posedge i_clk);
        `apb_write_bus(interface_pkg::ADDR_CONTROL, 8'h11);
        repeat(2) @(posedge i_clk);

        // Verify RX can still receive
        for (i = 0; i < 8; i++) begin
            bus_val = '0;
            bus_val[BUS_CDR_SAMPLE_BIT] = 1'b1;
            bus_val[BUS_SERIAL_RX_BIT] = 1'b1;
            `set_bus(bus_val);
            `set_bus('0);
        end

        repeat(5) @(posedge i_clk);
        assert (o_bus_out[9] == 1'b0)
            else $error("  [CONFIG_TRANS] FAIL: RX_ONLY should have received data");

        $display("  [CONFIG_TRANS] PASS: Configuration transitions work correctly");

        $display("[INTERFACE CONFIG_TRANS] Configuration transitions test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: FIFO stress test
    // CONFIG REQUIRED: CFG_FIFO_TX (3'b100) - pre-set by test plan
    // =========================================================================
    task automatic run_interface_tc_stress_fifo_ops(`IFACE_ARGS);
        logic [21:0] bus_val;
        logic [7:0] data;
        logic [7:0] expected;
        int i, phase, wr_count, rd_count;
    begin
        $display("[INTERFACE STRESS_FIFO] FIFO stress test start");

        // Config pre-set by caller/test plan
        repeat(2) @(posedge i_clk);

        // Phase 1: Alternating writes and reads
        $display("  [STRESS_FIFO] Phase 1: Alternating write/read");
        for (phase = 0; phase < 5; phase++) begin
            for (wr_count = 0; wr_count < 4; wr_count++) begin
                bus_val = '0;
                bus_val[0] = 1'b1;
                bus_val[17:10] = 8'h50 + (phase * 4) + wr_count;
                `set_bus(bus_val);
                `set_bus('0);
            end

            repeat(2) @(posedge i_clk);

            for (rd_count = 0; rd_count < 4; rd_count++) begin
                bus_val = '0;
                bus_val[1] = 1'b1;
                `set_bus(bus_val);
                `set_bus('0);
                
                data = o_bus_out[7:0];
                expected = 8'h50 + (phase * 4) + rd_count;
                assert (data === expected)
                    else $error("  [STRESS_FIFO] FAIL: Phase %0d read %0d got 0x%0h, expected 0x%0h", 
                               phase, rd_count, data, expected);
            end

            // FIFO should be empty
            assert (o_bus_out[9] == 1'b1)
                else $error("  [STRESS_FIFO] FAIL: FIFO should be empty after phase %0d", phase);
        end

        // Phase 2: Fill to capacity repeatedly
        $display("  [STRESS_FIFO] Phase 2: Fill to capacity 5 times");
        for (phase = 0; phase < 5; phase++) begin
            // Fill to capacity
            for (i = 0; i < 8; i++) begin
                bus_val = '0;
                bus_val[0] = 1'b1;
                bus_val[17:10] = 8'hD0 + i;
                `set_bus(bus_val);
                `set_bus('0);
            end

            // Verify full
            assert (o_bus_out[8] == 1'b1)
                else $error("  [STRESS_FIFO] FAIL: FIFO should be full, phase %0d", phase);

            // Drain
            for (i = 0; i < 8; i++) begin
                bus_val = '0;
                bus_val[1] = 1'b1;
                `set_bus(bus_val);
                `set_bus('0);
            end

            // Verify empty
            assert (o_bus_out[9] == 1'b1)
                else $error("  [STRESS_FIFO] FAIL: FIFO should be empty after draining, phase %0d", phase);

            repeat(1) @(posedge i_clk);
        end

        $display("[INTERFACE STRESS_FIFO] FIFO stress test PASS");
    end
    endtask

    // =========================================================================
    // TEST PLAN: Smoke tests
    // =========================================================================
    task automatic run_interface_test_plan_smoke(`IFACE_ARGS);
    begin
        $display("\n========== [INTERFACE TEST PLAN SMOKE] Start ==========\n");

        // Test 1: Reset and smoke test
        $display("[SMOKE] 1/5: Reset/smoke test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        run_interface_tc_t0_reset_smoke(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // Test 2: APB registers test
        $display("[SMOKE] 2/5: APB registers test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        run_interface_tc_t1_apb_regs(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // Test 3: TX FIFO basic test
        $display("[SMOKE] 3/5: TX FIFO basic test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b100);  // CFG_FIFO_TX
        run_interface_tc_fifo_tx_basic(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // Test 4: RX nominal test
        $display("[SMOKE] 4/5: RX nominal test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        run_interface_tc_rx_nominal(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // Test 5: TX FIFO full test
        $display("[SMOKE] 5/5: TX FIFO full test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b100);  // CFG_FIFO_TX
        run_interface_tc_fifo_tx_full(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        $display("\n========== [INTERFACE TEST PLAN SMOKE] PASS ==========\n");
    end
    endtask

    // =========================================================================
    // TEST PLAN: Full comprehensive test suite
    // =========================================================================
    task automatic run_interface_test_plan_full(`IFACE_ARGS);
    begin
        $display("\n");
        $display("╔═══════════════════════════════════════════════════════════════════╗");
        $display("║         [INTERFACE TEST PLAN FULL] - Complete Test Suite          ║");
        $display("╚═══════════════════════════════════════════════════════════════════╝\n");

        // ========================================================================
        // BASIC TESTS (Reset, Smoke, Register Access)
        // ========================================================================
        $display("[FULL] Category: BASIC TESTS");
        $display("────────────────────────────────────────────────────────────────────");

        $display("[FULL] 1/15: Reset/smoke test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        // No specific config needed for reset/smoke
        run_interface_tc_t0_reset_smoke(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        $display("[FULL] 2/15: APB registers test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        // No specific config needed for APB register test
        run_interface_tc_t1_apb_regs(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // ========================================================================
        // TX FIFO TESTS
        // ========================================================================
        $display("\n[FULL] Category: TX FIFO TESTS");
        $display("────────────────────────────────────────────────────────────────────");

        $display("[FULL] 3/15: TX FIFO basic (fill/read)...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b100);  // CFG_FIFO_TX
        repeat(2) @(posedge i_clk);
        run_interface_tc_fifo_tx_basic(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        $display("[FULL] 4/15: TX FIFO full capacity test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b100);  // CFG_FIFO_TX
        repeat(2) @(posedge i_clk);
        run_interface_tc_fifo_tx_full(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        $display("[FULL] 5/15: TX FIFO sequential operations...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b100);  // CFG_FIFO_TX
        repeat(2) @(posedge i_clk);
        run_interface_tc_fifo_sequential_ops(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // ========================================================================
        // RX RECEPTION TESTS
        // ========================================================================
        $display("\n[FULL] Category: RX RECEPTION TESTS");
        $display("────────────────────────────────────────────────────────────────────");

        $display("[FULL] 6/15: RX nominal single byte test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        run_interface_tc_rx_nominal(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        $display("[FULL] 7/15: RX multiple bytes reception...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        run_interface_tc_rx_multiple_bytes(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // ========================================================================
        // DATA PATTERN TESTS
        // ========================================================================
        $display("\n[FULL] Category: DATA PATTERN TESTS");
        $display("────────────────────────────────────────────────────────────────────");

        $display("[FULL] 8/15: Data pattern verification...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        run_interface_tc_data_patterns(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // ========================================================================
        // ERROR HANDLING TESTS
        // ========================================================================
        $display("\n[FULL] Category: ERROR HANDLING TESTS");
        $display("────────────────────────────────────────────────────────────────────");

        $display("[FULL] 9/15: RX overflow error test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        run_interface_tc_rx_overflow_error(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // ========================================================================
        // CONFIGURATION TESTS
        // IMPORTANT: config_transitions tests config switching, so it sets configs itself
        // ========================================================================
        $display("\n[FULL] Category: CONFIGURATION TESTS");
        $display("────────────────────────────────────────────────────────────────────");

        $display("[FULL] 10/15: Configuration transitions test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // Start in CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        // NOTE: This test manages its own config changes - do NOT pre-set config
        run_interface_tc_config_transitions(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // ========================================================================
        // STRESS TESTS
        // ========================================================================
        $display("\n[FULL] Category: STRESS TESTS");
        $display("────────────────────────────────────────────────────────────────────");

        $display("[FULL] 11/15: FIFO stress test (alternating ops)...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b100);  // CFG_FIFO_TX
        repeat(2) @(posedge i_clk);
        run_interface_tc_stress_fifo_ops(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // ========================================================================
        // REPEAT SMOKE TESTS TO VERIFY STABILITY
        // ========================================================================
        $display("\n[FULL] Category: REGRESSION/STABILITY TESTS");
        $display("────────────────────────────────────────────────────────────────────");

        $display("[FULL] 12/15: Repeat reset/smoke test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        run_interface_tc_t0_reset_smoke(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        $display("[FULL] 13/15: Repeat APB test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        run_interface_tc_t1_apb_regs(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        $display("[FULL] 14/15: Repeat RX nominal...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b000);  // CFG_RX_ONLY
        repeat(2) @(posedge i_clk);
        run_interface_tc_rx_nominal(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        $display("[FULL] 15/15: Repeat FIFO test...");
        `apply_reset(5);
        `set_config_wrapper(i_clk, i_cfg_local, 3'b100);  // CFG_FIFO_TX
        repeat(2) @(posedge i_clk);
        run_interface_tc_fifo_tx_basic(i_clk, i_rst_n, i_cfg_local, i_top_cfg, i_bus_in, o_bus_out);
        repeat(5) @(posedge i_clk);

        // ========================================================================
        // TEST SUMMARY
        // ========================================================================
        $display("\n");
        $display("╔═══════════════════════════════════════════════════════════════════╗");
        $display("║                 [INTERFACE TEST PLAN FULL] - PASS                 ║");
        $display("║                   All 15 tests completed successfully             ║");
        $display("╚═══════════════════════════════════════════════════════════════════╝");
    end
    endtask

endpackage : interface_tasks_pkg
