`timescale 1ns/1ps

module tb_phase_detector;

reg clk;
reg rst_n;
reg decision_in;
reg sample_clk;
wire decision_out;
wire up;
wire down;

//////////////////////////////////////////
// Instantiate DUT
//////////////////////////////////////////

phase_detector dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_sample_clk(sample_clk),
    .i_decision_in(decision_in),
    .o_decision_out(decision_out),
    .o_up(up),
    .o_down(down)
);

//////////////////////////////////////////
// Clock 50 MHz
//////////////////////////////////////////

initial begin 
clk = 0;

sample_clk=0;
end
always #10 clk = ~clk;   // 20ns period
always #250 sample_clk = ~sample_clk; // 0.5 us period

//////////////////////////////////////////
// Stimulus
//////////////////////////////////////////

initial begin

    rst_n = 0;
    decision_in = 0;

    #100;
    rst_n = 1;

    //////////////////////////////////////
    // Sequence de bits
    //////////////////////////////////////

    #500 decision_in = 1;
    #500 decision_in = 0;
    #500 decision_in = 1;
    #500 decision_in = 1;
    #500 decision_in = 0;
    #500 decision_in = 0;
    #500 decision_in = 1;

    //////////////////////////////////////
    // Random data
    //////////////////////////////////////

    repeat(20) begin
        #500 decision_in = $random;
    end

    #1000 $stop;

end

//////////////////////////////////////////
// Monitoring
//////////////////////////////////////////

initial begin
    $display("time decision decision_out up down");
    $monitor("%t   %b        %b          %b   %b",
             $time, decision_in, decision_out, up, down);
end

/// assert 
always @(posedge sample_clk) begin
    if(!rst_n) begin
        assert(!(up && down))
        else $error("error : UP et DOWN actif en meme temps");
    end
end

reg decision_prev;
always @(posedge sample_clk) 
begin 
    decision_prev <= decision_in;
    if(!rst_n) begin
        if (decision_prev==0 && decision_in==1) 
        begin 
            assert (up==1)
            else $error("error : transition 0 1 sans up");
        end
    end
end

always @(posedge sample_clk) 
begin 
    decision_prev <= decision_in;
    if(!rst_n) begin
        if (decision_prev==1 && decision_in==0) 
        begin 
            assert (down==1)
            else $error("error : transition 1 0");
        end
    end
end

endmodule
