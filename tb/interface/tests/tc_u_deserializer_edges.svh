task automatic run_tc_u_deserializer_edges;
    logic [7:0] payload;
    int i;
    int push_count;
begin
    $display("[U_DES_EDGE] Deserializer edge test start");

    payload = 8'h5A;
    push_count = 0;

    u_des_enable       = 1'b0;
    u_des_fifo_full    = 1'b0;
    u_des_sample_valid = 1'b0;
    u_des_serial_data  = 1'b0;

    // Samples while disabled must be ignored
    for (i = 0; i < 8; i++) begin
        u_des_serial_data  = payload[i];
        u_des_sample_valid = 1'b1;
        @(posedge i_clk); #1;
        if (u_des_push) push_count++;
        u_des_sample_valid = 1'b0;
        @(posedge i_clk); #1;
    end
    assert (push_count == 0)
        else $fatal(1, "[U_DES_EDGE] Push must stay 0 while disabled");

    // Enable, inject partial, disable => partial word must be dropped
    u_des_enable = 1'b1;
    for (i = 0; i < 4; i++) begin
        u_des_serial_data  = payload[i];
        u_des_sample_valid = 1'b1;
        @(posedge i_clk); #1;
        u_des_sample_valid = 1'b0;
        @(posedge i_clk); #1;
    end

    u_des_enable = 1'b0;
    @(posedge i_clk); #1;
    u_des_enable = 1'b1;

    // Now send full byte, should produce exactly one push with exact payload
    push_count = 0;
    for (i = 0; i < 8; i++) begin
        u_des_serial_data  = payload[i];
        u_des_sample_valid = 1'b1;
        @(posedge i_clk); #1;
        if (u_des_push) push_count++;
        u_des_sample_valid = 1'b0;
        @(posedge i_clk); #1;
    end

    assert (push_count == 1)
        else $fatal(1, "[U_DES_EDGE] Expected one push after full byte, got=%0d", push_count);
    assert (u_des_para_data == payload)
        else $fatal(1, "[U_DES_EDGE] Data mismatch after re-enable. got=%0h exp=%0h", u_des_para_data, payload);

    $display("[U_DES_EDGE] Deserializer edge test PASS");
end
endtask
