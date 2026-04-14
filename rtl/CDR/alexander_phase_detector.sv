    module phase_detector(clk,rst,sample,decision_in,decision_out, up,down);
        //inout definition
         input wire  clk;
         input wire rst;
         input wire  decision_in;
         output wire decision_out;
         output wire up;
         output wire down;
         input wire sample;
         
         logic a;
         logic b;
         logic c;
         //logic d;
         
         
         bascule b1(.ck(clk),.en(sample),.rst(rst),.D(decision_in), .Q(a));
         bascule b2(.ck(clk),.en(~sample),.rst(rst),.D(decision_in), .Q(b));
         bascule b3(.ck(clk),.en(sample),.rst(rst),.D(a), .Q(c));
         //bascule b4(.ck(clk),.en(sample),.rst(rst),.D(b), .Q(d));
         
         /*bascule b1(.ck(clk),.rst(rst),.D(decision_in), .Q(a));
         bascule b2(.ck(~clk),.rst(rst),.D(decision_in), .Q(b));
         bascule b3(.ck(clk),.rst(rst),.D(a), .Q(c));
         bascule b4(.ck(clk),.rst(rst),.D(b), .Q(d));*/
         assign decision_out = a;
         assign up      = (c ^ a) && ~(b ^ c);
         assign down    = (b ^ c) && ~(c ^ a);
       endmodule
