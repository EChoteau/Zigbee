######################################################
#  Encounter CORNER Pad placement file               #
######################################################

# Format
# Pad:	<pad_name>	<side> [<cell type>]

# Definition des pads North
Pad:	io_i_clk			N
Pad:	io_i_rst_n			N
Pad:	PWR1				N VDD3ALLP
Pad:	GND1				N GND3ALLP

# Definition des pads East
Pad:	io_i_phase_0			E
Pad:	io_i_phase_1			E
Pad:	io_i_phase_2			E
Pad:	io_i_phase_3			E
Pad:	io_i_phase_4			E
Pad:	io_i_phase_5			E
Pad:	io_i_phase_6			E
Pad:	io_i_phase_7			E

# Definition des pads South
Pad:	PWR2				S VDD3ALLP
Pad:	GND2				S GND3ALLP

# Definition des pads West
Pad:	PWR3				W VDD3ALLP
Pad:	io_o_phase_deriv_0		W
Pad:	io_o_phase_deriv_1		W
Pad:	io_o_phase_deriv_2		W
Pad:	io_o_phase_deriv_3		W
Pad:	io_o_phase_deriv_4		W
Pad:	io_o_phase_deriv_5		W
Pad:	io_o_phase_deriv_6		W
Pad:	io_o_phase_deriv_7		W
Pad:	GND3				W GND3ALLP

# Definition des pads de Corner
Pad:	io_CORNER0	NW CORNERP
Pad:	io_CORNER1	NE CORNERP
Pad:	io_CORNER2	SE CORNERP
Pad:	io_CORNER3	SW CORNERP
