# UART to AXI IP
This file contains an IP for a UART to AXI master.<br>
<br>
***MARK -> 99%***
Tested with TB and a Zynq with Vitis
<br>
### WRITE TO AXI EX

| ADDRESS       | R/W   | data UART TX                |
|---------------|--------|------------------------------|
| 32 bits       | 8 bits | 32 bits                     |
| 0xC0000000    | 0x00   | <span style="color: red;">0xDEADBEEF</span> |

### READ FROM AXI EX

| ADDRESS       | R/W   | data UART RX                |
|---------------|--------|------------------------------|
| 32 bits       | 8 bits | 32 bits                     |
| 0xC0000000    | 0x01   | <span style="color: blue;">0xDEADBEEF</span> |
