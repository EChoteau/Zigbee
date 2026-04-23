

module cdr_top
  #(parameter phase_resolution=6,
    parameter ctrl_width=2) 
  (i_clk,i_rst_n,i_dphi, o_data,o_enable);
   input wire 		       	i_clk;
   input wire 			i_rst_n;
   input  wire [phase_resolution-1:0] 	i_dphi;
   output wire 		       	o_data;
   output wire 		      	o_enable;
   wire s_recovered_clk;
   wire 		       	s_decision;
   reg			s_decision_out;
   wire s_up;
   wire s_down;
   wire s_decision_sig;
   wire signed [ctrl_width-1:0] s_control;
    wire s_ack;
   
   
   always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n)
        s_decision_out <= 1'b0;
    else if (s_recovered_clk)
        s_decision_out <= s_decision_sig;
    end
    decision_block#(.resolution_in(phase_resolution)) u_dec (.i_dphi_in(i_dphi),.o_decision_out(s_decision_sig));

   phase_detector u_pd(.i_clk(i_clk),.i_sample_clk(s_recovered_clk),.i_rst_n(i_rst_n),.i_decision_in(s_decision_sig),.o_up(s_up),.o_down(s_down));
    loop_filter #(.WIDTH(ctrl_width)) u_lf (.i_clk(i_clk),.i_rst_n(i_rst_n),.i_up(s_up),.i_down(s_down),.o_ctrl(s_control),.i_ctrl_ack(s_ack));
   nco#(.CTRL_W(ctrl_width)) u_nco (.i_clk(i_clk),.i_rst_n(i_rst_n),.i_ctrl(s_control),.o_sample_enable(o_enable),.o_recovered_clk(s_recovered_clk),.o_ctrl_ack(s_ack));
   assign o_data =s_decision_out;

endmodule
