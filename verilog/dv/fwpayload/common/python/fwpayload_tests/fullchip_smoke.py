import cocotb


@cocotb.test()
async def test(top):
    print("test")
    await cocotb.triggers.Timer(10, "ms")
    
