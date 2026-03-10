

module cdr_top
  #(parameter phase_resolution=6) (clk,rst,dphi, data,enable);
   input wire 		       	clk;
   input wire 			rst;
   input  wire [phase_resolution-1:0] 	dphi;
   output wire 		       	data;
   output wire 		      	enable;
   wire recovered_clk;
   wire 		       	decision;
   wire			decision_out;
   wire up;
   wire down;
   wire decision_sig;
   wire signed [15:0] control;
   reg u_data;

   
    decision_block u_dec (.dphi_in(dphi),.decision_out(decision_sig));

   phase_detector u_pd(.clk(clk),.sample(
   recovered_clk),.rst(rst),.decision_in(decision_sig),.decision_out(decision_out),.up(up),.down(down));
   loop_filter u_lf (.clk(clk),.rst(rst),.up(up),.down(down),.ctrl(control));
   nco u_nco (.clk(clk),.rst(rst),.ctrl(control),.sample_enable(enable),.recovered_clk(recovered_clk));
   assign data =u_data;
   always @(posedge enable)
   begin
    u_data <= decision_sig;
   
   end

endmodule
