# AXI to uart IP
This file contains a IP for an axi slave to uart.<br>
<br>
***MARK -> 99%***
Tested with TB and a zynq with vitis

´´´
### REGISTER MAP
|    OFSET     | Encabezado 2 |
|--------------|--------------|
| 0x00000      | GPIO OUT     |
| 0x00004      | GPIO IN      |

### GPIO OUT

| N to 0     | GPIO TO WRITE ON 1 OFF 0|
|------------|---------------|

### GPIO IN

| N to 0     | GPIO TO READ  ON 1 OFF 0|
|------------|----------------|

´´´
´´´
Files:
axi_2_gpio.vhd -> IP
vitis.c -> TB
´´´

<br>
