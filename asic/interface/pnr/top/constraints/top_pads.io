######################################################
#  Encounter CORNER Pad placement file               #
######################################################

## Info
# DIL 48
# Square die 2mm x 2mm
# 23 pads by side
# 4 corner pads


#### Definition des pads North ####
#System signals
Pad:	io_i_clk			N
Pad:	io_i_rst_n			N

#Power and Ground
#Creat an isolation between clk and (power + signal pads)
Pad:	PWR1				N VDD3ALLP
Pad:	GND1				N GND3ALLP


#APB signals input
Pad:	io_i_pwdata_0		N
Pad:	io_i_pwdata_1		N
Pad:	io_i_pwdata_2		N
Pad:	io_i_pwdata_3		N
Pad:	io_i_pwdata_4		N
Pad:	io_i_pwdata_5		N
Pad:	io_i_pwdata_6		N
Pad:	io_i_pwdata_7		N


#### Definition des pads East ####
#APB signals input
Pad:	io_i_psel		    E
Pad:	io_i_penable		E
Pad:	io_i_pwrite			E
Pad:	io_i_paddr_0		E
Pad:	io_i_paddr_1		E
Pad:	io_i_paddr_2		E
Pad:	io_i_paddr_3		E
Pad:	io_i_paddr_4		E
Pad:	io_i_paddr_5		E
Pad:	io_i_paddr_6		E
Pad:	io_i_paddr_7		E


#### Definition des pads South ####
Pad:	PWR2				S VDD3ALLP
Pad:	GND2				S GND3ALLP

#APB signals output
Pad:	io_o_prdata_0		S
Pad:	io_o_prdata_1		S
Pad:	io_o_prdata_2		S
Pad:	io_o_prdata_3		S
Pad:	io_o_prdata_4		S
Pad:	io_o_prdata_5		S
Pad:	io_o_prdata_6		S
Pad:	io_o_prdata_7		S

# Free pads
Pad:     io_NC1GND		        S GND3ALLP
Pad:     io_NC2GND		        S GND3ALLP


#### Definition des pads West ####
## Serial interface input (from CDR)
Pad:	io_i_serial_rx		    W
Pad:    io_i_cdr_sample_valid	W

## Serial interface output (to MODULATION)
Pad:	io_o_serial_tx		    W
Pad:	io_o_tx_sample_tick	    W

#Free pads
Pad:     io_NC3GND		        W GND3ALLP
Pad:     io_NC3GND		        W GND3ALLP
Pad:     io_NC4GND		        W GND3ALLP
Pad:     io_NC5GND		        W GND3ALLP
Pad:     io_NC6GND		        W GND3ALLP

#APB signals output
Pad:	io_o_pready			    W
Pad:	io_o_pslverr		    W
Pad:	io_o_tx_valid		    W

#### Definition des pads de Corner ####
Pad:	io_CORNER0	NW CORNERP
Pad:	io_CORNER1	NE CORNERP
Pad:	io_CORNER2	SE CORNERP
Pad:	io_CORNER3	SW CORNERP

