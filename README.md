# CPU Module

This Verilog file defines a CPU module. This module simulates a simple RISC-V based processor.

## Module Description

### Module Name

CPU

### Inputs

- `clk`: Clock signal
- `rst`: Reset signal
- `bellek_oku_veri`: Data read from memory
- `bellek_yaz_veri`: Data to be written to memory

### Outputs

- `bellek_adres`: Memory address
- `bellek_yaz`: Memory write signal

## File Information

### Author

[[CaganDurgun]](https://github.com/cagandurgun)

### Creation Date

26.05.2024 15:06:30

## Parameters

- `ADRES_BIT`: Number of memory address bits (default: 32)
- `VERI_BIT`: Number of memory data bits (default: 32)
- `YAZMAC_SAYISI`: Number of registers (default: 32)
- `BELLEK_ADRES`: Initial memory address (default: 32'h8000_0000)

## Design Description

This module simulates a RISC-V based processor. It performs memory operations and data processing based on the given instructions.

## Dependencies

There are no dependencies.

## Revision History

- **Revision 0.01**: File Created

## Additional Comments

There are no additional comments.
