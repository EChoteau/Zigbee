module serializer #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8
    )(
        input logic i_clk,
        input logic i_rst_n,

        input logic baud_rate_en,

        //Parallel input interface
        input logic i_wr_en,
        input logic [DATA_WIDTH-1:0] i_data,
        input logic i_fifo_empty,

        //Serial output interface
        output logic o_serial_data,
        output logic o_valid

        
    );

    localparam DATA_NB_BIT = $clog2(DEPTH);

    logic [DATA_WIDTH-1:0] shift_reg;
    logic [DATA_NB_BIT:0] bit_count;

    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            shift_reg <= 0;
            bit_count <= 0;
            o_serial_data <= 0;
            o_valid <= 0;
        end 
        
        else begin

            if (i_wr_en && !i_fifo_empty && !o_valid) begin
                shift_reg <= i_data; // Load parallel data into shift register
                bit_count <= 0; // Reset bit count for new data
                o_valid <= 1; // Indicate valid data is being processed
            end
            
            else if (i_wr_en && o_valid && baud_rate_en) begin
                o_serial_data <= shift_reg[DATA_WIDTH-1]; // Output the MSB first
                shift_reg <= shift_reg << 1; // Shift left to prepare next bit
                bit_count <= bit_count + 1; // Increment bit count

                if (bit_count == DATA_WIDTH - 1) begin
                    o_valid <= 0; // All bits have been output, clear valid signal
                end
            end 
            
            else if (baud_rate_en) begin
                o_serial_data <= 0; // No valid data, output low
            end
            
            else begin
                //pass
            end
        end
    end

endmodule
