
+define+MINIMIZE_COMM

-f ${MEMORY_PRIMITIVES}/rtl/sim/sim.f

-f ${FWRISC}/rtl/fwrisc.f
+incdir+${FWRISC}/ve/fwrisc_tracer_bfm
${FWRISC}/ve/fwrisc_tracer_bfm/fwrisc_tracer_bfm.sv
-F ${FWRISC}/ve/fwrisc/tb/tb.F

// -f ${FWRISC}/ve/fwrisc/sim/scripts/vlog_hdl.f
// -f ${FWRISC}/ve/fwrisc/sim/scripts/vlog_hvl_ms.f

