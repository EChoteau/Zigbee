module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8
    )(
        input logic i_clk,
        input logic i_rst_n,

        //Write interface
        input logic i_wr_en,
        input logic [DATA_WIDTH-1:0] i_data,
        output logic o_full,

        //Read interface
        input logic i_rd_en,
        output logic [DATA_WIDTH-1:0] o_data,
        output logic o_rd_valid,
        output logic o_empty
    );


    localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam PTR_WIDTH = ADDR_WIDTH + 1; // Extra bit for round done

    //memory array
    logic [DATA_WIDTH-1:0] mem [DEPTH-1:0];
    //write and read pointers
    logic [PTR_WIDTH-1:0] wr_ptr, rd_ptr;  

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            o_data <= 0;
            o_rd_valid <= 1'b0;
        end else begin
            o_rd_valid <= 1'b0;
            // Write operation
            if (i_wr_en && !o_full) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= i_data;
                wr_ptr <= wr_ptr + 1;
            end
            // Read operation
            if (i_rd_en && !o_empty) begin
                o_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
                rd_ptr <= rd_ptr + 1;
                o_rd_valid <= 1'b1;
            end
        end
    end
    
    assign o_empty = (wr_ptr == rd_ptr);
    assign o_full = (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]) && (wr_ptr[PTR_WIDTH-1] != rd_ptr[PTR_WIDTH-1]);

endmodule