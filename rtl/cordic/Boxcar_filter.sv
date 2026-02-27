module boxcar_filter #(
    parameter int WIDTH = 16,
    parameter int N     = 8,      // Filter length
    // The output width must grow to prevent overflow : OUT_WIDTH = WIDTH + log2(N)
    parameter int OUT_WIDTH = WIDTH + $clog2(N) 
)(
    input  logic clk,
    input  logic rst_n,
    input  logic signed [WIDTH-1:0]     data_in,
    output logic signed [OUT_WIDTH-1:0] data_out 
);

    // Delay line to keep track of the oldest sample
    logic signed [WIDTH-1:0] delay_line [0:N-1];
    
    // Internal accumulator
    logic signed [OUT_WIDTH-1:0] acc;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc <= '0;
            for (int i = 0; i < N; i++) begin
                delay_line[i] <= '0;
            end
        end else begin
            // 1. Update the accumulator: 
            acc <= acc + data_in - delay_line[N-1];

            // 2. Shift the delay line
            delay_line[0] <= data_in;
            for (int i = 1; i < N; i++) begin
                delay_line[i] <= delay_line[i-1];
            end
        end
    end

    // The output is the running sum
    assign data_out = acc;

endmodule

