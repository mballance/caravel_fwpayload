# FWPayload

FWPayload is a small processor+peripherals subsystem, targeting the user-project
area of Caraval.

## Block diagram
![FWPayload Block Diagram](doc/images/fwpayload_diagram.png)


## External IP
FWPayload uses several pieces of external IP. Some are bundled with the project,
and some are fetched during the initialization step.

### FWRISC
RISC-V core originally targeted for FPGA application
- Git: https://github.com/mballance/fwrisc.git
- License: Apache 2.0

### fw-wishbone-interconnect
Parameterized Wishbone interconnect
- Git: https://github.com/featherweight-ip/fw-wishbone-interconnect
- License: Apache 2.0

### simple_spi_master
SPI master IP, obtained from the Caravel repository. Bundled with the project.
- License: GNU LGPL

### simpleuart
UART IP, obtained from the Caravel repository. Bundled with the project.
- License: BSD-style


## Memory map

The FWPayload memory map is designed to fit within the 28-bit user-area
portion of the Caravel memory map. 

- *0xX000_0000..0xX000_03FF* - 1Kb register RAM
- *0xX100_0000..0xX100_00FF* - UART
- *0xX100_0100..0xX100_01FF* - SPI
- *0xX100_0200..0xX100_02FF* - GPIO

## Pin map

## Bring-up/Debug Support

FWPayload uses the Caravel logic analyzer to configure reset and clocking,
probe the program counter of the FWRISC, and optionally, single-step the clock.

- [127]   - Controls the clock when configured as an output
- [126]   - Controls the system reset when configured as an output
- [125]   - Controls the FWRISC core reset when configured as an output
- [39:36] - Loopback, probing the GPIO output
- [33]    - Loopback, probing UART tx output
- [32]    - Input, probing the 'instruction-complete' FWRISC net
- [31:0]  - Input, probing the FWRISC program-counter net

# Developer Notes

## Required Tools
- Python 3       (3.6.8 was used)
- Icarus Verilog (11.0 was used)
- Verilator      (4.102 was used)
- Openlane       (rc4 was used)
- Skywater PDK   (PDK_ROOT is assumed to be properly set)

## Project Setup
The FWPayload project uses IVPM (IP and Verification Package Manager) to manage
external IP and Python dependencies. The project can be setup both with and
without IVPM installed.

In both cases, setting up the project will result in creation of a `packages`
directory within the project that contains external IPs and required Python
packages.

### Setup with IVPM installed
Ensure IVPM is installed:

```
% pip3 install ivpm --user --upgrade
```

```
% cd <fwpayload_dir>
% ivpm update
```

### Setup without IVPM installed
The project can also be setup without installing IVPM. The `bootstrap.sh` 
script is provided for this purpose. `bootstrap.sh` clones a local 
copy of ivpm.

```
% cd <fwpayload_dir>
% ./bootstrap.sh
```


## Integration Testing


## Current Status
Openlane completes with the following status:

```
Number of pins violated: 479
Number of nets violated: 297
Total number of nets: 44367
[INFO]: Generating Final Summary Report...
[SUCCESS]: Flow Completed Without Fatal Errors.
```


