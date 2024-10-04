#  uart to axi IP
This file contains a IP for a uart to axi master.<br>
<br>
***MARK -> 99%***
Tested with TB and a zynq with vitis
<br>
### WRITE TO AXI EX

| ADDRES    | W(0) | data uart tx |
|------------|---------------|------|
| 32 bits    | 8 bits| 32 bits |
| 0xC0000000    | 0x00 | <span style="color: red;">0xDEADBEEF</span> |

### READ FROM AXI EX

| ADDRES    | W(0) | data uart rx |
|------------|---------------|------|
| 32 bits    | 8 bits| 32 bits |
| 0xC0000000    | 0x00 | <span style="color: blue;">0xDEADBEEF</span> |