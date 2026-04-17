######################################################
#  Encounter CORNER Pad placement file               #
######################################################

## Info
# DIL 48
# Square die 2mm x 2mm
# 23 pads by side
# 4 corner pads


#### Definition des pads North ####
Pad:	io_i_clk			N
Pad:	io_i_rst_n			N
Pad:	PWR1				N VDD3ALLP
Pad:	GND1				N GND3ALLP

# Free pads
Pad:	NC1				    N GND3ALLP
Pad:	NC2				    N GND3ALLP
Pad:	NC3				    N GND3ALLP
Pad:	NC4				    N GND3ALLP
Pad:	NC5				    N GND3ALLP
Pad:	NC6				    N GND3ALLP
Pad:	NC7				    N GND3ALLP
Pad:	NC8				    N GND3ALLP
Pad:	NC9				    N GND3ALLP
Pad:	NC10				N GND3ALLP
Pad:	NC11				N GND3ALLP
Pad:	NC12				N GND3ALLP
Pad:	NC13				N GND3ALLP
Pad:	NC14				N GND3ALLP
Pad:	NC15				N GND3ALLP
Pad:	NC16				N GND3ALLP
Pad:	NC17				N GND3ALLP
Pad:	NC18				N GND3ALLP
Pad:	NC19				N GND3ALLP


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
Pad:	io_i_pwdata_0		E
Pad:	io_i_pwdata_1		E
Pad:	io_i_pwdata_2		E
Pad:	io_i_pwdata_3		E
Pad:	io_i_pwdata_4		E
Pad:	io_i_pwdata_5		E
Pad:	io_i_pwdata_6		E
Pad:	io_i_pwdata_7		E

## Free pads
Pad:	NC20				E GND3ALLP
Pad:	NC21				E GND3ALLP
Pad:	NC22				E GND3ALLP
Pad:	NC23				E GND3ALLP


#### Definition des pads South ####
Pad:	PWR2				S VDD3ALLP
Pad:	GND2				S GND3ALLP

#APB signals output
Pad:	io_o_pready			S
Pad:	io_o_pslverr		S
Pad:	io_o_tx_valid		S
Pad:	io_o_prdata_0		S
Pad:	io_o_prdata_1		S
Pad:	io_o_prdata_2		S
Pad:	io_o_prdata_3		S
Pad:	io_o_prdata_4		S
Pad:	io_o_prdata_5		S
Pad:	io_o_prdata_6		S
Pad:	io_o_prdata_7		S

#Free pads
Pad:	NC24				S GND3ALLP
Pad:	NC25				S GND3ALLP
Pad:	NC26				S GND3ALLP
Pad:	NC27				S GND3ALLP
Pad:	NC28				S GND3ALLP
Pad:	NC29				S GND3ALLP
Pad:	NC30				S GND3ALLP
Pad:	NC31				S GND3ALLP
Pad:	NC32				S GND3ALLP
Pad:	NC33				S GND3ALLP




#### Definition des pads West ####
## Serial interface input (from CDR)
Pad:	io_i_serial_rx		    W
Pad:    io_i_cdr_sample_valid	W

## Serial interface output (to MODULATION)
Pad:	io_o_serial_tx		    W
Pad:	io_o_tx_sample_tick	    W

#Free pads
Pad:	NC34				W GND3ALLP
Pad:	NC35				W GND3ALLP
Pad:	NC36				W GND3ALLP
Pad:	NC37				W GND3ALLP
Pad:	NC38				W GND3ALLP
Pad:	NC39				W GND3ALLP
Pad:	NC40				W GND3ALLP
Pad:	NC41				W GND3ALLP
Pad:	NC42				W GND3ALLP
Pad:	NC43				W GND3ALLP
Pad:	NC44				W GND3ALLP
Pad:	NC45				W GND3ALLP
Pad:	NC46				W GND3ALLP
Pad:	NC47				W GND3ALLP
Pad:	NC48				W GND3ALLP
Pad:	NC49				W GND3ALLP
Pad:	NC50				W GND3ALLP
Pad:	NC51				W GND3ALLP
Pad:	NC52				W GND3ALLP


#### Definition des pads de Corner ####
Pad:	io_CORNER0	NW CORNERP
Pad:	io_CORNER1	NE CORNERP
Pad:	io_CORNER2	SE CORNERP
Pad:	io_CORNER3	SW CORNERP

