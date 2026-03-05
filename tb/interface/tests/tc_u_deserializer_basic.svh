task automatic run_tc_u_deserializer_basic;
    logic [7:0] payload;
    int i;
    int push_count;
    int ovf_count;
begin
    $display("[U_DES] Basic deserializer test start");

    payload = 8'h3C;
    push_count = 0;
    ovf_count = 0;

    u_des_enable       = 1'b1;
    u_des_fifo_full    = 1'b0;
    u_des_sample_valid = 1'b0;
    u_des_serial_data  = 1'b0;

    for (i = 0; i < 8; i++) begin
        u_des_serial_data  = payload[i];
        u_des_sample_valid = 1'b1;
        @(posedge i_clk); #1;
        if (u_des_push) push_count++;
        u_des_sample_valid = 1'b0;
        @(posedge i_clk); #1;
    end

    assert (push_count == 1)
        else $fatal(1, "[U_DES] Expected exactly one push pulse, got=%0d", push_count);
    assert (u_des_para_data == payload)
        else $fatal(1, "[U_DES] Deserialized data mismatch. got=%0h expected=%0h", u_des_para_data, payload);

    u_des_fifo_full = 1'b1;
    for (i = 0; i < 8; i++) begin
        u_des_serial_data  = payload[i];
        u_des_sample_valid = 1'b1;
        @(posedge i_clk); #1;
        if (u_des_ovf_pulse) ovf_count++;
        u_des_sample_valid = 1'b0;
        @(posedge i_clk); #1;
        if (u_des_ovf_pulse) ovf_count++;
    end

    assert (ovf_count >= 1)
        else $fatal(1, "[U_DES] Expected overflow pulse when fifo_full=1");

    u_des_fifo_full = 1'b0;
    u_des_enable    = 1'b0;

    $display("[U_DES] Basic deserializer test PASS");
end
endtask
