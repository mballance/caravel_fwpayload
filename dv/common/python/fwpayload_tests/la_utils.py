'''
Created on Nov 22, 2020

@author: mballance
'''

class LaUtils(object):
    CLOCK_IDX      = 127
    RESET_IDX      = 126
    CORE_RESET_IDX = 125
    PC_IDX         = 0
    GPIO_OUT_IDX   = 36
    
    def __init__(self, la_bfm):
        self.la_bfm = la_bfm
        
    async def set_dut_clock_control(self, en):
        # First, set reset high and clock low
        await self.la_bfm.set_bits(LaUtils.RESET_IDX, 0, 1)
        await self.la_bfm.set_bits(LaUtils.CLOCK_IDX, 0, 1)
        
        if en:
            # Now, set output mode for these signals
            await self.la_bfm.set_oen(LaUtils.RESET_IDX, 0, 1)
            await self.la_bfm.set_oen(LaUtils.CLOCK_IDX, 0, 1)
        else:
            # Now, set input mode for these signals
            await self.la_bfm.set_oen(LaUtils.RESET_IDX, 1, 1)
            await self.la_bfm.set_oen(LaUtils.CLOCK_IDX, 1, 1)
        
    async def set_core_reset(self, en):
        if en:
            await self.la_bfm.set_bits(LaUtils.CORE_RESET_IDX, 0, 1)
        else:
            await self.la_bfm.set_bits(LaUtils.CORE_RESET_IDX, 1, 1)
            
    async def set_sys_reset(self, en):
        if en:
            await self.la_bfm.set_bits(LaUtils.RESET_IDX, 0, 1)
        else:
            await self.la_bfm.set_bits(LaUtils.RESET_IDX, 1, 1)
        
    async def reset_cycle_dut(self, cycles=10):
        # Set reset high
        await self.la_bfm.set_bits(LaUtils.RESET_IDX, 0, 1)
        await self.la_bfm.propagate()
        
        # Clock 
        for i in range(cycles):
            await self.clock_dut()
            
        # Set reset low
        await self.la_bfm.set_bits(LaUtils.RESET_IDX, 1, 1)
        await self.clock_dut()
        
    def get_gpio_out(self):
        return (self.la_bfm.in_data >> LaUtils.GPIO_OUT_IDX) & 0xF
        pass
        
    async def clock_dut(self):
        await self.la_bfm.set_bits(LaUtils.CLOCK_IDX, 1, 1)
        await self.la_bfm.propagate()
        await self.la_bfm.set_bits(LaUtils.CLOCK_IDX, 0, 1)
        await self.la_bfm.propagate()

        
        