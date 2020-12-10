'''
Created on Feb 1, 2020

@author: ballance
'''
import cocotb
from fwrisc_rv32i_tests.zephyr_tests import ZephyrTests
from cocotb.bfms import BfmMgr
from fwrisc_tracer_bfm.fwrisc_tracer_signal_bfm import FwriscTracerSignalBfm

class ZephyrSynchronizationTest(ZephyrTests):
    
    def __init__(self, tracer_bfm):
        super().__init__(tracer_bfm)
        self.threada_count = 0
        self.threadb_count = 0
        self.sync_limit = 32
        
    def configure_tracer(self):
        super().configure_tracer()
        if "trace_all" in cocotb.plusargs:
            self.tracer_bfm.set_trace_instr(1, 1, 1)
            self.tracer_bfm.set_trace_all_memwrite(1)
            self.tracer_bfm.set_trace_reg_writes(1)
#         self.tracer_bfm.set_trace_instr(1, 1, 1)
#         self.tracer_bfm.set_trace_all_memwrite(1)
#         self.tracer_bfm.set_trace_reg_writes(1)
        
    def console_line(self, line):
        super().console_line(line)
        
        if line == "threadA: Hello World from fwrisc_sim!":
            self.threada_count += 1
        if line == "threadB: Hello World from fwrisc_sim!":
            self.threadb_count += 1
            
        if self.threada_count >= self.sync_limit and self.threadb_count >= self.sync_limit:
            cocotb.log.info("threada_count=%d threadb_count=%d" % (self.threada_count, self.threadb_count))
            self.test_done_ev.set()
    
@cocotb.test()
def runtest(dut):
    use_tf_bfm = "use_sig_bfm" not in cocotb.plusargs
   
    if use_tf_bfm:
        tracer_bfm = BfmMgr.find_bfm(".*u_tracer")
    else:
        tracer_bfm = FwriscTracerSignalBfm(dut.u_dut.u_core.u_tracer)
        
    test = ZephyrSynchronizationTest(tracer_bfm)
    
    yield test.run()    
