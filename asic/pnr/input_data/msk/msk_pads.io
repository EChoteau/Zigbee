######################################################
#  Encounter CORNER Pad placement file               #
######################################################

# Format
# Pad:	<pad_name>	<side> [<cell type>]

# Definition des pads North
Pad:	PWR1				N VDD3ALLP
Pad:	GND1				N GND3ALLP
Pad:	io_i_flag_enable		N
Pad:	io_i_enable_ech			N
Pad:	io_i_b_in			N
Pad:	io_i_clk			N
Pad:	io_i_rst_n			N
Pad:	PWR25				N VDD3ALLP
Pad:	GND26				N GND3ALLP
Pad:	GND43				E GND3ALLP*
Pad:	PWR44				E VDD3ALLP
Pad:	GND45				E GND3ALLP

# Definition des pads East
Pad:	PWR3				E VDD3ALLP
Pad:	GND3				E GND3ALLP
Pad:	io_o_I_BB_0			E
Pad:	io_o_I_BB_1			E
Pad:	io_o_I_BB_2			E
Pad:	io_o_I_BB_3			E
Pad:	io_o_I_BB_4			E
Pad:	io_o_I_BB_5			E
Pad:	PWR4				E VDD3ALLP
Pad:	GND4				E GND3ALLP*
Pad:	PWR41				E VDD3ALLP
Pad:	GND42				E GND3ALLP

# Definition des pads South
Pad:	PWR5				S VDD3ALLP
Pad:	io_o_Q_BB_0			S
Pad:	io_o_Q_BB_1			S
Pad:	io_o_Q_BB_2			S
Pad:	io_o_Q_BB_3			S
Pad:	io_o_Q_BB_4			S
Pad:	io_o_Q_BB_5			S
Pad:	GND5				S GND3ALLP
Pad:	PWR12				S VDD3ALLP
Pad:	GND13				S GND3ALLP
Pad:	PWR23				S VDD3ALLP
Pad:	GND14				S GND3ALLP

# Definition des pads West
Pad:	PWR6				W VDD3ALLP
Pad:	GND6				W GND3ALLP
Pad:	PWR10				W VDD3ALLP
Pad:	GND10				W GND3ALLP
Pad:	io_i_q_0			W
Pad:	io_i_q_1			W
Pad:	io_i_q_2			W
Pad:	io_i_q_3			W
Pad:	io_i_q_4			W
Pad:	io_i_q_5			W
Pad:	io_i_q_6			W
Pad:	io_i_q_7			W
Pad:	PWR11				W VDD3ALLP
Pad:	GND11				W GND3ALLP

# Definition des pads de Corner
Pad:	io_CORNER0	NW CORNERP
Pad:	io_CORNER1	NE CORNERP
Pad:	io_CORNER2	SE CORNERP
Pad:	io_CORNER3	SW CORNERP
