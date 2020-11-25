'''
Created on Nov 22, 2020

@author: mballance
'''
import cocotb
import pybfms
from wishbone_bfms.wb_initiator_bfm import WbInitiatorBfm
from logic_analyzer_bfms.la_initiator_bfm import LaInitiatorBfm
from random import Random
from bringup_tests.la_utils import LaUtils

@cocotb.test()
async def test(top):
    """
    Hold the payload DUT in reset via the logic analyzer
    Meanwhile, test that the management interface can access memory
    """
    await pybfms.init()
    u_wb : WbInitiatorBfm = pybfms.find_bfm(".*u_wb")
    u_la : LaInitiatorBfm = pybfms.find_bfm(".*u_la")
    
    la_utils = LaUtils(u_la) 
    
    await la_utils.set_dut_clock_control(True)
    await la_utils.reset_cycle_dut(100)

    