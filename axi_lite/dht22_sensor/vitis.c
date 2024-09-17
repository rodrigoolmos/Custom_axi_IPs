#include <stdio.h>
#include "xil_io.h"
#include "sleep.h"
#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"

#define AXI_DHT22_BASE 0x43C00000

#define DHT22_REG0 0x0000
#define DHT22_REG1 0x0004
#define DHT22_REG2 0x0008
#define DHT22_REG3 0x000C

void start(){
	
	Xil_Out32(AXI_DHT22_BASE + DHT22_REG0, 0x1);
}

void reset(){
	
	Xil_Out32(AXI_DHT22_BASE + DHT22_REG0, 0x2);
}

void wait_done(){

	uint32_t done = 0;
	while(done != 0x4){
		done = 0x4 & Xil_In32(AXI_DHT22_BASE + DHT22_REG0);
	}
}

int main(){

	volatile uint8_t control;
	volatile uint16_t hum;
	volatile uint16_t temp;
	volatile uint16_t crc;

    init_platform();

	while(1){

		reset();
		start();

		wait_done();

		control = 0xF & Xil_In32(AXI_DHT22_BASE + DHT22_REG0);
		temp = 0xFFFF & Xil_In32(AXI_DHT22_BASE + DHT22_REG1);
		hum  = 0xFFFF & Xil_In32(AXI_DHT22_BASE + DHT22_REG2);
		crc  = 0xFFFF & Xil_In32(AXI_DHT22_BASE + DHT22_REG3);

		printf("Temperature %f, humidity %f\n\r", (float)temp/10, (float)hum/10);
		if(control & 0x8){
			print("Error measurement\n\r");
		}

		sleep(1);

    }

    cleanup_platform();
    return 0;
}
