;////////////////////////////////////////////////////
; MASK LAYER VERIFICATION IN VIRTUOSO
;////////////////////////////////////////////////////

; Configuration
let((outputRoot moduleName reportDir)
  
  ; Set module name from variable or default to "top"
  moduleName = getShellEnvVar("MODULE_NAME") || "top"
  outputRoot = sprintf("../output_data/%s" moduleName)
  reportDir = sprintf("%s/verification" outputRoot)
  libName = sprintf("%s_lib" moduleName)
  
  ; Create output directory
  system(sprintf("mkdir -p %s" reportDir))
  
  DEFINE SFCLIB_C35B4C0 $AMS_DIR/cds/HK_C35/SFCLIB_C35B4C0
  defin -def \"/tp/xph2app/xph2app110/Zigbee/asic/pnr/output_data/cordic_system/fab/cordic_system.def\" -lib libName -libPath /tp/xph2app/xph2app110/Zigbee/asic/pnr/work_virtuoso/libName -tech TECH_C35B4


)
