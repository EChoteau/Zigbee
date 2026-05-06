######################################################
#  Encounter CORNER Pad placement file               #
######################################################
# Format
# Pad:	<pad_name>	<side> [<cell type>]

# Definition des pads North
Pad:	PWR1			N VDD3ALLP
Pad:	GND1			N GND3ALLP
Pad:	io_i_dphi_0		N
Pad:	io_i_dphi_1		N
Pad:	io_i_dphi_2		N
Pad:	io_i_dphi_3		N
Pad:	io_i_dphi_4		N
Pad:	io_i_dphi_5		N
Pad:	PWR2			N VDD3ALLP
Pad:	GND2			N GND3ALLP

# Definition des pads East
Pad:	PWR3			E VDD3ALLP
Pad:	GND3			E GND3ALLP
Pad:	io_i_clk		E
Pad:	io_i_rst_n		E
Pad:	PWR4			E VDD3ALLP
Pad:	GND4			E GND3ALLP

# Definition des pads South
Pad:	PWR5			S VDD3ALLP
Pad:	GND5			S GND3ALLP
Pad:	io_o_data		S
Pad:	io_o_enable		S
Pad:	PWR6			S VDD3ALLP
Pad:	GND6			S GND3ALLP

# Definition des pads West
Pad:	PWR7			W VDD3ALLP
Pad:	GND7			W GND3ALLP
Pad:	PWR8			W VDD3ALLP
Pad:	GND8			W GND3ALLP

# Definition des pads de Corner
Pad:	io_CORNER0		NW CORNERP
Pad:	io_CORNER1		NE CORNERP
Pad:	io_CORNER2		SE CORNERP
Pad:	io_CORNER3		SW CORNERP
