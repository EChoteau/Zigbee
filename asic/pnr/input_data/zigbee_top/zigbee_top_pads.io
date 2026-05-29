######################################################
#           PAD MANAGEMENT FOR ZIGBEE TOP            #
######################################################

#======================= Info =========================
#
#             ┌───────── North ─────────┐
#        1  ──┤• N6*                 N7 ├── 48
#        2  ──┤  N5      DIL 48      N8 ├── 47
#        3  ──┤  N4                  N9 ├── 46
#        4  ──┤  N3                 N10 ├── 45
#        5  ──┤  N2                 N11 ├── 44
#        6  ──┤  N1                 N12 ├── 43
#        7  ──┤  W1                  E1 ├── 42
#        8  ──┤  W2                  E2 ├── 41
#        9  ──┤  W3                  E3 ├── 40
#       10  ──┤  W4    ┌─ North ─┐   E4 ├── 39
#       11  ──┤  W5    |         |   E5 ├── 38
#       12  ──┤  W6*   |         |   E6 ├── 37
#       13  ──┤  W7#   |         |  #E7 ├── 36
#       14  ──┤  W8    └─────────┘   E8 ├── 35
#       15  ──┤  W9                  E9 ├── 34
#       16  ──┤  W10                E10 ├── 33
#       17  ──┤  W11                E11 ├── 32
#       18  ──┤  W12                E12 ├── 31
#       19  ──┤  S1                 S12 ├── 30
#       20  ──┤  S2                 S11 ├── 29
#       21  ──┤  S3                 S10 ├── 28
#       22  ──┤  S4                  S9 ├── 27
#       23  ──┤  S5                  S8 ├── 26
#       24  ──┤  S6                  S7 ├── 25
#             └─────────────────────────┘
#
#                                NORTH
#            N1  N2  N3  N4  N5  N6* N7  N8  N9 N10 N11 N12
#          ┌────────────────────────────────────────────────┐
#       W1 │                                                │ E1
#       W2 │                                                │ E2
#       W3 │                                                │ E3
#       W4 │                     DIE                        │ E4
#       W5 │                   (2x2 mm)                     │ E5
#  W   W6* │                    48 Pads                     │ E6    E
#  E   W7# │                                                │ E7#   A
#  S    W8 │                                                │ E8    S
#  T    W9 │                                                │ E9    T
#      W10 │                                                │ E10
#      W11 │                                                │ E11
#      W12 │                                                │ E12
#          └────────────────────────────────────────────────┘
#            S1  S2  S3  S4  S5  S6  S7 S8  S9 S10 S11 S12
#                               SOUTH
# 
#                              Legend:
#           * VDD (3v3) : N6 (Pin 1), W6 (Pin 12)
#           # GND       : W7 (Pin 13), E7 (Pin 36)



#================== Pads definition ===================

#=========== North ===========
Pad:    io_i_bus_in_4       N               # N1
Pad:    io_i_bus_in_3       N               # N2
Pad:    io_i_bus_in_2       N               # N3
Pad:    io_i_bus_in_1       N               # N4
Pad:    io_i_bus_in_0       N               # N5
Pad:	PWR1				N VDD3ALLP      # N6
Pad:    io_i_cfg_top_0      N               # N7
Pad:    io_i_cfg_top_1      N               # N8
Pad:    io_i_cfg_top_2      N               # N9
Pad:    io_i_cfg_0          N               # N10
Pad:    io_i_cfg_1          N               # N11
Pad:    io_i_cfg_2          N               # N12

#=========== EAST ===========
Pad:    io_o_bus_out_13     E               # E1
Pad:    io_o_bus_out_12     E               # E2
Pad:    io_o_bus_out_11     E               # E3
Pad:    io_o_bus_out_10     E               # E4
Pad:	io_i_rst_n			E               # E5
Pad:	io_i_clk			E               # E6
Pad:	GND1				E GND3ALLP      # E7
Pad:    io_o_bus_out_9      E               # E8
Pad:    io_o_bus_out_8      E               # E9
Pad:    io_o_bus_out_7      E               # E10
Pad:    io_o_bus_out_6      E               # E11
Pad:    io_o_bus_out_5      E               # E12

#=========== SOUTH ===========
Pad:    io_i_bus_in_15      S               # S1
Pad:    io_i_bus_in_16      S               # S2
Pad:    io_i_bus_in_17      S               # S3
Pad:    io_i_bus_in_18      S               # S4
Pad:    io_i_bus_in_19      S               # S5
Pad:    io_i_bus_in_20      S               # S6
Pad:    io_i_bus_in_21      S               # S7
Pad:    io_o_bus_out_0      S               # S8
Pad:    io_o_bus_out_1      S               # S9
Pad:    io_o_bus_out_2      S               # S10
Pad:    io_o_bus_out_3      S               # S11
Pad:    io_o_bus_out_4      S               # S12

#=========== WEST ===========
Pad:    io_i_bus_in_5       W               # W1
Pad:    io_i_bus_in_6       W               # W2
Pad:    io_i_bus_in_7       W               # W3
Pad:    io_i_bus_in_8       W               # W4
Pad:    io_i_bus_in_9       W               # W5
Pad:	PWR2				W VDD3ALLP      # W6
Pad:	GND2				W GND3ALLP      # W7
Pad:    io_i_bus_in_10      W               # W8
Pad:    io_i_bus_in_11      W               # W9
Pad:    io_i_bus_in_12      W               # W10
Pad:    io_i_bus_in_13      W               # W11
Pad:    io_i_bus_in_14      W               # W12


#=========== Corner ===========
Pad:	io_CORNER0	NW CORNERP
Pad:	io_CORNER1	NE CORNERP
Pad:	io_CORNER2	SE CORNERP
Pad:	io_CORNER3	SW CORNERP

