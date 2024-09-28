#include <stdio.h>
#include "xil_io.h"
#include "sleep.h"
#include "xil_io.h"

// max 1 shot burst 1024

#define BURST_SIZE 512

int main(){


	int data_read;
	int i;
	int error = 0;

	// send data test
	for(i=0; i<BURST_SIZE; i++){
	    Xil_Out32(0xC0000000 + i*4, i);
	}

	Xil_Out32(0x10000 + 0x10, 0xC0000000); // set src addr
	Xil_Out32(0x10000 + 0x1C, 0xC0001000); // set dest addr
	Xil_Out32(0x10000 + 0x28, BURST_SIZE); // set size
	Xil_Out32(0x10000, 0xC0000001); // set launch

	while((Xil_In32(0x10000) & 0x2) == 0); // wait done

	// read data test
	for(i=0; i<BURST_SIZE; i++){
		data_read = Xil_In32(0xC0001000 + i*4);
		if(data_read != i)
			error = 1;
	}



    return 0;
}
