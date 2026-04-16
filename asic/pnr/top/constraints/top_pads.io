######################################################
#  Encounter CORNER Pad placement file               #
######################################################

# Format
# Pad:	<pad_name>	<side> [<cell type>]

# Definition des pads North
Pad:	io_i_phase_0			N
Pad:	io_i_phase_1			N
Pad:	io_i_phase_2			N
Pad:	io_i_phase_3			N
Pad:	io_i_phase_4			N
Pad:	io_i_phase_5			N
Pad:	io_i_phase_6			N
Pad:	io_i_phase_7			N

# Definition des pads East
Pad:	io_i_clk			E
Pad:	io_i_rst_n			E
Pad:	PWR1				E VDD3ALLP
Pad:	GND1				E GND3ALLP

# Definition des pads South
Pad:	io_o_phase_deriv_0		S
Pad:	io_o_phase_deriv_1		S
Pad:	io_o_phase_deriv_2		S
Pad:	io_o_phase_deriv_3		S
Pad:	io_o_phase_deriv_4		S
Pad:	io_o_phase_deriv_5		S
Pad:	io_o_phase_deriv_6		S
Pad:	io_o_phase_deriv_7		S

# Definition des pads West
Pad:	PWR2				W VDD3ALLP
Pad:	GND2				W GND3ALLP
Pad:	PWR3				W VDD3ALLP
Pad:	GND3				W GND3ALLP

# Definition des pads de Corner
Pad:	io_CORNER0	NW CORNERP
Pad:	io_CORNER1	NE CORNERP
Pad:	io_CORNER2	SE CORNERP
Pad:	io_CORNER3	SW CORNERP
