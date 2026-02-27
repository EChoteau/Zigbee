module deserializer #(
    parameter DATA_WIDTH = 8
)(
    input  logic i_clk,
    input  logic i_rst_n,

    // Serial input interface
    input  logic i_serial_data,
    input  logic i_serial_en, // (Baud rate clock)
    
    // Parallel output interface
    output logic [DATA_WIDTH-1:0] o_para_data,
    output logic o_valid // Indiquate that new data is available 
);

    localparam BIT_CNT = $clog2(DATA_WIDTH);

    logic [DATA_WIDTH-1:0] shift_reg;
    logic [BIT_CNT-1:0]    bit_count;

    logic baud_rate_en_d1;
    logic baud_rate_en_d2;
    logic baud_edge;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            baud_rate_en_d1 <= 1'b0;
            baud_rate_en_d2 <= 1'b0;
        end else begin
            baud_rate_en_d1 <= i_serial_en;
            baud_rate_en_d2 <= baud_rate_en_d1;
        end
    end

    assign baud_edge = baud_rate_en_d1 & ~baud_rate_en_d2;

    // --- Parallelisation logic ---
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            shift_reg        <= '0;
            bit_count        <= '0;
            o_para_data      <= '0;
            o_valid          <= 1'b0;
        end 
        else begin
            if (baud_edge) begin
                // (MSB first logic)
                shift_reg <= {shift_reg[DATA_WIDTH-2:0], i_serial_data};
            
                if (bit_count == (DATA_WIDTH - 1)) begin
                    o_para_data      <= {shift_reg[DATA_WIDTH-2:0], i_serial_data};
                    o_valid          <= 1'b1;
                    bit_count        <= '0;
                end else begin
                    o_valid          <= 1'b0; 
                    bit_count        <= bit_count + 1'b1;
                end
            end else begin
                o_valid <= 1'b0;
            end
        end
    end

endmodule