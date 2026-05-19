package demod_pkg;

    // =========================================================================
    // DEMOD MODULE PARAMETERS
    // =========================================================================
    localparam int DATA_WIDTH     = 8;
    localparam int IQ_WIDTH       = 4;
    localparam int OUTPUT_WIDTH   = 14;

    // =========================================================================
    // DEMOD CONFIGURATION MODES
    // =========================================================================
    localparam logic [2:0] CFG_NORMAL         = 3'b000;  // Normal production mode
    localparam logic [2:0] CFG_DEBUG_DEMOD_I  = 3'b001;  // Debug demod I channel
    localparam logic [2:0] CFG_DEBUG_DEMOD_Q  = 3'b010;  // Debug demod Q channel
    localparam logic [2:0] CFG_DEBUG_FIR_I    = 3'b100;  // Debug FIR I filter
    localparam logic [2:0] CFG_DEBUG_FIR_Q    = 3'b101;  // Debug FIR Q filter
    localparam logic [2:0] CFG_DEBUG_FIRC_I   = 3'b110;  // Debug full chain I
    localparam logic [2:0] CFG_DEBUG_FIRC_Q   = 3'b111;  // Debug full chain Q

    // =========================================================================
    // BUS MAPPING (based on top_tb interface)
    // For DEMOD block testing via top_tb:
    //   IN[17:14]   = I sample (4-bit ADC input)
    //   IN[13:10]   = Q sample (4-bit ADC input)
    //   IN[9:2]     = Reserved/unused in DEMOD mode
    //   IN[1:0]     = Control signals
    //
    //   OUT[5:0]    = I channel output (6-bit)
    //   OUT[11:6]   = Q channel output (6-bit)
    //   OUT[13:12]  = Status flags
    // =========================================================================
    localparam int BUS_IN_WIDTH   = 22;
    localparam int BUS_OUT_WIDTH  = 14;

    // Bus input bit positions (I/Q channels)
    localparam int BUS_I_SAMPLE_MSB    = 17;
    localparam int BUS_I_SAMPLE_LSB    = 14;
    localparam int BUS_Q_SAMPLE_MSB    = 13;
    localparam int BUS_Q_SAMPLE_LSB    = 10;

    // Bus output bit positions (I/Q results and debug)
    localparam int BUS_OUT_I_MSB       = 5;
    localparam int BUS_OUT_I_LSB       = 0;
    localparam int BUS_OUT_Q_MSB       = 11;
    localparam int BUS_OUT_Q_LSB       = 6;
    localparam int BUS_OUT_STATUS_MSB  = 13;
    localparam int BUS_OUT_STATUS_LSB  = 12;

    // Timing parameters
    localparam int DEMOD_LATENCY       = 8;   // Cycles from I/Q input to output
    localparam int FIR_LATENCY         = 12;  // Cycles for FIR filter output
    localparam int CHAIN_LATENCY       = 15;  // Cycles for full chain processing

endpackage : demod_pkg
