# AXI to GPIO IP
This file contains a IP for an axi slave to GPIO.<br>
<br>

### IP:
![IP](IP.png)

***MARK -> 99%***
Tested with TB and a zynq with vitis

### REGISTER MAP
|    OFSET     | USE |
|--------------|--------------|
| 0x00000      | GPIO OUT     |
| 0x00004      | GPIO IN      |

### GPIO OUT

| bits N to 0     | GPIO TO WRITE ON 1 OFF 0|
|------------|---------------|

### GPIO IN

| bits N to 0     | GPIO TO READ  ON 1 OFF 0|
|------------|----------------|

```
Files:
axi_2_gpio.vhd -> IP
vitis.c -> TB
```

<br>
