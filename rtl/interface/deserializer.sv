module deserializer #(
    parameter DATA_WIDTH = 8
)(
    input  logic i_clk,
    input  logic i_rst_n,

    // Serial input interface
    input  logic i_serial_data,
    input  logic i_sample_valid, // Impulsion 1 cycle : échantillon CDR valide
    input  logic i_enable,
    input  logic i_fifo_full,
    
    // Parallel output interface
    output logic [DATA_WIDTH-1:0] o_para_data,
    output logic o_push,
    output logic o_ovf_pulse
);

    localparam BIT_CNT = $clog2(DATA_WIDTH);

    logic [DATA_WIDTH-1:0] shift_reg;
    logic [BIT_CNT-1:0]    bit_count;

    // --- Parallelisation logic ---
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            shift_reg        <= '0;
            bit_count        <= '0;
            o_para_data      <= '0;
            o_push           <= 1'b0;
            o_ovf_pulse      <= 1'b0;
        end 
        else begin
            o_push      <= 1'b0;
            o_ovf_pulse <= 1'b0;

            if (!i_enable) begin
                bit_count <= '0;
            end else if (i_sample_valid) begin
                shift_reg <= {i_serial_data, shift_reg[DATA_WIDTH-1:1]}; // LSB first

                if (bit_count == (DATA_WIDTH - 1)) begin
                    bit_count <= '0;
                    if (!i_fifo_full) begin
                        o_para_data <= {i_serial_data, shift_reg[DATA_WIDTH-1:1]};
                        o_push      <= 1'b1;
                    end else begin
                        o_ovf_pulse <= 1'b1;
                    end
                end else begin
                    bit_count <= bit_count + 1'b1;
                end
            end
        end
    end

endmodule