module serializer #(
    parameter DATA_WIDTH = 8
    )(
        input logic i_clk,
        input logic i_rst_n,

        input logic baud_rate_en, // Tick de baud rate (impulsion 1 cycle)

        //Parallel input interface
        input logic [DATA_WIDTH-1:0] i_data,
        input logic i_fifo_empty,
        input logic i_fifo_data_valid,
        output logic o_fifo_pop,

        //Serial output interface
        output logic o_serial_data,
        output logic o_valid,
        output logic o_sample_tick

    );

    localparam BIT_CNT = $clog2(DATA_WIDTH);

    logic [DATA_WIDTH-1:0] shift_reg;
    logic [BIT_CNT-1:0] bit_count;
    logic s_pop_pending;
    logic s_end_pending;
    logic s_sample_pending;

    // --- Serialization logic ---
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            shift_reg     <= '0;
            bit_count     <= '0;
            s_pop_pending <= 1'b0;
            s_end_pending <= 1'b0;
            s_sample_pending <= 1'b0;
            o_fifo_pop    <= 1'b0;
            o_serial_data <= 1'b0;
            o_valid       <= 1'b0;
            o_sample_tick <= 1'b0;
        end 
        
        else begin
            o_fifo_pop <= 1'b0;
            o_sample_tick <= 1'b0;

            if (s_sample_pending) begin
                o_sample_tick <= 1'b1;
                s_sample_pending <= 1'b0;
            end

            if (s_end_pending) begin
                o_valid <= 1'b0;
                s_end_pending <= 1'b0;
            end else begin
                // STEP 1: Ready to load
                if (!o_valid) begin
                    if (s_pop_pending) begin
                        if (i_fifo_data_valid) begin
                            shift_reg <= i_data;
                            bit_count <= '0;
                            s_pop_pending <= 1'b0;
                            o_valid   <= 1'b1;
                        end
                    end else if (!i_fifo_empty) begin
                        o_fifo_pop <= 1'b1;
                        s_pop_pending <= 1'b1;
                    end
                end

                // STEP 2: Transmission in progress
                else begin
                    if (baud_rate_en) begin
                        o_serial_data <= shift_reg[0];
                        shift_reg     <= shift_reg >> 1;
                        s_sample_pending <= 1'b1;

                        if (bit_count == (DATA_WIDTH - 1)) begin
                            s_end_pending <= 1'b1; // End of transmission after this tick
                        end else begin
                            bit_count <= bit_count + 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule
