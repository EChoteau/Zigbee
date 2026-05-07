module nco #(
    parameter int PHASE_WIDTH = 16,
    parameter int K_NOMINAL   = 5,      // number of i_clk cycles per bit
    parameter int CTRL_W      = 8
) (
    input  logic                          i_clk,
    input  logic                          i_rst_n,
    input  logic signed [CTRL_W-1:0]      i_ctrl,
    output logic                          o_recovered_clk,
    output logic                          o_sample_enable,
    output logic                          o_ctrl_ack
);

    logic [3:0] s_period;   // Adjusted period: bounded between 4 and 6
    logic [3:0] s_cnt;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            s_cnt <= 4'h0;
            s_period <= 4'h5;  // K_NOMINAL
            o_sample_enable <= 1'b0;
            o_ctrl_ack <= 1'b0;
        end
        else begin
            o_sample_enable <= 1'b0;
            o_ctrl_ack <= 1'b0;

            if (s_cnt == (s_period - 4'h1)) begin
                s_cnt <= 4'h0;
                o_sample_enable <= 1'b1;
                o_ctrl_ack <= 1'b1;

                // Period adjustment based on control input
                if (i_ctrl > 0 && s_period < 4'h6) 
                    s_period <= s_period + 4'h1;
                else if (i_ctrl < 0 && s_period > 4'h4) 
                    s_period <= s_period - 4'h1;
                else 
                    s_period <= 4'h5;  // K_NOMINAL
            end
            else begin
                s_cnt <= s_cnt + 4'h1;
            end
        end
    end

    // Recovered clock = MSB of counter (50% duty cycle)
    assign o_recovered_clk = s_cnt < (s_period >> 1);

endmodule
