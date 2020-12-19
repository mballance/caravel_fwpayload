'''
Created on Nov 22, 2020

@author: mballance
'''

class LaUtils(object):
    CLOCK_IDX      = 127
    RESET_IDX      = 126
    CORE_RESET_IDX = 125
    CLKDIV_IDX     = 120
    PC_IDX         = 0
    GPIO_IN_IDX    = 116
    GPIO_OUT_IDX   = 112
    
    WBA_ACK      = 54
    WBA_WE       = 53
    WBA_STB_CYC  = 52
    WBA_SEL      = 48
    WBA_ADR      = 32
    WBA_DAT      = 0
    
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
        print("--> set_high")
        await self.la_bfm.set_bits(LaUtils.RESET_IDX, 0, 1)
        print("<-- set_high")
        print("--> propagate")
        await self.la_bfm.propagate()
        print("<-- propagate")
        
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
        
    async def write(self, adr, dat, sel):
        
        await self.la_bfm.set_oen(LaUtils.WBA_ADR, 0, 0xFFFF)
        await self.la_bfm.set_oen(LaUtils.WBA_DAT, 0, 0xFFFFFFFF)
        await self.la_bfm.set_bits(LaUtils.WBA_ADR, adr, 0xFFFF)
        await self.la_bfm.set_bits(LaUtils.WBA_DAT, dat, 0xFFFFFFFF)
        await self.la_bfm.set_bits(LaUtils.WBA_SEL, sel, 0xF)
        await self.la_bfm.set_bits(LaUtils.WBA_WE, 1, 1)
        await self.la_bfm.set_bits(LaUtils.WBA_STB_CYC, 1, 1)
       
        while True:
            await self.clock_dut()
            if (self.la_bfm.in_data >> LaUtils.WBA_ACK) & 0x1:
                break
            
        await self.la_bfm.set_bits(LaUtils.WBA_WE, 0, 1)
        await self.la_bfm.set_bits(LaUtils.WBA_STB_CYC, 0, 1)
        await self.la_bfm.set_bits(LaUtils.WBA_DAT, 0, 0xFFFFFFFF)
        await self.la_bfm.set_bits(LaUtils.WBA_SEL, 0, 0xF)
        await self.clock_dut()
        
    async def read(self, adr):
        
        await self.la_bfm.set_oen(LaUtils.WBA_ADR, 0, 0xFFFF)
        await self.la_bfm.set_oen(LaUtils.WBA_DAT, 0, 0xFFFFFFFF)
        await self.la_bfm.set_bits(LaUtils.WBA_ADR, adr, 0xFFFF)
        await self.la_bfm.set_bits(LaUtils.WBA_WE, 0, 1)
        await self.la_bfm.set_bits(LaUtils.WBA_STB_CYC, 1, 1)
       
        while True:
            await self.clock_dut()
            if (self.la_bfm.in_data >> LaUtils.WBA_ACK) & 0x1:
                break
            
        dat = ((self.la_bfm.in_data >> LaUtils.WBA_DAT) & 0xFFFFFFFF)
        await self.la_bfm.set_bits(LaUtils.WBA_WE, 0, 1)
        await self.la_bfm.set_bits(LaUtils.WBA_STB_CYC, 0, 1)
        await self.clock_dut()
        
        return dat
        
        
