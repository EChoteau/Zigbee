module boxcar_filter #(
    parameter int WIDTH = 16,
    parameter int N     = 8,      // Filter length
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic signed [WIDTH-1:0] i_data,
    output logic signed [WIDTH-1:0] o_data 
);

    // Delay line to keep track of the oldest sample
    logic signed [WIDTH-1:0] s_delay_line [0:N-1];
    
    // Internal accumulator: wider to avoid intermediate overflow
    localparam int ACC_WIDTH = WIDTH + $clog2(N);
    // Saturation limits (represented in ACC_WIDTH bits)
    localparam logic signed [ACC_WIDTH-1:0] SAT_MAX = (1 << (WIDTH-1)) - 1;
    localparam logic signed [ACC_WIDTH-1:0] SAT_MIN = - (1 << (WIDTH-1));

    // Use a wider accumulator internally, but output is WIDTH
    logic signed [ACC_WIDTH-1:0] s_acc;
    logic signed [WIDTH-1:0] s_out;

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

    // Saturate the accumulator to the interface width limits
    always_comb begin
        if (s_acc > SAT_MAX)
            s_out = SAT_MAX[WIDTH-1:0];
        else if (s_acc < SAT_MIN)
            s_out = SAT_MIN[WIDTH-1:0];
        else
            s_out = s_acc[WIDTH-1:0];
    end

    // The output is the possibly-saturated running sum
    assign o_data = s_out;

endmodule

