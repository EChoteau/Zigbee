

module CDR_top
  #(parameter phase_resolution=6,
    parameter ctrl_width=4) 
  (i_clk,i_rst_n,i_dphi,o_data,o_enable,i_phase_detector_debug, i_loop_filter_debug,i_nco_debug,i_recovered_clk_d,i_decision_d,i_up_d,i_down_d,i_decision_sig_d,i_ack_d,i_control_d);
   input wire 		       	i_clk;
   input wire 			i_rst_n;
   input  wire [phase_resolution-1:0] 	i_dphi;
   output wire 		       	o_data;
   output wire 		      	o_enable;
   
   input wire i_recovered_clk_d,i_decision_d,i_up_d,i_down_d,i_decision_sig_d,i_ack_d; //forced signal
   input wire signed [ctrl_width-1:0] i_control_d;
   input wire i_phase_detector_debug, i_loop_filter_debug,i_nco_debug; // modules debug enable signals. no signal for decision because it's always connected
   wire s_recovered_clk;
   wire 		       	s_decision;
   reg			s_decision_out;
   wire s_up;
   wire s_down;
   wire s_decision_sig;
   wire signed [ctrl_width-1:0] s_control;
   wire s_ack;
   
   // phase detector debug 
   wire s_sample_clk;
   assign s_sample_clk = (i_phase_detector_debug) ? i_recovered_clk_d:s_recovered_clk;
   wire s_decision_in;
   assign s_decision_in = (i_phase_detector_debug) ? i_decision_d:s_decision_sig;
   
   // loop filter debug
   wire s_ctrl_ack;
   assign s_ctrl_ack = (i_loop_filter_debug) ? i_ack_d:s_ack;
   wire s_up_in;
   assign s_up_in = (i_loop_filter_debug) ? i_up_d:s_up;
   wire s_down_in;
   assign s_down_in = (i_loop_filter_debug) ? i_down_d:i_down_d;
    //nco 
    wire s_control_in;
   assign s_control_in = (i_nco_debug) ? i_control_d:s_control;
   
   always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n)
        s_decision_out <= 1'b0;
    else if (s_recovered_clk)
        s_decision_out <= s_decision_sig;
    end
    decision#(.resolution_in(phase_resolution)) u_dec (.i_clk(i_clk),.i_rst_n(i_rst_n),.i_dphi_in(i_dphi),.o_decision_out(s_decision_sig));

   phase_detector u_pd(.i_clk(i_clk),.i_sample_clk(s_recovered_clk),.i_rst_n(i_rst_n),.i_decision_in(s_decision_sig),.o_up(s_up),.o_down(s_down));
   
    loop_filter #(.WIDTH(ctrl_width)) u_lf (.i_clk(i_clk),.i_rst_n(i_rst_n),.i_up(s_up_in),.i_down(s_down_in),.o_ctrl(s_control),.i_ctrl_ack(s_ack));
   nco#(.CTRL_W(ctrl_width)) u_nco (.i_clk(i_clk),.i_rst_n(i_rst_n),.i_ctrl(s_control_in),.o_sample_enable(o_enable),.o_recovered_clk(s_recovered_clk),.o_ctrl_ack(s_ack));
   assign o_data =s_decision_out;

endmodule
