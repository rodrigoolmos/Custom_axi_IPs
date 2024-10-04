This folder contains a base for the AXI Master Lite interface from which different IPs can be created. 
The folder also contains a testbench that consists of the interconnection of an AXI Master and an AXI Slave to test the traffic and ensure the correct functionality of the IP.
![BD test](bd.png)

```
Files:
    axi_lite.vhd =>  stuf for vhdl TB
    axi_lite_top.vhd => stuf for vhdl TB
    axi_master_interface_controller.vhd => it handels the axi protocol
    design_top.vhd => stuf for vhdl TB
    design_top_tb.vhd => stuf for vhdl TB
    master_axi_base_top.vhd => here you should put your logic
```
