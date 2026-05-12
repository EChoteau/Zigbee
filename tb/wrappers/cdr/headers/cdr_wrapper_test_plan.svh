`include "tb/wrappers/cdr/headers/cdr_wrapper_debug_decision.svh"
`include "tb/wrappers/cdr/headers/cdr_wrapper_debug_lf.svh"
`include "tb/wrappers/cdr/headers/cdr_wrapper_debug_nco.svh"
`include "tb/wrappers/cdr/headers/cdr_wrapper_debug_pd.svh"
`include "tb/wrappers/cdr/headers/cdr_wrapper_normal.svh"

task automatic run_cdr_wrapper_test_plan();
begin

    test_cdr_wrapper_debug_decision();
    apply_reset(3);

    test_cdr_wrapper_debug_lf();
    apply_reset(3);

    test_cdr_wrapper_debug_nco();
    apply_reset(3);

    test_cdr_wrapper_debug_pd();
    apply_reset(3);

    test_cdr_wrapper_normal();
    apply_reset(3);

    $display("\n========== ALL CDR WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask