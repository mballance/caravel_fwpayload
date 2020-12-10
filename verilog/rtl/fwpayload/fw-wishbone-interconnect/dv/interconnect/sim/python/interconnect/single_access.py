'''
Created on Nov 27, 2020

@author: mballance
'''
import cocotb
import pybfms

class memory(object):
    
    def __init__(self):
        self.m = []
        self.m.append([0]*1024)
        self.m.append([0]*1024)
        self.m.append([0]*1024)
        self.m.append([0]*1024)
    
    def access(self, bfm, adr, we, sel, dat_w):
        idx = (adr & 0xF0000000) >> 28
        
        if idx > 0 and idx <= 4:
            idx -= 1
            w_adr = (adr & 0xFFF) >> 2
            print("idx=" + str(idx))
            dat_r = 0
            if we == 1:
                self.m[idx][w_adr] = dat_w
            else:
                dat_r = self.m[idx][w_adr]
            
            bfm.access_ack(dat_r, 0)
        else:
            print("Error: out-of-bounds access")
        pass

def wb_responder(bfm, adr, we, sel, dat_w):
    print("wb_responder: " + hex(adr))
    bfm.access_ack(0x55aaEEFF, 0)

@cocotb.test()
async def single_access(top):
    await pybfms.init()
    
    mem = memory()
    
    u_i0 = pybfms.find_bfm(".*u_init_0")
    u_i1 = pybfms.find_bfm(".*u_init_1")
    
    u_t0 = pybfms.find_bfm(".*u_target_0")
    u_t0.set_responder(mem.access)
    u_t1 = pybfms.find_bfm(".*u_target_1")
    u_t1.set_responder(mem.access)
    u_t2 = pybfms.find_bfm(".*u_target_2")
    u_t2.set_responder(mem.access)
    u_t3 = pybfms.find_bfm(".*u_target_3")
    u_t3.set_responder(mem.access)
   
    print("Hello from single_access")
    for init in range(2):
        for targ in range(4):
            for cnt in range(100):
                adr = (0x10000000*(targ+1))+(0x200*init)+(4*cnt)
                exp = (0x1000*init+0x100*targ)+cnt
                print("=> Write[" + hex(adr) + "] : init=" + str(init) + " targ=" + str(targ) + " cnt=" + str(cnt) + " adr=" + hex(adr) + " exp=" + hex(exp))
                await u_i0.write(adr, exp, 0xF)
                print("<= Write[" + hex(adr) + "] : init=" + str(init) + " targ=" + str(targ) + " cnt=" + str(cnt))
                
    for init in range(2):
        for targ in range(4):
            for cnt in range(100):
                adr = (0x10000000*(targ+1))+0x200*init+4*cnt
                data = await u_i0.read(adr)
                exp = (0x1000*init+0x100*targ)+cnt
                if data == exp:
                    print("PASS: init=" + str(init) + " targ=" + str(targ) + " cnt=" + str(cnt) + " exp=" + hex(exp))
                else:
                    print("FAIL: init=" + str(init) + " targ=" + str(targ) + 
                          " cnt=" + str(cnt) + " exp=" + hex(exp) + " data=" + hex(data))
        
    pass
