/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : U-2022.12
// Date      : Wed Apr 15 09:30:54 2026
/////////////////////////////////////////////////////////////


module receiver_system ( CLK, RSTn, adc_eoc, I_in, Q_in, I_filtered, 
        Q_filtered );
  input [3:0] I_in;
  input [3:0] Q_in;
  output [7:0] I_filtered;
  output [7:0] Q_filtered;
  input CLK, RSTn, adc_eoc;
  wire   \u_demod/cos_signal/prev_counter[1] , \u_fir_i/u_core/N38 ,
         \u_fir_i/u_core/N36 , \u_fir_i/u_core/N35 , \u_fir_i/u_core/N34 ,
         \u_fir_i/u_core/N33 , \u_fir_i/u_core/N32 , \u_fir_q/u_core/N38 ,
         \u_fir_q/u_core/N36 , \u_fir_q/u_core/N35 , \u_fir_q/u_core/N34 ,
         \u_fir_q/u_core/N33 , \u_fir_q/u_core/N32 , \u_fir_q/u_core/N31 , n37,
         n38, n39, n42, n43, n44, n45, n46, n47, n48, n51, n52, n53, n54, n55,
         n56, n57, n58, n60, n61, n62, n63, n64, n65, n66, n67, n69, n70, n71,
         n72, n73, n74, n75, n78, n79, n80, n81, n82, n83, n84, n87, n88, n89,
         n90, n114, n115, n116, n117, n123, n124, n125, n126, n132, n133, n134,
         n135, n141, n142, n143, n144, n150, n151, n152, n153, n172, n173,
         n174, n176, n177, n178, n179, \intadd_31/A[9] , \intadd_31/A[8] ,
         \intadd_31/A[7] , \intadd_31/B[9] , \intadd_31/B[8] ,
         \intadd_31/B[7] , \intadd_31/CI , \intadd_31/SUM[9] ,
         \intadd_31/SUM[8] , \intadd_31/SUM[7] , \intadd_31/SUM[6] ,
         \intadd_31/SUM[5] , \intadd_31/SUM[4] , \intadd_31/SUM[3] ,
         \intadd_31/SUM[2] , \intadd_31/SUM[1] , \intadd_31/SUM[0] ,
         \intadd_31/n10 , \intadd_31/n9 , \intadd_31/n8 , \intadd_31/n7 ,
         \intadd_31/n6 , \intadd_31/n5 , \intadd_31/n4 , \intadd_31/n3 ,
         \intadd_31/n2 , \intadd_31/n1 , \intadd_32/A[8] , \intadd_32/A[7] ,
         \intadd_32/A[6] , \intadd_32/A[5] , \intadd_32/A[4] ,
         \intadd_32/A[3] , \intadd_32/A[2] , \intadd_32/A[1] ,
         \intadd_32/A[0] , \intadd_32/B[9] , \intadd_32/B[8] ,
         \intadd_32/B[7] , \intadd_32/B[6] , \intadd_32/B[5] ,
         \intadd_32/B[4] , \intadd_32/B[3] , \intadd_32/B[2] ,
         \intadd_32/B[1] , \intadd_32/B[0] , \intadd_32/CI ,
         \intadd_32/SUM[9] , \intadd_32/SUM[8] , \intadd_32/SUM[7] ,
         \intadd_32/SUM[6] , \intadd_32/SUM[5] , \intadd_32/SUM[4] ,
         \intadd_32/SUM[3] , \intadd_32/SUM[2] , \intadd_32/SUM[1] ,
         \intadd_32/SUM[0] , \intadd_32/n10 , \intadd_32/n9 , \intadd_32/n8 ,
         \intadd_32/n7 , \intadd_32/n6 , \intadd_32/n5 , \intadd_32/n4 ,
         \intadd_32/n3 , \intadd_32/n2 , \intadd_32/n1 , \intadd_33/A[9] ,
         \intadd_33/A[8] , \intadd_33/A[7] , \intadd_33/B[9] ,
         \intadd_33/B[8] , \intadd_33/B[7] , \intadd_33/CI ,
         \intadd_33/SUM[9] , \intadd_33/SUM[8] , \intadd_33/SUM[7] ,
         \intadd_33/SUM[6] , \intadd_33/SUM[5] , \intadd_33/SUM[4] ,
         \intadd_33/SUM[3] , \intadd_33/SUM[2] , \intadd_33/SUM[1] ,
         \intadd_33/SUM[0] , \intadd_33/n10 , \intadd_33/n9 , \intadd_33/n8 ,
         \intadd_33/n7 , \intadd_33/n6 , \intadd_33/n5 , \intadd_33/n4 ,
         \intadd_33/n3 , \intadd_33/n2 , \intadd_33/n1 , \intadd_34/A[8] ,
         \intadd_34/A[7] , \intadd_34/A[6] , \intadd_34/A[5] ,
         \intadd_34/A[4] , \intadd_34/A[3] , \intadd_34/A[2] ,
         \intadd_34/A[1] , \intadd_34/A[0] , \intadd_34/B[9] ,
         \intadd_34/B[8] , \intadd_34/B[7] , \intadd_34/B[6] ,
         \intadd_34/B[5] , \intadd_34/B[4] , \intadd_34/B[3] ,
         \intadd_34/B[2] , \intadd_34/B[1] , \intadd_34/B[0] , \intadd_34/CI ,
         \intadd_34/SUM[9] , \intadd_34/SUM[8] , \intadd_34/SUM[7] ,
         \intadd_34/SUM[6] , \intadd_34/SUM[5] , \intadd_34/SUM[4] ,
         \intadd_34/SUM[3] , \intadd_34/SUM[2] , \intadd_34/SUM[1] ,
         \intadd_34/SUM[0] , \intadd_34/n10 , \intadd_34/n9 , \intadd_34/n8 ,
         \intadd_34/n7 , \intadd_34/n6 , \intadd_34/n5 , \intadd_34/n4 ,
         \intadd_34/n3 , \intadd_34/n2 , \intadd_34/n1 , \intadd_35/A[5] ,
         \intadd_35/A[4] , \intadd_35/A[3] , \intadd_35/A[2] ,
         \intadd_35/B[7] , \intadd_35/B[6] , \intadd_35/B[5] ,
         \intadd_35/B[4] , \intadd_35/B[2] , \intadd_35/B[0] , \intadd_35/CI ,
         \intadd_35/SUM[7] , \intadd_35/SUM[6] , \intadd_35/SUM[5] ,
         \intadd_35/SUM[4] , \intadd_35/SUM[3] , \intadd_35/SUM[2] ,
         \intadd_35/SUM[1] , \intadd_35/SUM[0] , \intadd_35/n8 ,
         \intadd_35/n7 , \intadd_35/n6 , \intadd_35/n5 , \intadd_35/n4 ,
         \intadd_35/n3 , \intadd_35/n2 , \intadd_35/n1 , \intadd_36/A[5] ,
         \intadd_36/A[4] , \intadd_36/A[3] , \intadd_36/A[2] ,
         \intadd_36/B[7] , \intadd_36/B[6] , \intadd_36/B[5] ,
         \intadd_36/B[4] , \intadd_36/B[2] , \intadd_36/B[0] , \intadd_36/CI ,
         \intadd_36/SUM[7] , \intadd_36/SUM[6] , \intadd_36/SUM[5] ,
         \intadd_36/SUM[4] , \intadd_36/SUM[3] , \intadd_36/SUM[2] ,
         \intadd_36/SUM[1] , \intadd_36/SUM[0] , \intadd_36/n8 ,
         \intadd_36/n7 , \intadd_36/n6 , \intadd_36/n5 , \intadd_36/n4 ,
         \intadd_36/n3 , \intadd_36/n2 , \intadd_36/n1 , \intadd_37/B[6] ,
         \intadd_37/B[5] , \intadd_37/B[4] , \intadd_37/B[3] ,
         \intadd_37/B[1] , \intadd_37/B[0] , \intadd_37/CI ,
         \intadd_37/SUM[6] , \intadd_37/SUM[5] , \intadd_37/SUM[4] ,
         \intadd_37/SUM[3] , \intadd_37/SUM[2] , \intadd_37/SUM[1] ,
         \intadd_37/SUM[0] , \intadd_37/n7 , \intadd_37/n6 , \intadd_37/n5 ,
         \intadd_37/n4 , \intadd_37/n3 , \intadd_37/n2 , \intadd_37/n1 ,
         \intadd_38/CI , \intadd_38/SUM[1] , \intadd_38/SUM[0] ,
         \intadd_38/n7 , \intadd_38/n6 , \intadd_38/n5 , \intadd_38/n4 ,
         \intadd_38/n3 , \intadd_38/n2 , \intadd_38/n1 , \intadd_39/CI ,
         \intadd_39/SUM[1] , \intadd_39/n7 , \intadd_39/n6 , \intadd_39/n5 ,
         \intadd_39/n4 , \intadd_39/n3 , \intadd_39/n2 , \intadd_39/n1 ,
         \intadd_40/CI , \intadd_40/SUM[6] , \intadd_40/SUM[4] ,
         \intadd_40/SUM[3] , \intadd_40/SUM[2] , \intadd_40/n7 ,
         \intadd_40/n6 , \intadd_40/n5 , \intadd_40/n4 , \intadd_40/n3 ,
         \intadd_40/n2 , \intadd_40/n1 , \intadd_41/B[6] , \intadd_41/B[5] ,
         \intadd_41/B[4] , \intadd_41/B[3] , \intadd_41/B[1] ,
         \intadd_41/B[0] , \intadd_41/CI , \intadd_41/SUM[6] ,
         \intadd_41/SUM[5] , \intadd_41/SUM[4] , \intadd_41/SUM[3] ,
         \intadd_41/SUM[2] , \intadd_41/SUM[1] , \intadd_41/SUM[0] ,
         \intadd_41/n7 , \intadd_41/n6 , \intadd_41/n5 , \intadd_41/n4 ,
         \intadd_41/n3 , \intadd_41/n2 , \intadd_41/n1 , \intadd_42/CI ,
         \intadd_42/SUM[1] , \intadd_42/SUM[0] , \intadd_42/n7 ,
         \intadd_42/n6 , \intadd_42/n5 , \intadd_42/n4 , \intadd_42/n3 ,
         \intadd_42/n2 , \intadd_42/n1 , \intadd_43/CI , \intadd_43/SUM[1] ,
         \intadd_43/n7 , \intadd_43/n6 , \intadd_43/n5 , \intadd_43/n4 ,
         \intadd_43/n3 , \intadd_43/n2 , \intadd_43/n1 , \intadd_44/CI ,
         \intadd_44/SUM[6] , \intadd_44/SUM[4] , \intadd_44/SUM[3] ,
         \intadd_44/SUM[2] , \intadd_44/n7 , \intadd_44/n6 , \intadd_44/n5 ,
         \intadd_44/n4 , \intadd_44/n3 , \intadd_44/n2 , \intadd_44/n1 ,
         \intadd_45/A[4] , \intadd_45/A[3] , \intadd_45/A[2] ,
         \intadd_45/A[1] , \intadd_45/B[4] , \intadd_45/B[3] ,
         \intadd_45/B[2] , \intadd_45/B[1] , \intadd_45/B[0] , \intadd_45/CI ,
         \intadd_45/SUM[4] , \intadd_45/SUM[3] , \intadd_45/SUM[2] ,
         \intadd_45/SUM[1] , \intadd_45/SUM[0] , \intadd_45/n5 ,
         \intadd_45/n4 , \intadd_45/n3 , \intadd_45/n2 , \intadd_45/n1 ,
         \intadd_46/A[4] , \intadd_46/A[3] , \intadd_46/A[2] ,
         \intadd_46/A[1] , \intadd_46/B[4] , \intadd_46/B[3] ,
         \intadd_46/B[2] , \intadd_46/B[1] , \intadd_46/B[0] , \intadd_46/CI ,
         \intadd_46/SUM[4] , \intadd_46/SUM[3] , \intadd_46/SUM[2] ,
         \intadd_46/SUM[1] , \intadd_46/SUM[0] , \intadd_46/n5 ,
         \intadd_46/n4 , \intadd_46/n3 , \intadd_46/n2 , \intadd_46/n1 ,
         \intadd_47/A[1] , \intadd_47/A[0] , \intadd_47/B[3] ,
         \intadd_47/B[2] , \intadd_47/B[0] , \intadd_47/SUM[3] ,
         \intadd_47/SUM[2] , \intadd_47/SUM[1] , \intadd_47/SUM[0] ,
         \intadd_47/n4 , \intadd_47/n3 , \intadd_47/n2 , \intadd_47/n1 ,
         \intadd_48/A[1] , \intadd_48/A[0] , \intadd_48/B[3] ,
         \intadd_48/B[2] , \intadd_48/B[0] , \intadd_48/SUM[3] ,
         \intadd_48/SUM[2] , \intadd_48/SUM[1] , \intadd_48/SUM[0] ,
         \intadd_48/n4 , \intadd_48/n3 , \intadd_48/n2 , \intadd_48/n1 ,
         \intadd_50/A[3] , \intadd_50/A[2] , \intadd_50/A[1] ,
         \intadd_50/A[0] , \intadd_50/B[2] , \intadd_50/CI ,
         \intadd_50/SUM[3] , \intadd_50/SUM[2] , \intadd_50/SUM[1] ,
         \intadd_50/SUM[0] , \intadd_50/n4 , \intadd_50/n3 , \intadd_50/n2 ,
         \intadd_50/n1 , \intadd_51/A[2] , \intadd_51/B[0] ,
         \intadd_51/SUM[3] , \intadd_51/n4 , \intadd_51/n3 , \intadd_51/n2 ,
         \intadd_51/n1 , \intadd_53/A[3] , \intadd_53/A[2] , \intadd_53/A[1] ,
         \intadd_53/A[0] , \intadd_53/B[2] , \intadd_53/CI ,
         \intadd_53/SUM[3] , \intadd_53/SUM[2] , \intadd_53/SUM[1] ,
         \intadd_53/SUM[0] , \intadd_53/n4 , \intadd_53/n3 , \intadd_53/n2 ,
         \intadd_53/n1 , \intadd_54/A[2] , \intadd_54/B[0] ,
         \intadd_54/SUM[3] , \intadd_54/n4 , \intadd_54/n3 , \intadd_54/n2 ,
         \intadd_54/n1 , \intadd_55/A[2] , \intadd_55/B[2] , \intadd_55/B[1] ,
         \intadd_55/B[0] , \intadd_55/CI , \intadd_55/n3 , \intadd_55/n2 ,
         \intadd_55/n1 , \intadd_56/A[2] , \intadd_56/B[2] , \intadd_56/B[1] ,
         \intadd_56/B[0] , \intadd_56/CI , \intadd_56/n3 , \intadd_56/n2 ,
         \intadd_56/n1 , \intadd_57/A[2] , \intadd_57/A[1] , \intadd_57/B[2] ,
         \intadd_57/B[1] , \intadd_57/SUM[2] , \intadd_57/SUM[1] ,
         \intadd_57/n3 , \intadd_57/n2 , \intadd_57/n1 , \intadd_58/A[2] ,
         \intadd_58/A[1] , \intadd_58/B[2] , \intadd_58/B[1] ,
         \intadd_58/B[0] , \intadd_58/CI , \intadd_58/SUM[0] , \intadd_58/n3 ,
         \intadd_58/n2 , \intadd_58/n1 , \intadd_59/A[2] , \intadd_59/A[1] ,
         \intadd_59/A[0] , \intadd_59/B[2] , \intadd_59/B[1] ,
         \intadd_59/B[0] , \intadd_59/CI , \intadd_59/n3 , \intadd_59/n2 ,
         \intadd_59/n1 , \intadd_60/A[2] , \intadd_60/A[1] , \intadd_60/B[2] ,
         \intadd_60/B[1] , \intadd_60/B[0] , \intadd_60/CI ,
         \intadd_60/SUM[0] , \intadd_60/n3 , \intadd_60/n2 , \intadd_60/n1 ,
         \intadd_61/A[2] , \intadd_61/A[1] , \intadd_61/A[0] ,
         \intadd_61/B[2] , \intadd_61/B[1] , \intadd_61/B[0] , \intadd_61/CI ,
         \intadd_61/n3 , \intadd_61/n2 , \intadd_61/n1 , n204, n205, n206,
         n207, n208, n209, n210, n211, n212, n213, n214, n215, n216, n217,
         n218, n219, n220, n221, n222, n223, n224, n225, n226, n227, n228,
         n229, n230, n231, n232, n233, n234, n235, n236, n237, n238, n239,
         n240, n241, n242, n243, n244, n245, n246, n247, n248, n249, n250,
         n251, n252, n253, n254, n255, n256, n257, n258, n259, n260, n261,
         n262, n263, n264, n265, n266, n267, n268, n269, n270, n271, n272,
         n273, n274, n275, n276, n277, n278, n279, n280, n281, n282, n283,
         n284, n285, n286, n287, n288, n289, n290, n291, n292, n293, n294,
         n295, n296, n297, n298, n299, n300, n301, n302, n303, n304, n305,
         n306, n307, n308, n309, n310, n311, n312, n313, n314, n315, n316,
         n317, n318, n319, n320, n321, n322, n323, n324, n325, n326, n327,
         n328, n329, n330, n331, n332, n333, n334, n335, n336, n337, n338,
         n339, n340, n341, n342, n343, n344, n345, n346, n347, n348, n349,
         n350, n351, n352, n353, n354, n355, n356, n357, n358, n359, n360,
         n361, n362, n363, n364, n365, n366, n367, n368, n369, n370, n371,
         n372, n373, n374, n375, n376, n377, n378, n379, n380, n381, n382,
         n383, n384, n385, n386, n387, n388, n389, n390, n391, n392, n393,
         n394, n395, n396, n397, n398, n399, n400, n401, n402, n403, n404,
         n405, n406, n407, n408, n409, n410, n411, n412, n413, n414, n415,
         n416, n417, n418, n419, n420, n421, n422, n423, n424, n425, n426,
         n427, n428, n429, n430, n431, n432, n433, n434, n435, n436, n437,
         n438, n439, n440, n441, n442, n443, n444, n445, n446, n447, n448,
         n449, n450, n451, n452, n453, n454, n455, n456, n457, n458, n459,
         n460, n461, n462, n463, n464, n465, n466, n467, n468, n469, n470,
         n471, n472, n473, n474, n475, n476, n477, n478, n479, n480, n481,
         n482, n483, n484, n485, n486, n487, n488, n489, n490, n491, n492,
         n493, n494, n495, n496, n497, n498, n499, n500, n501, n502, n503,
         n504, n505, n506, n507, n508, n509, n510, n511, n512, n513, n514,
         n515, n516, n517, n518, n519, n520, n521, n522, n523, n524, n525,
         n526, n527, n528, n529, n530, n531, n532, n533, n534, n535, n536,
         n537, n538, n539, n540, n541, n542, n543, n544, n545, n546, n547,
         n548, n549, n550, n551, n552, n553, n554, n555, n556, n557, n558,
         n559, n560, n561, n562, n563, n564, n565, n566, n567, n568, n569,
         n570, n571, n572, n573, n574, n575, n576, n577, n578, n579, n580,
         n581, n582, n583, n584, n585, n586, n587, n588, n589, n590, n591,
         n592, n593, n594, n595, n596, n597, n598, n599, n600, n601, n602,
         n603, n604, n605, n606, n607, n608, n609, n610, n611, n612, n613,
         n614, n615, n616;
  wire   [7:0] I_demod;
  wire   [7:0] Q_demod;
  wire   [3:0] \u_demod/IF_Q ;
  wire   [3:0] \u_demod/IF_I ;
  wire   [3:0] \u_demod/Q_tmpin ;
  wire   [3:0] \u_demod/I_tmpin ;
  wire   [1:0] \u_demod/sin_signal/prev_counter ;
  wire   [71:0] \u_fir_i/x_delay_flat ;
  wire   [71:0] \u_fir_q/x_delay_flat ;
  assign I_filtered[7] = I_filtered[6];
  assign Q_filtered[7] = Q_filtered[6];

  DFC1 \u_demod/cos_signal/prev_counter_reg[0]  ( .D(n179), .C(CLK), .RN(n535), 
        .QN(n597) );
  DFC1 \u_demod/cos_signal/prev_counter_reg[1]  ( .D(n178), .C(CLK), .RN(n535), 
        .Q(\u_demod/cos_signal/prev_counter[1] ), .QN(n598) );
  DFC1 \u_demod/cos_signal/data_out_reg[0]  ( .D(n177), .C(CLK), .RN(n204), 
        .Q(\u_demod/IF_I [0]), .QN(n554) );
  DFC1 \u_demod/cos_signal/data_out_reg[3]  ( .D(n176), .C(CLK), .RN(n204), 
        .Q(\u_demod/IF_I [3]), .QN(n569) );
  DFC1 \u_demod/sin_signal/prev_counter_reg[1]  ( .D(n174), .C(CLK), .RN(n204), 
        .Q(\u_demod/sin_signal/prev_counter [1]), .QN(n599) );
  DFC1 \u_demod/sin_signal/data_out_reg[0]  ( .D(n173), .C(CLK), .RN(n204), 
        .Q(\u_demod/IF_Q [0]), .QN(n540) );
  DFC1 \u_demod/sin_signal/data_out_reg[3]  ( .D(n172), .C(CLK), .RN(n204), 
        .Q(\u_demod/IF_Q [3]), .QN(n574) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[0][2]  ( .D(n153), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [2]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[1][2]  ( .D(n152), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [10]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[2][2]  ( .D(n151), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [18]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[3][2]  ( .D(n150), .C(CLK), .RN(n535), .Q(
        \u_fir_i/x_delay_flat [26]), .QN(n205) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[0][3]  ( .D(n144), .C(CLK), .RN(RSTn), .Q(
        \u_fir_i/x_delay_flat [3]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[1][3]  ( .D(n143), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [11]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[2][3]  ( .D(n142), .C(CLK), .RN(n535), .Q(
        \u_fir_i/x_delay_flat [19]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[3][3]  ( .D(n141), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [27]), .QN(n209) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[0][4]  ( .D(n135), .C(CLK), .RN(RSTn), .Q(
        \u_fir_i/x_delay_flat [4]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[1][4]  ( .D(n134), .C(CLK), .RN(n535), .Q(
        \u_fir_i/x_delay_flat [12]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[2][4]  ( .D(n133), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [20]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[3][4]  ( .D(n132), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [28]), .QN(n210) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[0][5]  ( .D(n126), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [5]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[1][5]  ( .D(n125), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [13]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[2][5]  ( .D(n124), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [21]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[3][5]  ( .D(n123), .C(CLK), .RN(n535), .Q(
        \u_fir_i/x_delay_flat [29]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[0][6]  ( .D(n117), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [6]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[1][6]  ( .D(n116), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [14]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[2][6]  ( .D(n115), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [22]) );
  DFC1 \u_fir_i/u_delay/i_x_out_reg[3][6]  ( .D(n114), .C(CLK), .RN(n204), .Q(
        \u_fir_i/x_delay_flat [30]), .QN(n211) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[0][1]  ( .D(n90), .C(CLK), .RN(n535), .Q(
        \u_fir_q/x_delay_flat [1]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[1][1]  ( .D(n89), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [9]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[2][1]  ( .D(n88), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [17]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[3][1]  ( .D(n87), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [25]), .QN(n207) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[6][1]  ( .D(n84), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [49]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[7][1]  ( .D(n83), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [57]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[8][1]  ( .D(n82), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [65]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[0][2]  ( .D(n81), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [2]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[1][2]  ( .D(n80), .C(CLK), .RN(n535), .Q(
        \u_fir_q/x_delay_flat [10]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[2][2]  ( .D(n79), .C(CLK), .RN(n535), .Q(
        \u_fir_q/x_delay_flat [18]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[3][2]  ( .D(n78), .C(CLK), .RN(n535), .Q(
        \u_fir_q/x_delay_flat [26]), .QN(n208) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[6][2]  ( .D(n75), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [50]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[7][2]  ( .D(n74), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [58]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[8][2]  ( .D(n73), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [66]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[0][3]  ( .D(n72), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [3]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[1][3]  ( .D(n71), .C(CLK), .RN(n535), .Q(
        \u_fir_q/x_delay_flat [11]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[2][3]  ( .D(n70), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [19]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[3][3]  ( .D(n69), .C(CLK), .RN(n535), .Q(
        \u_fir_q/x_delay_flat [27]), .QN(n212) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[5][3]  ( .D(n67), .C(CLK), .RN(n535), .Q(
        \u_fir_q/x_delay_flat [43]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[6][3]  ( .D(n66), .C(CLK), .RN(n535), .Q(
        \u_fir_q/x_delay_flat [51]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[7][3]  ( .D(n65), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [59]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[8][3]  ( .D(n64), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [67]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[0][4]  ( .D(n63), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [4]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[1][4]  ( .D(n62), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [12]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[2][4]  ( .D(n61), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [20]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[3][4]  ( .D(n60), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [28]), .QN(n206) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[5][4]  ( .D(n58), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [44]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[6][4]  ( .D(n57), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [52]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[7][4]  ( .D(n56), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [60]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[8][4]  ( .D(n55), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [68]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[0][5]  ( .D(n54), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [5]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[1][5]  ( .D(n53), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [13]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[2][5]  ( .D(n52), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [21]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[3][5]  ( .D(n51), .C(CLK), .RN(n204), .Q(
        \u_fir_q/x_delay_flat [29]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[6][5]  ( .D(n48), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [53]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[7][5]  ( .D(n47), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [61]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[8][5]  ( .D(n46), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [69]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[0][6]  ( .D(n45), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [6]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[1][6]  ( .D(n44), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [14]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[2][6]  ( .D(n43), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [22]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[3][6]  ( .D(n42), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [30]), .QN(n213) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[6][6]  ( .D(n39), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [54]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[7][6]  ( .D(n38), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [62]) );
  DFC1 \u_fir_q/u_delay/i_x_out_reg[8][6]  ( .D(n37), .C(CLK), .RN(RSTn), .Q(
        \u_fir_q/x_delay_flat [70]) );
  DF1 \u_fir_i/u_core/y_out_reg[11]  ( .D(\u_fir_i/u_core/N32 ), .C(CLK), .Q(
        I_filtered[1]) );
  DF1 \u_fir_i/u_core/y_out_reg[12]  ( .D(\u_fir_i/u_core/N33 ), .C(CLK), .Q(
        I_filtered[2]) );
  DF1 \u_fir_i/u_core/y_out_reg[13]  ( .D(\u_fir_i/u_core/N34 ), .C(CLK), .Q(
        I_filtered[3]) );
  DF1 \u_fir_i/u_core/y_out_reg[14]  ( .D(\u_fir_i/u_core/N35 ), .C(CLK), .Q(
        I_filtered[4]) );
  DF1 \u_fir_i/u_core/y_out_reg[15]  ( .D(\u_fir_i/u_core/N36 ), .C(CLK), .Q(
        I_filtered[5]) );
  DF1 \u_fir_i/u_core/y_out_reg[16]  ( .D(\u_fir_i/u_core/N38 ), .C(CLK), .Q(
        I_filtered[6]) );
  DF1 \u_fir_q/u_core/y_out_reg[10]  ( .D(\u_fir_q/u_core/N31 ), .C(CLK), .Q(
        Q_filtered[0]) );
  DF1 \u_fir_q/u_core/y_out_reg[11]  ( .D(\u_fir_q/u_core/N32 ), .C(CLK), .Q(
        Q_filtered[1]) );
  DF1 \u_fir_q/u_core/y_out_reg[12]  ( .D(\u_fir_q/u_core/N33 ), .C(CLK), .Q(
        Q_filtered[2]) );
  DF1 \u_fir_q/u_core/y_out_reg[13]  ( .D(\u_fir_q/u_core/N34 ), .C(CLK), .Q(
        Q_filtered[3]) );
  DF1 \u_fir_q/u_core/y_out_reg[14]  ( .D(\u_fir_q/u_core/N35 ), .C(CLK), .Q(
        Q_filtered[4]) );
  DF1 \u_fir_q/u_core/y_out_reg[15]  ( .D(\u_fir_q/u_core/N36 ), .C(CLK), .Q(
        Q_filtered[5]) );
  DF1 \u_fir_q/u_core/y_out_reg[16]  ( .D(\u_fir_q/u_core/N38 ), .C(CLK), .Q(
        Q_filtered[6]) );
  ADD31 \intadd_31/U11  ( .A(\u_fir_i/x_delay_flat [57]), .B(
        \u_fir_i/x_delay_flat [9]), .CI(\intadd_31/CI ), .CO(\intadd_31/n10 ), 
        .S(\intadd_31/SUM[0] ) );
  ADD31 \intadd_31/U10  ( .A(\u_fir_i/x_delay_flat [58]), .B(
        \u_fir_i/x_delay_flat [10]), .CI(\intadd_31/n10 ), .CO(\intadd_31/n9 ), 
        .S(\intadd_31/SUM[1] ) );
  ADD31 \intadd_31/U9  ( .A(\u_fir_i/x_delay_flat [59]), .B(
        \u_fir_i/x_delay_flat [11]), .CI(\intadd_31/n9 ), .CO(\intadd_31/n8 ), 
        .S(\intadd_31/SUM[2] ) );
  ADD31 \intadd_31/U8  ( .A(\u_fir_i/x_delay_flat [60]), .B(
        \u_fir_i/x_delay_flat [12]), .CI(\intadd_31/n8 ), .CO(\intadd_31/n7 ), 
        .S(\intadd_31/SUM[3] ) );
  ADD31 \intadd_31/U7  ( .A(\u_fir_i/x_delay_flat [61]), .B(
        \u_fir_i/x_delay_flat [13]), .CI(\intadd_31/n7 ), .CO(\intadd_31/n6 ), 
        .S(\intadd_31/SUM[4] ) );
  ADD31 \intadd_31/U6  ( .A(\u_fir_i/x_delay_flat [62]), .B(
        \u_fir_i/x_delay_flat [14]), .CI(\intadd_31/n6 ), .CO(\intadd_31/n5 ), 
        .S(\intadd_31/SUM[5] ) );
  ADD31 \intadd_31/U5  ( .A(n567), .B(n552), .CI(\intadd_31/n5 ), .CO(
        \intadd_31/n4 ), .S(\intadd_31/SUM[6] ) );
  ADD31 \intadd_31/U4  ( .A(\intadd_31/A[7] ), .B(\intadd_31/B[7] ), .CI(
        \intadd_31/n4 ), .CO(\intadd_31/n3 ), .S(\intadd_31/SUM[7] ) );
  ADD31 \intadd_31/U3  ( .A(\intadd_31/A[8] ), .B(\intadd_31/B[8] ), .CI(
        \intadd_31/n3 ), .CO(\intadd_31/n2 ), .S(\intadd_31/SUM[8] ) );
  ADD31 \intadd_31/U2  ( .A(\intadd_31/A[9] ), .B(\intadd_31/B[9] ), .CI(
        \intadd_31/n2 ), .CO(\intadd_31/n1 ), .S(\intadd_31/SUM[9] ) );
  ADD31 \intadd_32/U11  ( .A(\intadd_32/A[0] ), .B(\intadd_32/B[0] ), .CI(
        \intadd_32/CI ), .CO(\intadd_32/n10 ), .S(\intadd_32/SUM[0] ) );
  ADD31 \intadd_32/U10  ( .A(\intadd_32/A[1] ), .B(\intadd_32/B[1] ), .CI(
        \intadd_32/n10 ), .CO(\intadd_32/n9 ), .S(\intadd_32/SUM[1] ) );
  ADD31 \intadd_32/U9  ( .A(\intadd_32/A[2] ), .B(\intadd_32/B[2] ), .CI(
        \intadd_32/n9 ), .CO(\intadd_32/n8 ), .S(\intadd_32/SUM[2] ) );
  ADD31 \intadd_32/U8  ( .A(\intadd_32/A[3] ), .B(\intadd_32/B[3] ), .CI(
        \intadd_32/n8 ), .CO(\intadd_32/n7 ), .S(\intadd_32/SUM[3] ) );
  ADD31 \intadd_32/U7  ( .A(\intadd_32/A[4] ), .B(\intadd_32/B[4] ), .CI(
        \intadd_32/n7 ), .CO(\intadd_32/n6 ), .S(\intadd_32/SUM[4] ) );
  ADD31 \intadd_32/U6  ( .A(\intadd_32/A[5] ), .B(\intadd_32/B[5] ), .CI(
        \intadd_32/n6 ), .CO(\intadd_32/n5 ), .S(\intadd_32/SUM[5] ) );
  ADD31 \intadd_32/U5  ( .A(\intadd_32/A[6] ), .B(\intadd_32/B[6] ), .CI(
        \intadd_32/n5 ), .CO(\intadd_32/n4 ), .S(\intadd_32/SUM[6] ) );
  ADD31 \intadd_32/U4  ( .A(\intadd_32/A[7] ), .B(\intadd_32/B[7] ), .CI(
        \intadd_32/n4 ), .CO(\intadd_32/n3 ), .S(\intadd_32/SUM[7] ) );
  ADD31 \intadd_32/U3  ( .A(\intadd_32/A[8] ), .B(\intadd_32/B[8] ), .CI(
        \intadd_32/n3 ), .CO(\intadd_32/n2 ), .S(\intadd_32/SUM[8] ) );
  ADD31 \intadd_32/U2  ( .A(\intadd_56/n1 ), .B(\intadd_32/B[9] ), .CI(
        \intadd_32/n2 ), .CO(\intadd_32/n1 ), .S(\intadd_32/SUM[9] ) );
  ADD31 \intadd_33/U11  ( .A(\u_fir_q/x_delay_flat [57]), .B(
        \u_fir_q/x_delay_flat [9]), .CI(\intadd_33/CI ), .CO(\intadd_33/n10 ), 
        .S(\intadd_33/SUM[0] ) );
  ADD31 \intadd_33/U10  ( .A(\u_fir_q/x_delay_flat [58]), .B(
        \u_fir_q/x_delay_flat [10]), .CI(\intadd_33/n10 ), .CO(\intadd_33/n9 ), 
        .S(\intadd_33/SUM[1] ) );
  ADD31 \intadd_33/U9  ( .A(\u_fir_q/x_delay_flat [59]), .B(
        \u_fir_q/x_delay_flat [11]), .CI(\intadd_33/n9 ), .CO(\intadd_33/n8 ), 
        .S(\intadd_33/SUM[2] ) );
  ADD31 \intadd_33/U8  ( .A(\u_fir_q/x_delay_flat [60]), .B(
        \u_fir_q/x_delay_flat [12]), .CI(\intadd_33/n8 ), .CO(\intadd_33/n7 ), 
        .S(\intadd_33/SUM[3] ) );
  ADD31 \intadd_33/U7  ( .A(\u_fir_q/x_delay_flat [61]), .B(
        \u_fir_q/x_delay_flat [13]), .CI(\intadd_33/n7 ), .CO(\intadd_33/n6 ), 
        .S(\intadd_33/SUM[4] ) );
  ADD31 \intadd_33/U6  ( .A(\u_fir_q/x_delay_flat [62]), .B(
        \u_fir_q/x_delay_flat [14]), .CI(\intadd_33/n6 ), .CO(\intadd_33/n5 ), 
        .S(\intadd_33/SUM[5] ) );
  ADD31 \intadd_33/U5  ( .A(n568), .B(n553), .CI(\intadd_33/n5 ), .CO(
        \intadd_33/n4 ), .S(\intadd_33/SUM[6] ) );
  ADD31 \intadd_33/U4  ( .A(\intadd_33/A[7] ), .B(\intadd_33/B[7] ), .CI(
        \intadd_33/n4 ), .CO(\intadd_33/n3 ), .S(\intadd_33/SUM[7] ) );
  ADD31 \intadd_33/U3  ( .A(\intadd_33/A[8] ), .B(\intadd_33/B[8] ), .CI(
        \intadd_33/n3 ), .CO(\intadd_33/n2 ), .S(\intadd_33/SUM[8] ) );
  ADD31 \intadd_33/U2  ( .A(\intadd_33/A[9] ), .B(\intadd_33/B[9] ), .CI(
        \intadd_33/n2 ), .CO(\intadd_33/n1 ), .S(\intadd_33/SUM[9] ) );
  ADD31 \intadd_34/U11  ( .A(\intadd_34/A[0] ), .B(\intadd_34/B[0] ), .CI(
        \intadd_34/CI ), .CO(\intadd_34/n10 ), .S(\intadd_34/SUM[0] ) );
  ADD31 \intadd_34/U10  ( .A(\intadd_34/A[1] ), .B(\intadd_34/B[1] ), .CI(
        \intadd_34/n10 ), .CO(\intadd_34/n9 ), .S(\intadd_34/SUM[1] ) );
  ADD31 \intadd_34/U9  ( .A(\intadd_34/A[2] ), .B(\intadd_34/B[2] ), .CI(
        \intadd_34/n9 ), .CO(\intadd_34/n8 ), .S(\intadd_34/SUM[2] ) );
  ADD31 \intadd_34/U8  ( .A(\intadd_34/A[3] ), .B(\intadd_34/B[3] ), .CI(
        \intadd_34/n8 ), .CO(\intadd_34/n7 ), .S(\intadd_34/SUM[3] ) );
  ADD31 \intadd_34/U7  ( .A(\intadd_34/A[4] ), .B(\intadd_34/B[4] ), .CI(
        \intadd_34/n7 ), .CO(\intadd_34/n6 ), .S(\intadd_34/SUM[4] ) );
  ADD31 \intadd_34/U6  ( .A(\intadd_34/A[5] ), .B(\intadd_34/B[5] ), .CI(
        \intadd_34/n6 ), .CO(\intadd_34/n5 ), .S(\intadd_34/SUM[5] ) );
  ADD31 \intadd_34/U5  ( .A(\intadd_34/A[6] ), .B(\intadd_34/B[6] ), .CI(
        \intadd_34/n5 ), .CO(\intadd_34/n4 ), .S(\intadd_34/SUM[6] ) );
  ADD31 \intadd_34/U4  ( .A(\intadd_34/A[7] ), .B(\intadd_34/B[7] ), .CI(
        \intadd_34/n4 ), .CO(\intadd_34/n3 ), .S(\intadd_34/SUM[7] ) );
  ADD31 \intadd_34/U3  ( .A(\intadd_34/A[8] ), .B(\intadd_34/B[8] ), .CI(
        \intadd_34/n3 ), .CO(\intadd_34/n2 ), .S(\intadd_34/SUM[8] ) );
  ADD31 \intadd_34/U2  ( .A(\intadd_55/n1 ), .B(\intadd_34/B[9] ), .CI(
        \intadd_34/n2 ), .CO(\intadd_34/n1 ), .S(\intadd_34/SUM[9] ) );
  ADD31 \intadd_35/U9  ( .A(\u_fir_i/x_delay_flat [37]), .B(\intadd_35/B[0] ), 
        .CI(\intadd_35/CI ), .CO(\intadd_35/n8 ), .S(\intadd_35/SUM[0] ) );
  ADD31 \intadd_35/U8  ( .A(\u_fir_i/x_delay_flat [38]), .B(\intadd_35/B[0] ), 
        .CI(\intadd_35/n8 ), .CO(\intadd_35/n7 ), .S(\intadd_35/SUM[1] ) );
  ADD31 \intadd_35/U7  ( .A(\intadd_35/A[2] ), .B(\intadd_35/B[2] ), .CI(
        \intadd_35/n7 ), .CO(\intadd_35/n6 ), .S(\intadd_35/SUM[2] ) );
  ADD31 \intadd_35/U6  ( .A(\intadd_35/A[3] ), .B(\intadd_32/A[2] ), .CI(
        \intadd_35/n6 ), .CO(\intadd_35/n5 ), .S(\intadd_35/SUM[3] ) );
  ADD31 \intadd_35/U5  ( .A(\intadd_35/A[4] ), .B(\intadd_35/B[4] ), .CI(
        \intadd_35/n5 ), .CO(\intadd_35/n4 ), .S(\intadd_35/SUM[4] ) );
  ADD31 \intadd_35/U4  ( .A(\intadd_35/A[5] ), .B(\intadd_35/B[5] ), .CI(
        \intadd_35/n4 ), .CO(\intadd_35/n3 ), .S(\intadd_35/SUM[5] ) );
  ADD31 \intadd_35/U3  ( .A(\intadd_48/n1 ), .B(\intadd_35/B[6] ), .CI(
        \intadd_35/n3 ), .CO(\intadd_35/n2 ), .S(\intadd_35/SUM[6] ) );
  ADD31 \intadd_35/U2  ( .A(\intadd_31/SUM[8] ), .B(\intadd_35/B[7] ), .CI(
        \intadd_35/n2 ), .CO(\intadd_35/n1 ), .S(\intadd_35/SUM[7] ) );
  ADD31 \intadd_36/U9  ( .A(\u_fir_q/x_delay_flat [37]), .B(\intadd_36/B[0] ), 
        .CI(\intadd_36/CI ), .CO(\intadd_36/n8 ), .S(\intadd_36/SUM[0] ) );
  ADD31 \intadd_36/U8  ( .A(\u_fir_q/x_delay_flat [38]), .B(\intadd_36/B[0] ), 
        .CI(\intadd_36/n8 ), .CO(\intadd_36/n7 ), .S(\intadd_36/SUM[1] ) );
  ADD31 \intadd_36/U7  ( .A(\intadd_36/A[2] ), .B(\intadd_36/B[2] ), .CI(
        \intadd_36/n7 ), .CO(\intadd_36/n6 ), .S(\intadd_36/SUM[2] ) );
  ADD31 \intadd_36/U6  ( .A(\intadd_36/A[3] ), .B(\intadd_34/A[2] ), .CI(
        \intadd_36/n6 ), .CO(\intadd_36/n5 ), .S(\intadd_36/SUM[3] ) );
  ADD31 \intadd_36/U5  ( .A(\intadd_36/A[4] ), .B(\intadd_36/B[4] ), .CI(
        \intadd_36/n5 ), .CO(\intadd_36/n4 ), .S(\intadd_36/SUM[4] ) );
  ADD31 \intadd_36/U4  ( .A(\intadd_36/A[5] ), .B(\intadd_36/B[5] ), .CI(
        \intadd_36/n4 ), .CO(\intadd_36/n3 ), .S(\intadd_36/SUM[5] ) );
  ADD31 \intadd_36/U3  ( .A(\intadd_47/n1 ), .B(\intadd_36/B[6] ), .CI(
        \intadd_36/n3 ), .CO(\intadd_36/n2 ), .S(\intadd_36/SUM[6] ) );
  ADD31 \intadd_36/U2  ( .A(\intadd_33/SUM[8] ), .B(\intadd_36/B[7] ), .CI(
        \intadd_36/n2 ), .CO(\intadd_36/n1 ), .S(\intadd_36/SUM[7] ) );
  ADD31 \intadd_37/U8  ( .A(\u_fir_i/x_delay_flat [34]), .B(\intadd_37/B[0] ), 
        .CI(\intadd_37/CI ), .CO(\intadd_37/n7 ), .S(\intadd_37/SUM[0] ) );
  ADD31 \intadd_37/U7  ( .A(\u_fir_i/x_delay_flat [35]), .B(\intadd_37/B[1] ), 
        .CI(\intadd_37/n7 ), .CO(\intadd_37/n6 ), .S(\intadd_37/SUM[1] ) );
  ADD31 \intadd_37/U6  ( .A(\u_fir_i/x_delay_flat [36]), .B(\intadd_32/A[3] ), 
        .CI(\intadd_37/n6 ), .CO(\intadd_37/n5 ), .S(\intadd_37/SUM[2] ) );
  ADD31 \intadd_37/U5  ( .A(\u_fir_i/x_delay_flat [37]), .B(\intadd_37/B[3] ), 
        .CI(\intadd_37/n5 ), .CO(\intadd_37/n4 ), .S(\intadd_37/SUM[3] ) );
  ADD31 \intadd_37/U4  ( .A(\intadd_32/A[5] ), .B(\intadd_37/B[4] ), .CI(
        \intadd_37/n4 ), .CO(\intadd_37/n3 ), .S(\intadd_37/SUM[4] ) );
  ADD31 \intadd_37/U3  ( .A(n572), .B(\intadd_37/B[5] ), .CI(\intadd_37/n3 ), 
        .CO(\intadd_37/n2 ), .S(\intadd_37/SUM[5] ) );
  ADD31 \intadd_37/U2  ( .A(\intadd_38/n1 ), .B(\intadd_37/B[6] ), .CI(
        \intadd_37/n2 ), .CO(\intadd_37/n1 ), .S(\intadd_37/SUM[6] ) );
  ADD31 \intadd_38/U8  ( .A(\u_fir_i/x_delay_flat [41]), .B(
        \u_fir_i/x_delay_flat [25]), .CI(\intadd_38/CI ), .CO(\intadd_38/n7 ), 
        .S(\intadd_38/SUM[0] ) );
  ADD31 \intadd_38/U7  ( .A(\u_fir_i/x_delay_flat [42]), .B(
        \u_fir_i/x_delay_flat [26]), .CI(\intadd_38/n7 ), .CO(\intadd_38/n6 ), 
        .S(\intadd_38/SUM[1] ) );
  ADD31 \intadd_38/U6  ( .A(\u_fir_i/x_delay_flat [43]), .B(
        \u_fir_i/x_delay_flat [27]), .CI(\intadd_38/n6 ), .CO(\intadd_38/n5 ), 
        .S(\intadd_37/B[0] ) );
  ADD31 \intadd_38/U5  ( .A(\u_fir_i/x_delay_flat [44]), .B(
        \u_fir_i/x_delay_flat [28]), .CI(\intadd_38/n5 ), .CO(\intadd_38/n4 ), 
        .S(\intadd_37/B[1] ) );
  ADD31 \intadd_38/U4  ( .A(\u_fir_i/x_delay_flat [45]), .B(
        \u_fir_i/x_delay_flat [29]), .CI(\intadd_38/n4 ), .CO(\intadd_38/n3 ), 
        .S(\intadd_32/A[3] ) );
  ADD31 \intadd_38/U3  ( .A(\u_fir_i/x_delay_flat [46]), .B(
        \u_fir_i/x_delay_flat [30]), .CI(\intadd_38/n3 ), .CO(\intadd_38/n2 ), 
        .S(\intadd_37/B[3] ) );
  ADD31 \intadd_38/U2  ( .A(n550), .B(n538), .CI(\intadd_38/n2 ), .CO(
        \intadd_38/n1 ), .S(\intadd_32/A[5] ) );
  ADD31 \intadd_39/U8  ( .A(\u_fir_i/x_delay_flat [65]), .B(
        \u_fir_i/x_delay_flat [1]), .CI(\intadd_39/CI ), .CO(\intadd_39/n7 ), 
        .S(\intadd_32/B[0] ) );
  ADD31 \intadd_39/U7  ( .A(\u_fir_i/x_delay_flat [66]), .B(
        \u_fir_i/x_delay_flat [2]), .CI(\intadd_39/n7 ), .CO(\intadd_39/n6 ), 
        .S(\intadd_39/SUM[1] ) );
  ADD31 \intadd_39/U6  ( .A(\u_fir_i/x_delay_flat [67]), .B(
        \u_fir_i/x_delay_flat [3]), .CI(\intadd_39/n6 ), .CO(\intadd_39/n5 ), 
        .S(\intadd_32/B[1] ) );
  ADD31 \intadd_39/U5  ( .A(\u_fir_i/x_delay_flat [68]), .B(
        \u_fir_i/x_delay_flat [4]), .CI(\intadd_39/n5 ), .CO(\intadd_39/n4 ), 
        .S(\intadd_32/A[2] ) );
  ADD31 \intadd_39/U4  ( .A(\u_fir_i/x_delay_flat [69]), .B(
        \u_fir_i/x_delay_flat [5]), .CI(\intadd_39/n4 ), .CO(\intadd_39/n3 ), 
        .S(\intadd_35/B[4] ) );
  ADD31 \intadd_39/U3  ( .A(\u_fir_i/x_delay_flat [70]), .B(
        \u_fir_i/x_delay_flat [6]), .CI(\intadd_39/n3 ), .CO(\intadd_39/n2 ), 
        .S(\intadd_35/B[5] ) );
  ADD31 \intadd_39/U2  ( .A(n548), .B(n589), .CI(\intadd_39/n2 ), .CO(
        \intadd_39/n1 ), .S(\intadd_31/B[7] ) );
  ADD31 \intadd_40/U8  ( .A(\u_fir_i/x_delay_flat [49]), .B(
        \u_fir_i/x_delay_flat [17]), .CI(\intadd_40/CI ), .CO(\intadd_40/n7 ), 
        .S(\intadd_32/A[0] ) );
  ADD31 \intadd_40/U7  ( .A(\u_fir_i/x_delay_flat [50]), .B(
        \u_fir_i/x_delay_flat [18]), .CI(\intadd_40/n7 ), .CO(\intadd_40/n6 ), 
        .S(\intadd_32/A[1] ) );
  ADD31 \intadd_40/U6  ( .A(\u_fir_i/x_delay_flat [51]), .B(
        \u_fir_i/x_delay_flat [19]), .CI(\intadd_40/n6 ), .CO(\intadd_40/n5 ), 
        .S(\intadd_40/SUM[2] ) );
  ADD31 \intadd_40/U5  ( .A(\u_fir_i/x_delay_flat [52]), .B(
        \u_fir_i/x_delay_flat [20]), .CI(\intadd_40/n5 ), .CO(\intadd_40/n4 ), 
        .S(\intadd_40/SUM[3] ) );
  ADD31 \intadd_40/U4  ( .A(\u_fir_i/x_delay_flat [53]), .B(
        \u_fir_i/x_delay_flat [21]), .CI(\intadd_40/n4 ), .CO(\intadd_40/n3 ), 
        .S(\intadd_40/SUM[4] ) );
  ADD31 \intadd_40/U3  ( .A(\u_fir_i/x_delay_flat [54]), .B(
        \u_fir_i/x_delay_flat [22]), .CI(\intadd_40/n3 ), .CO(\intadd_40/n2 ), 
        .S(\intadd_32/A[4] ) );
  ADD31 \intadd_40/U2  ( .A(n536), .B(n565), .CI(\intadd_40/n2 ), .CO(
        \intadd_40/n1 ), .S(\intadd_40/SUM[6] ) );
  ADD31 \intadd_41/U8  ( .A(\u_fir_q/x_delay_flat [34]), .B(\intadd_41/B[0] ), 
        .CI(\intadd_41/CI ), .CO(\intadd_41/n7 ), .S(\intadd_41/SUM[0] ) );
  ADD31 \intadd_41/U7  ( .A(\u_fir_q/x_delay_flat [35]), .B(\intadd_41/B[1] ), 
        .CI(\intadd_41/n7 ), .CO(\intadd_41/n6 ), .S(\intadd_41/SUM[1] ) );
  ADD31 \intadd_41/U6  ( .A(\u_fir_q/x_delay_flat [36]), .B(\intadd_34/A[3] ), 
        .CI(\intadd_41/n6 ), .CO(\intadd_41/n5 ), .S(\intadd_41/SUM[2] ) );
  ADD31 \intadd_41/U5  ( .A(\u_fir_q/x_delay_flat [37]), .B(\intadd_41/B[3] ), 
        .CI(\intadd_41/n5 ), .CO(\intadd_41/n4 ), .S(\intadd_41/SUM[3] ) );
  ADD31 \intadd_41/U4  ( .A(\intadd_34/A[5] ), .B(\intadd_41/B[4] ), .CI(
        \intadd_41/n4 ), .CO(\intadd_41/n3 ), .S(\intadd_41/SUM[4] ) );
  ADD31 \intadd_41/U3  ( .A(n573), .B(\intadd_41/B[5] ), .CI(\intadd_41/n3 ), 
        .CO(\intadd_41/n2 ), .S(\intadd_41/SUM[5] ) );
  ADD31 \intadd_41/U2  ( .A(\intadd_42/n1 ), .B(\intadd_41/B[6] ), .CI(
        \intadd_41/n2 ), .CO(\intadd_41/n1 ), .S(\intadd_41/SUM[6] ) );
  ADD31 \intadd_42/U8  ( .A(\u_fir_q/x_delay_flat [41]), .B(
        \u_fir_q/x_delay_flat [25]), .CI(\intadd_42/CI ), .CO(\intadd_42/n7 ), 
        .S(\intadd_42/SUM[0] ) );
  ADD31 \intadd_42/U7  ( .A(\u_fir_q/x_delay_flat [42]), .B(
        \u_fir_q/x_delay_flat [26]), .CI(\intadd_42/n7 ), .CO(\intadd_42/n6 ), 
        .S(\intadd_42/SUM[1] ) );
  ADD31 \intadd_42/U6  ( .A(\u_fir_q/x_delay_flat [43]), .B(
        \u_fir_q/x_delay_flat [27]), .CI(\intadd_42/n6 ), .CO(\intadd_42/n5 ), 
        .S(\intadd_41/B[0] ) );
  ADD31 \intadd_42/U5  ( .A(\u_fir_q/x_delay_flat [44]), .B(
        \u_fir_q/x_delay_flat [28]), .CI(\intadd_42/n5 ), .CO(\intadd_42/n4 ), 
        .S(\intadd_41/B[1] ) );
  ADD31 \intadd_42/U4  ( .A(\u_fir_q/x_delay_flat [45]), .B(
        \u_fir_q/x_delay_flat [29]), .CI(\intadd_42/n4 ), .CO(\intadd_42/n3 ), 
        .S(\intadd_34/A[3] ) );
  ADD31 \intadd_42/U3  ( .A(\u_fir_q/x_delay_flat [46]), .B(
        \u_fir_q/x_delay_flat [30]), .CI(\intadd_42/n3 ), .CO(\intadd_42/n2 ), 
        .S(\intadd_41/B[3] ) );
  ADD31 \intadd_42/U2  ( .A(n551), .B(n539), .CI(\intadd_42/n2 ), .CO(
        \intadd_42/n1 ), .S(\intadd_34/A[5] ) );
  ADD31 \intadd_43/U8  ( .A(\u_fir_q/x_delay_flat [65]), .B(
        \u_fir_q/x_delay_flat [1]), .CI(\intadd_43/CI ), .CO(\intadd_43/n7 ), 
        .S(\intadd_34/B[0] ) );
  ADD31 \intadd_43/U7  ( .A(\u_fir_q/x_delay_flat [66]), .B(
        \u_fir_q/x_delay_flat [2]), .CI(\intadd_43/n7 ), .CO(\intadd_43/n6 ), 
        .S(\intadd_43/SUM[1] ) );
  ADD31 \intadd_43/U6  ( .A(\u_fir_q/x_delay_flat [67]), .B(
        \u_fir_q/x_delay_flat [3]), .CI(\intadd_43/n6 ), .CO(\intadd_43/n5 ), 
        .S(\intadd_34/B[1] ) );
  ADD31 \intadd_43/U5  ( .A(\u_fir_q/x_delay_flat [68]), .B(
        \u_fir_q/x_delay_flat [4]), .CI(\intadd_43/n5 ), .CO(\intadd_43/n4 ), 
        .S(\intadd_34/A[2] ) );
  ADD31 \intadd_43/U4  ( .A(\u_fir_q/x_delay_flat [69]), .B(
        \u_fir_q/x_delay_flat [5]), .CI(\intadd_43/n4 ), .CO(\intadd_43/n3 ), 
        .S(\intadd_36/B[4] ) );
  ADD31 \intadd_43/U3  ( .A(\u_fir_q/x_delay_flat [70]), .B(
        \u_fir_q/x_delay_flat [6]), .CI(\intadd_43/n3 ), .CO(\intadd_43/n2 ), 
        .S(\intadd_36/B[5] ) );
  ADD31 \intadd_43/U2  ( .A(n549), .B(n590), .CI(\intadd_43/n2 ), .CO(
        \intadd_43/n1 ), .S(\intadd_33/B[7] ) );
  ADD31 \intadd_44/U8  ( .A(\u_fir_q/x_delay_flat [49]), .B(
        \u_fir_q/x_delay_flat [17]), .CI(\intadd_44/CI ), .CO(\intadd_44/n7 ), 
        .S(\intadd_34/A[0] ) );
  ADD31 \intadd_44/U7  ( .A(\u_fir_q/x_delay_flat [50]), .B(
        \u_fir_q/x_delay_flat [18]), .CI(\intadd_44/n7 ), .CO(\intadd_44/n6 ), 
        .S(\intadd_34/A[1] ) );
  ADD31 \intadd_44/U6  ( .A(\u_fir_q/x_delay_flat [51]), .B(
        \u_fir_q/x_delay_flat [19]), .CI(\intadd_44/n6 ), .CO(\intadd_44/n5 ), 
        .S(\intadd_44/SUM[2] ) );
  ADD31 \intadd_44/U5  ( .A(\u_fir_q/x_delay_flat [52]), .B(
        \u_fir_q/x_delay_flat [20]), .CI(\intadd_44/n5 ), .CO(\intadd_44/n4 ), 
        .S(\intadd_44/SUM[3] ) );
  ADD31 \intadd_44/U4  ( .A(\u_fir_q/x_delay_flat [53]), .B(
        \u_fir_q/x_delay_flat [21]), .CI(\intadd_44/n4 ), .CO(\intadd_44/n3 ), 
        .S(\intadd_44/SUM[4] ) );
  ADD31 \intadd_44/U3  ( .A(\u_fir_q/x_delay_flat [54]), .B(
        \u_fir_q/x_delay_flat [22]), .CI(\intadd_44/n3 ), .CO(\intadd_44/n2 ), 
        .S(\intadd_34/A[4] ) );
  ADD31 \intadd_44/U2  ( .A(n537), .B(n566), .CI(\intadd_44/n2 ), .CO(
        \intadd_44/n1 ), .S(\intadd_44/SUM[6] ) );
  ADD31 \intadd_45/U6  ( .A(\intadd_35/B[2] ), .B(\intadd_45/B[0] ), .CI(
        \intadd_45/CI ), .CO(\intadd_45/n5 ), .S(\intadd_45/SUM[0] ) );
  ADD31 \intadd_45/U5  ( .A(\intadd_45/A[1] ), .B(\intadd_45/B[1] ), .CI(
        \intadd_45/n5 ), .CO(\intadd_45/n4 ), .S(\intadd_45/SUM[1] ) );
  ADD31 \intadd_45/U4  ( .A(\intadd_45/A[2] ), .B(\intadd_45/B[2] ), .CI(
        \intadd_45/n4 ), .CO(\intadd_45/n3 ), .S(\intadd_45/SUM[2] ) );
  ADD31 \intadd_45/U3  ( .A(\intadd_45/A[3] ), .B(\intadd_45/B[3] ), .CI(
        \intadd_45/n3 ), .CO(\intadd_45/n2 ), .S(\intadd_45/SUM[3] ) );
  ADD31 \intadd_45/U2  ( .A(\intadd_45/A[4] ), .B(\intadd_45/B[4] ), .CI(
        \intadd_45/n2 ), .CO(\intadd_45/n1 ), .S(\intadd_45/SUM[4] ) );
  ADD31 \intadd_46/U6  ( .A(\intadd_36/B[2] ), .B(\intadd_46/B[0] ), .CI(
        \intadd_46/CI ), .CO(\intadd_46/n5 ), .S(\intadd_46/SUM[0] ) );
  ADD31 \intadd_46/U5  ( .A(\intadd_46/A[1] ), .B(\intadd_46/B[1] ), .CI(
        \intadd_46/n5 ), .CO(\intadd_46/n4 ), .S(\intadd_46/SUM[1] ) );
  ADD31 \intadd_46/U4  ( .A(\intadd_46/A[2] ), .B(\intadd_46/B[2] ), .CI(
        \intadd_46/n4 ), .CO(\intadd_46/n3 ), .S(\intadd_46/SUM[2] ) );
  ADD31 \intadd_46/U3  ( .A(\intadd_46/A[3] ), .B(\intadd_46/B[3] ), .CI(
        \intadd_46/n3 ), .CO(\intadd_46/n2 ), .S(\intadd_46/SUM[3] ) );
  ADD31 \intadd_46/U2  ( .A(\intadd_46/A[4] ), .B(\intadd_46/B[4] ), .CI(
        \intadd_46/n2 ), .CO(\intadd_46/n1 ), .S(\intadd_46/SUM[4] ) );
  ADD31 \intadd_47/U5  ( .A(\intadd_47/A[0] ), .B(\intadd_47/B[0] ), .CI(
        \intadd_34/B[1] ), .CO(\intadd_47/n4 ), .S(\intadd_47/SUM[0] ) );
  ADD31 \intadd_47/U4  ( .A(\intadd_47/A[1] ), .B(\intadd_33/SUM[3] ), .CI(
        \intadd_47/n4 ), .CO(\intadd_47/n3 ), .S(\intadd_47/SUM[1] ) );
  ADD31 \intadd_47/U3  ( .A(\intadd_33/SUM[5] ), .B(\intadd_47/B[2] ), .CI(
        \intadd_47/n3 ), .CO(\intadd_47/n2 ), .S(\intadd_47/SUM[2] ) );
  ADD31 \intadd_47/U2  ( .A(\intadd_33/SUM[6] ), .B(\intadd_47/B[3] ), .CI(
        \intadd_47/n2 ), .CO(\intadd_47/n1 ), .S(\intadd_47/SUM[3] ) );
  ADD31 \intadd_48/U5  ( .A(\intadd_48/A[0] ), .B(\intadd_48/B[0] ), .CI(
        \intadd_32/B[1] ), .CO(\intadd_48/n4 ), .S(\intadd_48/SUM[0] ) );
  ADD31 \intadd_48/U4  ( .A(\intadd_48/A[1] ), .B(\intadd_31/SUM[3] ), .CI(
        \intadd_48/n4 ), .CO(\intadd_48/n3 ), .S(\intadd_48/SUM[1] ) );
  ADD31 \intadd_48/U3  ( .A(\intadd_31/SUM[5] ), .B(\intadd_48/B[2] ), .CI(
        \intadd_48/n3 ), .CO(\intadd_48/n2 ), .S(\intadd_48/SUM[2] ) );
  ADD31 \intadd_48/U2  ( .A(\intadd_31/SUM[6] ), .B(\intadd_48/B[3] ), .CI(
        \intadd_48/n2 ), .CO(\intadd_48/n1 ), .S(\intadd_48/SUM[3] ) );
  ADD31 \intadd_50/U5  ( .A(\intadd_50/A[0] ), .B(\intadd_31/SUM[0] ), .CI(
        \intadd_50/CI ), .CO(\intadd_50/n4 ), .S(\intadd_50/SUM[0] ) );
  ADD31 \intadd_50/U4  ( .A(\intadd_50/A[1] ), .B(\intadd_31/SUM[1] ), .CI(
        \intadd_50/n4 ), .CO(\intadd_50/n3 ), .S(\intadd_50/SUM[1] ) );
  ADD31 \intadd_50/U3  ( .A(\intadd_50/A[2] ), .B(\intadd_50/B[2] ), .CI(
        \intadd_50/n3 ), .CO(\intadd_50/n2 ), .S(\intadd_50/SUM[2] ) );
  ADD31 \intadd_50/U2  ( .A(\intadd_50/A[3] ), .B(\intadd_48/SUM[0] ), .CI(
        \intadd_50/n2 ), .CO(\intadd_50/n1 ), .S(\intadd_50/SUM[3] ) );
  ADD31 \intadd_51/U5  ( .A(\intadd_32/B[0] ), .B(\intadd_51/B[0] ), .CI(
        \intadd_35/SUM[0] ), .CO(\intadd_51/n4 ), .S(\intadd_50/A[1] ) );
  ADD31 \intadd_51/U4  ( .A(\intadd_35/SUM[1] ), .B(\intadd_31/SUM[2] ), .CI(
        \intadd_51/n4 ), .CO(\intadd_51/n3 ), .S(\intadd_50/A[2] ) );
  ADD31 \intadd_51/U3  ( .A(\intadd_51/A[2] ), .B(\intadd_35/SUM[2] ), .CI(
        \intadd_51/n3 ), .CO(\intadd_51/n2 ), .S(\intadd_50/A[3] ) );
  ADD31 \intadd_51/U2  ( .A(\intadd_31/SUM[4] ), .B(\intadd_35/SUM[3] ), .CI(
        \intadd_51/n2 ), .CO(\intadd_51/n1 ), .S(\intadd_51/SUM[3] ) );
  ADD31 \intadd_53/U5  ( .A(\intadd_53/A[0] ), .B(\intadd_33/SUM[0] ), .CI(
        \intadd_53/CI ), .CO(\intadd_53/n4 ), .S(\intadd_53/SUM[0] ) );
  ADD31 \intadd_53/U4  ( .A(\intadd_53/A[1] ), .B(\intadd_33/SUM[1] ), .CI(
        \intadd_53/n4 ), .CO(\intadd_53/n3 ), .S(\intadd_53/SUM[1] ) );
  ADD31 \intadd_53/U3  ( .A(\intadd_53/A[2] ), .B(\intadd_53/B[2] ), .CI(
        \intadd_53/n3 ), .CO(\intadd_53/n2 ), .S(\intadd_53/SUM[2] ) );
  ADD31 \intadd_53/U2  ( .A(\intadd_53/A[3] ), .B(\intadd_47/SUM[0] ), .CI(
        \intadd_53/n2 ), .CO(\intadd_53/n1 ), .S(\intadd_53/SUM[3] ) );
  ADD31 \intadd_54/U5  ( .A(\intadd_34/B[0] ), .B(\intadd_54/B[0] ), .CI(
        \intadd_36/SUM[0] ), .CO(\intadd_54/n4 ), .S(\intadd_53/A[1] ) );
  ADD31 \intadd_54/U4  ( .A(\intadd_36/SUM[1] ), .B(\intadd_33/SUM[2] ), .CI(
        \intadd_54/n4 ), .CO(\intadd_54/n3 ), .S(\intadd_53/A[2] ) );
  ADD31 \intadd_54/U3  ( .A(\intadd_54/A[2] ), .B(\intadd_36/SUM[2] ), .CI(
        \intadd_54/n3 ), .CO(\intadd_54/n2 ), .S(\intadd_53/A[3] ) );
  ADD31 \intadd_54/U2  ( .A(\intadd_33/SUM[4] ), .B(\intadd_36/SUM[3] ), .CI(
        \intadd_54/n2 ), .CO(\intadd_54/n1 ), .S(\intadd_54/SUM[3] ) );
  ADD31 \intadd_55/U4  ( .A(\intadd_43/n1 ), .B(\intadd_55/B[0] ), .CI(
        \intadd_55/CI ), .CO(\intadd_55/n3 ), .S(\intadd_34/A[6] ) );
  ADD31 \intadd_55/U3  ( .A(\intadd_44/n1 ), .B(\intadd_55/B[1] ), .CI(
        \intadd_55/n3 ), .CO(\intadd_55/n2 ), .S(\intadd_34/B[7] ) );
  ADD31 \intadd_55/U2  ( .A(\intadd_55/A[2] ), .B(\intadd_55/B[2] ), .CI(
        \intadd_55/n2 ), .CO(\intadd_55/n1 ), .S(\intadd_34/A[8] ) );
  ADD31 \intadd_56/U4  ( .A(\intadd_39/n1 ), .B(\intadd_56/B[0] ), .CI(
        \intadd_56/CI ), .CO(\intadd_56/n3 ), .S(\intadd_32/A[6] ) );
  ADD31 \intadd_56/U3  ( .A(\intadd_40/n1 ), .B(\intadd_56/B[1] ), .CI(
        \intadd_56/n3 ), .CO(\intadd_56/n2 ), .S(\intadd_32/B[7] ) );
  ADD31 \intadd_56/U2  ( .A(\intadd_56/A[2] ), .B(\intadd_56/B[2] ), .CI(
        \intadd_56/n2 ), .CO(\intadd_56/n1 ), .S(\intadd_32/A[8] ) );
  ADD31 \intadd_57/U3  ( .A(\intadd_57/A[1] ), .B(\intadd_57/B[1] ), .CI(
        \intadd_57/n3 ), .CO(\intadd_57/n2 ), .S(\intadd_57/SUM[1] ) );
  ADD31 \intadd_57/U2  ( .A(\intadd_57/A[2] ), .B(\intadd_57/B[2] ), .CI(
        \intadd_57/n2 ), .CO(\intadd_57/n1 ), .S(\intadd_57/SUM[2] ) );
  ADD31 \intadd_58/U4  ( .A(\intadd_39/n1 ), .B(\intadd_58/B[0] ), .CI(
        \intadd_58/CI ), .CO(\intadd_58/n3 ), .S(\intadd_58/SUM[0] ) );
  ADD31 \intadd_58/U3  ( .A(\intadd_58/A[1] ), .B(\intadd_58/B[1] ), .CI(
        \intadd_58/n3 ), .CO(\intadd_58/n2 ), .S(\intadd_56/B[2] ) );
  ADD31 \intadd_58/U2  ( .A(\intadd_58/A[2] ), .B(\intadd_58/B[2] ), .CI(
        \intadd_58/n2 ), .CO(\intadd_58/n1 ), .S(\intadd_32/B[9] ) );
  ADD31 \intadd_59/U4  ( .A(\intadd_59/A[0] ), .B(\intadd_59/B[0] ), .CI(
        \intadd_59/CI ), .CO(\intadd_59/n3 ), .S(\intadd_45/A[1] ) );
  ADD31 \intadd_59/U3  ( .A(\intadd_59/A[1] ), .B(\intadd_59/B[1] ), .CI(
        \intadd_59/n3 ), .CO(\intadd_59/n2 ), .S(\intadd_45/A[2] ) );
  ADD31 \intadd_59/U2  ( .A(\intadd_59/A[2] ), .B(\intadd_59/B[2] ), .CI(
        \intadd_59/n2 ), .CO(\intadd_59/n1 ), .S(\intadd_45/A[3] ) );
  ADD31 \intadd_60/U4  ( .A(\intadd_43/n1 ), .B(\intadd_60/B[0] ), .CI(
        \intadd_60/CI ), .CO(\intadd_60/n3 ), .S(\intadd_60/SUM[0] ) );
  ADD31 \intadd_60/U3  ( .A(\intadd_60/A[1] ), .B(\intadd_60/B[1] ), .CI(
        \intadd_60/n3 ), .CO(\intadd_60/n2 ), .S(\intadd_55/B[2] ) );
  ADD31 \intadd_60/U2  ( .A(\intadd_60/A[2] ), .B(\intadd_60/B[2] ), .CI(
        \intadd_60/n2 ), .CO(\intadd_60/n1 ), .S(\intadd_34/B[9] ) );
  ADD31 \intadd_61/U4  ( .A(\intadd_61/A[0] ), .B(\intadd_61/B[0] ), .CI(
        \intadd_61/CI ), .CO(\intadd_61/n3 ), .S(\intadd_46/A[1] ) );
  ADD31 \intadd_61/U3  ( .A(\intadd_61/A[1] ), .B(\intadd_61/B[1] ), .CI(
        \intadd_61/n3 ), .CO(\intadd_61/n2 ), .S(\intadd_46/A[2] ) );
  ADD31 \intadd_61/U2  ( .A(\intadd_61/A[2] ), .B(\intadd_61/B[2] ), .CI(
        \intadd_61/n2 ), .CO(\intadd_61/n1 ), .S(\intadd_46/A[3] ) );
  DFEP1 \u_demod/Q_tmpin_reg[3]  ( .D(Q_in[3]), .E(adc_eoc), .C(CLK), .SN(n535), .Q(n571), .QN(\u_demod/Q_tmpin [3]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[3][1]  ( .D(n556), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n576), .QN(\u_fir_i/x_delay_flat [25]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[2][1]  ( .D(n575), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n556), .QN(\u_fir_i/x_delay_flat [17]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[1][1]  ( .D(n555), .E(n532), .C(CLK), 
        .SN(n204), .Q(n575), .QN(\u_fir_i/x_delay_flat [9]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[0][1]  ( .D(n577), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n555), .QN(\u_fir_i/x_delay_flat [1]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[0][7]  ( .D(n529), .E(n533), .C(CLK), 
        .SN(RSTn), .Q(n549) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[0][7]  ( .D(n528), .E(n533), .C(CLK), 
        .SN(n535), .Q(n548) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[4][1]  ( .D(n576), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n547), .QN(\u_fir_i/x_delay_flat [33]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[4][0]  ( .D(n562), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n588), .QN(\u_fir_q/x_delay_flat [32]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[3][0]  ( .D(n579), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n562), .QN(\u_fir_q/x_delay_flat [24]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[4][0]  ( .D(n561), .E(n533), .C(CLK), 
        .SN(RSTn), .Q(n587), .QN(\u_fir_i/x_delay_flat [32]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[3][0]  ( .D(n578), .E(n533), .C(CLK), 
        .SN(n535), .Q(n561), .QN(\u_fir_i/x_delay_flat [24]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[4][4]  ( .D(n206), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n584), .QN(\u_fir_q/x_delay_flat [36]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[4][3]  ( .D(n212), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n583), .QN(\u_fir_q/x_delay_flat [35]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[4][4]  ( .D(n210), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n563), .QN(\u_fir_i/x_delay_flat [36]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[4][3]  ( .D(n209), .E(adc_eoc), .C(CLK), 
        .SN(n535), .Q(n582), .QN(\u_fir_i/x_delay_flat [35]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[6][0]  ( .D(n545), .E(n532), .C(CLK), 
        .SN(n204), .Q(n558), .QN(\u_fir_q/x_delay_flat [48]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[5][0]  ( .D(n588), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n545), .QN(\u_fir_q/x_delay_flat [40]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[6][0]  ( .D(n546), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n557), .QN(\u_fir_i/x_delay_flat [48]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[5][0]  ( .D(n587), .E(adc_eoc), .C(CLK), 
        .SN(n535), .Q(n546), .QN(\u_fir_i/x_delay_flat [40]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[4][7]  ( .D(n551), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n573), .QN(\u_fir_q/x_delay_flat [39]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[4][7]  ( .D(n550), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n572), .QN(\u_fir_i/x_delay_flat [39]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[2][0]  ( .D(n560), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n579), .QN(\u_fir_q/x_delay_flat [16]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[2][0]  ( .D(n559), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n578), .QN(\u_fir_i/x_delay_flat [16]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[1][0]  ( .D(n541), .E(n533), .C(CLK), 
        .SN(n535), .Q(n560), .QN(\u_fir_q/x_delay_flat [8]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[1][0]  ( .D(n542), .E(n533), .C(CLK), 
        .SN(n204), .Q(n559), .QN(\u_fir_i/x_delay_flat [8]) );
  DFEP1 \u_demod/Q_tmpin_reg[2]  ( .D(n527), .E(n534), .C(CLK), .SN(n535), .Q(
        n593), .QN(\u_demod/Q_tmpin [2]) );
  DFEP1 \u_demod/Q_tmpin_reg[0]  ( .D(n526), .E(n534), .C(CLK), .SN(n204), .Q(
        n570), .QN(\u_demod/Q_tmpin [0]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[4][2]  ( .D(n208), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n564), .QN(\u_fir_q/x_delay_flat [34]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[4][2]  ( .D(n205), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n585), .QN(\u_fir_i/x_delay_flat [34]) );
  DFEP1 \u_demod/I_tmpin_reg[3]  ( .D(I_in[3]), .E(n534), .C(CLK), .SN(n204), 
        .Q(n592), .QN(\u_demod/I_tmpin [3]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[7][0]  ( .D(n558), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n543), .QN(\u_fir_q/x_delay_flat [56]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[7][0]  ( .D(n557), .E(adc_eoc), .C(CLK), 
        .SN(n535), .Q(n544), .QN(\u_fir_i/x_delay_flat [56]) );
  DFEP1 \u_demod/I_tmpin_reg[2]  ( .D(n525), .E(n534), .C(CLK), .SN(n204), .Q(
        n594), .QN(\u_demod/I_tmpin [2]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[4][6]  ( .D(n213), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n596), .QN(\u_fir_q/x_delay_flat [38]) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[4][6]  ( .D(n211), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n595), .QN(\u_fir_i/x_delay_flat [38]) );
  DFEP1 \u_demod/I_tmpin_reg[0]  ( .D(n524), .E(n534), .C(CLK), .SN(RSTn), .Q(
        n591), .QN(\u_demod/I_tmpin [0]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[4][1]  ( .D(n207), .E(adc_eoc), .C(CLK), 
        .SN(n535), .Q(n586), .QN(\u_fir_q/x_delay_flat [33]) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[8][7]  ( .D(n553), .E(n532), .C(CLK), 
        .SN(n204), .Q(n590) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[8][7]  ( .D(n552), .E(n533), .C(CLK), 
        .SN(n204), .Q(n589) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[7][7]  ( .D(n566), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n553) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[6][7]  ( .D(n539), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n566) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[7][7]  ( .D(n565), .E(n532), .C(CLK), 
        .SN(n204), .Q(n552) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[6][7]  ( .D(n538), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n565) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[0][0]  ( .D(n601), .E(n532), .C(CLK), 
        .SN(n535), .Q(n541) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[0][0]  ( .D(n600), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n542) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[5][7]  ( .D(n573), .E(n533), .C(CLK), 
        .SN(RSTn), .Q(n539) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[5][7]  ( .D(n572), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n538) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[3][7]  ( .D(n537), .E(n532), .C(CLK), 
        .SN(RSTn), .Q(n551) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[2][7]  ( .D(n568), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n537) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[1][7]  ( .D(n549), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n568) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[3][7]  ( .D(n536), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n550) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[2][7]  ( .D(n567), .E(n533), .C(CLK), 
        .SN(RSTn), .Q(n536) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[1][7]  ( .D(n548), .E(adc_eoc), .C(CLK), 
        .SN(n204), .Q(n567) );
  DFEP1 \u_fir_q/u_delay/i_x_out_reg[8][0]  ( .D(n543), .E(n532), .C(CLK), 
        .SN(n535), .Q(n581) );
  DFEP1 \u_fir_i/u_delay/i_x_out_reg[8][0]  ( .D(n544), .E(adc_eoc), .C(CLK), 
        .SN(RSTn), .Q(n580) );
  DFEP1 \u_demod/I_out_reg[0]  ( .D(n609), .E(n534), .C(CLK), .SN(n535), .Q(
        n600) );
  DFEP1 \u_demod/Q_out_reg[0]  ( .D(n603), .E(n534), .C(CLK), .SN(n204), .Q(
        n601) );
  DFEP1 \u_demod/I_out_reg[1]  ( .D(n610), .E(n534), .C(CLK), .SN(n535), .Q(
        n577) );
  JKC1 \u_demod/sin_signal/prev_counter_reg[0]  ( .J(adc_eoc), .K(adc_eoc), 
        .C(CLK), .RN(n204), .Q(\u_demod/sin_signal/prev_counter [0]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[8][6]  ( .D(\u_fir_i/x_delay_flat [62]), 
        .E(n531), .C(CLK), .RN(RSTn), .Q(\u_fir_i/x_delay_flat [70]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[8][5]  ( .D(\u_fir_i/x_delay_flat [61]), 
        .E(n531), .C(CLK), .RN(n204), .Q(\u_fir_i/x_delay_flat [69]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[8][4]  ( .D(\u_fir_i/x_delay_flat [60]), 
        .E(n531), .C(CLK), .RN(RSTn), .Q(\u_fir_i/x_delay_flat [68]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[8][3]  ( .D(\u_fir_i/x_delay_flat [59]), 
        .E(n531), .C(CLK), .RN(n535), .Q(\u_fir_i/x_delay_flat [67]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[8][2]  ( .D(\u_fir_i/x_delay_flat [58]), 
        .E(n531), .C(CLK), .RN(RSTn), .Q(\u_fir_i/x_delay_flat [66]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[8][1]  ( .D(\u_fir_i/x_delay_flat [57]), 
        .E(n532), .C(CLK), .RN(n204), .Q(\u_fir_i/x_delay_flat [65]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[7][6]  ( .D(\u_fir_i/x_delay_flat [54]), 
        .E(adc_eoc), .C(CLK), .RN(n535), .Q(\u_fir_i/x_delay_flat [62]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[7][5]  ( .D(\u_fir_i/x_delay_flat [53]), 
        .E(n531), .C(CLK), .RN(n204), .Q(\u_fir_i/x_delay_flat [61]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[7][4]  ( .D(\u_fir_i/x_delay_flat [52]), 
        .E(adc_eoc), .C(CLK), .RN(RSTn), .Q(\u_fir_i/x_delay_flat [60]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[7][3]  ( .D(\u_fir_i/x_delay_flat [51]), 
        .E(adc_eoc), .C(CLK), .RN(n535), .Q(\u_fir_i/x_delay_flat [59]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[7][2]  ( .D(\u_fir_i/x_delay_flat [50]), 
        .E(adc_eoc), .C(CLK), .RN(n204), .Q(\u_fir_i/x_delay_flat [58]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[7][1]  ( .D(\u_fir_i/x_delay_flat [49]), 
        .E(adc_eoc), .C(CLK), .RN(RSTn), .Q(\u_fir_i/x_delay_flat [57]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[6][6]  ( .D(\u_fir_i/x_delay_flat [46]), 
        .E(adc_eoc), .C(CLK), .RN(n204), .Q(\u_fir_i/x_delay_flat [54]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[6][5]  ( .D(\u_fir_i/x_delay_flat [45]), 
        .E(n531), .C(CLK), .RN(n204), .Q(\u_fir_i/x_delay_flat [53]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[6][4]  ( .D(\u_fir_i/x_delay_flat [44]), 
        .E(adc_eoc), .C(CLK), .RN(RSTn), .Q(\u_fir_i/x_delay_flat [52]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[6][3]  ( .D(\u_fir_i/x_delay_flat [43]), 
        .E(adc_eoc), .C(CLK), .RN(n535), .Q(\u_fir_i/x_delay_flat [51]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[6][2]  ( .D(\u_fir_i/x_delay_flat [42]), 
        .E(adc_eoc), .C(CLK), .RN(n204), .Q(\u_fir_i/x_delay_flat [50]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[6][1]  ( .D(\u_fir_i/x_delay_flat [41]), 
        .E(adc_eoc), .C(CLK), .RN(n204), .Q(\u_fir_i/x_delay_flat [49]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[5][4]  ( .D(\u_fir_i/x_delay_flat [36]), 
        .E(adc_eoc), .C(CLK), .RN(RSTn), .Q(\u_fir_i/x_delay_flat [44]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[5][3]  ( .D(\u_fir_i/x_delay_flat [35]), 
        .E(adc_eoc), .C(CLK), .RN(n535), .Q(\u_fir_i/x_delay_flat [43]) );
  DFEC1 \u_fir_q/u_delay/i_x_out_reg[5][2]  ( .D(\u_fir_q/x_delay_flat [34]), 
        .E(adc_eoc), .C(CLK), .RN(RSTn), .Q(\u_fir_q/x_delay_flat [42]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[5][2]  ( .D(\u_fir_i/x_delay_flat [34]), 
        .E(adc_eoc), .C(CLK), .RN(n535), .Q(\u_fir_i/x_delay_flat [42]) );
  DFEC1 \u_demod/Q_tmpin_reg[1]  ( .D(Q_in[1]), .E(n530), .C(CLK), .RN(n204), 
        .Q(\u_demod/Q_tmpin [1]) );
  DFEC1 \u_fir_q/u_delay/i_x_out_reg[4][5]  ( .D(\u_fir_q/x_delay_flat [29]), 
        .E(n530), .C(CLK), .RN(n204), .Q(\u_fir_q/x_delay_flat [37]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[4][5]  ( .D(\u_fir_i/x_delay_flat [29]), 
        .E(n530), .C(CLK), .RN(n204), .Q(\u_fir_i/x_delay_flat [37]) );
  DFEC1 \u_fir_q/u_delay/i_x_out_reg[5][5]  ( .D(\u_fir_q/x_delay_flat [37]), 
        .E(n530), .C(CLK), .RN(n204), .Q(\u_fir_q/x_delay_flat [45]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[5][5]  ( .D(\u_fir_i/x_delay_flat [37]), 
        .E(n530), .C(CLK), .RN(RSTn), .Q(\u_fir_i/x_delay_flat [45]) );
  DFEC1 \u_fir_q/u_delay/i_x_out_reg[5][6]  ( .D(\u_fir_q/x_delay_flat [38]), 
        .E(adc_eoc), .C(CLK), .RN(n204), .Q(\u_fir_q/x_delay_flat [46]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[5][6]  ( .D(\u_fir_i/x_delay_flat [38]), 
        .E(adc_eoc), .C(CLK), .RN(n204), .Q(\u_fir_i/x_delay_flat [46]) );
  DFEC1 \u_fir_i/u_delay/i_x_out_reg[5][1]  ( .D(\u_fir_i/x_delay_flat [33]), 
        .E(adc_eoc), .C(CLK), .RN(RSTn), .Q(\u_fir_i/x_delay_flat [41]) );
  DFEC1 \u_demod/I_tmpin_reg[1]  ( .D(I_in[1]), .E(n534), .C(CLK), .RN(n535), 
        .Q(\u_demod/I_tmpin [1]) );
  DFEC1 \u_fir_q/u_delay/i_x_out_reg[5][1]  ( .D(\u_fir_q/x_delay_flat [33]), 
        .E(adc_eoc), .C(CLK), .RN(n204), .Q(\u_fir_q/x_delay_flat [41]) );
  DFEC1 \u_demod/Q_out_reg[1]  ( .D(n604), .E(n530), .C(CLK), .RN(n204), .Q(
        Q_demod[1]) );
  DFEC1 \u_demod/Q_out_reg[2]  ( .D(\intadd_57/SUM[1] ), .E(n530), .C(CLK), 
        .RN(n535), .Q(Q_demod[2]) );
  DFEC1 \u_demod/I_out_reg[2]  ( .D(n611), .E(n530), .C(CLK), .RN(n204), .Q(
        I_demod[2]) );
  DFEC1 \u_demod/Q_out_reg[3]  ( .D(\intadd_57/SUM[2] ), .E(n530), .C(CLK), 
        .RN(n204), .Q(Q_demod[3]) );
  DFEC1 \u_demod/I_out_reg[3]  ( .D(n612), .E(adc_eoc), .C(CLK), .RN(n204), 
        .Q(I_demod[3]) );
  DFEC1 \u_demod/Q_out_reg[5]  ( .D(n606), .E(adc_eoc), .C(CLK), .RN(RSTn), 
        .Q(Q_demod[5]) );
  DFEC1 \u_demod/I_out_reg[4]  ( .D(n613), .E(adc_eoc), .C(CLK), .RN(n204), 
        .Q(I_demod[4]) );
  DFEC1 \u_demod/Q_out_reg[4]  ( .D(n605), .E(adc_eoc), .C(CLK), .RN(n204), 
        .Q(Q_demod[4]) );
  DFEC1 \u_demod/I_out_reg[5]  ( .D(n614), .E(adc_eoc), .C(CLK), .RN(n535), 
        .Q(I_demod[5]) );
  DFEC1 \u_demod/Q_out_reg[6]  ( .D(n607), .E(adc_eoc), .C(CLK), .RN(n535), 
        .Q(Q_demod[6]) );
  DFEC1 \u_demod/Q_out_reg[7]  ( .D(n608), .E(adc_eoc), .C(CLK), .RN(n535), 
        .QN(n529) );
  DFEC1 \u_demod/I_out_reg[6]  ( .D(n615), .E(adc_eoc), .C(CLK), .RN(n535), 
        .Q(I_demod[6]) );
  DFEC1 \u_demod/I_out_reg[7]  ( .D(n616), .E(n533), .C(CLK), .RN(n535), .QN(
        n528) );
  DFP1 \u_fir_i/u_core/y_out_reg[10]  ( .D(n602), .C(CLK), .SN(n523), .QN(
        I_filtered[0]) );
  INV6 U218 ( .A(n214), .Q(n204) );
  NOR20 U219 ( .A(n580), .B(n542), .Q(\intadd_39/CI ) );
  NOR20 U220 ( .A(n581), .B(n541), .Q(\intadd_43/CI ) );
  INV0 U221 ( .A(n326), .Q(n308) );
  NOR20 U222 ( .A(n308), .B(n584), .Q(\intadd_54/B[0] ) );
  NOR20 U223 ( .A(n557), .B(n578), .Q(\intadd_40/CI ) );
  NOR20 U224 ( .A(n546), .B(n561), .Q(\intadd_38/CI ) );
  INV0 U225 ( .A(n404), .Q(n386) );
  NOR20 U226 ( .A(n386), .B(n563), .Q(\intadd_51/B[0] ) );
  NOR20 U227 ( .A(n545), .B(n562), .Q(\intadd_42/CI ) );
  INV0 U228 ( .A(\intadd_34/A[1] ), .Q(\intadd_36/B[2] ) );
  INV0 U229 ( .A(\intadd_42/SUM[1] ), .Q(\intadd_36/A[2] ) );
  INV0 U230 ( .A(\intadd_38/SUM[1] ), .Q(\intadd_35/A[2] ) );
  INV0 U231 ( .A(\intadd_39/SUM[1] ), .Q(\intadd_59/A[0] ) );
  INV0 U232 ( .A(n275), .Q(\intadd_48/B[0] ) );
  IMUX20 U233 ( .A(\intadd_59/A[1] ), .B(\intadd_40/SUM[2] ), .S(
        \intadd_37/B[0] ), .Q(n397) );
  NOR20 U234 ( .A(n586), .B(\intadd_36/A[2] ), .Q(\intadd_41/CI ) );
  INV0 U235 ( .A(\intadd_43/SUM[1] ), .Q(\intadd_61/A[0] ) );
  IMUX20 U236 ( .A(\intadd_61/A[1] ), .B(\intadd_44/SUM[2] ), .S(
        \intadd_41/B[0] ), .Q(n319) );
  IMUX20 U237 ( .A(\intadd_59/A[0] ), .B(\intadd_39/SUM[1] ), .S(n402), .Q(
        \intadd_50/B[2] ) );
  IMUX20 U238 ( .A(n276), .B(n277), .S(n397), .Q(\intadd_48/A[1] ) );
  INV0 U239 ( .A(\intadd_35/B[5] ), .Q(n422) );
  INV0 U240 ( .A(\intadd_31/SUM[3] ), .Q(\intadd_51/A[2] ) );
  IMUX20 U241 ( .A(\intadd_59/A[2] ), .B(\intadd_40/SUM[3] ), .S(
        \intadd_37/B[1] ), .Q(n414) );
  NOR20 U242 ( .A(\intadd_35/B[4] ), .B(\intadd_40/SUM[4] ), .Q(n393) );
  INV0 U243 ( .A(\intadd_41/SUM[0] ), .Q(\intadd_36/A[4] ) );
  INV0 U244 ( .A(\intadd_34/A[3] ), .Q(n367) );
  OAI210 U245 ( .A(n313), .B(n293), .C(n312), .Q(n364) );
  INV0 U246 ( .A(\intadd_41/B[3] ), .Q(n370) );
  IMUX20 U247 ( .A(n292), .B(n293), .S(n319), .Q(\intadd_47/A[1] ) );
  INV0 U248 ( .A(\intadd_36/B[5] ), .Q(n344) );
  INV0 U249 ( .A(\intadd_34/A[4] ), .Q(n368) );
  INV0 U250 ( .A(\intadd_37/SUM[0] ), .Q(\intadd_35/A[4] ) );
  INV0 U251 ( .A(\intadd_37/B[3] ), .Q(n448) );
  INV0 U252 ( .A(\intadd_32/A[4] ), .Q(n446) );
  INV0 U253 ( .A(\intadd_40/SUM[4] ), .Q(n443) );
  OAI210 U254 ( .A(n272), .B(n430), .C(n271), .Q(n273) );
  INV0 U255 ( .A(\intadd_51/SUM[3] ), .Q(n269) );
  NOR20 U256 ( .A(\intadd_31/B[7] ), .B(\intadd_40/SUM[6] ), .Q(n272) );
  IMUX20 U257 ( .A(n414), .B(n278), .S(n442), .Q(\intadd_48/B[2] ) );
  INV0 U258 ( .A(\intadd_48/SUM[1] ), .Q(\intadd_56/CI ) );
  INV0 U259 ( .A(\intadd_50/n1 ), .Q(\intadd_56/B[0] ) );
  INV0 U260 ( .A(n427), .Q(n428) );
  IMUX20 U261 ( .A(n451), .B(\intadd_40/SUM[6] ), .S(\intadd_31/B[7] ), .Q(
        n431) );
  INV0 U262 ( .A(n270), .Q(n421) );
  INV0 U263 ( .A(\intadd_44/SUM[6] ), .Q(n373) );
  INV0 U264 ( .A(\intadd_54/n1 ), .Q(\intadd_60/B[0] ) );
  INV0 U265 ( .A(\intadd_41/SUM[1] ), .Q(\intadd_36/A[5] ) );
  IMUX20 U266 ( .A(n336), .B(n294), .S(n364), .Q(\intadd_47/B[2] ) );
  NOR20 U267 ( .A(\intadd_33/B[7] ), .B(\intadd_44/SUM[6] ), .Q(n288) );
  INV0 U268 ( .A(\intadd_47/SUM[1] ), .Q(\intadd_55/CI ) );
  INV0 U269 ( .A(\intadd_53/n1 ), .Q(\intadd_55/B[0] ) );
  IMUX20 U270 ( .A(n373), .B(\intadd_44/SUM[6] ), .S(\intadd_33/B[7] ), .Q(
        n353) );
  INV0 U271 ( .A(\intadd_53/SUM[3] ), .Q(\intadd_34/B[5] ) );
  INV0 U272 ( .A(n286), .Q(n343) );
  INV0 U273 ( .A(\intadd_60/SUM[0] ), .Q(n297) );
  INV0 U274 ( .A(n289), .Q(n295) );
  INV0 U275 ( .A(\intadd_40/SUM[6] ), .Q(n451) );
  INV0 U276 ( .A(\intadd_35/SUM[4] ), .Q(\intadd_58/CI ) );
  INV0 U277 ( .A(\intadd_51/n1 ), .Q(\intadd_58/B[0] ) );
  INV0 U278 ( .A(\intadd_37/SUM[1] ), .Q(\intadd_35/A[5] ) );
  INV0 U279 ( .A(\intadd_58/SUM[0] ), .Q(n281) );
  INV0 U280 ( .A(n273), .Q(n279) );
  INV0 U281 ( .A(\intadd_48/SUM[2] ), .Q(\intadd_56/B[1] ) );
  IMUX20 U282 ( .A(n432), .B(n431), .S(n430), .Q(n436) );
  INV0 U283 ( .A(n433), .Q(n434) );
  INV0 U284 ( .A(\intadd_42/n1 ), .Q(n379) );
  IMUX20 U285 ( .A(\intadd_42/n1 ), .B(n379), .S(\intadd_44/n1 ), .Q(n348) );
  INV0 U286 ( .A(n299), .Q(\intadd_41/B[4] ) );
  INV0 U287 ( .A(\intadd_34/A[5] ), .Q(n374) );
  INV0 U288 ( .A(\intadd_47/SUM[3] ), .Q(\intadd_60/A[1] ) );
  INV0 U289 ( .A(n290), .Q(\intadd_34/A[7] ) );
  INV0 U290 ( .A(\intadd_47/SUM[2] ), .Q(\intadd_55/B[1] ) );
  OAI210 U291 ( .A(n345), .B(n288), .C(n287), .Q(\intadd_34/B[6] ) );
  IMUX20 U292 ( .A(n354), .B(n353), .S(n352), .Q(n358) );
  INV0 U293 ( .A(n355), .Q(n356) );
  INV0 U294 ( .A(n298), .Q(\intadd_55/A[2] ) );
  IMUX20 U295 ( .A(\intadd_38/n1 ), .B(n457), .S(\intadd_40/n1 ), .Q(n426) );
  INV0 U296 ( .A(n283), .Q(\intadd_37/B[4] ) );
  INV0 U297 ( .A(\intadd_32/A[5] ), .Q(n452) );
  INV0 U298 ( .A(\intadd_35/SUM[5] ), .Q(\intadd_58/B[1] ) );
  INV0 U299 ( .A(\intadd_48/SUM[3] ), .Q(\intadd_58/A[1] ) );
  INV0 U300 ( .A(\intadd_37/SUM[2] ), .Q(\intadd_31/A[7] ) );
  INV0 U301 ( .A(n282), .Q(\intadd_56/A[2] ) );
  INV0 U302 ( .A(n439), .Q(n440) );
  INV0 U303 ( .A(\intadd_41/SUM[4] ), .Q(\intadd_33/A[9] ) );
  INV0 U304 ( .A(\intadd_36/SUM[7] ), .Q(n375) );
  INV0 U305 ( .A(\intadd_33/SUM[7] ), .Q(\intadd_60/A[2] ) );
  INV0 U306 ( .A(\intadd_36/SUM[6] ), .Q(\intadd_60/B[2] ) );
  INV0 U307 ( .A(n361), .Q(n362) );
  INV0 U308 ( .A(\intadd_37/SUM[4] ), .Q(\intadd_31/A[9] ) );
  INV0 U309 ( .A(\intadd_35/SUM[7] ), .Q(n453) );
  INV0 U310 ( .A(\intadd_31/SUM[7] ), .Q(\intadd_58/A[2] ) );
  INV0 U311 ( .A(\intadd_35/SUM[6] ), .Q(\intadd_58/B[2] ) );
  NAND20 U312 ( .A(n535), .B(\intadd_41/SUM[6] ), .Q(n284) );
  OAI210 U313 ( .A(\intadd_33/n1 ), .B(n382), .C(n204), .Q(n381) );
  IMUX20 U314 ( .A(n383), .B(\intadd_41/SUM[5] ), .S(n384), .Q(n382) );
  OAI210 U315 ( .A(\intadd_33/SUM[9] ), .B(n378), .C(RSTn), .Q(n377) );
  NAND20 U316 ( .A(n204), .B(\intadd_34/SUM[8] ), .Q(n265) );
  NAND20 U317 ( .A(n535), .B(\intadd_37/SUM[6] ), .Q(n268) );
  OAI210 U318 ( .A(\intadd_31/n1 ), .B(n460), .C(RSTn), .Q(n459) );
  IMUX20 U319 ( .A(n461), .B(\intadd_37/SUM[5] ), .S(n462), .Q(n460) );
  OAI210 U320 ( .A(\intadd_31/SUM[9] ), .B(n456), .C(n204), .Q(n455) );
  NAND20 U321 ( .A(n204), .B(\intadd_32/SUM[9] ), .Q(n266) );
  INV3 U322 ( .A(n214), .Q(n535) );
  INV0 U323 ( .A(RSTn), .Q(n214) );
  INV0 U324 ( .A(adc_eoc), .Q(n300) );
  CLKIN1 U325 ( .A(adc_eoc), .Q(n301) );
  INV0 U326 ( .A(\intadd_34/B[0] ), .Q(n325) );
  INV0 U327 ( .A(\intadd_32/B[0] ), .Q(n403) );
  IMUX20 U328 ( .A(\intadd_32/B[0] ), .B(n403), .S(n402), .Q(n407) );
  NOR20 U329 ( .A(n544), .B(n559), .Q(\intadd_31/CI ) );
  NOR20 U330 ( .A(\intadd_34/A[0] ), .B(\intadd_42/SUM[0] ), .Q(n309) );
  NOR20 U331 ( .A(\intadd_32/A[0] ), .B(\intadd_38/SUM[0] ), .Q(n387) );
  IMUX20 U332 ( .A(n399), .B(n398), .S(n397), .Q(n412) );
  OAI210 U333 ( .A(n315), .B(\intadd_61/n1 ), .C(n317), .Q(n286) );
  INV0 U334 ( .A(\intadd_50/SUM[0] ), .Q(\intadd_32/B[2] ) );
  INV0 U335 ( .A(\intadd_32/A[2] ), .Q(\intadd_59/B[2] ) );
  INV0 U336 ( .A(\intadd_44/SUM[3] ), .Q(\intadd_61/A[2] ) );
  INV0 U337 ( .A(\intadd_32/A[1] ), .Q(\intadd_35/B[2] ) );
  NAND20 U338 ( .A(\intadd_35/B[4] ), .B(\intadd_40/SUM[4] ), .Q(n395) );
  INV0 U339 ( .A(\intadd_45/SUM[3] ), .Q(n417) );
  IMUX20 U340 ( .A(\intadd_61/A[2] ), .B(\intadd_44/SUM[3] ), .S(
        \intadd_41/B[1] ), .Q(n336) );
  NAND20 U341 ( .A(\intadd_37/B[0] ), .B(\intadd_40/SUM[2] ), .Q(n390) );
  OAI210 U342 ( .A(n393), .B(\intadd_50/SUM[1] ), .C(n395), .Q(
        \intadd_32/B[4] ) );
  INV0 U343 ( .A(\intadd_45/SUM[4] ), .Q(n419) );
  OAI210 U344 ( .A(n288), .B(n352), .C(n287), .Q(n289) );
  OAI210 U345 ( .A(n391), .B(n277), .C(n390), .Q(n442) );
  INV0 U346 ( .A(\intadd_50/SUM[3] ), .Q(\intadd_32/B[5] ) );
  INV0 U347 ( .A(\intadd_44/SUM[4] ), .Q(n365) );
  INV0 U348 ( .A(\intadd_36/SUM[4] ), .Q(\intadd_60/CI ) );
  INV0 U349 ( .A(\intadd_32/A[3] ), .Q(n445) );
  OAI210 U350 ( .A(n423), .B(n272), .C(n271), .Q(\intadd_32/B[6] ) );
  INV0 U351 ( .A(\intadd_41/SUM[2] ), .Q(\intadd_33/A[7] ) );
  INV0 U352 ( .A(\intadd_36/SUM[5] ), .Q(\intadd_60/B[1] ) );
  INV0 U353 ( .A(\intadd_38/n1 ), .Q(n457) );
  INV0 U354 ( .A(n274), .Q(\intadd_32/A[7] ) );
  INV0 U355 ( .A(n476), .Q(n218) );
  INV0 U356 ( .A(\intadd_41/SUM[3] ), .Q(\intadd_33/B[8] ) );
  INV0 U357 ( .A(\intadd_37/SUM[3] ), .Q(\intadd_31/B[8] ) );
  OAI220 U358 ( .A(n473), .B(n471), .C(n507), .D(n505), .Q(n226) );
  INV0 U359 ( .A(n244), .Q(n237) );
  INV0 U360 ( .A(\intadd_41/SUM[5] ), .Q(n383) );
  INV0 U361 ( .A(\intadd_37/SUM[5] ), .Q(n461) );
  IMUX20 U362 ( .A(n509), .B(n258), .S(n510), .Q(n259) );
  OAI210 U363 ( .A(n239), .B(n238), .C(n237), .Q(n497) );
  NAND20 U364 ( .A(n535), .B(\intadd_34/SUM[9] ), .Q(n267) );
  NAND20 U365 ( .A(n535), .B(\intadd_32/SUM[8] ), .Q(n602) );
  IMUX20 U366 ( .A(n511), .B(n260), .S(n259), .Q(n614) );
  INV0 U367 ( .A(n266), .Q(\u_fir_i/u_core/N32 ) );
  LOGIC1 U368 ( .Q(n523) );
  INV0 U369 ( .A(I_in[0]), .Q(n524) );
  INV0 U370 ( .A(I_in[2]), .Q(n525) );
  INV0 U371 ( .A(Q_in[0]), .Q(n526) );
  INV0 U372 ( .A(Q_in[2]), .Q(n527) );
  INV0 U373 ( .A(n301), .Q(n530) );
  INV0 U374 ( .A(n301), .Q(n531) );
  CLKIN1 U375 ( .A(n301), .Q(n532) );
  CLKIN1 U376 ( .A(n301), .Q(n533) );
  INV0 U377 ( .A(n301), .Q(n534) );
  NOR20 U378 ( .A(n543), .B(n560), .Q(\intadd_33/CI ) );
  NOR20 U379 ( .A(n558), .B(n579), .Q(\intadd_44/CI ) );
  NOR20 U380 ( .A(\u_demod/IF_I [0]), .B(n569), .Q(n246) );
  CLKIN1 U381 ( .A(n246), .Q(n505) );
  NAND30 U382 ( .A(\u_demod/IF_Q [0]), .B(n505), .C(n592), .Q(n219) );
  INV0 U383 ( .A(n219), .Q(n215) );
  NAND20 U384 ( .A(\u_demod/IF_Q [3]), .B(n540), .Q(n507) );
  NOR20 U385 ( .A(\u_demod/IF_Q [3]), .B(n540), .Q(n245) );
  INV0 U386 ( .A(n245), .Q(n508) );
  IMUX20 U387 ( .A(n507), .B(n508), .S(\u_demod/I_tmpin [1]), .Q(n220) );
  IMUX20 U388 ( .A(n215), .B(n219), .S(n220), .Q(n230) );
  NAND20 U389 ( .A(\u_demod/IF_Q [0]), .B(n592), .Q(n216) );
  AOI210 U390 ( .A(n246), .B(n216), .C(n215), .Q(n473) );
  NOR40 U391 ( .A(n554), .B(n540), .C(\u_demod/Q_tmpin [2]), .D(
        \u_demod/I_tmpin [2]), .Q(n468) );
  INV0 U392 ( .A(n468), .Q(n471) );
  NOR20 U393 ( .A(\u_demod/Q_tmpin [3]), .B(n554), .Q(n476) );
  IMUX20 U394 ( .A(n507), .B(n508), .S(\u_demod/I_tmpin [0]), .Q(n475) );
  NAND20 U395 ( .A(\u_demod/IF_I [0]), .B(\u_demod/Q_tmpin [0]), .Q(n262) );
  OAI220 U396 ( .A(\u_demod/IF_I [3]), .B(n262), .C(\u_demod/Q_tmpin [0]), .D(
        n505), .Q(n474) );
  NAND20 U397 ( .A(n569), .B(\u_demod/IF_I [0]), .Q(n506) );
  IMUX20 U398 ( .A(n505), .B(n506), .S(\u_demod/Q_tmpin [1]), .Q(n217) );
  IMUX20 U399 ( .A(n476), .B(n218), .S(n217), .Q(n224) );
  MAJ31 U400 ( .A(n230), .B(\intadd_57/n1 ), .C(n233), .Q(n480) );
  INV0 U401 ( .A(n480), .Q(n229) );
  NAND20 U402 ( .A(n218), .B(n217), .Q(n483) );
  NAND20 U403 ( .A(n220), .B(n219), .Q(n482) );
  IMUX20 U404 ( .A(\u_demod/IF_Q [3]), .B(\u_demod/IF_Q [0]), .S(
        \u_demod/I_tmpin [2]), .Q(n221) );
  AOI210 U405 ( .A(\u_demod/IF_Q [3]), .B(\u_demod/IF_Q [0]), .C(n221), .Q(
        n223) );
  IMUX20 U406 ( .A(n505), .B(n506), .S(\u_demod/Q_tmpin [2]), .Q(n222) );
  NOR20 U407 ( .A(n223), .B(n222), .Q(n488) );
  AOI210 U408 ( .A(n223), .B(n222), .C(n488), .Q(n481) );
  INV0 U409 ( .A(n227), .Q(n478) );
  ADD31 U410 ( .A(n226), .B(n225), .CI(n224), .CO(n479), .S(n233) );
  IMUX20 U411 ( .A(n478), .B(n227), .S(n479), .Q(n228) );
  IMUX20 U412 ( .A(n480), .B(n229), .S(n228), .Q(n606) );
  INV0 U413 ( .A(n233), .Q(n232) );
  XNR20 U414 ( .A(n230), .B(\intadd_57/n1 ), .Q(n231) );
  IMUX20 U415 ( .A(n233), .B(n232), .S(n231), .Q(n605) );
  NOR40 U416 ( .A(n540), .B(n554), .C(n591), .D(n570), .Q(n306) );
  INV0 U417 ( .A(n306), .Q(n496) );
  AOI210 U418 ( .A(\u_demod/I_tmpin [1]), .B(\u_demod/I_tmpin [0]), .C(n554), 
        .Q(n234) );
  OAI210 U419 ( .A(\u_demod/I_tmpin [1]), .B(\u_demod/I_tmpin [0]), .C(n234), 
        .Q(n495) );
  NAND20 U420 ( .A(\u_demod/IF_Q [0]), .B(\u_demod/Q_tmpin [1]), .Q(n494) );
  OAI310 U421 ( .A(\u_demod/I_tmpin [1]), .B(\u_demod/I_tmpin [0]), .C(n554), 
        .D(n235), .Q(n236) );
  INV0 U422 ( .A(n236), .Q(n498) );
  NOR20 U423 ( .A(n540), .B(n593), .Q(n239) );
  NOR20 U424 ( .A(\u_demod/I_tmpin [2]), .B(n554), .Q(n238) );
  NOR40 U425 ( .A(\u_demod/I_tmpin [2]), .B(n554), .C(n540), .D(n593), .Q(n244) );
  NOR20 U426 ( .A(n498), .B(n497), .Q(n501) );
  NOR20 U427 ( .A(n540), .B(n571), .Q(n251) );
  NAND20 U428 ( .A(\u_demod/IF_I [0]), .B(n592), .Q(n249) );
  INV0 U429 ( .A(n249), .Q(n247) );
  IMUX20 U430 ( .A(n508), .B(n507), .S(\u_demod/Q_tmpin [0]), .Q(n240) );
  IMUX20 U431 ( .A(n249), .B(n247), .S(n240), .Q(n243) );
  IMUX20 U432 ( .A(n505), .B(n506), .S(\u_demod/I_tmpin [0]), .Q(n242) );
  NAND20 U433 ( .A(n247), .B(n240), .Q(n252) );
  MUX21 U434 ( .A(n508), .B(n507), .S(\u_demod/Q_tmpin [1]), .Q(n250) );
  INV0 U435 ( .A(n241), .Q(n503) );
  ADD31 U436 ( .A(n244), .B(n243), .CI(n242), .CO(n257), .S(n499) );
  ADD31 U437 ( .A(n246), .B(n245), .CI(n251), .CO(n256), .S(n500) );
  IMUX20 U438 ( .A(n505), .B(n506), .S(\u_demod/I_tmpin [1]), .Q(n248) );
  IMUX20 U439 ( .A(n247), .B(n249), .S(n248), .Q(n255) );
  INV0 U440 ( .A(n511), .Q(n260) );
  NAND20 U441 ( .A(n249), .B(n248), .Q(n514) );
  ADD31 U442 ( .A(n252), .B(n251), .CI(n250), .CO(n513), .S(n241) );
  IMUX20 U443 ( .A(n505), .B(n506), .S(\u_demod/I_tmpin [2]), .Q(n254) );
  IMUX20 U444 ( .A(n508), .B(n507), .S(\u_demod/Q_tmpin [2]), .Q(n253) );
  NOR20 U445 ( .A(n254), .B(n253), .Q(n519) );
  AOI210 U446 ( .A(n254), .B(n253), .C(n519), .Q(n512) );
  INV0 U447 ( .A(n258), .Q(n509) );
  ADD31 U448 ( .A(n257), .B(n256), .CI(n255), .CO(n510), .S(n502) );
  NOR20 U449 ( .A(n547), .B(\intadd_35/A[2] ), .Q(\intadd_37/CI ) );
  INV0 U450 ( .A(\intadd_34/A[2] ), .Q(\intadd_61/B[2] ) );
  INV0 U451 ( .A(\intadd_40/SUM[2] ), .Q(\intadd_59/A[1] ) );
  IMUX20 U452 ( .A(\u_fir_i/x_delay_flat [40]), .B(n546), .S(
        \u_fir_i/x_delay_flat [24]), .Q(\intadd_35/B[0] ) );
  INV0 U453 ( .A(\intadd_44/SUM[2] ), .Q(\intadd_61/A[1] ) );
  IMUX20 U454 ( .A(\u_fir_q/x_delay_flat [40]), .B(n545), .S(
        \u_fir_q/x_delay_flat [24]), .Q(\intadd_36/B[0] ) );
  NAND20 U455 ( .A(adc_eoc), .B(\u_demod/sin_signal/prev_counter [0]), .Q(n302) );
  OAI220 U456 ( .A(adc_eoc), .B(n574), .C(n599), .D(n302), .Q(n172) );
  NAND20 U457 ( .A(adc_eoc), .B(n597), .Q(n261) );
  OAI210 U458 ( .A(adc_eoc), .B(n597), .C(n261), .Q(n179) );
  OAI220 U459 ( .A(n533), .B(n569), .C(n598), .D(n261), .Q(n176) );
  OAI220 U460 ( .A(adc_eoc), .B(n554), .C(\u_demod/cos_signal/prev_counter[1] ), .D(n261), .Q(n177) );
  OAI220 U461 ( .A(n531), .B(n540), .C(\u_demod/sin_signal/prev_counter [1]), 
        .D(n302), .Q(n173) );
  INV0 U462 ( .A(\intadd_32/B[1] ), .Q(\intadd_59/B[1] ) );
  IMUX20 U463 ( .A(\u_fir_i/x_delay_flat [38]), .B(n595), .S(n426), .Q(
        \intadd_31/B[9] ) );
  INV0 U464 ( .A(\intadd_34/B[1] ), .Q(\intadd_61/B[1] ) );
  IMUX20 U465 ( .A(\u_fir_q/x_delay_flat [38]), .B(n596), .S(n348), .Q(
        \intadd_33/B[9] ) );
  NOR20 U466 ( .A(n540), .B(n591), .Q(n264) );
  INV0 U467 ( .A(n262), .Q(n263) );
  OAI210 U468 ( .A(n264), .B(n263), .C(n496), .Q(n603) );
  INV0 U469 ( .A(n265), .Q(\u_fir_q/u_core/N31 ) );
  INV0 U470 ( .A(n267), .Q(\u_fir_q/u_core/N32 ) );
  NOR20 U471 ( .A(\intadd_37/n1 ), .B(n214), .Q(\u_fir_i/u_core/N38 ) );
  NOR20 U472 ( .A(\intadd_41/n1 ), .B(n214), .Q(\u_fir_q/u_core/N38 ) );
  INV0 U473 ( .A(n268), .Q(\u_fir_i/u_core/N36 ) );
  INV0 U474 ( .A(\intadd_32/SUM[2] ), .Q(\intadd_45/B[2] ) );
  INV0 U475 ( .A(\intadd_32/SUM[0] ), .Q(\intadd_45/CI ) );
  INV0 U476 ( .A(\intadd_32/SUM[1] ), .Q(\intadd_45/B[1] ) );
  NAND20 U477 ( .A(\intadd_31/B[7] ), .B(\intadd_40/SUM[6] ), .Q(n271) );
  IMAJ30 U478 ( .A(n269), .B(\intadd_38/n1 ), .C(\intadd_40/n1 ), .Q(n280) );
  OAI210 U479 ( .A(n393), .B(\intadd_59/n1 ), .C(n395), .Q(n270) );
  AOI210 U480 ( .A(\intadd_38/SUM[0] ), .B(\intadd_32/A[0] ), .C(n387), .Q(
        n402) );
  ADD31 U481 ( .A(\u_fir_i/x_delay_flat [32]), .B(\u_fir_i/x_delay_flat [39]), 
        .CI(\intadd_38/SUM[0] ), .CO(n276), .S(n275) );
  INV0 U482 ( .A(n276), .Q(n277) );
  INV0 U483 ( .A(\intadd_40/SUM[3] ), .Q(\intadd_59/A[2] ) );
  INV0 U484 ( .A(n414), .Q(n278) );
  NOR20 U485 ( .A(\intadd_37/B[0] ), .B(\intadd_40/SUM[2] ), .Q(n391) );
  ADD31 U486 ( .A(n281), .B(n280), .CI(n279), .CO(n282), .S(n274) );
  AOI210 U487 ( .A(n580), .B(n542), .C(\intadd_39/CI ), .Q(n404) );
  NOR20 U488 ( .A(\u_fir_i/x_delay_flat [33]), .B(n386), .Q(n304) );
  NAND20 U489 ( .A(n304), .B(n585), .Q(\intadd_59/CI ) );
  INV0 U490 ( .A(n284), .Q(\u_fir_q/u_core/N36 ) );
  INV0 U491 ( .A(\intadd_34/SUM[2] ), .Q(\intadd_46/B[2] ) );
  INV0 U492 ( .A(\intadd_34/SUM[0] ), .Q(\intadd_46/CI ) );
  INV0 U493 ( .A(\intadd_34/SUM[1] ), .Q(\intadd_46/B[1] ) );
  INV0 U494 ( .A(\intadd_53/SUM[0] ), .Q(\intadd_34/B[2] ) );
  NOR20 U495 ( .A(\intadd_36/B[4] ), .B(\intadd_44/SUM[4] ), .Q(n315) );
  NAND20 U496 ( .A(\intadd_36/B[4] ), .B(\intadd_44/SUM[4] ), .Q(n317) );
  OAI210 U497 ( .A(n315), .B(\intadd_53/SUM[1] ), .C(n317), .Q(
        \intadd_34/B[4] ) );
  NAND20 U498 ( .A(\intadd_33/B[7] ), .B(\intadd_44/SUM[6] ), .Q(n287) );
  INV0 U499 ( .A(\intadd_54/SUM[3] ), .Q(n285) );
  IMAJ30 U500 ( .A(n285), .B(\intadd_42/n1 ), .C(\intadd_44/n1 ), .Q(n296) );
  AOI210 U501 ( .A(\intadd_42/SUM[0] ), .B(\intadd_34/A[0] ), .C(n309), .Q(
        n324) );
  IMUX20 U502 ( .A(\intadd_61/A[0] ), .B(\intadd_43/SUM[1] ), .S(n324), .Q(
        \intadd_53/B[2] ) );
  INV0 U503 ( .A(n291), .Q(\intadd_47/B[0] ) );
  ADD31 U504 ( .A(\u_fir_q/x_delay_flat [32]), .B(\u_fir_q/x_delay_flat [39]), 
        .CI(\intadd_42/SUM[0] ), .CO(n292), .S(n291) );
  INV0 U505 ( .A(n292), .Q(n293) );
  INV0 U506 ( .A(n336), .Q(n294) );
  NOR20 U507 ( .A(\intadd_41/B[0] ), .B(\intadd_44/SUM[2] ), .Q(n313) );
  NAND20 U508 ( .A(\intadd_41/B[0] ), .B(\intadd_44/SUM[2] ), .Q(n312) );
  ADD31 U509 ( .A(n297), .B(n296), .CI(n295), .CO(n298), .S(n290) );
  AOI210 U510 ( .A(n581), .B(n541), .C(\intadd_43/CI ), .Q(n326) );
  NOR20 U511 ( .A(\u_fir_q/x_delay_flat [33]), .B(n308), .Q(n305) );
  NAND20 U512 ( .A(n305), .B(n564), .Q(\intadd_61/CI ) );
  INV0 U513 ( .A(\intadd_33/SUM[3] ), .Q(\intadd_54/A[2] ) );
  MUX21 U514 ( .A(\u_fir_q/x_delay_flat [51]), .B(\u_fir_q/x_delay_flat [59]), 
        .S(n300), .Q(n65) );
  MUX21 U515 ( .A(\u_fir_q/x_delay_flat [42]), .B(\u_fir_q/x_delay_flat [50]), 
        .S(n301), .Q(n75) );
  MUX21 U516 ( .A(\u_fir_q/x_delay_flat [50]), .B(\u_fir_q/x_delay_flat [58]), 
        .S(n300), .Q(n74) );
  MUX21 U517 ( .A(\u_fir_q/x_delay_flat [44]), .B(\u_fir_q/x_delay_flat [52]), 
        .S(n301), .Q(n57) );
  MUX21 U518 ( .A(\u_fir_q/x_delay_flat [52]), .B(\u_fir_q/x_delay_flat [60]), 
        .S(n300), .Q(n56) );
  MUX21 U519 ( .A(\u_fir_q/x_delay_flat [35]), .B(\u_fir_q/x_delay_flat [43]), 
        .S(n301), .Q(n67) );
  MUX21 U520 ( .A(\u_fir_q/x_delay_flat [43]), .B(\u_fir_q/x_delay_flat [51]), 
        .S(n301), .Q(n66) );
  MUX21 U521 ( .A(\u_fir_q/x_delay_flat [49]), .B(\u_fir_q/x_delay_flat [57]), 
        .S(n300), .Q(n83) );
  MUX21 U522 ( .A(\u_fir_q/x_delay_flat [36]), .B(\u_fir_q/x_delay_flat [44]), 
        .S(n301), .Q(n58) );
  MUX21 U523 ( .A(\u_fir_q/x_delay_flat [46]), .B(\u_fir_q/x_delay_flat [54]), 
        .S(n301), .Q(n39) );
  MUX21 U524 ( .A(\u_fir_q/x_delay_flat [41]), .B(\u_fir_q/x_delay_flat [49]), 
        .S(n301), .Q(n84) );
  MUX21 U525 ( .A(\u_fir_q/x_delay_flat [54]), .B(\u_fir_q/x_delay_flat [62]), 
        .S(n301), .Q(n38) );
  MUX21 U526 ( .A(\u_fir_i/x_delay_flat [5]), .B(I_demod[5]), .S(n533), .Q(
        n126) );
  MUX21 U527 ( .A(\u_fir_i/x_delay_flat [6]), .B(I_demod[6]), .S(n533), .Q(
        n117) );
  MUX21 U528 ( .A(\u_fir_q/x_delay_flat [4]), .B(Q_demod[4]), .S(n533), .Q(n63) );
  MUX21 U529 ( .A(\u_fir_i/x_delay_flat [2]), .B(I_demod[2]), .S(n533), .Q(
        n153) );
  MUX21 U530 ( .A(\u_fir_q/x_delay_flat [5]), .B(Q_demod[5]), .S(n533), .Q(n54) );
  MUX21 U531 ( .A(\u_fir_q/x_delay_flat [2]), .B(Q_demod[2]), .S(n533), .Q(n81) );
  MUX21 U532 ( .A(\u_fir_i/x_delay_flat [4]), .B(I_demod[4]), .S(adc_eoc), .Q(
        n135) );
  MUX21 U533 ( .A(\u_fir_q/x_delay_flat [6]), .B(Q_demod[6]), .S(adc_eoc), .Q(
        n45) );
  MUX21 U534 ( .A(\u_fir_q/x_delay_flat [1]), .B(Q_demod[1]), .S(adc_eoc), .Q(
        n90) );
  MUX21 U535 ( .A(\u_fir_q/x_delay_flat [3]), .B(Q_demod[3]), .S(adc_eoc), .Q(
        n72) );
  MUX21 U536 ( .A(\u_fir_i/x_delay_flat [3]), .B(I_demod[3]), .S(adc_eoc), .Q(
        n144) );
  MUX21 U537 ( .A(\u_fir_q/x_delay_flat [14]), .B(\u_fir_q/x_delay_flat [6]), 
        .S(adc_eoc), .Q(n44) );
  MUX21 U538 ( .A(\u_fir_q/x_delay_flat [13]), .B(\u_fir_q/x_delay_flat [5]), 
        .S(adc_eoc), .Q(n53) );
  MUX21 U539 ( .A(\u_fir_i/x_delay_flat [11]), .B(\u_fir_i/x_delay_flat [3]), 
        .S(adc_eoc), .Q(n143) );
  MUX21 U540 ( .A(\u_fir_i/x_delay_flat [19]), .B(\u_fir_i/x_delay_flat [11]), 
        .S(adc_eoc), .Q(n142) );
  MUX21 U541 ( .A(\u_fir_i/x_delay_flat [10]), .B(\u_fir_i/x_delay_flat [2]), 
        .S(adc_eoc), .Q(n152) );
  MUX21 U542 ( .A(\u_fir_q/x_delay_flat [22]), .B(\u_fir_q/x_delay_flat [14]), 
        .S(adc_eoc), .Q(n43) );
  MUX21 U543 ( .A(\u_fir_i/x_delay_flat [28]), .B(\u_fir_i/x_delay_flat [20]), 
        .S(adc_eoc), .Q(n132) );
  MUX21 U544 ( .A(\u_fir_q/x_delay_flat [27]), .B(\u_fir_q/x_delay_flat [19]), 
        .S(adc_eoc), .Q(n69) );
  MUX21 U545 ( .A(\u_fir_i/x_delay_flat [21]), .B(\u_fir_i/x_delay_flat [13]), 
        .S(adc_eoc), .Q(n124) );
  MUX21 U546 ( .A(\u_fir_i/x_delay_flat [29]), .B(\u_fir_i/x_delay_flat [21]), 
        .S(adc_eoc), .Q(n123) );
  MUX21 U547 ( .A(\u_fir_i/x_delay_flat [12]), .B(\u_fir_i/x_delay_flat [4]), 
        .S(adc_eoc), .Q(n134) );
  MUX21 U548 ( .A(\u_fir_i/x_delay_flat [20]), .B(\u_fir_i/x_delay_flat [12]), 
        .S(adc_eoc), .Q(n133) );
  MUX21 U549 ( .A(\u_fir_i/x_delay_flat [14]), .B(\u_fir_i/x_delay_flat [6]), 
        .S(adc_eoc), .Q(n116) );
  MUX21 U550 ( .A(\u_fir_i/x_delay_flat [13]), .B(\u_fir_i/x_delay_flat [5]), 
        .S(adc_eoc), .Q(n125) );
  MUX21 U551 ( .A(\u_fir_q/x_delay_flat [21]), .B(\u_fir_q/x_delay_flat [13]), 
        .S(adc_eoc), .Q(n52) );
  MUX21 U552 ( .A(\u_fir_q/x_delay_flat [9]), .B(\u_fir_q/x_delay_flat [1]), 
        .S(adc_eoc), .Q(n89) );
  MUX21 U553 ( .A(\u_fir_i/x_delay_flat [27]), .B(\u_fir_i/x_delay_flat [19]), 
        .S(adc_eoc), .Q(n141) );
  MUX21 U554 ( .A(\u_fir_q/x_delay_flat [28]), .B(\u_fir_q/x_delay_flat [20]), 
        .S(adc_eoc), .Q(n60) );
  MUX21 U555 ( .A(\u_fir_q/x_delay_flat [12]), .B(\u_fir_q/x_delay_flat [4]), 
        .S(adc_eoc), .Q(n62) );
  MUX21 U556 ( .A(\u_fir_q/x_delay_flat [30]), .B(\u_fir_q/x_delay_flat [22]), 
        .S(adc_eoc), .Q(n42) );
  MUX21 U557 ( .A(\u_fir_q/x_delay_flat [17]), .B(\u_fir_q/x_delay_flat [9]), 
        .S(n533), .Q(n88) );
  MUX21 U558 ( .A(\u_fir_q/x_delay_flat [10]), .B(\u_fir_q/x_delay_flat [2]), 
        .S(adc_eoc), .Q(n80) );
  MUX21 U559 ( .A(\u_fir_q/x_delay_flat [26]), .B(\u_fir_q/x_delay_flat [18]), 
        .S(n532), .Q(n78) );
  MUX21 U560 ( .A(\u_fir_q/x_delay_flat [20]), .B(\u_fir_q/x_delay_flat [12]), 
        .S(n532), .Q(n61) );
  MUX21 U561 ( .A(\u_fir_q/x_delay_flat [29]), .B(\u_fir_q/x_delay_flat [21]), 
        .S(adc_eoc), .Q(n51) );
  MUX21 U562 ( .A(\u_fir_i/x_delay_flat [18]), .B(\u_fir_i/x_delay_flat [10]), 
        .S(adc_eoc), .Q(n151) );
  MUX21 U563 ( .A(\u_fir_i/x_delay_flat [26]), .B(\u_fir_i/x_delay_flat [18]), 
        .S(n532), .Q(n150) );
  MUX21 U564 ( .A(\u_fir_q/x_delay_flat [11]), .B(\u_fir_q/x_delay_flat [3]), 
        .S(n532), .Q(n71) );
  MUX21 U565 ( .A(\u_fir_q/x_delay_flat [19]), .B(\u_fir_q/x_delay_flat [11]), 
        .S(n532), .Q(n70) );
  MUX21 U566 ( .A(\u_fir_i/x_delay_flat [30]), .B(\u_fir_i/x_delay_flat [22]), 
        .S(n532), .Q(n114) );
  MUX21 U567 ( .A(\u_fir_q/x_delay_flat [25]), .B(\u_fir_q/x_delay_flat [17]), 
        .S(n532), .Q(n87) );
  MUX21 U568 ( .A(\u_fir_i/x_delay_flat [22]), .B(\u_fir_i/x_delay_flat [14]), 
        .S(n532), .Q(n115) );
  MUX21 U569 ( .A(\u_fir_q/x_delay_flat [18]), .B(\u_fir_q/x_delay_flat [10]), 
        .S(n532), .Q(n79) );
  MUX21 U570 ( .A(\u_fir_q/x_delay_flat [70]), .B(\u_fir_q/x_delay_flat [62]), 
        .S(n531), .Q(n37) );
  MUX21 U571 ( .A(\u_fir_q/x_delay_flat [65]), .B(\u_fir_q/x_delay_flat [57]), 
        .S(n533), .Q(n82) );
  MUX21 U572 ( .A(\u_fir_q/x_delay_flat [69]), .B(\u_fir_q/x_delay_flat [61]), 
        .S(n532), .Q(n46) );
  MUX21 U573 ( .A(\u_fir_q/x_delay_flat [66]), .B(\u_fir_q/x_delay_flat [58]), 
        .S(adc_eoc), .Q(n73) );
  MUX21 U574 ( .A(\u_fir_q/x_delay_flat [67]), .B(\u_fir_q/x_delay_flat [59]), 
        .S(adc_eoc), .Q(n64) );
  MUX21 U575 ( .A(\u_fir_q/x_delay_flat [53]), .B(\u_fir_q/x_delay_flat [45]), 
        .S(adc_eoc), .Q(n48) );
  MUX21 U576 ( .A(\u_fir_q/x_delay_flat [68]), .B(\u_fir_q/x_delay_flat [60]), 
        .S(adc_eoc), .Q(n55) );
  MUX21 U577 ( .A(\u_fir_q/x_delay_flat [61]), .B(\u_fir_q/x_delay_flat [53]), 
        .S(adc_eoc), .Q(n47) );
  IMUX20 U578 ( .A(\u_demod/sin_signal/prev_counter [1]), .B(n599), .S(n302), 
        .Q(n174) );
  NOR20 U579 ( .A(n300), .B(n597), .Q(n303) );
  IMUX20 U580 ( .A(n598), .B(\u_demod/cos_signal/prev_counter[1] ), .S(n303), 
        .Q(n178) );
  IMUX20 U581 ( .A(\u_fir_i/x_delay_flat [34]), .B(n585), .S(n304), .Q(
        \intadd_32/CI ) );
  IMUX20 U582 ( .A(\u_fir_i/x_delay_flat [48]), .B(n557), .S(
        \u_fir_i/x_delay_flat [16]), .Q(\intadd_35/CI ) );
  IMUX20 U583 ( .A(\u_fir_i/x_delay_flat [33]), .B(n547), .S(
        \intadd_38/SUM[1] ), .Q(\intadd_35/A[3] ) );
  IMUX20 U584 ( .A(\u_fir_q/x_delay_flat [34]), .B(n564), .S(n305), .Q(
        \intadd_34/CI ) );
  IMUX20 U585 ( .A(\u_fir_q/x_delay_flat [48]), .B(n558), .S(
        \u_fir_q/x_delay_flat [16]), .Q(\intadd_36/CI ) );
  IMUX20 U586 ( .A(\u_fir_q/x_delay_flat [33]), .B(n586), .S(
        \intadd_42/SUM[1] ), .Q(\intadd_36/A[3] ) );
  NOR20 U587 ( .A(\u_demod/I_tmpin [0]), .B(n540), .Q(n467) );
  NOR20 U588 ( .A(\u_demod/I_tmpin [1]), .B(n540), .Q(n466) );
  NOR20 U589 ( .A(\u_demod/Q_tmpin [0]), .B(n554), .Q(n465) );
  NOR20 U590 ( .A(\u_demod/Q_tmpin [1]), .B(n554), .Q(n463) );
  ADD31 U591 ( .A(n306), .B(n464), .CI(n463), .CO(\intadd_57/n3 ) );
  AOI2110 U592 ( .A(n543), .B(n560), .C(\intadd_33/CI ), .D(n583), .Q(
        \intadd_53/A[0] ) );
  IMUX20 U593 ( .A(\u_fir_q/x_delay_flat [56]), .B(n543), .S(
        \u_fir_q/x_delay_flat [8]), .Q(n307) );
  AOI210 U594 ( .A(n583), .B(n307), .C(\intadd_53/A[0] ), .Q(\intadd_61/B[0] )
         );
  AOI210 U595 ( .A(n308), .B(n584), .C(\intadd_54/B[0] ), .Q(\intadd_53/CI )
         );
  INV0 U596 ( .A(n309), .Q(n314) );
  AOI220 U597 ( .A(\intadd_34/A[0] ), .B(\intadd_42/SUM[0] ), .C(n314), .D(
        \intadd_61/A[0] ), .Q(\intadd_47/A[0] ) );
  OAI310 U598 ( .A(\u_fir_q/x_delay_flat [32]), .B(n326), .C(
        \u_fir_q/x_delay_flat [33]), .D(\intadd_36/CI ), .Q(n311) );
  NAND20 U599 ( .A(\u_fir_q/x_delay_flat [32]), .B(\u_fir_q/x_delay_flat [33]), 
        .Q(n310) );
  AOI220 U600 ( .A(n326), .B(\u_fir_q/x_delay_flat [33]), .C(n311), .D(n310), 
        .Q(n322) );
  OAI210 U601 ( .A(n313), .B(n320), .C(n312), .Q(n335) );
  MAJ31 U602 ( .A(\intadd_41/B[1] ), .B(\intadd_44/SUM[3] ), .C(n335), .Q(
        \intadd_34/B[3] ) );
  AOI220 U603 ( .A(\intadd_34/B[0] ), .B(n314), .C(\intadd_34/A[0] ), .D(
        \intadd_42/SUM[0] ), .Q(\intadd_46/B[0] ) );
  INV0 U604 ( .A(n315), .Q(n316) );
  NAND20 U605 ( .A(n317), .B(n316), .Q(n318) );
  XNR20 U606 ( .A(\intadd_53/SUM[1] ), .B(n318), .Q(\intadd_46/B[3] ) );
  ADD31 U607 ( .A(n370), .B(n344), .CI(\intadd_53/SUM[2] ), .CO(n345), .S(
        \intadd_46/A[4] ) );
  XNR20 U608 ( .A(\intadd_61/n1 ), .B(n318), .Q(\intadd_46/B[4] ) );
  INV0 U609 ( .A(n320), .Q(n321) );
  IMUX20 U610 ( .A(n321), .B(n320), .S(n319), .Q(n334) );
  ADD31 U611 ( .A(\intadd_36/A[2] ), .B(\intadd_61/A[0] ), .CI(n322), .CO(n320), .S(n332) );
  NOR20 U612 ( .A(\u_fir_q/x_delay_flat [32]), .B(n326), .Q(n323) );
  XNR30 U613 ( .A(n323), .B(\intadd_36/CI ), .C(\u_fir_q/x_delay_flat [33]), 
        .Q(n330) );
  IMUX20 U614 ( .A(\intadd_34/B[0] ), .B(n325), .S(n324), .Q(n329) );
  IMUX20 U615 ( .A(\u_fir_q/x_delay_flat [32]), .B(n588), .S(n326), .Q(n327)
         );
  ADD31 U616 ( .A(n327), .B(\intadd_36/B[0] ), .CI(\intadd_36/CI ), .CO(n328)
         );
  ADD31 U617 ( .A(n330), .B(n329), .CI(n328), .CO(n331) );
  ADD31 U618 ( .A(\intadd_46/SUM[0] ), .B(n332), .CI(n331), .CO(n333) );
  MAJ31 U619 ( .A(\intadd_46/SUM[1] ), .B(n334), .C(n333), .Q(n338) );
  XNR20 U620 ( .A(n336), .B(n335), .Q(n337) );
  IMAJ30 U621 ( .A(n338), .B(\intadd_46/SUM[2] ), .C(n337), .Q(n340) );
  INV0 U622 ( .A(\intadd_46/SUM[3] ), .Q(n339) );
  MAJ31 U623 ( .A(\intadd_34/SUM[3] ), .B(n340), .C(n339), .Q(n342) );
  INV0 U624 ( .A(\intadd_46/SUM[4] ), .Q(n341) );
  IMAJ30 U625 ( .A(\intadd_34/SUM[4] ), .B(n342), .C(n341), .Q(n347) );
  ADD31 U626 ( .A(n368), .B(n344), .CI(n343), .CO(n352), .S(n349) );
  XNR20 U627 ( .A(n345), .B(n353), .Q(n351) );
  XOR30 U628 ( .A(\intadd_34/SUM[5] ), .B(n349), .C(n351), .Q(n346) );
  IMAJ30 U629 ( .A(n347), .B(\intadd_46/n1 ), .C(n346), .Q(n357) );
  XNR20 U630 ( .A(\intadd_54/SUM[3] ), .B(n348), .Q(n360) );
  INV0 U631 ( .A(n349), .Q(n350) );
  IMAJ30 U632 ( .A(\intadd_34/SUM[5] ), .B(n351), .C(n350), .Q(n359) );
  INV0 U633 ( .A(n353), .Q(n354) );
  MAJ31 U634 ( .A(\intadd_34/SUM[6] ), .B(n357), .C(n356), .Q(n363) );
  ADD31 U635 ( .A(n360), .B(n359), .CI(n358), .CO(n361), .S(n355) );
  MAJ31 U636 ( .A(\intadd_34/SUM[7] ), .B(n363), .C(n362), .Q(\intadd_34/B[8] ) );
  IMAJ30 U637 ( .A(\intadd_41/B[1] ), .B(\intadd_44/SUM[3] ), .C(n364), .Q(
        n366) );
  ADD31 U638 ( .A(n367), .B(n366), .CI(n365), .CO(n369), .S(\intadd_47/B[3] )
         );
  ADD31 U639 ( .A(n370), .B(n369), .CI(n368), .CO(\intadd_33/A[8] ), .S(
        \intadd_36/B[6] ) );
  IMUX20 U640 ( .A(\intadd_36/SUM[7] ), .B(n375), .S(\intadd_60/n1 ), .Q(n372)
         );
  OAI210 U641 ( .A(\intadd_34/n1 ), .B(n372), .C(RSTn), .Q(n371) );
  AOI210 U642 ( .A(\intadd_34/n1 ), .B(n372), .C(n371), .Q(
        \u_fir_q/u_core/N33 ) );
  ADD31 U643 ( .A(n374), .B(\intadd_43/n1 ), .CI(n373), .CO(n299), .S(
        \intadd_36/B[7] ) );
  IMAJ30 U644 ( .A(\intadd_34/n1 ), .B(\intadd_60/n1 ), .C(n375), .Q(n380) );
  INV0 U645 ( .A(n380), .Q(n376) );
  IMUX20 U646 ( .A(n380), .B(n376), .S(\intadd_36/n1 ), .Q(n378) );
  AOI210 U647 ( .A(\intadd_33/SUM[9] ), .B(n378), .C(n377), .Q(
        \u_fir_q/u_core/N34 ) );
  MAJ31 U648 ( .A(\intadd_44/n1 ), .B(\u_fir_q/x_delay_flat [38]), .C(n379), 
        .Q(\intadd_41/B[5] ) );
  MAJ31 U649 ( .A(\intadd_33/SUM[9] ), .B(n380), .C(\intadd_36/n1 ), .Q(n384)
         );
  AOI210 U650 ( .A(\intadd_33/n1 ), .B(n382), .C(n381), .Q(
        \u_fir_q/u_core/N35 ) );
  IMAJ30 U651 ( .A(n384), .B(\intadd_33/n1 ), .C(n383), .Q(\intadd_41/B[6] )
         );
  AOI2110 U652 ( .A(n544), .B(n559), .C(\intadd_31/CI ), .D(n582), .Q(
        \intadd_50/A[0] ) );
  IMUX20 U653 ( .A(\u_fir_i/x_delay_flat [56]), .B(n544), .S(
        \u_fir_i/x_delay_flat [8]), .Q(n385) );
  AOI210 U654 ( .A(n582), .B(n385), .C(\intadd_50/A[0] ), .Q(\intadd_59/B[0] )
         );
  AOI210 U655 ( .A(n386), .B(n563), .C(\intadd_51/B[0] ), .Q(\intadd_50/CI )
         );
  INV0 U656 ( .A(n387), .Q(n392) );
  AOI220 U657 ( .A(\intadd_32/A[0] ), .B(\intadd_38/SUM[0] ), .C(n392), .D(
        \intadd_59/A[0] ), .Q(\intadd_48/A[0] ) );
  OAI310 U658 ( .A(\u_fir_i/x_delay_flat [32]), .B(n404), .C(
        \u_fir_i/x_delay_flat [33]), .D(\intadd_35/CI ), .Q(n389) );
  NAND20 U659 ( .A(\u_fir_i/x_delay_flat [32]), .B(\u_fir_i/x_delay_flat [33]), 
        .Q(n388) );
  AOI220 U660 ( .A(n404), .B(\u_fir_i/x_delay_flat [33]), .C(n389), .D(n388), 
        .Q(n400) );
  OAI210 U661 ( .A(n391), .B(n398), .C(n390), .Q(n413) );
  MAJ31 U662 ( .A(\intadd_37/B[1] ), .B(\intadd_40/SUM[3] ), .C(n413), .Q(
        \intadd_32/B[3] ) );
  AOI220 U663 ( .A(\intadd_32/B[0] ), .B(n392), .C(\intadd_32/A[0] ), .D(
        \intadd_38/SUM[0] ), .Q(\intadd_45/B[0] ) );
  INV0 U664 ( .A(n393), .Q(n394) );
  NAND20 U665 ( .A(n395), .B(n394), .Q(n396) );
  XNR20 U666 ( .A(\intadd_50/SUM[1] ), .B(n396), .Q(\intadd_45/B[3] ) );
  ADD31 U667 ( .A(n448), .B(n422), .CI(\intadd_50/SUM[2] ), .CO(n423), .S(
        \intadd_45/A[4] ) );
  XNR20 U668 ( .A(\intadd_59/n1 ), .B(n396), .Q(\intadd_45/B[4] ) );
  INV0 U669 ( .A(n398), .Q(n399) );
  ADD31 U670 ( .A(\intadd_35/A[2] ), .B(\intadd_59/A[0] ), .CI(n400), .CO(n398), .S(n410) );
  NOR20 U671 ( .A(\u_fir_i/x_delay_flat [32]), .B(n404), .Q(n401) );
  XNR30 U672 ( .A(n401), .B(\intadd_35/CI ), .C(\u_fir_i/x_delay_flat [33]), 
        .Q(n408) );
  IMUX20 U673 ( .A(\u_fir_i/x_delay_flat [32]), .B(n587), .S(n404), .Q(n405)
         );
  ADD31 U674 ( .A(n405), .B(\intadd_35/B[0] ), .CI(\intadd_35/CI ), .CO(n406)
         );
  ADD31 U675 ( .A(n408), .B(n407), .CI(n406), .CO(n409) );
  ADD31 U676 ( .A(\intadd_45/SUM[0] ), .B(n410), .CI(n409), .CO(n411) );
  MAJ31 U677 ( .A(\intadd_45/SUM[1] ), .B(n412), .C(n411), .Q(n416) );
  XNR20 U678 ( .A(n414), .B(n413), .Q(n415) );
  IMAJ30 U679 ( .A(n416), .B(\intadd_45/SUM[2] ), .C(n415), .Q(n418) );
  MAJ31 U680 ( .A(\intadd_32/SUM[3] ), .B(n418), .C(n417), .Q(n420) );
  IMAJ30 U681 ( .A(\intadd_32/SUM[4] ), .B(n420), .C(n419), .Q(n425) );
  ADD31 U682 ( .A(n446), .B(n422), .CI(n421), .CO(n430), .S(n427) );
  XNR20 U683 ( .A(n423), .B(n431), .Q(n429) );
  XOR30 U684 ( .A(\intadd_32/SUM[5] ), .B(n427), .C(n429), .Q(n424) );
  IMAJ30 U685 ( .A(n425), .B(\intadd_45/n1 ), .C(n424), .Q(n435) );
  XNR20 U686 ( .A(\intadd_51/SUM[3] ), .B(n426), .Q(n438) );
  IMAJ30 U687 ( .A(\intadd_32/SUM[5] ), .B(n429), .C(n428), .Q(n437) );
  INV0 U688 ( .A(n431), .Q(n432) );
  MAJ31 U689 ( .A(\intadd_32/SUM[6] ), .B(n435), .C(n434), .Q(n441) );
  ADD31 U690 ( .A(n438), .B(n437), .CI(n436), .CO(n439), .S(n433) );
  MAJ31 U691 ( .A(\intadd_32/SUM[7] ), .B(n441), .C(n440), .Q(\intadd_32/B[8] ) );
  IMAJ30 U692 ( .A(\intadd_37/B[1] ), .B(\intadd_40/SUM[3] ), .C(n442), .Q(
        n444) );
  ADD31 U693 ( .A(n445), .B(n444), .CI(n443), .CO(n447), .S(\intadd_48/B[3] )
         );
  ADD31 U694 ( .A(n448), .B(n447), .CI(n446), .CO(\intadd_31/A[8] ), .S(
        \intadd_35/B[6] ) );
  IMUX20 U695 ( .A(\intadd_35/SUM[7] ), .B(n453), .S(\intadd_58/n1 ), .Q(n450)
         );
  OAI210 U696 ( .A(\intadd_32/n1 ), .B(n450), .C(RSTn), .Q(n449) );
  AOI210 U697 ( .A(\intadd_32/n1 ), .B(n450), .C(n449), .Q(
        \u_fir_i/u_core/N33 ) );
  ADD31 U698 ( .A(n452), .B(\intadd_39/n1 ), .CI(n451), .CO(n283), .S(
        \intadd_35/B[7] ) );
  IMAJ30 U699 ( .A(\intadd_32/n1 ), .B(\intadd_58/n1 ), .C(n453), .Q(n458) );
  INV0 U700 ( .A(n458), .Q(n454) );
  IMUX20 U701 ( .A(n458), .B(n454), .S(\intadd_35/n1 ), .Q(n456) );
  AOI210 U702 ( .A(\intadd_31/SUM[9] ), .B(n456), .C(n455), .Q(
        \u_fir_i/u_core/N34 ) );
  MAJ31 U703 ( .A(\intadd_40/n1 ), .B(\u_fir_i/x_delay_flat [38]), .C(n457), 
        .Q(\intadd_37/B[5] ) );
  MAJ31 U704 ( .A(\intadd_31/SUM[9] ), .B(n458), .C(\intadd_35/n1 ), .Q(n462)
         );
  AOI210 U705 ( .A(\intadd_31/n1 ), .B(n460), .C(n459), .Q(
        \u_fir_i/u_core/N35 ) );
  IMAJ30 U706 ( .A(n462), .B(\intadd_31/n1 ), .C(n461), .Q(\intadd_37/B[6] )
         );
  XNR30 U707 ( .A(n464), .B(n463), .C(n496), .Q(n604) );
  ADD31 U708 ( .A(n467), .B(n466), .CI(n465), .CO(\intadd_57/A[1] ), .S(n464)
         );
  NAND20 U709 ( .A(\u_demod/IF_I [0]), .B(n593), .Q(n470) );
  NAND20 U710 ( .A(\u_demod/IF_Q [0]), .B(n594), .Q(n469) );
  AOI210 U711 ( .A(n470), .B(n469), .C(n468), .Q(\intadd_57/B[1] ) );
  NAND20 U712 ( .A(n471), .B(n507), .Q(n472) );
  XNR20 U713 ( .A(n473), .B(n472), .Q(\intadd_57/A[2] ) );
  ADD31 U714 ( .A(n476), .B(n475), .CI(n474), .CO(n225), .S(\intadd_57/B[2] )
         );
  IMUX20 U715 ( .A(\u_demod/I_tmpin [3]), .B(\u_demod/IF_Q [3]), .S(
        \u_demod/IF_Q [0]), .Q(n477) );
  OAI210 U716 ( .A(\u_demod/IF_Q [3]), .B(\u_demod/I_tmpin [3]), .C(n477), .Q(
        n489) );
  IMUX20 U717 ( .A(n505), .B(n506), .S(\u_demod/Q_tmpin [3]), .Q(n487) );
  IMAJ30 U718 ( .A(n480), .B(n479), .C(n478), .Q(n485) );
  ADD31 U719 ( .A(n483), .B(n482), .CI(n481), .CO(n484), .S(n227) );
  XNR30 U720 ( .A(n486), .B(n485), .C(n484), .Q(n607) );
  MAJ31 U721 ( .A(n486), .B(n485), .C(n484), .Q(n491) );
  ADD31 U722 ( .A(n488), .B(n489), .CI(n487), .CO(n490), .S(n486) );
  XOR30 U723 ( .A(n491), .B(n490), .C(n489), .Q(n608) );
  NOR20 U724 ( .A(n554), .B(n591), .Q(n493) );
  NOR20 U725 ( .A(n540), .B(n570), .Q(n492) );
  XNR20 U726 ( .A(n493), .B(n492), .Q(n609) );
  ADD31 U727 ( .A(n496), .B(n495), .CI(n494), .CO(n235), .S(n610) );
  AOI210 U728 ( .A(n498), .B(n497), .C(n501), .Q(n611) );
  ADD31 U729 ( .A(n501), .B(n500), .CI(n499), .CO(n504), .S(n612) );
  ADD31 U730 ( .A(n504), .B(n503), .CI(n502), .CO(n511), .S(n613) );
  MUX21 U731 ( .A(n506), .B(n505), .S(n592), .Q(n521) );
  IMUX20 U732 ( .A(n508), .B(n507), .S(\u_demod/Q_tmpin [3]), .Q(n518) );
  IMAJ30 U733 ( .A(n511), .B(n510), .C(n509), .Q(n516) );
  ADD31 U734 ( .A(n514), .B(n513), .CI(n512), .CO(n515), .S(n258) );
  XNR30 U735 ( .A(n517), .B(n516), .C(n515), .Q(n615) );
  MAJ31 U736 ( .A(n517), .B(n516), .C(n515), .Q(n522) );
  ADD31 U737 ( .A(n519), .B(n521), .CI(n518), .CO(n520), .S(n517) );
  XOR30 U738 ( .A(n522), .B(n521), .C(n520), .Q(n616) );
endmodule

