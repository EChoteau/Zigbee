/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : U-2022.12
// Date      : Fri Apr 24 09:05:55 2026
/////////////////////////////////////////////////////////////


module interface ( i_clk, i_rst_n, i_psel, i_penable, i_pwrite, 
        i_paddr, i_pwdata, o_prdata, o_pready, o_pslverr, i_serial_rx, 
        i_cdr_sample_valid, o_serial_tx, o_tx_valid, o_tx_sample_tick, 
        o_dbg_tx_fifo_data, o_dbg_tx_fifo_push, o_dbg_tx_fifo_full, 
        o_dbg_tx_fifo_pop, o_dbg_tx_fifo_q, o_dbg_tx_fifo_rd_valid, 
        o_dbg_tx_fifo_empty, o_dbg_rx_fifo_data, o_dbg_rx_fifo_push, 
        o_dbg_rx_fifo_full, o_dbg_rx_fifo_pop, o_dbg_rx_fifo_q, 
        o_dbg_rx_fifo_empty, o_dbg_rx_ovf_pulse, o_dbg_tx_tick, 
        o_dbg_tx_path_en, o_dbg_rx_path_en, o_dbg_global_en, o_dbg_tx_start, 
        o_dbg_rx_enable, o_dbg_div_val, o_dbg_tx_und_err, o_dbg_rx_ovf_err );
  input [7:0] i_paddr;
  input [31:0] i_pwdata;
  output [31:0] o_prdata;
  output [7:0] o_dbg_tx_fifo_data;
  output [7:0] o_dbg_tx_fifo_q;
  output [7:0] o_dbg_rx_fifo_data;
  output [7:0] o_dbg_rx_fifo_q;
  output [7:0] o_dbg_div_val;
  input i_clk, i_rst_n, i_psel, i_penable, i_pwrite, i_serial_rx,
         i_cdr_sample_valid;
  output o_pready, o_pslverr, o_serial_tx, o_tx_valid, o_tx_sample_tick,
         o_dbg_tx_fifo_push, o_dbg_tx_fifo_full, o_dbg_tx_fifo_pop,
         o_dbg_tx_fifo_rd_valid, o_dbg_tx_fifo_empty, o_dbg_rx_fifo_push,
         o_dbg_rx_fifo_full, o_dbg_rx_fifo_pop, o_dbg_rx_fifo_empty,
         o_dbg_rx_ovf_pulse, o_dbg_tx_tick, o_dbg_tx_path_en,
         o_dbg_rx_path_en, o_dbg_global_en, o_dbg_tx_start, o_dbg_rx_enable,
         o_dbg_tx_und_err, o_dbg_rx_ovf_err;
  wire   \*Logic0* , o_tx_valid, s_tx_run, s_tx_path_en_d, w_sw_reset,
         w_clear_err, \u_apb_slave_regs/s_tx_push_n , \u_fifo_tx/N40 ,
         \u_fifo_tx/s_mem[7][7] , \u_fifo_tx/s_mem[7][6] ,
         \u_fifo_tx/s_mem[7][5] , \u_fifo_tx/s_mem[7][4] ,
         \u_fifo_tx/s_mem[7][3] , \u_fifo_tx/s_mem[7][2] ,
         \u_fifo_tx/s_mem[7][1] , \u_fifo_tx/s_mem[7][0] ,
         \u_fifo_tx/s_mem[6][7] , \u_fifo_tx/s_mem[6][6] ,
         \u_fifo_tx/s_mem[6][5] , \u_fifo_tx/s_mem[6][4] ,
         \u_fifo_tx/s_mem[6][3] , \u_fifo_tx/s_mem[6][2] ,
         \u_fifo_tx/s_mem[6][1] , \u_fifo_tx/s_mem[6][0] ,
         \u_fifo_tx/s_mem[5][7] , \u_fifo_tx/s_mem[5][6] ,
         \u_fifo_tx/s_mem[5][5] , \u_fifo_tx/s_mem[5][4] ,
         \u_fifo_tx/s_mem[5][3] , \u_fifo_tx/s_mem[5][2] ,
         \u_fifo_tx/s_mem[5][1] , \u_fifo_tx/s_mem[5][0] ,
         \u_fifo_tx/s_mem[4][7] , \u_fifo_tx/s_mem[4][6] ,
         \u_fifo_tx/s_mem[4][5] , \u_fifo_tx/s_mem[4][4] ,
         \u_fifo_tx/s_mem[4][3] , \u_fifo_tx/s_mem[4][2] ,
         \u_fifo_tx/s_mem[4][1] , \u_fifo_tx/s_mem[4][0] ,
         \u_fifo_tx/s_mem[3][7] , \u_fifo_tx/s_mem[3][6] ,
         \u_fifo_tx/s_mem[3][5] , \u_fifo_tx/s_mem[3][4] ,
         \u_fifo_tx/s_mem[3][3] , \u_fifo_tx/s_mem[3][2] ,
         \u_fifo_tx/s_mem[3][1] , \u_fifo_tx/s_mem[3][0] ,
         \u_fifo_tx/s_mem[2][7] , \u_fifo_tx/s_mem[2][6] ,
         \u_fifo_tx/s_mem[2][5] , \u_fifo_tx/s_mem[2][4] ,
         \u_fifo_tx/s_mem[2][3] , \u_fifo_tx/s_mem[2][2] ,
         \u_fifo_tx/s_mem[2][1] , \u_fifo_tx/s_mem[2][0] ,
         \u_fifo_tx/s_mem[1][7] , \u_fifo_tx/s_mem[1][6] ,
         \u_fifo_tx/s_mem[1][5] , \u_fifo_tx/s_mem[1][4] ,
         \u_fifo_tx/s_mem[1][3] , \u_fifo_tx/s_mem[1][2] ,
         \u_fifo_tx/s_mem[1][1] , \u_fifo_tx/s_mem[1][0] ,
         \u_fifo_tx/s_mem[0][7] , \u_fifo_tx/s_mem[0][6] ,
         \u_fifo_tx/s_mem[0][5] , \u_fifo_tx/s_mem[0][4] ,
         \u_fifo_tx/s_mem[0][3] , \u_fifo_tx/s_mem[0][2] ,
         \u_fifo_tx/s_mem[0][1] , \u_fifo_tx/s_mem[0][0] , \u_serializer/N38 ,
         \u_serializer/N23 , \u_serializer/s_bit_event_d ,
         \u_serializer/s_waiting_fifo_data , \u_deserializer/N24 ,
         \u_deserializer/N23 , \u_tx_baud_rate_gen/N35 ,
         \u_tx_baud_rate_gen/N34 , \u_tx_baud_rate_gen/N33 ,
         \u_tx_baud_rate_gen/N32 , \u_tx_baud_rate_gen/N31 ,
         \u_tx_baud_rate_gen/N30 , \u_tx_baud_rate_gen/N29 ,
         \u_tx_baud_rate_gen/N28 , \u_tx_baud_rate_gen/N27 ,
         \u_fifo_rx/s_mem[7][7] , \u_fifo_rx/s_mem[7][6] ,
         \u_fifo_rx/s_mem[7][5] , \u_fifo_rx/s_mem[7][4] ,
         \u_fifo_rx/s_mem[7][3] , \u_fifo_rx/s_mem[7][2] ,
         \u_fifo_rx/s_mem[7][1] , \u_fifo_rx/s_mem[7][0] ,
         \u_fifo_rx/s_mem[6][7] , \u_fifo_rx/s_mem[6][6] ,
         \u_fifo_rx/s_mem[6][5] , \u_fifo_rx/s_mem[6][4] ,
         \u_fifo_rx/s_mem[6][3] , \u_fifo_rx/s_mem[6][2] ,
         \u_fifo_rx/s_mem[6][1] , \u_fifo_rx/s_mem[6][0] ,
         \u_fifo_rx/s_mem[5][7] , \u_fifo_rx/s_mem[5][6] ,
         \u_fifo_rx/s_mem[5][5] , \u_fifo_rx/s_mem[5][4] ,
         \u_fifo_rx/s_mem[5][3] , \u_fifo_rx/s_mem[5][2] ,
         \u_fifo_rx/s_mem[5][1] , \u_fifo_rx/s_mem[5][0] ,
         \u_fifo_rx/s_mem[4][7] , \u_fifo_rx/s_mem[4][6] ,
         \u_fifo_rx/s_mem[4][5] , \u_fifo_rx/s_mem[4][4] ,
         \u_fifo_rx/s_mem[4][3] , \u_fifo_rx/s_mem[4][2] ,
         \u_fifo_rx/s_mem[4][1] , \u_fifo_rx/s_mem[4][0] ,
         \u_fifo_rx/s_mem[3][7] , \u_fifo_rx/s_mem[3][6] ,
         \u_fifo_rx/s_mem[3][5] , \u_fifo_rx/s_mem[3][4] ,
         \u_fifo_rx/s_mem[3][3] , \u_fifo_rx/s_mem[3][2] ,
         \u_fifo_rx/s_mem[3][1] , \u_fifo_rx/s_mem[3][0] ,
         \u_fifo_rx/s_mem[2][7] , \u_fifo_rx/s_mem[2][6] ,
         \u_fifo_rx/s_mem[2][5] , \u_fifo_rx/s_mem[2][4] ,
         \u_fifo_rx/s_mem[2][3] , \u_fifo_rx/s_mem[2][2] ,
         \u_fifo_rx/s_mem[2][1] , \u_fifo_rx/s_mem[2][0] ,
         \u_fifo_rx/s_mem[1][7] , \u_fifo_rx/s_mem[1][6] ,
         \u_fifo_rx/s_mem[1][5] , \u_fifo_rx/s_mem[1][4] ,
         \u_fifo_rx/s_mem[1][3] , \u_fifo_rx/s_mem[1][2] ,
         \u_fifo_rx/s_mem[1][1] , \u_fifo_rx/s_mem[1][0] ,
         \u_fifo_rx/s_mem[0][7] , \u_fifo_rx/s_mem[0][6] ,
         \u_fifo_rx/s_mem[0][5] , \u_fifo_rx/s_mem[0][4] ,
         \u_fifo_rx/s_mem[0][3] , \u_fifo_rx/s_mem[0][2] ,
         \u_fifo_rx/s_mem[0][1] , \u_fifo_rx/s_mem[0][0] , \eq_x_54/n25 ,
         \eq_x_23/n25 , n354, n355, n356, n357, n358, n359, n360, n361, n362,
         n363, n364, n365, n366, n367, n368, n369, n370, n371, n372, n373,
         n374, n375, n376, n377, n378, n381, n385, n387, n389, n391, n393,
         n451, n452, n453, n454, n455, n456, n457, n458, n459, n460, n461,
         n462, n463, n464, n465, n466, n467, n468, n469, n470, n471, n472,
         n473, n474, n475, n476, n477, n478, n479, n544, n545, n546, n547,
         n548, n549, n550, n551, n552, n555, n556, n557, n559, n568, n569,
         n570, n571, n572, n573, n574, n575, n576, n577, n578, n579, n580,
         n581, n582, n583, n584, n585, n586, n587, n588, n589, n590, n591,
         n592, n593, n594, n595, n596, n597, n598, n599, n600, n601, n602,
         n603, n604, n605, n606, n607, n608, n609, n610, n611, n612, n613,
         n614, n615, n616, n617, n618, n619, n620, n621, n622, n623, n624,
         n625, n626, n627, n628, n629, n630, n631, n632, n633, n634, n635,
         n636, n637, n638, n639, n640, n641, n642, n643, n644, n645, n646,
         n647, n648, n649, n650, n651, n652, n653, n654, n655, n656, n657,
         n658, n659, n660, n661, n662, n663, n664, n665, n666, n667, n668,
         n669, n670, n671, n672, n673, n674, n675, n676, n677, n678, n679,
         n680, n681, n682, n683, n684, n685, n686, n687, n688, n689, n690,
         n691, n692, n693, n694, n695, n696, n697, n698, n699, n700, n701,
         n702, n703, n704, n705, n706, n707, n708, n709, n710, n711, n712,
         n713, n714, n715, n716, n717, n718, n719, n720, n721, n722, n723,
         n724, n725, n726, n727, n728, n729, n730, n731, n732, n733, n734,
         n735, n736, n737, n738, n739, n740, n741, n742, n743, n744, n745,
         n746, n747, n748, n749, n750, n751, n752, n753, n754, n755, n756,
         n757, n758, n759, n760, n761, n762, n763, n764, n765, n766, n767,
         n768, n769, n770, n771, n772, n773, n774, n775, n776, n777, n778,
         n779, n780, n781, n782, n783, n784, n785, n786, n787, n788, n789,
         n790, n791, n792, n793, n794, n795, n796, n797, n798, n799, n800,
         n801, n802, n803, n804, n805, n806, n807, n808, n809, n810, n811,
         n812, n813, n814, n815, n816, n817, n818, n819, n820, n821, n822,
         n823, n824, n825, n826, n827, n828, n829, n830, n831, n832, n833,
         n834, n835, n836, n837, n838, n839, n840, n841, n842, n843, n844,
         n845, n846, n847, n848, n849, n850, n851, n852, n853, n854, n855,
         n856, n857, n858, n859, n860, n861, n862, n863, n864, n865, n866,
         n867, n868, n869, n870, n871, n872, n873, n874, n875, n876, n877,
         n878, n879, n880, n881, n882, n883, n884, n885, n886, n887, n888,
         n889, n890, n891, n892, n893, n894, n895, n896, n897, n898, n899,
         n900, n901, n902, n903;
  wire   [3:1] \u_apb_slave_regs/s_reg_control_n ;
  wire   [7:0] \u_apb_slave_regs/s_reg_divider ;
  wire   [3:0] \u_fifo_tx/s_rd_ptr ;
  wire   [3:0] \u_fifo_tx/s_wr_ptr ;
  wire   [2:0] \u_serializer/s_bit_count ;
  wire   [7:0] \u_serializer/s_shift_reg ;
  wire   [2:0] \u_deserializer/s_bit_count ;
  wire   [7:1] \u_deserializer/s_shift_reg ;
  wire   [7:0] \u_tx_baud_rate_gen/s_counter ;
  wire   [3:0] \u_fifo_rx/s_rd_ptr ;
  wire   [3:0] \u_fifo_rx/s_wr_ptr ;
  assign o_pslverr = \*Logic0* ;
  assign o_prdata[8] = \*Logic0* ;
  assign o_prdata[9] = \*Logic0* ;
  assign o_prdata[10] = \*Logic0* ;
  assign o_prdata[11] = \*Logic0* ;
  assign o_prdata[12] = \*Logic0* ;
  assign o_prdata[13] = \*Logic0* ;
  assign o_prdata[14] = \*Logic0* ;
  assign o_prdata[15] = \*Logic0* ;
  assign o_prdata[16] = \*Logic0* ;
  assign o_prdata[17] = \*Logic0* ;
  assign o_prdata[18] = \*Logic0* ;
  assign o_prdata[19] = \*Logic0* ;
  assign o_prdata[20] = \*Logic0* ;
  assign o_prdata[21] = \*Logic0* ;
  assign o_prdata[22] = \*Logic0* ;
  assign o_prdata[23] = \*Logic0* ;
  assign o_prdata[24] = \*Logic0* ;
  assign o_prdata[25] = \*Logic0* ;
  assign o_prdata[26] = \*Logic0* ;
  assign o_prdata[27] = \*Logic0* ;
  assign o_prdata[28] = \*Logic0* ;
  assign o_prdata[29] = \*Logic0* ;
  assign o_prdata[30] = \*Logic0* ;
  assign o_prdata[31] = \*Logic0* ;
  assign o_dbg_div_val[7] = \u_apb_slave_regs/s_reg_divider  [7];
  assign o_dbg_div_val[6] = \u_apb_slave_regs/s_reg_divider  [6];
  assign o_dbg_div_val[5] = \u_apb_slave_regs/s_reg_divider  [5];
  assign o_dbg_div_val[4] = \u_apb_slave_regs/s_reg_divider  [4];
  assign o_dbg_div_val[3] = \u_apb_slave_regs/s_reg_divider  [3];
  assign o_dbg_div_val[2] = \u_apb_slave_regs/s_reg_divider  [2];
  assign o_dbg_div_val[1] = \u_apb_slave_regs/s_reg_divider  [1];
  assign o_dbg_rx_fifo_empty = \eq_x_54/n25 ;
  assign o_dbg_tx_fifo_empty = \eq_x_23/n25 ;

  DFC1 \u_apb_slave_regs/s_reg_control_reg[1]  ( .D(
        \u_apb_slave_regs/s_reg_control_n [1]), .C(i_clk), .RN(i_rst_n), .Q(
        w_sw_reset) );
  DFC1 \u_apb_slave_regs/s_reg_control_reg[2]  ( .D(
        \u_apb_slave_regs/s_reg_control_n [2]), .C(i_clk), .RN(i_rst_n), .Q(
        w_clear_err) );
  DFC1 \u_apb_slave_regs/s_reg_control_reg[3]  ( .D(
        \u_apb_slave_regs/s_reg_control_n [3]), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_tx_start) );
  DFC1 \u_apb_slave_regs/s_reg_control_reg[4]  ( .D(n559), .C(i_clk), .RN(
        i_rst_n), .Q(o_dbg_rx_enable) );
  DFC1 \u_deserializer/s_bit_count_reg[0]  ( .D(n453), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_deserializer/s_bit_count [0]), .QN(n874) );
  DFC1 \u_deserializer/s_bit_count_reg[1]  ( .D(n452), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_deserializer/s_bit_count [1]) );
  DFC1 \u_deserializer/s_bit_count_reg[2]  ( .D(n451), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_deserializer/s_bit_count [2]) );
  DFC1 \u_tx_baud_rate_gen/o_tick_reg  ( .D(\u_tx_baud_rate_gen/N27 ), .C(
        i_clk), .RN(i_rst_n), .Q(o_dbg_tx_tick), .QN(n870) );
  DFC1 \u_serializer/s_bit_event_d_reg  ( .D(\u_serializer/N38 ), .C(i_clk), 
        .RN(i_rst_n), .Q(\u_serializer/s_bit_event_d ) );
  DFC1 \u_serializer/o_tx_sample_tick_reg  ( .D(\u_serializer/s_bit_event_d ), 
        .C(i_clk), .RN(i_rst_n), .Q(o_tx_sample_tick) );
  DFC1 \u_serializer/s_bit_count_reg[1]  ( .D(n477), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_bit_count [1]), .QN(n857) );
  DFC1 \u_serializer/o_tx_busy_reg  ( .D(n557), .C(i_clk), .RN(i_rst_n), .Q(
        o_tx_valid), .QN(n848) );
  DFC1 \u_tx_baud_rate_gen/s_counter_reg[0]  ( .D(\u_tx_baud_rate_gen/N28 ), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_tx_baud_rate_gen/s_counter [0]), .QN(
        n849) );
  DFC1 \u_tx_baud_rate_gen/s_counter_reg[1]  ( .D(\u_tx_baud_rate_gen/N29 ), 
        .C(i_clk), .RN(i_rst_n), .QN(n842) );
  DFC1 \u_tx_baud_rate_gen/s_counter_reg[2]  ( .D(\u_tx_baud_rate_gen/N30 ), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_tx_baud_rate_gen/s_counter [2]), .QN(
        n856) );
  DFC1 \u_tx_baud_rate_gen/s_counter_reg[3]  ( .D(\u_tx_baud_rate_gen/N31 ), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_tx_baud_rate_gen/s_counter [3]) );
  DFC1 \u_tx_baud_rate_gen/s_counter_reg[4]  ( .D(\u_tx_baud_rate_gen/N32 ), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_tx_baud_rate_gen/s_counter [4]), .QN(
        n858) );
  DFC1 \u_tx_baud_rate_gen/s_counter_reg[5]  ( .D(\u_tx_baud_rate_gen/N33 ), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_tx_baud_rate_gen/s_counter [5]) );
  DFC1 \u_tx_baud_rate_gen/s_counter_reg[6]  ( .D(\u_tx_baud_rate_gen/N34 ), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_tx_baud_rate_gen/s_counter [6]), .QN(
        n859) );
  DFC1 \u_tx_baud_rate_gen/s_counter_reg[7]  ( .D(\u_tx_baud_rate_gen/N35 ), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_tx_baud_rate_gen/s_counter [7]) );
  DFC1 \u_serializer/s_waiting_fifo_data_reg  ( .D(n555), .C(i_clk), .RN(
        i_rst_n), .Q(\u_serializer/s_waiting_fifo_data ), .QN(n871) );
  DFC1 \u_serializer/o_tx_fifo_pop_reg  ( .D(\u_serializer/N23 ), .C(i_clk), 
        .RN(i_rst_n), .Q(o_dbg_tx_fifo_pop) );
  DFC1 \u_fifo_tx/o_rd_valid_reg  ( .D(\u_fifo_tx/N40 ), .C(i_clk), .RN(
        i_rst_n), .Q(o_dbg_tx_fifo_rd_valid) );
  DFC1 \u_apb_slave_regs/o_tx_push_reg  ( .D(\u_apb_slave_regs/s_tx_push_n ), 
        .C(i_clk), .RN(i_rst_n), .Q(o_dbg_tx_fifo_push) );
  DFC1 \u_apb_slave_regs/o_tx_data_reg[6]  ( .D(n552), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_tx_fifo_data[6]) );
  DFC1 \u_apb_slave_regs/o_tx_data_reg[0]  ( .D(n551), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_tx_fifo_data[0]) );
  DFC1 \u_apb_slave_regs/o_tx_data_reg[1]  ( .D(n550), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_tx_fifo_data[1]) );
  DFC1 \u_apb_slave_regs/o_tx_data_reg[2]  ( .D(n549), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_tx_fifo_data[2]) );
  DFC1 \u_apb_slave_regs/o_tx_data_reg[3]  ( .D(n548), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_tx_fifo_data[3]) );
  DFC1 \u_apb_slave_regs/o_tx_data_reg[4]  ( .D(n547), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_tx_fifo_data[4]) );
  DFC1 \u_apb_slave_regs/o_tx_data_reg[5]  ( .D(n546), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_tx_fifo_data[5]) );
  DFC1 \u_apb_slave_regs/o_tx_data_reg[7]  ( .D(n545), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_tx_fifo_data[7]) );
  DFC1 \u_fifo_tx/s_wr_ptr_reg[3]  ( .D(n544), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_tx/s_wr_ptr [3]), .QN(n876) );
  DFC1 s_tx_run_reg ( .D(n556), .C(i_clk), .RN(i_rst_n), .Q(s_tx_run) );
  DFC1 s_tx_path_en_d_reg ( .D(o_dbg_tx_path_en), .C(i_clk), .RN(i_rst_n), .Q(
        s_tx_path_en_d) );
  DFC1 \u_serializer/s_bit_count_reg[2]  ( .D(n479), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_bit_count [2]), .QN(n873) );
  DFC1 \u_serializer/s_bit_count_reg[0]  ( .D(n478), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_bit_count [0]), .QN(n843) );
  DFC1 s_tx_und_err_reg ( .D(n455), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_tx_und_err) );
  DFC1 \u_serializer/s_shift_reg_reg[7]  ( .D(n469), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_shift_reg [7]) );
  DFC1 \u_serializer/s_shift_reg_reg[6]  ( .D(n470), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_shift_reg [6]) );
  DFC1 \u_serializer/s_shift_reg_reg[5]  ( .D(n471), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_shift_reg [5]) );
  DFC1 \u_serializer/s_shift_reg_reg[4]  ( .D(n472), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_shift_reg [4]) );
  DFC1 \u_serializer/s_shift_reg_reg[3]  ( .D(n473), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_shift_reg [3]) );
  DFC1 \u_serializer/s_shift_reg_reg[2]  ( .D(n474), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_shift_reg [2]) );
  DFC1 \u_serializer/s_shift_reg_reg[1]  ( .D(n475), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_shift_reg [1]) );
  DFC1 \u_serializer/s_shift_reg_reg[0]  ( .D(n476), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_serializer/s_shift_reg [0]) );
  DFC1 \u_fifo_rx/s_wr_ptr_reg[3]  ( .D(n468), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_rx/s_wr_ptr [3]) );
  DFC1 \u_fifo_rx/s_rd_ptr_reg[0]  ( .D(n467), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_rx/s_rd_ptr [0]), .QN(n844) );
  DFC1 \u_fifo_rx/s_rd_ptr_reg[1]  ( .D(n466), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_rx/s_rd_ptr [1]), .QN(n862) );
  DFC1 \u_fifo_rx/s_rd_ptr_reg[2]  ( .D(n465), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_rx/s_rd_ptr [2]), .QN(n861) );
  DFC1 \u_fifo_rx/s_rd_ptr_reg[3]  ( .D(n464), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_rx/s_rd_ptr [3]), .QN(n863) );
  DFC1 \u_deserializer/o_ovf_pulse_reg  ( .D(\u_deserializer/N23 ), .C(i_clk), 
        .RN(i_rst_n), .Q(o_dbg_rx_ovf_pulse), .QN(n877) );
  DFC1 s_rx_ovf_err_reg ( .D(n454), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_rx_ovf_err), .QN(n860) );
  DFC1 \u_deserializer/o_para_data_reg[0]  ( .D(n463), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_rx_fifo_data[0]) );
  DFC1 \u_deserializer/o_para_data_reg[7]  ( .D(n462), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_rx_fifo_data[7]) );
  DFC1 \u_deserializer/o_para_data_reg[6]  ( .D(n461), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_rx_fifo_data[6]) );
  DFC1 \u_deserializer/o_para_data_reg[5]  ( .D(n460), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_rx_fifo_data[5]) );
  DFC1 \u_deserializer/o_para_data_reg[4]  ( .D(n459), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_rx_fifo_data[4]) );
  DFC1 \u_deserializer/o_para_data_reg[3]  ( .D(n458), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_rx_fifo_data[3]) );
  DFC1 \u_deserializer/o_para_data_reg[2]  ( .D(n457), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_rx_fifo_data[2]) );
  DFC1 \u_deserializer/o_para_data_reg[1]  ( .D(n456), .C(i_clk), .RN(i_rst_n), 
        .Q(o_dbg_rx_fifo_data[1]) );
  DFC1 \u_deserializer/o_push_reg  ( .D(\u_deserializer/N24 ), .C(i_clk), .RN(
        i_rst_n), .Q(o_dbg_rx_fifo_push) );
  DFC1 \u_fifo_rx/o_data_reg[0]  ( .D(n393), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_rx_fifo_q[0]) );
  DFC1 \u_fifo_rx/o_data_reg[1]  ( .D(n391), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_rx_fifo_q[1]) );
  DFC1 \u_fifo_rx/o_data_reg[2]  ( .D(n389), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_rx_fifo_q[2]) );
  DFC1 \u_fifo_rx/o_data_reg[3]  ( .D(n387), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_rx_fifo_q[3]) );
  DFC1 \u_fifo_rx/o_data_reg[4]  ( .D(n385), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_rx_fifo_q[4]) );
  DFC1 \u_fifo_rx/o_data_reg[6]  ( .D(n381), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_rx_fifo_q[6]), .QN(n886) );
  DFC1 \u_fifo_rx/o_data_reg[7]  ( .D(n378), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_rx_fifo_q[7]), .QN(n887) );
  DFC1 \u_deserializer/s_shift_reg_reg[7]  ( .D(n377), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_deserializer/s_shift_reg [7]) );
  DFC1 \u_deserializer/s_shift_reg_reg[6]  ( .D(n376), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_deserializer/s_shift_reg [6]) );
  DFC1 \u_deserializer/s_shift_reg_reg[5]  ( .D(n375), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_deserializer/s_shift_reg [5]) );
  DFC1 \u_deserializer/s_shift_reg_reg[4]  ( .D(n374), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_deserializer/s_shift_reg [4]) );
  DFC1 \u_deserializer/s_shift_reg_reg[3]  ( .D(n373), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_deserializer/s_shift_reg [3]) );
  DFC1 \u_deserializer/s_shift_reg_reg[2]  ( .D(n372), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_deserializer/s_shift_reg [2]) );
  DFC1 \u_deserializer/s_shift_reg_reg[1]  ( .D(n371), .C(i_clk), .RN(i_rst_n), 
        .Q(\u_deserializer/s_shift_reg [1]) );
  DFC1 \u_fifo_tx/s_rd_ptr_reg[1]  ( .D(n370), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_tx/s_rd_ptr [1]), .QN(n845) );
  DFC1 \u_fifo_tx/s_rd_ptr_reg[2]  ( .D(n369), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_tx/s_rd_ptr [2]), .QN(n872) );
  DFC1 \u_fifo_tx/s_wr_ptr_reg[0]  ( .D(n368), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_tx/s_wr_ptr [0]), .QN(n868) );
  DFC1 \u_fifo_tx/s_wr_ptr_reg[1]  ( .D(n367), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_tx/s_wr_ptr [1]), .QN(n869) );
  DFC1 \u_fifo_tx/s_wr_ptr_reg[2]  ( .D(n366), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_tx/s_wr_ptr [2]), .QN(n864) );
  DFC1 \u_fifo_tx/o_data_reg[0]  ( .D(n365), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_tx_fifo_q[0]), .QN(n878) );
  DFC1 \u_fifo_tx/o_data_reg[7]  ( .D(n364), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_tx_fifo_q[7]) );
  DFC1 \u_fifo_tx/o_data_reg[6]  ( .D(n363), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_tx_fifo_q[6]), .QN(n884) );
  DFC1 \u_fifo_tx/o_data_reg[5]  ( .D(n362), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_tx_fifo_q[5]), .QN(n883) );
  DFC1 \u_fifo_tx/o_data_reg[4]  ( .D(n361), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_tx_fifo_q[4]), .QN(n882) );
  DFC1 \u_fifo_tx/o_data_reg[3]  ( .D(n360), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_tx_fifo_q[3]), .QN(n881) );
  DFC1 \u_fifo_tx/o_data_reg[2]  ( .D(n359), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_tx_fifo_q[2]), .QN(n880) );
  DFC1 \u_fifo_tx/o_data_reg[1]  ( .D(n358), .C(i_clk), .RN(i_rst_n), .Q(
        o_dbg_tx_fifo_q[1]), .QN(n879) );
  DFC1 \u_serializer/o_serial_data_reg  ( .D(n357), .C(i_clk), .RN(i_rst_n), 
        .Q(o_serial_tx) );
  DFC1 \u_fifo_rx/s_wr_ptr_reg[0]  ( .D(n356), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_rx/s_wr_ptr [0]) );
  DFC1 \u_fifo_rx/s_wr_ptr_reg[1]  ( .D(n355), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_rx/s_wr_ptr [1]), .QN(n867) );
  DFC1 \u_fifo_rx/s_wr_ptr_reg[2]  ( .D(n354), .C(i_clk), .RN(i_rst_n), .Q(
        \u_fifo_rx/s_wr_ptr [2]), .QN(n865) );
  DFEP1 \u_apb_slave_regs/s_reg_divider_reg[0]  ( .D(n889), .E(n890), .C(i_clk), .SN(i_rst_n), .Q(n847) );
  DFEC1 \u_apb_slave_regs/s_reg_divider_reg[4]  ( .D(i_pwdata[4]), .E(n890), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_apb_slave_regs/s_reg_divider [4]), .QN(
        n855) );
  DFEC1 \u_apb_slave_regs/s_reg_divider_reg[3]  ( .D(i_pwdata[3]), .E(n890), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_apb_slave_regs/s_reg_divider [3]), .QN(
        n852) );
  DFEC1 \u_apb_slave_regs/s_reg_divider_reg[2]  ( .D(i_pwdata[2]), .E(n890), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_apb_slave_regs/s_reg_divider [2]), .QN(
        n853) );
  DFEC1 \u_apb_slave_regs/s_reg_divider_reg[1]  ( .D(i_pwdata[1]), .E(n890), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_apb_slave_regs/s_reg_divider [1]), .QN(
        n854) );
  DFEC1 \u_apb_slave_regs/s_reg_divider_reg[5]  ( .D(i_pwdata[5]), .E(n890), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_apb_slave_regs/s_reg_divider [5]), .QN(
        n851) );
  DFEC1 \u_apb_slave_regs/s_reg_divider_reg[6]  ( .D(i_pwdata[6]), .E(n890), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_apb_slave_regs/s_reg_divider [6]), .QN(
        n850) );
  DFEC1 \u_apb_slave_regs/s_reg_divider_reg[7]  ( .D(i_pwdata[7]), .E(n890), 
        .C(i_clk), .RN(i_rst_n), .Q(\u_apb_slave_regs/s_reg_divider [7]), .QN(
        n846) );
  DFEC1 \u_apb_slave_regs/s_reg_control_reg[0]  ( .D(i_pwdata[0]), .E(n888), 
        .C(i_clk), .RN(i_rst_n), .Q(o_dbg_global_en), .QN(n875) );
  DFEC1 \u_fifo_tx/s_rd_ptr_reg[0]  ( .D(n569), .E(o_dbg_tx_fifo_pop), .C(
        i_clk), .RN(i_rst_n), .Q(\u_fifo_tx/s_rd_ptr [0]), .QN(n841) );
  DFEC1 \u_fifo_tx/s_rd_ptr_reg[3]  ( .D(n568), .E(n840), .C(i_clk), .RN(
        i_rst_n), .Q(\u_fifo_tx/s_rd_ptr [3]), .QN(n866) );
  DFP1 \u_fifo_rx/o_data_reg[5]  ( .D(n902), .C(i_clk), .SN(i_rst_n), .Q(n885), 
        .QN(o_dbg_rx_fifo_q[5]) );
  DFE1 \u_fifo_tx/s_mem_reg[3][7]  ( .D(o_dbg_tx_fifo_data[7]), .E(n894), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[3][7] ) );
  DFE1 \u_fifo_tx/s_mem_reg[3][6]  ( .D(o_dbg_tx_fifo_data[6]), .E(n894), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[3][6] ) );
  DFE1 \u_fifo_tx/s_mem_reg[3][5]  ( .D(o_dbg_tx_fifo_data[5]), .E(n894), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[3][5] ) );
  DFE1 \u_fifo_tx/s_mem_reg[3][4]  ( .D(o_dbg_tx_fifo_data[4]), .E(n894), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[3][4] ) );
  DFE1 \u_fifo_tx/s_mem_reg[3][3]  ( .D(o_dbg_tx_fifo_data[3]), .E(n894), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[3][3] ) );
  DFE1 \u_fifo_tx/s_mem_reg[3][2]  ( .D(o_dbg_tx_fifo_data[2]), .E(n894), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[3][2] ) );
  DFE1 \u_fifo_tx/s_mem_reg[3][1]  ( .D(o_dbg_tx_fifo_data[1]), .E(n894), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[3][1] ) );
  DFE1 \u_fifo_tx/s_mem_reg[3][0]  ( .D(o_dbg_tx_fifo_data[0]), .E(n894), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[3][0] ) );
  DFE1 \u_fifo_tx/s_mem_reg[7][7]  ( .D(o_dbg_tx_fifo_data[7]), .E(n898), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[7][7] ) );
  DFE1 \u_fifo_tx/s_mem_reg[7][6]  ( .D(o_dbg_tx_fifo_data[6]), .E(n898), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[7][6] ) );
  DFE1 \u_fifo_tx/s_mem_reg[7][5]  ( .D(o_dbg_tx_fifo_data[5]), .E(n898), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[7][5] ) );
  DFE1 \u_fifo_tx/s_mem_reg[7][4]  ( .D(o_dbg_tx_fifo_data[4]), .E(n898), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[7][4] ) );
  DFE1 \u_fifo_tx/s_mem_reg[7][3]  ( .D(o_dbg_tx_fifo_data[3]), .E(n898), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[7][3] ) );
  DFE1 \u_fifo_tx/s_mem_reg[7][2]  ( .D(o_dbg_tx_fifo_data[2]), .E(n898), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[7][2] ) );
  DFE1 \u_fifo_tx/s_mem_reg[7][1]  ( .D(o_dbg_tx_fifo_data[1]), .E(n898), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[7][1] ) );
  DFE1 \u_fifo_tx/s_mem_reg[7][0]  ( .D(o_dbg_tx_fifo_data[0]), .E(n898), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[7][0] ) );
  DFE1 \u_fifo_rx/s_mem_reg[5][7]  ( .D(o_dbg_rx_fifo_data[7]), .E(n901), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[5][7] ) );
  DFE1 \u_fifo_rx/s_mem_reg[5][6]  ( .D(o_dbg_rx_fifo_data[6]), .E(n901), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[5][6] ) );
  DFE1 \u_fifo_rx/s_mem_reg[5][5]  ( .D(o_dbg_rx_fifo_data[5]), .E(n901), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[5][5] ) );
  DFE1 \u_fifo_rx/s_mem_reg[5][4]  ( .D(o_dbg_rx_fifo_data[4]), .E(n901), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[5][4] ) );
  DFE1 \u_fifo_rx/s_mem_reg[5][3]  ( .D(o_dbg_rx_fifo_data[3]), .E(n901), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[5][3] ) );
  DFE1 \u_fifo_rx/s_mem_reg[5][2]  ( .D(o_dbg_rx_fifo_data[2]), .E(n901), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[5][2] ) );
  DFE1 \u_fifo_rx/s_mem_reg[5][1]  ( .D(o_dbg_rx_fifo_data[1]), .E(n901), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[5][1] ) );
  DFE1 \u_fifo_rx/s_mem_reg[5][0]  ( .D(o_dbg_rx_fifo_data[0]), .E(n901), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[5][0] ) );
  DFE1 \u_fifo_rx/s_mem_reg[1][7]  ( .D(o_dbg_rx_fifo_data[7]), .E(n899), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[1][7] ) );
  DFE1 \u_fifo_rx/s_mem_reg[1][6]  ( .D(o_dbg_rx_fifo_data[6]), .E(n899), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[1][6] ) );
  DFE1 \u_fifo_rx/s_mem_reg[1][5]  ( .D(o_dbg_rx_fifo_data[5]), .E(n899), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[1][5] ) );
  DFE1 \u_fifo_rx/s_mem_reg[1][4]  ( .D(o_dbg_rx_fifo_data[4]), .E(n899), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[1][4] ) );
  DFE1 \u_fifo_rx/s_mem_reg[1][3]  ( .D(o_dbg_rx_fifo_data[3]), .E(n899), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[1][3] ) );
  DFE1 \u_fifo_rx/s_mem_reg[1][2]  ( .D(o_dbg_rx_fifo_data[2]), .E(n899), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[1][2] ) );
  DFE1 \u_fifo_rx/s_mem_reg[1][1]  ( .D(o_dbg_rx_fifo_data[1]), .E(n899), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[1][1] ) );
  DFE1 \u_fifo_rx/s_mem_reg[1][0]  ( .D(o_dbg_rx_fifo_data[0]), .E(n899), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[1][0] ) );
  DFE1 \u_fifo_tx/s_mem_reg[4][7]  ( .D(o_dbg_tx_fifo_data[7]), .E(n895), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[4][7] ) );
  DFE1 \u_fifo_tx/s_mem_reg[4][6]  ( .D(o_dbg_tx_fifo_data[6]), .E(n895), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[4][6] ) );
  DFE1 \u_fifo_tx/s_mem_reg[4][5]  ( .D(o_dbg_tx_fifo_data[5]), .E(n895), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[4][5] ) );
  DFE1 \u_fifo_tx/s_mem_reg[4][4]  ( .D(o_dbg_tx_fifo_data[4]), .E(n895), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[4][4] ) );
  DFE1 \u_fifo_tx/s_mem_reg[4][3]  ( .D(o_dbg_tx_fifo_data[3]), .E(n895), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[4][3] ) );
  DFE1 \u_fifo_tx/s_mem_reg[4][2]  ( .D(o_dbg_tx_fifo_data[2]), .E(n895), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[4][2] ) );
  DFE1 \u_fifo_tx/s_mem_reg[4][1]  ( .D(o_dbg_tx_fifo_data[1]), .E(n895), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[4][1] ) );
  DFE1 \u_fifo_tx/s_mem_reg[4][0]  ( .D(o_dbg_tx_fifo_data[0]), .E(n895), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[4][0] ) );
  DFE1 \u_fifo_tx/s_mem_reg[5][7]  ( .D(o_dbg_tx_fifo_data[7]), .E(n896), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[5][7] ) );
  DFE1 \u_fifo_tx/s_mem_reg[5][6]  ( .D(o_dbg_tx_fifo_data[6]), .E(n896), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[5][6] ) );
  DFE1 \u_fifo_tx/s_mem_reg[5][5]  ( .D(o_dbg_tx_fifo_data[5]), .E(n896), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[5][5] ) );
  DFE1 \u_fifo_tx/s_mem_reg[5][4]  ( .D(o_dbg_tx_fifo_data[4]), .E(n896), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[5][4] ) );
  DFE1 \u_fifo_tx/s_mem_reg[5][3]  ( .D(o_dbg_tx_fifo_data[3]), .E(n896), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[5][3] ) );
  DFE1 \u_fifo_tx/s_mem_reg[5][2]  ( .D(o_dbg_tx_fifo_data[2]), .E(n896), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[5][2] ) );
  DFE1 \u_fifo_tx/s_mem_reg[5][1]  ( .D(o_dbg_tx_fifo_data[1]), .E(n896), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[5][1] ) );
  DFE1 \u_fifo_tx/s_mem_reg[5][0]  ( .D(o_dbg_tx_fifo_data[0]), .E(n896), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[5][0] ) );
  DFE1 \u_fifo_tx/s_mem_reg[6][7]  ( .D(o_dbg_tx_fifo_data[7]), .E(n897), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[6][7] ) );
  DFE1 \u_fifo_tx/s_mem_reg[6][6]  ( .D(o_dbg_tx_fifo_data[6]), .E(n897), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[6][6] ) );
  DFE1 \u_fifo_tx/s_mem_reg[6][5]  ( .D(o_dbg_tx_fifo_data[5]), .E(n897), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[6][5] ) );
  DFE1 \u_fifo_tx/s_mem_reg[6][4]  ( .D(o_dbg_tx_fifo_data[4]), .E(n897), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[6][4] ) );
  DFE1 \u_fifo_tx/s_mem_reg[6][3]  ( .D(o_dbg_tx_fifo_data[3]), .E(n897), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[6][3] ) );
  DFE1 \u_fifo_tx/s_mem_reg[6][2]  ( .D(o_dbg_tx_fifo_data[2]), .E(n897), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[6][2] ) );
  DFE1 \u_fifo_tx/s_mem_reg[6][1]  ( .D(o_dbg_tx_fifo_data[1]), .E(n897), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[6][1] ) );
  DFE1 \u_fifo_tx/s_mem_reg[6][0]  ( .D(o_dbg_tx_fifo_data[0]), .E(n897), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[6][0] ) );
  DFE1 \u_fifo_rx/s_mem_reg[2][7]  ( .D(o_dbg_rx_fifo_data[7]), .E(n839), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[2][7] ) );
  DFE1 \u_fifo_rx/s_mem_reg[2][6]  ( .D(o_dbg_rx_fifo_data[6]), .E(n839), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[2][6] ) );
  DFE1 \u_fifo_rx/s_mem_reg[2][5]  ( .D(o_dbg_rx_fifo_data[5]), .E(n839), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[2][5] ) );
  DFE1 \u_fifo_rx/s_mem_reg[2][4]  ( .D(o_dbg_rx_fifo_data[4]), .E(n839), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[2][4] ) );
  DFE1 \u_fifo_rx/s_mem_reg[2][3]  ( .D(o_dbg_rx_fifo_data[3]), .E(n839), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[2][3] ) );
  DFE1 \u_fifo_rx/s_mem_reg[2][2]  ( .D(o_dbg_rx_fifo_data[2]), .E(n839), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[2][2] ) );
  DFE1 \u_fifo_rx/s_mem_reg[2][1]  ( .D(o_dbg_rx_fifo_data[1]), .E(n839), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[2][1] ) );
  DFE1 \u_fifo_rx/s_mem_reg[2][0]  ( .D(o_dbg_rx_fifo_data[0]), .E(n839), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[2][0] ) );
  DFE1 \u_fifo_rx/s_mem_reg[0][7]  ( .D(o_dbg_rx_fifo_data[7]), .E(n838), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[0][7] ) );
  DFE1 \u_fifo_rx/s_mem_reg[0][6]  ( .D(o_dbg_rx_fifo_data[6]), .E(n838), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[0][6] ) );
  DFE1 \u_fifo_rx/s_mem_reg[0][5]  ( .D(o_dbg_rx_fifo_data[5]), .E(n838), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[0][5] ) );
  DFE1 \u_fifo_rx/s_mem_reg[0][4]  ( .D(o_dbg_rx_fifo_data[4]), .E(n838), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[0][4] ) );
  DFE1 \u_fifo_rx/s_mem_reg[0][3]  ( .D(o_dbg_rx_fifo_data[3]), .E(n838), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[0][3] ) );
  DFE1 \u_fifo_rx/s_mem_reg[0][2]  ( .D(o_dbg_rx_fifo_data[2]), .E(n838), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[0][2] ) );
  DFE1 \u_fifo_rx/s_mem_reg[0][1]  ( .D(o_dbg_rx_fifo_data[1]), .E(n838), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[0][1] ) );
  DFE1 \u_fifo_rx/s_mem_reg[0][0]  ( .D(o_dbg_rx_fifo_data[0]), .E(n838), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[0][0] ) );
  DFE1 \u_fifo_tx/s_mem_reg[0][7]  ( .D(o_dbg_tx_fifo_data[7]), .E(n891), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[0][7] ) );
  DFE1 \u_fifo_tx/s_mem_reg[0][6]  ( .D(o_dbg_tx_fifo_data[6]), .E(n891), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[0][6] ) );
  DFE1 \u_fifo_tx/s_mem_reg[0][5]  ( .D(o_dbg_tx_fifo_data[5]), .E(n891), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[0][5] ) );
  DFE1 \u_fifo_tx/s_mem_reg[0][4]  ( .D(o_dbg_tx_fifo_data[4]), .E(n891), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[0][4] ) );
  DFE1 \u_fifo_tx/s_mem_reg[0][3]  ( .D(o_dbg_tx_fifo_data[3]), .E(n891), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[0][3] ) );
  DFE1 \u_fifo_tx/s_mem_reg[0][2]  ( .D(o_dbg_tx_fifo_data[2]), .E(n891), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[0][2] ) );
  DFE1 \u_fifo_tx/s_mem_reg[0][1]  ( .D(o_dbg_tx_fifo_data[1]), .E(n891), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[0][1] ) );
  DFE1 \u_fifo_tx/s_mem_reg[0][0]  ( .D(o_dbg_tx_fifo_data[0]), .E(n891), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[0][0] ) );
  DFE1 \u_fifo_tx/s_mem_reg[1][7]  ( .D(o_dbg_tx_fifo_data[7]), .E(n892), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[1][7] ) );
  DFE1 \u_fifo_tx/s_mem_reg[1][6]  ( .D(o_dbg_tx_fifo_data[6]), .E(n892), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[1][6] ) );
  DFE1 \u_fifo_tx/s_mem_reg[1][5]  ( .D(o_dbg_tx_fifo_data[5]), .E(n892), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[1][5] ) );
  DFE1 \u_fifo_tx/s_mem_reg[1][4]  ( .D(o_dbg_tx_fifo_data[4]), .E(n892), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[1][4] ) );
  DFE1 \u_fifo_tx/s_mem_reg[1][3]  ( .D(o_dbg_tx_fifo_data[3]), .E(n892), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[1][3] ) );
  DFE1 \u_fifo_tx/s_mem_reg[1][2]  ( .D(o_dbg_tx_fifo_data[2]), .E(n892), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[1][2] ) );
  DFE1 \u_fifo_tx/s_mem_reg[1][1]  ( .D(o_dbg_tx_fifo_data[1]), .E(n892), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[1][1] ) );
  DFE1 \u_fifo_tx/s_mem_reg[1][0]  ( .D(o_dbg_tx_fifo_data[0]), .E(n892), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[1][0] ) );
  DFE1 \u_fifo_tx/s_mem_reg[2][7]  ( .D(o_dbg_tx_fifo_data[7]), .E(n893), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[2][7] ) );
  DFE1 \u_fifo_tx/s_mem_reg[2][6]  ( .D(o_dbg_tx_fifo_data[6]), .E(n893), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[2][6] ) );
  DFE1 \u_fifo_tx/s_mem_reg[2][5]  ( .D(o_dbg_tx_fifo_data[5]), .E(n893), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[2][5] ) );
  DFE1 \u_fifo_tx/s_mem_reg[2][4]  ( .D(o_dbg_tx_fifo_data[4]), .E(n893), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[2][4] ) );
  DFE1 \u_fifo_tx/s_mem_reg[2][3]  ( .D(o_dbg_tx_fifo_data[3]), .E(n893), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[2][3] ) );
  DFE1 \u_fifo_tx/s_mem_reg[2][2]  ( .D(o_dbg_tx_fifo_data[2]), .E(n893), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[2][2] ) );
  DFE1 \u_fifo_tx/s_mem_reg[2][1]  ( .D(o_dbg_tx_fifo_data[1]), .E(n893), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[2][1] ) );
  DFE1 \u_fifo_tx/s_mem_reg[2][0]  ( .D(o_dbg_tx_fifo_data[0]), .E(n893), .C(
        i_clk), .Q(\u_fifo_tx/s_mem[2][0] ) );
  DFE1 \u_fifo_rx/s_mem_reg[6][7]  ( .D(o_dbg_rx_fifo_data[7]), .E(n837), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[6][7] ) );
  DFE1 \u_fifo_rx/s_mem_reg[6][6]  ( .D(o_dbg_rx_fifo_data[6]), .E(n837), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[6][6] ) );
  DFE1 \u_fifo_rx/s_mem_reg[6][5]  ( .D(o_dbg_rx_fifo_data[5]), .E(n837), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[6][5] ) );
  DFE1 \u_fifo_rx/s_mem_reg[6][4]  ( .D(o_dbg_rx_fifo_data[4]), .E(n837), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[6][4] ) );
  DFE1 \u_fifo_rx/s_mem_reg[6][3]  ( .D(o_dbg_rx_fifo_data[3]), .E(n837), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[6][3] ) );
  DFE1 \u_fifo_rx/s_mem_reg[6][2]  ( .D(o_dbg_rx_fifo_data[2]), .E(n837), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[6][2] ) );
  DFE1 \u_fifo_rx/s_mem_reg[6][1]  ( .D(o_dbg_rx_fifo_data[1]), .E(n837), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[6][1] ) );
  DFE1 \u_fifo_rx/s_mem_reg[6][0]  ( .D(o_dbg_rx_fifo_data[0]), .E(n837), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[6][0] ) );
  DFE1 \u_fifo_rx/s_mem_reg[4][7]  ( .D(o_dbg_rx_fifo_data[7]), .E(n836), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[4][7] ) );
  DFE1 \u_fifo_rx/s_mem_reg[4][6]  ( .D(o_dbg_rx_fifo_data[6]), .E(n836), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[4][6] ) );
  DFE1 \u_fifo_rx/s_mem_reg[4][5]  ( .D(o_dbg_rx_fifo_data[5]), .E(n836), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[4][5] ) );
  DFE1 \u_fifo_rx/s_mem_reg[4][4]  ( .D(o_dbg_rx_fifo_data[4]), .E(n836), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[4][4] ) );
  DFE1 \u_fifo_rx/s_mem_reg[4][3]  ( .D(o_dbg_rx_fifo_data[3]), .E(n836), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[4][3] ) );
  DFE1 \u_fifo_rx/s_mem_reg[4][2]  ( .D(o_dbg_rx_fifo_data[2]), .E(n836), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[4][2] ) );
  DFE1 \u_fifo_rx/s_mem_reg[4][1]  ( .D(o_dbg_rx_fifo_data[1]), .E(n836), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[4][1] ) );
  DFE1 \u_fifo_rx/s_mem_reg[4][0]  ( .D(o_dbg_rx_fifo_data[0]), .E(n836), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[4][0] ) );
  DFE1 \u_fifo_rx/s_mem_reg[7][7]  ( .D(o_dbg_rx_fifo_data[7]), .E(n903), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[7][7] ) );
  DFE1 \u_fifo_rx/s_mem_reg[7][6]  ( .D(o_dbg_rx_fifo_data[6]), .E(n903), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[7][6] ) );
  DFE1 \u_fifo_rx/s_mem_reg[7][5]  ( .D(o_dbg_rx_fifo_data[5]), .E(n903), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[7][5] ) );
  DFE1 \u_fifo_rx/s_mem_reg[7][4]  ( .D(o_dbg_rx_fifo_data[4]), .E(n903), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[7][4] ) );
  DFE1 \u_fifo_rx/s_mem_reg[7][3]  ( .D(o_dbg_rx_fifo_data[3]), .E(n903), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[7][3] ) );
  DFE1 \u_fifo_rx/s_mem_reg[7][2]  ( .D(o_dbg_rx_fifo_data[2]), .E(n903), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[7][2] ) );
  DFE1 \u_fifo_rx/s_mem_reg[7][1]  ( .D(o_dbg_rx_fifo_data[1]), .E(n903), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[7][1] ) );
  DFE1 \u_fifo_rx/s_mem_reg[7][0]  ( .D(o_dbg_rx_fifo_data[0]), .E(n903), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[7][0] ) );
  DFE1 \u_fifo_rx/s_mem_reg[3][7]  ( .D(o_dbg_rx_fifo_data[7]), .E(n900), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[3][7] ) );
  DFE1 \u_fifo_rx/s_mem_reg[3][6]  ( .D(o_dbg_rx_fifo_data[6]), .E(n900), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[3][6] ) );
  DFE1 \u_fifo_rx/s_mem_reg[3][5]  ( .D(o_dbg_rx_fifo_data[5]), .E(n900), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[3][5] ) );
  DFE1 \u_fifo_rx/s_mem_reg[3][4]  ( .D(o_dbg_rx_fifo_data[4]), .E(n900), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[3][4] ) );
  DFE1 \u_fifo_rx/s_mem_reg[3][3]  ( .D(o_dbg_rx_fifo_data[3]), .E(n900), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[3][3] ) );
  DFE1 \u_fifo_rx/s_mem_reg[3][2]  ( .D(o_dbg_rx_fifo_data[2]), .E(n900), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[3][2] ) );
  DFE1 \u_fifo_rx/s_mem_reg[3][1]  ( .D(o_dbg_rx_fifo_data[1]), .E(n900), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[3][1] ) );
  DFE1 \u_fifo_rx/s_mem_reg[3][0]  ( .D(o_dbg_rx_fifo_data[0]), .E(n900), .C(
        i_clk), .Q(\u_fifo_rx/s_mem[3][0] ) );
  NOR30 U581 ( .A(i_paddr[1]), .B(i_paddr[7]), .C(i_paddr[0]), .Q(n592) );
  NAND20 U582 ( .A(i_psel), .B(n592), .Q(n593) );
  NAND20 U583 ( .A(n582), .B(n581), .Q(n585) );
  INV0 U584 ( .A(i_paddr[2]), .Q(n805) );
  INV0 U585 ( .A(i_paddr[3]), .Q(n814) );
  NAND21 U586 ( .A(n834), .B(i_rst_n), .Q(n594) );
  NOR20 U587 ( .A(n589), .B(n590), .Q(o_dbg_rx_fifo_full) );
  CLKIN1 U588 ( .A(n768), .Q(o_dbg_rx_path_en) );
  CLKIN1 U589 ( .A(n589), .Q(n591) );
  INV2 U590 ( .A(n645), .Q(o_dbg_tx_path_en) );
  CLKIN1 U591 ( .A(n587), .Q(n598) );
  CLKIN3 U592 ( .A(i_rst_n), .Q(n631) );
  MUX21 U593 ( .A(n866), .B(\u_fifo_tx/s_wr_ptr [3]), .S(n579), .Q(n568) );
  MUX21 U594 ( .A(n841), .B(\u_fifo_tx/s_wr_ptr [0]), .S(n583), .Q(n569) );
  LOGIC0 U595 ( .Q(\*Logic0* ) );
  LOGIC1 U596 ( .Q(o_pready) );
  IMUX20 U597 ( .A(\u_fifo_rx/s_rd_ptr [3]), .B(n863), .S(
        \u_fifo_rx/s_wr_ptr [3]), .Q(n589) );
  IMUX20 U598 ( .A(\u_fifo_rx/s_rd_ptr [0]), .B(n844), .S(
        \u_fifo_rx/s_wr_ptr [0]), .Q(n572) );
  IMUX20 U599 ( .A(n862), .B(\u_fifo_rx/s_rd_ptr [1]), .S(
        \u_fifo_rx/s_wr_ptr [1]), .Q(n570) );
  AOI210 U600 ( .A(\u_fifo_rx/s_wr_ptr [2]), .B(n861), .C(n570), .Q(n571) );
  OAI2110 U601 ( .A(\u_fifo_rx/s_wr_ptr [2]), .B(n861), .C(n572), .D(n571), 
        .Q(n590) );
  INV0 U602 ( .A(o_dbg_rx_fifo_full), .Q(n584) );
  NAND20 U603 ( .A(n584), .B(o_dbg_rx_fifo_push), .Q(n782) );
  NOR40 U604 ( .A(\u_fifo_rx/s_wr_ptr [1]), .B(\u_fifo_rx/s_wr_ptr [0]), .C(
        n782), .D(n631), .Q(n575) );
  NAND20 U605 ( .A(\u_fifo_rx/s_wr_ptr [2]), .B(n575), .Q(n573) );
  INV0 U606 ( .A(n573), .Q(n836) );
  NOR40 U607 ( .A(\u_fifo_rx/s_wr_ptr [0]), .B(n867), .C(n782), .D(n631), .Q(
        n577) );
  NAND20 U608 ( .A(\u_fifo_rx/s_wr_ptr [2]), .B(n577), .Q(n574) );
  INV0 U609 ( .A(n574), .Q(n837) );
  NAND20 U610 ( .A(n575), .B(n865), .Q(n576) );
  INV0 U611 ( .A(n576), .Q(n838) );
  NAND20 U612 ( .A(n577), .B(n865), .Q(n578) );
  INV0 U613 ( .A(n578), .Q(n839) );
  NAND20 U614 ( .A(\u_fifo_tx/s_wr_ptr [1]), .B(\u_fifo_tx/s_wr_ptr [0]), .Q(
        n783) );
  NOR20 U615 ( .A(n864), .B(n783), .Q(n579) );
  NOR30 U616 ( .A(n845), .B(n872), .C(n841), .Q(n702) );
  NAND20 U617 ( .A(o_dbg_tx_fifo_pop), .B(n702), .Q(n580) );
  INV0 U618 ( .A(n580), .Q(n840) );
  IMUX20 U619 ( .A(\u_fifo_tx/s_rd_ptr [3]), .B(n866), .S(
        \u_fifo_tx/s_wr_ptr [3]), .Q(n587) );
  IMUX20 U620 ( .A(\u_fifo_tx/s_rd_ptr [1]), .B(n845), .S(
        \u_fifo_tx/s_wr_ptr [1]), .Q(n582) );
  IMUX20 U621 ( .A(\u_fifo_tx/s_wr_ptr [2]), .B(n864), .S(
        \u_fifo_tx/s_rd_ptr [2]), .Q(n581) );
  NOR20 U622 ( .A(n598), .B(n585), .Q(n583) );
  NAND20 U623 ( .A(o_dbg_global_en), .B(o_dbg_rx_enable), .Q(n768) );
  INV0 U624 ( .A(i_cdr_sample_valid), .Q(n818) );
  NOR21 U625 ( .A(n768), .B(n818), .Q(n772) );
  NAND40 U626 ( .A(\u_deserializer/s_bit_count [2]), .B(
        \u_deserializer/s_bit_count [1]), .C(n772), .D(
        \u_deserializer/s_bit_count [0]), .Q(n626) );
  NOR20 U627 ( .A(n584), .B(n626), .Q(\u_deserializer/N23 ) );
  AOI210 U628 ( .A(\u_fifo_tx/s_wr_ptr [0]), .B(n841), .C(n585), .Q(n586) );
  OAI210 U629 ( .A(\u_fifo_tx/s_wr_ptr [0]), .B(n841), .C(n586), .Q(n597) );
  NOR21 U630 ( .A(n597), .B(n587), .Q(o_dbg_tx_fifo_full) );
  INV0 U631 ( .A(o_dbg_tx_fifo_full), .Q(n800) );
  NAND20 U632 ( .A(o_dbg_tx_fifo_push), .B(n800), .Q(n830) );
  NOR20 U633 ( .A(n631), .B(n830), .Q(n588) );
  NAND20 U634 ( .A(\u_fifo_tx/s_wr_ptr [2]), .B(n588), .Q(n629) );
  NOR30 U635 ( .A(\u_fifo_tx/s_wr_ptr [1]), .B(n868), .C(n629), .Q(n896) );
  NOR30 U636 ( .A(\u_fifo_tx/s_wr_ptr [0]), .B(n869), .C(n629), .Q(n897) );
  NAND20 U637 ( .A(n588), .B(n864), .Q(n630) );
  NOR30 U638 ( .A(\u_fifo_tx/s_wr_ptr [1]), .B(n868), .C(n630), .Q(n892) );
  NOR30 U639 ( .A(\u_fifo_tx/s_wr_ptr [0]), .B(n869), .C(n630), .Q(n893) );
  NOR21 U640 ( .A(n591), .B(n590), .Q(\eq_x_54/n25 ) );
  NOR40 U641 ( .A(i_paddr[5]), .B(i_paddr[4]), .C(i_paddr[6]), .D(n593), .Q(
        n632) );
  NAND31 U642 ( .A(n632), .B(n805), .C(n814), .Q(n628) );
  NOR40 U643 ( .A(i_pwrite), .B(\eq_x_54/n25 ), .C(i_penable), .D(n628), .Q(
        o_dbg_rx_fifo_pop) );
  INV0 U644 ( .A(n782), .Q(n781) );
  NAND20 U645 ( .A(\u_fifo_rx/s_wr_ptr [0]), .B(n781), .Q(n835) );
  NOR20 U646 ( .A(n867), .B(n835), .Q(n834) );
  NOR20 U647 ( .A(\u_fifo_rx/s_wr_ptr [2]), .B(n594), .Q(n900) );
  NOR20 U648 ( .A(n865), .B(n594), .Q(n903) );
  NOR20 U649 ( .A(n805), .B(n814), .Q(n797) );
  NAND20 U650 ( .A(n632), .B(n797), .Q(n595) );
  OAI220 U651 ( .A(n628), .B(n885), .C(n851), .D(n595), .Q(o_prdata[5]) );
  OAI220 U652 ( .A(n628), .B(n886), .C(n850), .D(n595), .Q(o_prdata[6]) );
  OAI220 U653 ( .A(n628), .B(n887), .C(n846), .D(n595), .Q(o_prdata[7]) );
  NAND20 U654 ( .A(i_pwrite), .B(i_penable), .Q(n633) );
  NOR20 U655 ( .A(n633), .B(n595), .Q(n890) );
  NOR20 U656 ( .A(n848), .B(n870), .Q(\u_serializer/N38 ) );
  NAND20 U657 ( .A(o_dbg_tx_fifo_rd_valid), .B(n848), .Q(n646) );
  NOR20 U658 ( .A(n871), .B(n646), .Q(n642) );
  NAND20 U659 ( .A(\u_serializer/N38 ), .B(\u_serializer/s_bit_count [0]), .Q(
        n779) );
  OAI220 U660 ( .A(n642), .B(n873), .C(n857), .D(n779), .Q(n479) );
  AOI210 U661 ( .A(\u_serializer/s_bit_count [1]), .B(
        \u_serializer/s_bit_count [2]), .C(n843), .Q(n596) );
  INV0 U662 ( .A(\u_serializer/N38 ), .Q(n600) );
  NOR20 U663 ( .A(\u_serializer/N38 ), .B(n642), .Q(n777) );
  INV0 U664 ( .A(n777), .Q(n602) );
  OAI220 U665 ( .A(n596), .B(n600), .C(n602), .D(n843), .Q(n478) );
  NAND20 U666 ( .A(o_dbg_global_en), .B(s_tx_run), .Q(n645) );
  NOR21 U667 ( .A(n598), .B(n597), .Q(\eq_x_23/n25 ) );
  NAND20 U668 ( .A(\eq_x_23/n25 ), .B(n848), .Q(n611) );
  AOI220 U669 ( .A(o_dbg_global_en), .B(o_dbg_tx_start), .C(o_dbg_tx_path_en), 
        .D(n611), .Q(n599) );
  NOR20 U670 ( .A(w_sw_reset), .B(n599), .Q(n556) );
  INV0 U671 ( .A(n642), .Q(n774) );
  NOR30 U672 ( .A(n857), .B(n873), .C(n843), .Q(n601) );
  NOR20 U673 ( .A(n601), .B(n600), .Q(n609) );
  INV0 U674 ( .A(n601), .Q(n773) );
  OAI210 U675 ( .A(n848), .B(n773), .C(n602), .Q(n643) );
  AOI220 U676 ( .A(\u_serializer/s_shift_reg [4]), .B(n609), .C(
        \u_serializer/s_shift_reg [3]), .D(n643), .Q(n603) );
  OAI210 U677 ( .A(n881), .B(n774), .C(n603), .Q(n473) );
  AOI220 U678 ( .A(\u_serializer/s_shift_reg [3]), .B(n609), .C(
        \u_serializer/s_shift_reg [2]), .D(n643), .Q(n604) );
  OAI210 U679 ( .A(n880), .B(n774), .C(n604), .Q(n474) );
  AOI220 U680 ( .A(\u_serializer/s_shift_reg [7]), .B(n609), .C(
        \u_serializer/s_shift_reg [6]), .D(n643), .Q(n605) );
  OAI210 U681 ( .A(n884), .B(n774), .C(n605), .Q(n470) );
  AOI220 U682 ( .A(\u_serializer/s_shift_reg [6]), .B(n609), .C(
        \u_serializer/s_shift_reg [5]), .D(n643), .Q(n606) );
  OAI210 U683 ( .A(n883), .B(n774), .C(n606), .Q(n471) );
  AOI220 U684 ( .A(\u_serializer/s_shift_reg [2]), .B(n609), .C(
        \u_serializer/s_shift_reg [1]), .D(n643), .Q(n607) );
  OAI210 U685 ( .A(n879), .B(n774), .C(n607), .Q(n475) );
  AOI220 U686 ( .A(\u_serializer/s_shift_reg [5]), .B(n609), .C(
        \u_serializer/s_shift_reg [4]), .D(n643), .Q(n608) );
  OAI210 U687 ( .A(n882), .B(n774), .C(n608), .Q(n472) );
  AOI220 U688 ( .A(\u_serializer/s_shift_reg [0]), .B(n643), .C(n609), .D(
        \u_serializer/s_shift_reg [1]), .Q(n610) );
  OAI210 U689 ( .A(n878), .B(n774), .C(n610), .Q(n476) );
  NOR30 U690 ( .A(s_tx_path_en_d), .B(n645), .C(n611), .Q(n612) );
  NOR20 U691 ( .A(o_dbg_tx_und_err), .B(n612), .Q(n613) );
  NOR30 U692 ( .A(w_sw_reset), .B(w_clear_err), .C(n613), .Q(n455) );
  NOR40 U693 ( .A(\u_apb_slave_regs/s_reg_divider [4]), .B(
        \u_apb_slave_regs/s_reg_divider [3]), .C(
        \u_apb_slave_regs/s_reg_divider [2]), .D(
        \u_apb_slave_regs/s_reg_divider [1]), .Q(n614) );
  NAND20 U694 ( .A(n614), .B(n846), .Q(n615) );
  OAI310 U695 ( .A(\u_apb_slave_regs/s_reg_divider [6]), .B(
        \u_apb_slave_regs/s_reg_divider [5]), .C(n615), .D(n847), .Q(
        o_dbg_div_val[0]) );
  IMUX20 U696 ( .A(n853), .B(\u_apb_slave_regs/s_reg_divider [2]), .S(
        \u_tx_baud_rate_gen/s_counter [2]), .Q(n619) );
  IMUX20 U697 ( .A(n846), .B(\u_apb_slave_regs/s_reg_divider [7]), .S(
        \u_tx_baud_rate_gen/s_counter [7]), .Q(n618) );
  IMUX20 U698 ( .A(\u_apb_slave_regs/s_reg_divider [1]), .B(n854), .S(n842), 
        .Q(n617) );
  IMUX20 U699 ( .A(n855), .B(\u_apb_slave_regs/s_reg_divider [4]), .S(
        \u_tx_baud_rate_gen/s_counter [4]), .Q(n616) );
  NOR40 U700 ( .A(n619), .B(n618), .C(n617), .D(n616), .Q(n625) );
  IMUX20 U701 ( .A(n851), .B(\u_apb_slave_regs/s_reg_divider [5]), .S(
        \u_tx_baud_rate_gen/s_counter [5]), .Q(n623) );
  IMUX20 U702 ( .A(n850), .B(\u_apb_slave_regs/s_reg_divider [6]), .S(
        \u_tx_baud_rate_gen/s_counter [6]), .Q(n622) );
  IMUX20 U703 ( .A(n852), .B(\u_apb_slave_regs/s_reg_divider [3]), .S(
        \u_tx_baud_rate_gen/s_counter [3]), .Q(n621) );
  IMUX20 U704 ( .A(n849), .B(\u_tx_baud_rate_gen/s_counter [0]), .S(
        o_dbg_div_val[0]), .Q(n620) );
  NOR40 U705 ( .A(n623), .B(n622), .C(n621), .D(n620), .Q(n624) );
  NAND20 U706 ( .A(n625), .B(n624), .Q(n780) );
  NAND30 U707 ( .A(o_dbg_global_en), .B(o_tx_valid), .C(n780), .Q(n795) );
  NOR20 U708 ( .A(\u_tx_baud_rate_gen/s_counter [0]), .B(n795), .Q(
        \u_tx_baud_rate_gen/N28 ) );
  NOR21 U709 ( .A(o_dbg_rx_fifo_full), .B(n626), .Q(\u_deserializer/N24 ) );
  NAND20 U710 ( .A(o_dbg_rx_fifo_pop), .B(n844), .Q(n716) );
  OAI210 U711 ( .A(o_dbg_rx_fifo_pop), .B(n844), .C(n716), .Q(n467) );
  INV0 U712 ( .A(\eq_x_23/n25 ), .Q(n627) );
  NAND22 U713 ( .A(n627), .B(o_dbg_tx_fifo_pop), .Q(n785) );
  INV0 U714 ( .A(n785), .Q(\u_fifo_tx/N40 ) );
  NOR31 U715 ( .A(o_dbg_tx_fifo_full), .B(n628), .C(n633), .Q(
        \u_apb_slave_regs/s_tx_push_n ) );
  NOR20 U716 ( .A(n783), .B(n629), .Q(n898) );
  NOR30 U717 ( .A(\u_fifo_tx/s_wr_ptr [1]), .B(\u_fifo_tx/s_wr_ptr [0]), .C(
        n629), .Q(n895) );
  NOR20 U718 ( .A(n630), .B(n783), .Q(n894) );
  NOR30 U719 ( .A(\u_fifo_tx/s_wr_ptr [1]), .B(\u_fifo_tx/s_wr_ptr [0]), .C(
        n630), .Q(n891) );
  NOR40 U720 ( .A(\u_fifo_rx/s_wr_ptr [1]), .B(n865), .C(n835), .D(n631), .Q(
        n901) );
  NOR40 U721 ( .A(\u_fifo_rx/s_wr_ptr [1]), .B(\u_fifo_rx/s_wr_ptr [2]), .C(
        n835), .D(n631), .Q(n899) );
  INV0 U722 ( .A(n632), .Q(n813) );
  NAND20 U723 ( .A(i_paddr[3]), .B(n805), .Q(n811) );
  NOR30 U724 ( .A(n813), .B(n633), .C(n811), .Q(n888) );
  INV0 U725 ( .A(i_pwdata[2]), .Q(n634) );
  INV0 U726 ( .A(n888), .Q(n766) );
  NOR20 U727 ( .A(n634), .B(n766), .Q(\u_apb_slave_regs/s_reg_control_n [2])
         );
  INV0 U728 ( .A(i_pwdata[3]), .Q(n639) );
  NOR20 U729 ( .A(n639), .B(n766), .Q(\u_apb_slave_regs/s_reg_control_n [3])
         );
  INV0 U730 ( .A(i_pwdata[1]), .Q(n635) );
  NOR20 U731 ( .A(n635), .B(n766), .Q(\u_apb_slave_regs/s_reg_control_n [1])
         );
  INV0 U732 ( .A(i_pwdata[4]), .Q(n638) );
  INV0 U733 ( .A(i_pwdata[5]), .Q(n637) );
  INV0 U734 ( .A(i_pwdata[7]), .Q(n636) );
  NAND40 U735 ( .A(n639), .B(n638), .C(n637), .D(n636), .Q(n640) );
  NOR40 U736 ( .A(i_pwdata[6]), .B(i_pwdata[1]), .C(i_pwdata[2]), .D(n640), 
        .Q(n641) );
  NOR20 U737 ( .A(i_pwdata[0]), .B(n641), .Q(n889) );
  AOI220 U738 ( .A(n643), .B(\u_serializer/s_shift_reg [7]), .C(
        o_dbg_tx_fifo_q[7]), .D(n642), .Q(n644) );
  INV0 U739 ( .A(n644), .Q(n469) );
  NOR40 U740 ( .A(o_tx_valid), .B(\eq_x_23/n25 ), .C(
        \u_serializer/s_waiting_fifo_data ), .D(n645), .Q(\u_serializer/N23 )
         );
  AOI210 U741 ( .A(\u_serializer/s_waiting_fifo_data ), .B(n646), .C(
        \u_serializer/N23 ), .Q(n647) );
  INV0 U742 ( .A(n647), .Q(n555) );
  NOR20 U743 ( .A(n849), .B(n842), .Q(n788) );
  INV0 U744 ( .A(n788), .Q(n790) );
  NOR20 U745 ( .A(n856), .B(n790), .Q(n789) );
  NAND20 U746 ( .A(\u_tx_baud_rate_gen/s_counter [3]), .B(n789), .Q(n792) );
  OAI210 U747 ( .A(\u_tx_baud_rate_gen/s_counter [3]), .B(n789), .C(n792), .Q(
        n648) );
  NOR20 U748 ( .A(n795), .B(n648), .Q(\u_tx_baud_rate_gen/N31 ) );
  NOR20 U749 ( .A(n858), .B(n792), .Q(n791) );
  NAND20 U750 ( .A(\u_tx_baud_rate_gen/s_counter [5]), .B(n791), .Q(n793) );
  OAI210 U751 ( .A(\u_tx_baud_rate_gen/s_counter [5]), .B(n791), .C(n793), .Q(
        n649) );
  NOR20 U752 ( .A(n795), .B(n649), .Q(\u_tx_baud_rate_gen/N33 ) );
  NAND20 U753 ( .A(\u_fifo_tx/s_rd_ptr [1]), .B(\u_fifo_tx/N40 ), .Q(n651) );
  NAND20 U754 ( .A(\u_fifo_tx/s_rd_ptr [0]), .B(n872), .Q(n652) );
  OAI210 U755 ( .A(n651), .B(n841), .C(\u_fifo_tx/s_rd_ptr [2]), .Q(n650) );
  OAI210 U756 ( .A(n651), .B(n652), .C(n650), .Q(n369) );
  NOR30 U757 ( .A(\u_fifo_tx/s_rd_ptr [1]), .B(n872), .C(n841), .Q(n703) );
  AOI220 U758 ( .A(\u_fifo_tx/s_mem[5][7] ), .B(n703), .C(
        \u_fifo_tx/s_mem[7][7] ), .D(n702), .Q(n659) );
  NOR21 U759 ( .A(\u_fifo_tx/s_rd_ptr [2]), .B(\u_fifo_tx/s_rd_ptr [0]), .Q(
        n705) );
  CLKIN1 U760 ( .A(n652), .Q(n704) );
  AOI220 U761 ( .A(\u_fifo_tx/s_mem[2][7] ), .B(n705), .C(
        \u_fifo_tx/s_mem[3][7] ), .D(n704), .Q(n656) );
  NOR21 U762 ( .A(\u_fifo_tx/s_rd_ptr [0]), .B(n872), .Q(n706) );
  AOI210 U763 ( .A(\u_fifo_tx/s_mem[6][7] ), .B(n706), .C(n845), .Q(n655) );
  AOI220 U764 ( .A(\u_fifo_tx/s_mem[0][7] ), .B(n705), .C(
        \u_fifo_tx/s_mem[1][7] ), .D(n704), .Q(n654) );
  AOI210 U765 ( .A(\u_fifo_tx/s_mem[4][7] ), .B(n706), .C(
        \u_fifo_tx/s_rd_ptr [1]), .Q(n653) );
  AOI220 U766 ( .A(n656), .B(n655), .C(n654), .D(n653), .Q(n657) );
  IMUX20 U767 ( .A(n657), .B(o_dbg_tx_fifo_q[7]), .S(n785), .Q(n658) );
  OAI210 U768 ( .A(n785), .B(n659), .C(n658), .Q(n364) );
  AOI220 U769 ( .A(\u_fifo_tx/s_mem[5][0] ), .B(n703), .C(
        \u_fifo_tx/s_mem[7][0] ), .D(n702), .Q(n666) );
  AOI220 U770 ( .A(\u_fifo_tx/s_mem[2][0] ), .B(n705), .C(
        \u_fifo_tx/s_mem[3][0] ), .D(n704), .Q(n663) );
  AOI210 U771 ( .A(\u_fifo_tx/s_mem[6][0] ), .B(n706), .C(n845), .Q(n662) );
  AOI220 U772 ( .A(\u_fifo_tx/s_mem[0][0] ), .B(n705), .C(
        \u_fifo_tx/s_mem[1][0] ), .D(n704), .Q(n661) );
  AOI210 U773 ( .A(\u_fifo_tx/s_mem[4][0] ), .B(n706), .C(
        \u_fifo_tx/s_rd_ptr [1]), .Q(n660) );
  AOI220 U774 ( .A(n663), .B(n662), .C(n661), .D(n660), .Q(n664) );
  IMUX20 U775 ( .A(n664), .B(o_dbg_tx_fifo_q[0]), .S(n785), .Q(n665) );
  OAI210 U776 ( .A(n785), .B(n666), .C(n665), .Q(n365) );
  AOI220 U777 ( .A(\u_fifo_tx/s_mem[5][6] ), .B(n703), .C(
        \u_fifo_tx/s_mem[7][6] ), .D(n702), .Q(n673) );
  AOI220 U778 ( .A(\u_fifo_tx/s_mem[2][6] ), .B(n705), .C(
        \u_fifo_tx/s_mem[3][6] ), .D(n704), .Q(n670) );
  AOI210 U779 ( .A(\u_fifo_tx/s_mem[6][6] ), .B(n706), .C(n845), .Q(n669) );
  AOI220 U780 ( .A(\u_fifo_tx/s_mem[0][6] ), .B(n705), .C(
        \u_fifo_tx/s_mem[1][6] ), .D(n704), .Q(n668) );
  AOI210 U781 ( .A(\u_fifo_tx/s_mem[4][6] ), .B(n706), .C(
        \u_fifo_tx/s_rd_ptr [1]), .Q(n667) );
  AOI220 U782 ( .A(n670), .B(n669), .C(n668), .D(n667), .Q(n671) );
  IMUX20 U783 ( .A(n671), .B(o_dbg_tx_fifo_q[6]), .S(n785), .Q(n672) );
  OAI210 U784 ( .A(n785), .B(n673), .C(n672), .Q(n363) );
  AOI220 U785 ( .A(\u_fifo_tx/s_mem[5][5] ), .B(n703), .C(
        \u_fifo_tx/s_mem[7][5] ), .D(n702), .Q(n680) );
  AOI220 U786 ( .A(\u_fifo_tx/s_mem[2][5] ), .B(n705), .C(
        \u_fifo_tx/s_mem[3][5] ), .D(n704), .Q(n677) );
  AOI210 U787 ( .A(\u_fifo_tx/s_mem[6][5] ), .B(n706), .C(n845), .Q(n676) );
  AOI220 U788 ( .A(\u_fifo_tx/s_mem[0][5] ), .B(n705), .C(
        \u_fifo_tx/s_mem[1][5] ), .D(n704), .Q(n675) );
  AOI210 U789 ( .A(\u_fifo_tx/s_mem[4][5] ), .B(n706), .C(
        \u_fifo_tx/s_rd_ptr [1]), .Q(n674) );
  AOI220 U790 ( .A(n677), .B(n676), .C(n675), .D(n674), .Q(n678) );
  IMUX20 U791 ( .A(n678), .B(o_dbg_tx_fifo_q[5]), .S(n785), .Q(n679) );
  OAI210 U792 ( .A(n785), .B(n680), .C(n679), .Q(n362) );
  AOI220 U793 ( .A(\u_fifo_tx/s_mem[5][4] ), .B(n703), .C(
        \u_fifo_tx/s_mem[7][4] ), .D(n702), .Q(n687) );
  AOI220 U794 ( .A(\u_fifo_tx/s_mem[2][4] ), .B(n705), .C(
        \u_fifo_tx/s_mem[3][4] ), .D(n704), .Q(n684) );
  AOI210 U795 ( .A(\u_fifo_tx/s_mem[6][4] ), .B(n706), .C(n845), .Q(n683) );
  AOI220 U796 ( .A(\u_fifo_tx/s_mem[0][4] ), .B(n705), .C(
        \u_fifo_tx/s_mem[1][4] ), .D(n704), .Q(n682) );
  AOI210 U797 ( .A(\u_fifo_tx/s_mem[4][4] ), .B(n706), .C(
        \u_fifo_tx/s_rd_ptr [1]), .Q(n681) );
  AOI220 U798 ( .A(n684), .B(n683), .C(n682), .D(n681), .Q(n685) );
  IMUX20 U799 ( .A(n685), .B(o_dbg_tx_fifo_q[4]), .S(n785), .Q(n686) );
  OAI210 U800 ( .A(n785), .B(n687), .C(n686), .Q(n361) );
  AOI220 U801 ( .A(\u_fifo_tx/s_mem[5][3] ), .B(n703), .C(
        \u_fifo_tx/s_mem[7][3] ), .D(n702), .Q(n694) );
  AOI220 U802 ( .A(\u_fifo_tx/s_mem[2][3] ), .B(n705), .C(
        \u_fifo_tx/s_mem[3][3] ), .D(n704), .Q(n691) );
  AOI210 U803 ( .A(\u_fifo_tx/s_mem[6][3] ), .B(n706), .C(n845), .Q(n690) );
  AOI220 U804 ( .A(\u_fifo_tx/s_mem[0][3] ), .B(n705), .C(
        \u_fifo_tx/s_mem[1][3] ), .D(n704), .Q(n689) );
  AOI210 U805 ( .A(\u_fifo_tx/s_mem[4][3] ), .B(n706), .C(
        \u_fifo_tx/s_rd_ptr [1]), .Q(n688) );
  AOI220 U806 ( .A(n691), .B(n690), .C(n689), .D(n688), .Q(n692) );
  IMUX20 U807 ( .A(n692), .B(o_dbg_tx_fifo_q[3]), .S(n785), .Q(n693) );
  OAI210 U808 ( .A(n785), .B(n694), .C(n693), .Q(n360) );
  AOI220 U809 ( .A(\u_fifo_tx/s_mem[5][2] ), .B(n703), .C(
        \u_fifo_tx/s_mem[7][2] ), .D(n702), .Q(n701) );
  AOI220 U810 ( .A(\u_fifo_tx/s_mem[2][2] ), .B(n705), .C(
        \u_fifo_tx/s_mem[3][2] ), .D(n704), .Q(n698) );
  AOI210 U811 ( .A(\u_fifo_tx/s_mem[6][2] ), .B(n706), .C(n845), .Q(n697) );
  AOI220 U812 ( .A(\u_fifo_tx/s_mem[0][2] ), .B(n705), .C(
        \u_fifo_tx/s_mem[1][2] ), .D(n704), .Q(n696) );
  AOI210 U813 ( .A(\u_fifo_tx/s_mem[4][2] ), .B(n706), .C(
        \u_fifo_tx/s_rd_ptr [1]), .Q(n695) );
  AOI220 U814 ( .A(n698), .B(n697), .C(n696), .D(n695), .Q(n699) );
  IMUX20 U815 ( .A(n699), .B(o_dbg_tx_fifo_q[2]), .S(n785), .Q(n700) );
  OAI210 U816 ( .A(n785), .B(n701), .C(n700), .Q(n359) );
  AOI220 U817 ( .A(\u_fifo_tx/s_mem[5][1] ), .B(n703), .C(
        \u_fifo_tx/s_mem[7][1] ), .D(n702), .Q(n713) );
  AOI220 U818 ( .A(\u_fifo_tx/s_mem[2][1] ), .B(n705), .C(
        \u_fifo_tx/s_mem[3][1] ), .D(n704), .Q(n710) );
  AOI210 U819 ( .A(\u_fifo_tx/s_mem[6][1] ), .B(n706), .C(n845), .Q(n709) );
  AOI220 U820 ( .A(\u_fifo_tx/s_mem[0][1] ), .B(n705), .C(
        \u_fifo_tx/s_mem[1][1] ), .D(n704), .Q(n708) );
  AOI210 U821 ( .A(\u_fifo_tx/s_mem[4][1] ), .B(n706), .C(
        \u_fifo_tx/s_rd_ptr [1]), .Q(n707) );
  AOI220 U822 ( .A(n710), .B(n709), .C(n708), .D(n707), .Q(n711) );
  IMUX20 U823 ( .A(n711), .B(o_dbg_tx_fifo_q[1]), .S(n785), .Q(n712) );
  OAI210 U824 ( .A(n785), .B(n713), .C(n712), .Q(n358) );
  NAND20 U825 ( .A(\u_fifo_rx/s_rd_ptr [0]), .B(o_dbg_rx_fifo_pop), .Q(n714)
         );
  NOR21 U826 ( .A(n862), .B(n714), .Q(n822) );
  IMUX20 U827 ( .A(n861), .B(\u_fifo_rx/s_rd_ptr [2]), .S(n822), .Q(n465) );
  NOR21 U828 ( .A(\u_fifo_rx/s_rd_ptr [1]), .B(n714), .Q(n821) );
  AOI210 U829 ( .A(n714), .B(\u_fifo_rx/s_rd_ptr [1]), .C(n821), .Q(n715) );
  INV0 U830 ( .A(n715), .Q(n466) );
  INV0 U831 ( .A(o_dbg_rx_fifo_pop), .Q(n829) );
  AOI220 U832 ( .A(n822), .B(\u_fifo_rx/s_mem[3][6] ), .C(n821), .D(
        \u_fifo_rx/s_mem[1][6] ), .Q(n718) );
  NOR21 U833 ( .A(n862), .B(n716), .Q(n824) );
  NOR21 U834 ( .A(\u_fifo_rx/s_rd_ptr [1]), .B(n716), .Q(n823) );
  AOI220 U835 ( .A(n824), .B(\u_fifo_rx/s_mem[2][6] ), .C(n823), .D(
        \u_fifo_rx/s_mem[0][6] ), .Q(n717) );
  AOI210 U836 ( .A(n718), .B(n717), .C(\u_fifo_rx/s_rd_ptr [2]), .Q(n722) );
  AOI220 U837 ( .A(n822), .B(\u_fifo_rx/s_mem[7][6] ), .C(n821), .D(
        \u_fifo_rx/s_mem[5][6] ), .Q(n720) );
  AOI220 U838 ( .A(n824), .B(\u_fifo_rx/s_mem[6][6] ), .C(n823), .D(
        \u_fifo_rx/s_mem[4][6] ), .Q(n719) );
  AOI210 U839 ( .A(n720), .B(n719), .C(n861), .Q(n721) );
  AOI2110 U840 ( .A(o_dbg_rx_fifo_q[6]), .B(n829), .C(n722), .D(n721), .Q(n723) );
  INV0 U841 ( .A(n723), .Q(n381) );
  AOI220 U842 ( .A(n822), .B(\u_fifo_rx/s_mem[3][1] ), .C(n821), .D(
        \u_fifo_rx/s_mem[1][1] ), .Q(n725) );
  AOI220 U843 ( .A(n824), .B(\u_fifo_rx/s_mem[2][1] ), .C(n823), .D(
        \u_fifo_rx/s_mem[0][1] ), .Q(n724) );
  AOI210 U844 ( .A(n725), .B(n724), .C(\u_fifo_rx/s_rd_ptr [2]), .Q(n729) );
  AOI220 U845 ( .A(n822), .B(\u_fifo_rx/s_mem[7][1] ), .C(n821), .D(
        \u_fifo_rx/s_mem[5][1] ), .Q(n727) );
  AOI220 U846 ( .A(n824), .B(\u_fifo_rx/s_mem[6][1] ), .C(n823), .D(
        \u_fifo_rx/s_mem[4][1] ), .Q(n726) );
  AOI210 U847 ( .A(n727), .B(n726), .C(n861), .Q(n728) );
  AOI2110 U848 ( .A(o_dbg_rx_fifo_q[1]), .B(n829), .C(n729), .D(n728), .Q(n730) );
  INV0 U849 ( .A(n730), .Q(n391) );
  AOI220 U850 ( .A(n822), .B(\u_fifo_rx/s_mem[3][0] ), .C(n821), .D(
        \u_fifo_rx/s_mem[1][0] ), .Q(n732) );
  AOI220 U851 ( .A(n824), .B(\u_fifo_rx/s_mem[2][0] ), .C(n823), .D(
        \u_fifo_rx/s_mem[0][0] ), .Q(n731) );
  AOI210 U852 ( .A(n732), .B(n731), .C(\u_fifo_rx/s_rd_ptr [2]), .Q(n736) );
  AOI220 U853 ( .A(n822), .B(\u_fifo_rx/s_mem[7][0] ), .C(n821), .D(
        \u_fifo_rx/s_mem[5][0] ), .Q(n734) );
  AOI220 U854 ( .A(n824), .B(\u_fifo_rx/s_mem[6][0] ), .C(n823), .D(
        \u_fifo_rx/s_mem[4][0] ), .Q(n733) );
  AOI210 U855 ( .A(n734), .B(n733), .C(n861), .Q(n735) );
  AOI2110 U856 ( .A(o_dbg_rx_fifo_q[0]), .B(n829), .C(n736), .D(n735), .Q(n737) );
  INV0 U857 ( .A(n737), .Q(n393) );
  AOI220 U858 ( .A(n822), .B(\u_fifo_rx/s_mem[3][7] ), .C(n821), .D(
        \u_fifo_rx/s_mem[1][7] ), .Q(n739) );
  AOI220 U859 ( .A(n824), .B(\u_fifo_rx/s_mem[2][7] ), .C(n823), .D(
        \u_fifo_rx/s_mem[0][7] ), .Q(n738) );
  AOI210 U860 ( .A(n739), .B(n738), .C(\u_fifo_rx/s_rd_ptr [2]), .Q(n743) );
  AOI220 U861 ( .A(n822), .B(\u_fifo_rx/s_mem[7][7] ), .C(n821), .D(
        \u_fifo_rx/s_mem[5][7] ), .Q(n741) );
  AOI220 U862 ( .A(n824), .B(\u_fifo_rx/s_mem[6][7] ), .C(n823), .D(
        \u_fifo_rx/s_mem[4][7] ), .Q(n740) );
  AOI210 U863 ( .A(n741), .B(n740), .C(n861), .Q(n742) );
  AOI2110 U864 ( .A(o_dbg_rx_fifo_q[7]), .B(n829), .C(n743), .D(n742), .Q(n744) );
  INV0 U865 ( .A(n744), .Q(n378) );
  AOI220 U866 ( .A(n822), .B(\u_fifo_rx/s_mem[3][2] ), .C(n821), .D(
        \u_fifo_rx/s_mem[1][2] ), .Q(n746) );
  AOI220 U867 ( .A(n824), .B(\u_fifo_rx/s_mem[2][2] ), .C(n823), .D(
        \u_fifo_rx/s_mem[0][2] ), .Q(n745) );
  AOI210 U868 ( .A(n746), .B(n745), .C(\u_fifo_rx/s_rd_ptr [2]), .Q(n750) );
  AOI220 U869 ( .A(n822), .B(\u_fifo_rx/s_mem[7][2] ), .C(n821), .D(
        \u_fifo_rx/s_mem[5][2] ), .Q(n748) );
  AOI220 U870 ( .A(n824), .B(\u_fifo_rx/s_mem[6][2] ), .C(n823), .D(
        \u_fifo_rx/s_mem[4][2] ), .Q(n747) );
  AOI210 U871 ( .A(n748), .B(n747), .C(n861), .Q(n749) );
  AOI2110 U872 ( .A(o_dbg_rx_fifo_q[2]), .B(n829), .C(n750), .D(n749), .Q(n751) );
  INV0 U873 ( .A(n751), .Q(n389) );
  AOI220 U874 ( .A(n822), .B(\u_fifo_rx/s_mem[3][3] ), .C(n821), .D(
        \u_fifo_rx/s_mem[1][3] ), .Q(n753) );
  AOI220 U875 ( .A(n824), .B(\u_fifo_rx/s_mem[2][3] ), .C(n823), .D(
        \u_fifo_rx/s_mem[0][3] ), .Q(n752) );
  AOI210 U876 ( .A(n753), .B(n752), .C(\u_fifo_rx/s_rd_ptr [2]), .Q(n757) );
  AOI220 U877 ( .A(n822), .B(\u_fifo_rx/s_mem[7][3] ), .C(n821), .D(
        \u_fifo_rx/s_mem[5][3] ), .Q(n755) );
  AOI220 U878 ( .A(n824), .B(\u_fifo_rx/s_mem[6][3] ), .C(n823), .D(
        \u_fifo_rx/s_mem[4][3] ), .Q(n754) );
  AOI210 U879 ( .A(n755), .B(n754), .C(n861), .Q(n756) );
  AOI2110 U880 ( .A(o_dbg_rx_fifo_q[3]), .B(n829), .C(n757), .D(n756), .Q(n758) );
  INV0 U881 ( .A(n758), .Q(n387) );
  AOI220 U882 ( .A(n822), .B(\u_fifo_rx/s_mem[3][4] ), .C(n821), .D(
        \u_fifo_rx/s_mem[1][4] ), .Q(n760) );
  AOI220 U883 ( .A(n824), .B(\u_fifo_rx/s_mem[2][4] ), .C(n823), .D(
        \u_fifo_rx/s_mem[0][4] ), .Q(n759) );
  AOI210 U884 ( .A(n760), .B(n759), .C(\u_fifo_rx/s_rd_ptr [2]), .Q(n764) );
  AOI220 U885 ( .A(n822), .B(\u_fifo_rx/s_mem[7][4] ), .C(n821), .D(
        \u_fifo_rx/s_mem[5][4] ), .Q(n762) );
  AOI220 U886 ( .A(n824), .B(\u_fifo_rx/s_mem[6][4] ), .C(n823), .D(
        \u_fifo_rx/s_mem[4][4] ), .Q(n761) );
  AOI210 U887 ( .A(n762), .B(n761), .C(n861), .Q(n763) );
  AOI2110 U888 ( .A(o_dbg_rx_fifo_q[4]), .B(n829), .C(n764), .D(n763), .Q(n765) );
  INV0 U889 ( .A(n765), .Q(n385) );
  MUX21 U890 ( .A(i_pwdata[4]), .B(o_dbg_rx_enable), .S(n766), .Q(n559) );
  MUX21 U891 ( .A(o_dbg_tx_fifo_data[2]), .B(i_pwdata[2]), .S(
        \u_apb_slave_regs/s_tx_push_n ), .Q(n549) );
  MUX21 U892 ( .A(o_dbg_tx_fifo_data[3]), .B(i_pwdata[3]), .S(
        \u_apb_slave_regs/s_tx_push_n ), .Q(n548) );
  MUX21 U893 ( .A(o_dbg_tx_fifo_data[4]), .B(i_pwdata[4]), .S(
        \u_apb_slave_regs/s_tx_push_n ), .Q(n547) );
  MUX21 U894 ( .A(o_dbg_tx_fifo_data[5]), .B(i_pwdata[5]), .S(
        \u_apb_slave_regs/s_tx_push_n ), .Q(n546) );
  MUX21 U895 ( .A(o_dbg_tx_fifo_data[7]), .B(i_pwdata[7]), .S(
        \u_apb_slave_regs/s_tx_push_n ), .Q(n545) );
  MUX21 U896 ( .A(o_dbg_tx_fifo_data[6]), .B(i_pwdata[6]), .S(
        \u_apb_slave_regs/s_tx_push_n ), .Q(n552) );
  MUX21 U897 ( .A(o_dbg_tx_fifo_data[0]), .B(i_pwdata[0]), .S(
        \u_apb_slave_regs/s_tx_push_n ), .Q(n551) );
  MUX21 U898 ( .A(o_dbg_tx_fifo_data[1]), .B(i_pwdata[1]), .S(
        \u_apb_slave_regs/s_tx_push_n ), .Q(n550) );
  NAND20 U899 ( .A(n772), .B(\u_deserializer/s_bit_count [0]), .Q(n767) );
  OAI210 U900 ( .A(n818), .B(n874), .C(o_dbg_rx_path_en), .Q(n817) );
  IMUX20 U901 ( .A(n767), .B(n817), .S(\u_deserializer/s_bit_count [1]), .Q(
        n452) );
  NAND30 U902 ( .A(\u_deserializer/s_bit_count [1]), .B(n772), .C(
        \u_deserializer/s_bit_count [0]), .Q(n771) );
  OAI210 U903 ( .A(n768), .B(\u_deserializer/s_bit_count [1]), .C(n817), .Q(
        n769) );
  INV0 U904 ( .A(n769), .Q(n770) );
  IMUX20 U905 ( .A(n771), .B(n770), .S(\u_deserializer/s_bit_count [2]), .Q(
        n451) );
  MUX21 U906 ( .A(\u_deserializer/s_shift_reg [7]), .B(i_serial_rx), .S(n772), 
        .Q(n377) );
  MUX21 U907 ( .A(\u_deserializer/s_shift_reg [6]), .B(
        \u_deserializer/s_shift_reg [7]), .S(n772), .Q(n376) );
  MUX21 U908 ( .A(\u_deserializer/s_shift_reg [1]), .B(
        \u_deserializer/s_shift_reg [2]), .S(n772), .Q(n371) );
  MUX21 U909 ( .A(\u_deserializer/s_shift_reg [3]), .B(
        \u_deserializer/s_shift_reg [4]), .S(n772), .Q(n373) );
  MUX21 U910 ( .A(\u_deserializer/s_shift_reg [4]), .B(
        \u_deserializer/s_shift_reg [5]), .S(n772), .Q(n374) );
  MUX21 U911 ( .A(\u_deserializer/s_shift_reg [5]), .B(
        \u_deserializer/s_shift_reg [6]), .S(n772), .Q(n375) );
  MUX21 U912 ( .A(\u_deserializer/s_shift_reg [2]), .B(
        \u_deserializer/s_shift_reg [3]), .S(n772), .Q(n372) );
  NOR20 U913 ( .A(n773), .B(n870), .Q(n775) );
  OAI210 U914 ( .A(n848), .B(n775), .C(n774), .Q(n557) );
  MUX21 U915 ( .A(o_serial_tx), .B(\u_serializer/s_shift_reg [0]), .S(
        \u_serializer/N38 ), .Q(n357) );
  AOI210 U916 ( .A(\u_serializer/s_bit_count [0]), .B(n873), .C(n848), .Q(n776) );
  NOR20 U917 ( .A(n777), .B(n776), .Q(n778) );
  IMUX20 U918 ( .A(n779), .B(n778), .S(\u_serializer/s_bit_count [1]), .Q(n477) );
  NOR30 U919 ( .A(n848), .B(n875), .C(n780), .Q(\u_tx_baud_rate_gen/N27 ) );
  IMUX20 U920 ( .A(n782), .B(n781), .S(\u_fifo_rx/s_wr_ptr [0]), .Q(n356) );
  IMUX20 U921 ( .A(\u_fifo_tx/s_wr_ptr [0]), .B(n868), .S(n830), .Q(n368) );
  MUX21 U922 ( .A(o_dbg_rx_fifo_data[0]), .B(\u_deserializer/s_shift_reg [1]), 
        .S(\u_deserializer/N24 ), .Q(n463) );
  MUX21 U923 ( .A(o_dbg_rx_fifo_data[2]), .B(\u_deserializer/s_shift_reg [3]), 
        .S(\u_deserializer/N24 ), .Q(n457) );
  MUX21 U924 ( .A(o_dbg_rx_fifo_data[1]), .B(\u_deserializer/s_shift_reg [2]), 
        .S(\u_deserializer/N24 ), .Q(n456) );
  MUX21 U925 ( .A(o_dbg_rx_fifo_data[7]), .B(i_serial_rx), .S(
        \u_deserializer/N24 ), .Q(n462) );
  MUX21 U926 ( .A(o_dbg_rx_fifo_data[3]), .B(\u_deserializer/s_shift_reg [4]), 
        .S(\u_deserializer/N24 ), .Q(n458) );
  MUX21 U927 ( .A(o_dbg_rx_fifo_data[6]), .B(\u_deserializer/s_shift_reg [7]), 
        .S(\u_deserializer/N24 ), .Q(n461) );
  MUX21 U928 ( .A(o_dbg_rx_fifo_data[5]), .B(\u_deserializer/s_shift_reg [6]), 
        .S(\u_deserializer/N24 ), .Q(n460) );
  MUX21 U929 ( .A(o_dbg_rx_fifo_data[4]), .B(\u_deserializer/s_shift_reg [5]), 
        .S(\u_deserializer/N24 ), .Q(n459) );
  NOR20 U930 ( .A(n830), .B(n783), .Q(n832) );
  NAND20 U931 ( .A(\u_fifo_tx/s_wr_ptr [2]), .B(n832), .Q(n784) );
  IMUX20 U932 ( .A(\u_fifo_tx/s_wr_ptr [3]), .B(n876), .S(n784), .Q(n544) );
  IMUX20 U933 ( .A(n864), .B(\u_fifo_tx/s_wr_ptr [2]), .S(n832), .Q(n366) );
  NOR20 U934 ( .A(n841), .B(n785), .Q(n786) );
  IMUX20 U935 ( .A(n845), .B(\u_fifo_tx/s_rd_ptr [1]), .S(n786), .Q(n370) );
  IMUX20 U936 ( .A(n865), .B(\u_fifo_rx/s_wr_ptr [2]), .S(n834), .Q(n354) );
  NAND20 U937 ( .A(\u_fifo_rx/s_rd_ptr [2]), .B(n822), .Q(n787) );
  IMUX20 U938 ( .A(\u_fifo_rx/s_rd_ptr [3]), .B(n863), .S(n787), .Q(n464) );
  AOI2110 U939 ( .A(n849), .B(n842), .C(n788), .D(n795), .Q(
        \u_tx_baud_rate_gen/N29 ) );
  AOI2110 U940 ( .A(n856), .B(n790), .C(n789), .D(n795), .Q(
        \u_tx_baud_rate_gen/N30 ) );
  AOI2110 U941 ( .A(n858), .B(n792), .C(n791), .D(n795), .Q(
        \u_tx_baud_rate_gen/N32 ) );
  NOR20 U942 ( .A(n859), .B(n793), .Q(n796) );
  AOI2110 U943 ( .A(n859), .B(n793), .C(n796), .D(n795), .Q(
        \u_tx_baud_rate_gen/N34 ) );
  NOR20 U944 ( .A(\u_tx_baud_rate_gen/s_counter [7]), .B(n796), .Q(n794) );
  AOI2110 U945 ( .A(\u_tx_baud_rate_gen/s_counter [7]), .B(n796), .C(n795), 
        .D(n794), .Q(\u_tx_baud_rate_gen/N35 ) );
  IMUX20 U946 ( .A(o_dbg_rx_fifo_q[0]), .B(\eq_x_54/n25 ), .S(i_paddr[2]), .Q(
        n799) );
  INV0 U947 ( .A(n797), .Q(n810) );
  OAI220 U948 ( .A(o_dbg_global_en), .B(n811), .C(n810), .D(o_dbg_div_val[0]), 
        .Q(n798) );
  AOI2110 U949 ( .A(n799), .B(n814), .C(n813), .D(n798), .Q(o_prdata[0]) );
  IMUX20 U950 ( .A(w_sw_reset), .B(\u_apb_slave_regs/s_reg_divider [1]), .S(
        i_paddr[2]), .Q(n803) );
  OAI210 U951 ( .A(n800), .B(n805), .C(n814), .Q(n801) );
  AOI210 U952 ( .A(o_dbg_rx_fifo_q[1]), .B(n805), .C(n801), .Q(n802) );
  AOI2110 U953 ( .A(i_paddr[3]), .B(n803), .C(n802), .D(n813), .Q(o_prdata[1])
         );
  IMUX20 U954 ( .A(w_clear_err), .B(\u_apb_slave_regs/s_reg_divider [2]), .S(
        i_paddr[2]), .Q(n807) );
  OAI210 U955 ( .A(n848), .B(n805), .C(n814), .Q(n804) );
  AOI210 U956 ( .A(o_dbg_rx_fifo_q[2]), .B(n805), .C(n804), .Q(n806) );
  AOI2110 U957 ( .A(i_paddr[3]), .B(n807), .C(n806), .D(n813), .Q(o_prdata[2])
         );
  IMUX20 U958 ( .A(o_dbg_rx_fifo_q[3]), .B(o_dbg_rx_ovf_err), .S(i_paddr[2]), 
        .Q(n809) );
  OAI220 U959 ( .A(o_dbg_tx_start), .B(n811), .C(
        \u_apb_slave_regs/s_reg_divider [3]), .D(n810), .Q(n808) );
  AOI2110 U960 ( .A(n809), .B(n814), .C(n813), .D(n808), .Q(o_prdata[3]) );
  IMUX20 U961 ( .A(o_dbg_rx_fifo_q[4]), .B(o_dbg_tx_und_err), .S(i_paddr[2]), 
        .Q(n815) );
  OAI220 U962 ( .A(o_dbg_rx_enable), .B(n811), .C(
        \u_apb_slave_regs/s_reg_divider [4]), .D(n810), .Q(n812) );
  AOI2110 U963 ( .A(n815), .B(n814), .C(n813), .D(n812), .Q(o_prdata[4]) );
  NAND20 U964 ( .A(\u_fifo_rx/s_wr_ptr [2]), .B(n834), .Q(n816) );
  XNR20 U965 ( .A(\u_fifo_rx/s_wr_ptr [3]), .B(n816), .Q(n468) );
  AOI2110 U966 ( .A(n860), .B(n877), .C(w_sw_reset), .D(w_clear_err), .Q(n454)
         );
  AOI210 U967 ( .A(n818), .B(n874), .C(n817), .Q(n453) );
  AOI220 U968 ( .A(n822), .B(\u_fifo_rx/s_mem[3][5] ), .C(n821), .D(
        \u_fifo_rx/s_mem[1][5] ), .Q(n820) );
  AOI220 U969 ( .A(n824), .B(\u_fifo_rx/s_mem[2][5] ), .C(n823), .D(
        \u_fifo_rx/s_mem[0][5] ), .Q(n819) );
  AOI210 U970 ( .A(n820), .B(n819), .C(\u_fifo_rx/s_rd_ptr [2]), .Q(n828) );
  AOI220 U971 ( .A(n822), .B(\u_fifo_rx/s_mem[7][5] ), .C(n821), .D(
        \u_fifo_rx/s_mem[5][5] ), .Q(n826) );
  AOI220 U972 ( .A(n824), .B(\u_fifo_rx/s_mem[6][5] ), .C(n823), .D(
        \u_fifo_rx/s_mem[4][5] ), .Q(n825) );
  AOI210 U973 ( .A(n826), .B(n825), .C(n861), .Q(n827) );
  AOI2110 U974 ( .A(o_dbg_rx_fifo_q[5]), .B(n829), .C(n828), .D(n827), .Q(n902) );
  INV0 U975 ( .A(n830), .Q(n831) );
  NAND20 U976 ( .A(\u_fifo_tx/s_wr_ptr [0]), .B(n831), .Q(n833) );
  AOI210 U977 ( .A(n869), .B(n833), .C(n832), .Q(n367) );
  AOI210 U978 ( .A(n867), .B(n835), .C(n834), .Q(n355) );
endmodule

