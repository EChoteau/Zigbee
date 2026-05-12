`include "tb/wrappers/demod/headers/demod_wrapper_debug_chain.svh"
`include "tb/wrappers/demod/headers/demod_wrapper_debug_demod.svh"
`include "tb/wrappers/demod/headers/demod_wrapper_debug_fir.svh"
`include "tb/wrappers/demod/headers/demod_wrapper_normal.svh"

task automatic run_demod_wrapper_test_plan();
begin

    test_demod_wrapper_debug_demod();
    apply_demod_reset(3);

    test_demod_wrapper_debug_fir();
    apply_demod_reset(3);

    test_demod_wrapper_debug_chain();
    apply_demod_reset(3);

    test_demod_wrapper_normal();
    apply_demod_reset(3);

    $display("\n========== ALL DEMOD WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask