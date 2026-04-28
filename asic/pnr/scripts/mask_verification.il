;////////////////////////////////////////////////////
; MASK LAYER VERIFICATION IN VIRTUOSO
;////////////////////////////////////////////////////

; Configuration
let((outputRoot moduleName reportDir)
  
  ; Set module name from variable or default to "top"
  moduleName = getShellEnvVar("MODULE_NAME") || "top"
  outputRoot = sprintf("../output_data/%s" moduleName)
  reportDir = sprintf("%s/verification" outputRoot)
  
  ; Create output directory
  system(sprintf("mkdir -p %s" reportDir))
  
  printf("=== Opening GDSII file for mask verification ===\n")
  
  ; Open the GDSII file
  dbOpenCellViewByType(
    sprintf("%s/%s" outputRoot moduleName) 
    "layout" 
    "maskLayoutOut"
    "gds"
    "r"
  )
  
  ; Get the active cell view
  let((cv))
    cv = geGetEditCellView()
    
    if(cv then
      (
        printf("=== Running DRC (Design Rule Check) ===\n")
        
        ; Run DRC verification
        drcRunCheck(
          cv
          list(
            list("drcWindow" nil)
            list("resultsWindow" nil)
          )
        )
        
        printf("=== Running LVS (Layout vs Schematic) ===\n")
        
        ; Run LVS verification
        lvsRun(
          cv
          list(
            list("lvsMaskDBFileView" "layout")
          )
        )
        
        printf("=== Generating DRC Report ===\n")
        drcGenerateReport(
          cv
          sprintf("%s/%s_drc.rpt" reportDir moduleName)
        )
        
        printf("=== Generating LVS Report ===\n")
        lvsGenerateReport(
          cv
          sprintf("%s/%s_lvs.rpt" reportDir moduleName)
        )
        
        printf("=== Mask verification completed ===\n")
        printf("Reports saved to: %s\n" reportDir)
      )
      (
        printf("ERROR: Could not open cell view for verification\n")
      )
    )
  )
)
