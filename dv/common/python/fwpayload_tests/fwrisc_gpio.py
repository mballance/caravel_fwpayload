'''
Created on Nov 22, 2020

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
    await la_utils.set_sys_reset(False)
    
    # Release the processor from reset
    await la_utils.set_core_reset(True)
    for i in range(10):
        await la_utils.reset_cycle_dut(10)
    await la_utils.set_core_reset(False)

    # Clock the system, while observing GPIO via the logic analyzer
    gpio_out_last = None
    for i in range(1000):
        await la_utils.clock_dut()
        gpio_out_new = la_utils.get_gpio_out()
        if gpio_out_last is None or gpio_out_new != gpio_out_last:
            print("New: " + hex(gpio_out_new))
            gpio_out_last = gpio_out_new
            if gpio_out_last == 0xF:
                break

    if gpio_out_last is None:
        raise cocotb.result.TestError("No gpio activity")


    if gpio_out_last != 0xF:
        raise cocotb.result.TestError("GPIO did something, but we didn't reach 0xF")
        