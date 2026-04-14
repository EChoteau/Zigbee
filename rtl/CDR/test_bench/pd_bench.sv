`timescale 1ns/1ps

module tb_phase_detector;

reg clk;
reg rst;
reg decision;
reg enable;
wire decision_out;
wire up;
wire down;

//////////////////////////////////////////
// Instantiate DUT
//////////////////////////////////////////

phase_detector dut (
    .clk(clk),
    .rst(rst),
    .sample(enable),
    .decision_in(decision),
    .decision_out(decision_out),
    .up(up),
    .down(down)
);

//////////////////////////////////////////
// Clock 50 MHz
//////////////////////////////////////////

initial begin 
clk = 0;

enable=0;
end
always #10 clk = ~clk;   // 20ns period
always #250 enable = ~enable; // 0.5 us period

//////////////////////////////////////////
// Stimulus
//////////////////////////////////////////

initial begin

    rst = 0;
    decision = 0;

    #100;
    rst = 1;

    //////////////////////////////////////
    // Sequence de bits
    //////////////////////////////////////

    #500 decision = 1;
    #500 decision = 0;
    #500 decision = 1;
    #500 decision = 1;
    #500 decision = 0;
    #500 decision = 0;
    #500 decision = 1;

    //////////////////////////////////////
    // Random data
    //////////////////////////////////////

    repeat(20) begin
        #500 decision = $random;
    end

    #1000 $stop;

end

//////////////////////////////////////////
// Monitoring
//////////////////////////////////////////

initial begin
    $display("time decision decision_out up down");
    $monitor("%t   %b        %b          %b   %b",
             $time, decision, decision_out, up, down);
end

/// assert 
always @(posedge enable) begin
    if(!rst) begin
        assert(!(up && down))
        else $error("error : UP et DOWN actif en meme temps");
    end
end

reg decision_prev;
always @(posedge enable) 
begin 
    decision_prev <= decision;
    if(!rst) begin
        if (decision_prev==0 && decision==1) 
        begin 
            assert (up==1)
            else $error("error : transition 0 1 sans up");
        end
    end
end

always @(posedge enable) 
begin 
    decision_prev <= decision;
    if(!rst) begin
        if (decision_prev==1 && decision==0) 
        begin 
            assert (down==1)
            else $error("error : transition 1 0");
        end
    end
end

endmodule
