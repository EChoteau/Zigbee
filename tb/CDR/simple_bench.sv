`timescale 1ns/1ps

module tb_cdr;

    //---------------------------------
    // Clock 50 MHz
    //---------------------------------
    reg clk = 0;
    always #50 clk = ~clk;   // 20ns period → 50 MHz

    //---------------------------------
    // Reset
    //---------------------------------
    reg rst;
    
    //---------------------------------
    // Inputs to CDR
    //---------------------------------
    reg  signed [5:0] dphi;
    
    //---------------------------------
    // Outputs
    //---------------------------------
    wire decision_out;
    wire clk_rec;

    //---------------------------------
    // Instantiate DUT
    //---------------------------------
    CDR_top dut (
        .i_clk(clk),
        .i_rst_n(rst),
        .i_dphi(dphi),
        .o_data(decision_out),
        .o_enable(clk_rec),
        // debug signals.
        .i_recovered_clk_d('0),
        .i_decision_d('0),
        .i_up_d('0),
        .i_down_d('0),
        .i_decision_sig_d('0),
        .i_ack_d('0),
        .i_control_d('0),
        //debug control 
        .i_phase_detector_debug('0),
        .i_loop_filter_debug('0),
        .i_nco_debug('0)
    );

    //---------------------------------
    // Generate 2 MHz data (25 cycles of 50MHz)
    //---------------------------------
    reg data_bit;
    integer cnt;

    initial begin
        data_bit = 0;
        cnt = 0;
    end
    reg data_bit_p;
    reg data_bit_i;
    int nb_data_t=0;
   reg [2:0] same_count = 0;
    reg new_data;
    always @(posedge clk) begin
    if (cnt == 2) begin

        new_data = $random; // génère une nouvelle valeur aléatoire

        if (new_data == data_bit) begin
            same_count <= same_count + 1;
        end else begin
            same_count <= 0;
        end

        // Si data_bit est resté identique 7 cycles, force changement
        if (same_count >= 7) begin
            data_bit <= ~data_bit; // ou data_bit <= $random; pour random
            same_count <= 0;
        end else begin
            data_bit <= new_data;
        end
        data_bit_p <= data_bit;
        nb_data_t <= nb_data_t + 1;
        //data_bit_i <= data_bit;
    
    end 
    if ( cnt==4 )begin
    
    cnt <= 0;
    
    end
    else  begin
        cnt <= cnt + 1;
    end
end


    //---------------------------------
    // Generate derivative phase model
    // Simple model:
    // If clock not aligned → produce +/- 8
    //---------------------------------
    
    always @(posedge clk) begin
        if (data_bit)
            dphi <= 6'sd8;     // positive slope
        else
            dphi <= -6'sd8;    // negative slope
    end
    int nb_data = 0;
    int nb_err = 0;
    always @(posedge clk_rec)
    begin
        nb_data = nb_data+1;
     assert(decision_out==data_bit_p);
     if (decision_out!=data_bit_p) nb_err =nb_err+1;
     
     end
    //---------------------------------
    // Reset sequence
    //---------------------------------
    initial begin
        rst = 0;
        #500;
        rst = 1;
    end

    //---------------------------------
    // Simulation time
    //---------------------------------
    initial begin
        #20000000;
        
        $display("Transmis=%0d  Reçus=%0d  Erreurs=%0d  TEB=%0f",
                  nb_data_t, nb_data, nb_err,
                  (nb_data > 0) ? real'(nb_err)/real'(nb_data) : 0.0);
        $stop;
    end

endmodule
