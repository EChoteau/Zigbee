module serializer #(
    parameter DATA_WIDTH = 8
    )(
        input logic i_clk,
        input logic i_rst_n,

        input logic i_baud_tick, // Tick de baud rate (impulsion 1 cycle)

        //Parallel input interface
        input logic [DATA_WIDTH-1:0] i_tx_data,
        input logic i_tx_fifo_empty,
        input logic i_tx_data_valid,
        output logic o_tx_fifo_pop,

        //Serial output interface
        output logic o_serial_data,
        output logic o_tx_busy,
        output logic o_tx_sample_tick

    );

    localparam BIT_CNT = $clog2(DATA_WIDTH);

    logic [DATA_WIDTH-1:0] s_shift_reg;
    logic [BIT_CNT-1:0] s_bit_count;
    logic s_waiting_fifo_data;
    logic s_bit_event_d;

    // --- Serialization logic ---
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            s_shift_reg     <= '0;
            s_bit_count     <= '0;
            s_waiting_fifo_data <= 1'b0;
            s_bit_event_d <= 1'b0;
            o_tx_fifo_pop    <= 1'b0;
            o_serial_data <= 1'b0;
            o_tx_busy       <= 1'b0;
            o_tx_sample_tick <= 1'b0;
        end 
        
        else begin
            o_tx_fifo_pop <= 1'b0;
            o_tx_sample_tick <= s_bit_event_d;
            s_bit_event_d <= o_tx_busy && i_baud_tick;

            // STEP 1: Ready to load
            if (!o_tx_busy) begin
                if (s_waiting_fifo_data) begin
                    if (i_tx_data_valid) begin
                        s_shift_reg <= i_tx_data;
                        s_bit_count <= '0;
                        s_waiting_fifo_data <= 1'b0;
                        o_tx_busy   <= 1'b1;
                    end
                end else if (!i_tx_fifo_empty) begin
                    o_tx_fifo_pop <= 1'b1;
                    s_waiting_fifo_data <= 1'b1;
                end
            end

            // STEP 2: Transmission in progress
            else if (i_baud_tick) begin
                o_serial_data <= s_shift_reg[0];

                if (s_bit_count == (DATA_WIDTH - 1)) begin
                    o_tx_busy <= 1'b0;
                end else begin
                    s_shift_reg <= s_shift_reg >> 1;
                    s_bit_count <= s_bit_count + 1'b1;
                end
            end
        end
    end

endmodule
