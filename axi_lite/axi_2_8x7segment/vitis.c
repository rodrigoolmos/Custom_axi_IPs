#include <stdio.h>
#include "xil_io.h"
#include "sleep.h"
#include "xil_io.h"

#define NUM0 0xC0  // 0b11000000  -> NOT A, B, C, D, E, F
#define NUM1 0xF9  // 0b11111001  -> NOT B, C
#define NUM2 0xA4  // 0b10100100  -> NOT A, B, D, E, G
#define NUM3 0xB0  // 0b10110000  -> NOT A, B, C, D, G
#define NUM4 0x99  // 0b10011001  -> NOT B, C, F, G
#define NUM5 0x92  // 0b10010010  -> NOT A, C, D, F, G
#define NUM6 0x82  // 0b10000010  -> NOT A, C, D, E, F, G
#define NUM7 0xF8  // 0b11111000  -> NOT A, B, C
#define NUM8 0x80  // 0b00000000  -> NOT A, B, C, D, E, F, G
#define NUM9 0x98  // 0b01101111  -> NOT A, B, C, D, F, G

int main(){

	volatile uint32_t data;


	while(1){
		data = Xil_In32(0x80000004);
		Xil_Out32(0x80000004, 0x01010101);
		Xil_Out32(0x80000000, NUM4 << 24 | NUM5 << 16 | NUM6 << 8 | NUM7);
		Xil_Out32(0x8000000C, 0x01010101);
		Xil_Out32(0x80000008, NUM0 << 24 | NUM1 << 16 | NUM2 << 8 | NUM3);
		data = Xil_In32(0x80000000);
		Xil_Out32(0x80000004, 0x00000000);
		Xil_Out32(0x80000000, 0x01020304);
		Xil_Out32(0x80000000, 0x05060708);
		Xil_Out32(0x80000000, 0x090A0B0C);
		Xil_Out32(0x80000000, 0x0D0E0F00);
		Xil_Out32(0x8000000C, 0x00000000);
		Xil_Out32(0x80000008, 0x01020304);
		Xil_Out32(0x80000008, 0x05060708);
		Xil_Out32(0x80000008, 0x090A0B0C);
		Xil_Out32(0x80000008, 0x0D0E0F00);
		data = Xil_In32(0x80000000);
		data = Xil_In32(0x80000004);
		data = Xil_In32(0x80000008);
		data = Xil_In32(0x8000000C);
    }

    return 0;
}
