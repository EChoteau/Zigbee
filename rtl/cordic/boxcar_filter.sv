module boxcar_filter #(
    parameter int WIDTH = 16,
    parameter int N     = 8,      // Filter length
    // The output width must grow to prevent overflow : OUT_WIDTH = WIDTH + log2(N)
    parameter int OUT_WIDTH = WIDTH + $clog2(N) 
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic signed [WIDTH-1:0]     i_data,
    output logic signed [OUT_WIDTH-1:0] o_data 
);

    // Delay line to keep track of the oldest sample
    logic signed [WIDTH-1:0] s_delay_line [0:N-1];
    
    // Internal accumulator
    logic signed [OUT_WIDTH-1:0] s_acc;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            s_acc <= '0;
            for (int i = 0; i < N; i++) begin
                s_delay_line[i] <= '0;
            end
        end else begin
            // 1. Update the accumulator: 
            s_acc <= s_acc + i_data - s_delay_line[N-1];

            // 2. Shift the delay line
            s_delay_line[0] <= i_data;
            for (int i = 1; i < N; i++) begin
                s_delay_line[i] <= s_delay_line[i-1];
            end
        end
    end

    // The output is the running sum
    assign o_data = s_acc;

endmodule

