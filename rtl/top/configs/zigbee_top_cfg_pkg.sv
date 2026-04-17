package zigbee_top_cfg_pkg;

  typedef enum logic [1:0] {
    CFG_IF_ONLY     = 2'b00,
    CFG_MSK_ONLY    = 2'b01,
    CFG_CORDIC_ONLY = 2'b10,
    CFG_RSVD        = 2'b11
  } zigbee_cfg_mode_e;

endpackage
