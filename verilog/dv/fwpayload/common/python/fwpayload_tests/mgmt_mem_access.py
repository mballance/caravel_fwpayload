'''
Created on Nov 28, 2020

@author: mballance
'''

import cocotb
import pybfms
from wishbone_bfms.wb_initiator_bfm import WbInitiatorBfm
from logic_analyzer_bfms.la_initiator_bfm import LaInitiatorBfm
from random import Random
from fwpayload_tests.la_utils import LaUtils

@cocotb.test()
async def test(top):
    """
    Hold the payload DUT in reset via the logic analyzer
    Meanwhile, test that the management interface can access memory
    """
    await pybfms.init()
    u_wb : WbInitiatorBfm = pybfms.find_bfm(".*u_wb")
    u_la : LaInitiatorBfm = pybfms.find_bfm(".*u_la")
    
    # Bring the system out of reset, while leaving the
    # FWRISC core in reset
    la_utils = LaUtils(u_la)
    await la_utils.reset_cycle_dut(100)
    await la_utils.set_dut_clock_control(False)
    
    # Test that we can write and read dut 'ROM'
    n_fails = 0
    r = Random(0)
    
    # First, do word accesses
    print("** Testing Word Accesses")
    wr_data = []
    for i in range(16):
        data = r.randint(0, 0xFFFFFFFF)
        print("Write: " + hex(0x30000000+4*i) + " = " + hex(data))
        await u_wb.write(0x30000000 + 4*i, data, 0xF)
        wr_data.append(data)
        print("wr_data[" + str(i) + "] = " + hex(wr_data[i]))
        
    for i in range(16):
        data = await u_wb.read(0x30000000 + 4*i)
        if wr_data[i] == data:
            print("PASS: " + hex(0x30000000+4*i))
        else:
            print("FAIL: " + hex(0x30000000+4*i) + " expect " + hex(wr_data[i]) + " receive " + hex(data))
            raise cocotb.result.TestError(
                "Addr: " + hex(0x30000000+4*i) + " expect " + hex(wr_data[i]) + " receive " + hex(data))
            n_fails += 1

    # First, do word accesses
    print("** Testing Half-word Accesses")
    wr_data = []
    for i in range(32):
        data = r.randint(0, 0xFFFF)
        wr_data.append(data)
        data <<= (16*(i%2))
        print("Write: " + hex(0x30000000+2*i) + " = " + hex(data))
        await u_wb.write(0x30000000 + 2*i, data, 
                         0x3 if (i%2) == 0 else 0xC)
        print("wr_data[" + str(i) + "] = " + hex(wr_data[i]))
        
    for i in range(32):
        data = await u_wb.read(0x30000000 + 2*i)
        if (i%2) != 0:
            data >>= 16
        data &= 0xFFFF
        if wr_data[i] == data:
            print("PASS: " + hex(0x30000000+2*i))
        else:
            print("FAIL: " + hex(0x30000000+2*i) + " expect " + hex(wr_data[i]) + " receive " + hex(data))
            raise cocotb.result.TestError(
                "Addr: " + hex(0x30000000+2*i) + " expect " + hex(wr_data[i]) + " receive " + hex(data))
            n_fails += 1

    # First, do word accesses
    print("** Testing Byte Accesses")
    wr_data = []
    for i in range(64):
        data = r.randint(0, 0xFF)
        wr_data.append(data)
        data <<= (8*(i%4))
        print("Write: " + hex(0x30000000+i) + " = " + hex(data))
        await u_wb.write(0x30000000 + i, data, (1 << (i%4)))
        print("wr_data[" + str(i) + "] = " + hex(wr_data[i]))
        
    for i in range(64):
        data = await u_wb.read(0x30000000 + i)
        data >>= (8*(i%4))
        data &= 0xFF
        if wr_data[i] == data:
            print("PASS: " + hex(0x30000000+i))
        else:
            print("FAIL: " + hex(0x30000000+i) + " expect " + hex(wr_data[i]) + " receive " + hex(data))
            raise cocotb.result.TestError(
                "Addr: " + hex(0x30000000+i) + " expect " + hex(wr_data[i]) + " receive " + hex(data))
            n_fails += 1

