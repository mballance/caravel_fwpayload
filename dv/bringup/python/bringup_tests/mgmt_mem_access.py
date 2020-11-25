'''
Created on Nov 22, 2020

@author: mballance
'''
import cocotb
import pybfms
from wishbone_bfms.wb_initiator_bfm import WbInitiatorBfm
from logic_analyzer_bfms.la_initiator_bfm import LaInitiatorBfm
from random import Random


@cocotb.test()
async def test(top):
    """
    Hold the payload DUT in reset via the logic analyzer
    Meanwhile, test that the management interface can access memory
    """
    await pybfms.init()
    u_wb : WbInitiatorBfm = pybfms.find_bfm(".*u_wb")
    u_la : LaInitiatorBfm = pybfms.find_bfm(".*u_la")
    
    # Test that we can write and read dut 'ROM'
    wr_data = []
    r = Random(0)
    for i in range(16):
        data = r.randint(0, 0xFFFFFFFF)
        print("Write: " + hex(0x80000000+4*i) + " = " + hex(data))
        await u_wb.write(0x80000000 + 4*i, data, 0xF)
        wr_data.append(data)
        print("wr_data[" + str(i) + "] = " + hex(wr_data[i]))
        
    for i in range(16):
        data = await u_wb.read(0x80000000 + 4*i)
        if wr_data[i] == data:
            print("PASS: " + hex(0x80000000+4*i))
        else:
            print("FAIL: " + hex(0x80000000+4*i) + " expect " + hex(wr_data[i]) + " receive " + hex(data))
            
