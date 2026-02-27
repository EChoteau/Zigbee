module serializer #(
    parameter DATA_WIDTH = 8
    )(
        input logic i_clk,
        input logic i_rst_n,

        input logic baud_rate_en, // (Baud rate clock)

        //Parallel input interface
        input logic i_wr_en,
        input logic [DATA_WIDTH-1:0] i_data,
        input logic i_fifo_empty,

        //Serial output interface
        output logic o_serial_data,
        output logic o_valid

    );

    localparam BIT_CNT = $clog2(DATA_WIDTH);

    logic [DATA_WIDTH-1:0] shift_reg;
    logic [BIT_CNT-1:0] bit_count;

    logic baud_rate_en_d1;
    logic baud_rate_en_d2;
    logic baud_edge;

    // --- Rising edge detector for baud_rate_en ---
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            baud_rate_en_d1 <= 1'b0;
            baud_rate_en_d2 <= 1'b0;
        end else begin
            baud_rate_en_d1 <= baud_rate_en;
            baud_rate_en_d2 <= baud_rate_en_d1;
        end
    end

    // baud_edge goes high for exactly ONE cycle of i_clk when a rising edge is detected on baud_rate_en
    assign baud_edge = baud_rate_en_d1 & ~baud_rate_en_d2;

    // --- Serialization logic ---
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            shift_reg     <= '0;
            bit_count     <= '0;
            o_serial_data <= 1'b0; 
            o_valid       <= 1'b0;
        end 
        
        else begin
            // STEP 1: Ready to load
            if (!o_valid) begin
                if (i_wr_en && !i_fifo_empty) begin
                    shift_reg <= i_data;
                    bit_count <= '0;
                    o_valid   <= 1'b1;
                end
            end
            
            // STEP 2: Transmission in progress
            else begin
                if (baud_edge) begin
                    o_serial_data <= shift_reg[DATA_WIDTH-1];
                    shift_reg     <= shift_reg << 1;

                    if (bit_count == (DATA_WIDTH - 1)) begin
                        o_valid <= 1'b0; //End of transmission of the current byte
                    end else begin
                        bit_count <= bit_count + 1'b1;
                    end
                end
            end
        end
    end

endmodule
