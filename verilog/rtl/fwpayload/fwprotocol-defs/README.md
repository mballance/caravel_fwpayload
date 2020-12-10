# Featherweight Protocol Definitions

The fwprotocol_defs project provides Verilog macros for declaring and connecting 
interfaces of various standard protocols.

A standard collection of macros is provided for each supported protocol:
- `PROTOCOL`_TARGET_PORT -- Declares the I/O signals for a target port
- `PROTOCOL`_INITIATOR_PORT -- Declares the I/O signals for an initiator port
- `PROTOCOL`_MONITOR_PORT -- Declares the I/O signals for 
- `PROTOCOL`_WIRES -- Declares wires for the protocol
- `PROTOCOL`_CONNECT -- Expands to the port-map statement used to connect wires to I/Os

Currently, the following protocols are supported:
- AXI4
- SDRAM


