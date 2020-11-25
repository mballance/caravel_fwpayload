'''
Created on Nov 21, 2020

@author: mballance
'''
import cocotb
import wishbone_bfms
import pybfms
from wishbone_bfms.wb_initiator_bfm import WbInitiatorBfm
from logic_analyzer_bfms.la_initiator_bfm import LaInitiatorBfm


@cocotb.test()
async def test(root):
    await pybfms.init()
    u_wb : WbInitiatorBfm = pybfms.find_bfm(".*u_wb")
    u_la : LaInitiatorBfm = pybfms.find_bfm(".*u_la")
   
    print("--> u_la.set_bits")
    await u_la.set_bits(0, 0x55AAEEFF, 0xFFFFFFFF)
    print("<-- u_la.set_bits")
#    print("--> u_la.propagate")
#    await u_la.propagate()
#    print("<-- u_la.propagate")
    
    for i in range(10):
        await u_wb.write(0x0, 0x55aa+i, 0xF)
        dat = await u_wb.read(0x0)
        print("dat=" + hex(dat))
        

