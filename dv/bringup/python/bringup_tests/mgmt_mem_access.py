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
    print("--> pybfms.init()")
    await pybfms.init()
    print("<-- pybfms.init()")
    u_wb : WbInitiatorBfm = pybfms.find_bfm(".*u_wb")
    u_la : LaInitiatorBfm = pybfms.find_bfm(".*u_la")
    
    print("u_wb=" + str(u_wb))
    print("u_la=" + str(u_la))
    
    # Bring the system out of reset
    la_utils = LaUtils(u_la)
    print("--> reset_cycle_dut")
    await la_utils.reset_cycle_dut(100)
    print("<-- reset_cycle_dut")
    await la_utils.set_dut_clock_control(False)
    
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

    # Load a short program that toggles the GPIO lines
    gpio_toggle_program = [
        0x010000b7,
        0x20008093,
        0x00000113,
        0x0020a023,
        0x00110113,
        0xff9ff06f,
        0x00000000]
    
    for i,data in enumerate(gpio_toggle_program):
        print("Write: " + hex(0x30000000+4*i) + " " + hex(data))
        await u_wb.write(0x30000000+4*i, data, 0xF)

    # Take back clock control    
    await la_utils.set_dut_clock_control(True)
    
    # Release the processor from reset
    await la_utils.set_core_reset(True)
    for i in range(10):
        await u_la.propagate()
    await la_utils.set_core_reset(False)

    for i in range(1000):
        await la_utils.clock_dut()

        