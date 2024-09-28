#include <stdio.h>
#include "xil_io.h"
#include "sleep.h"
#include "xil_io.h"

int main(){

	volatile uint32_t data;

	while(1){
		data = Xil_In32(0x10004);
		Xil_Out32(0x10000, data);
    }

    return 0;
}
