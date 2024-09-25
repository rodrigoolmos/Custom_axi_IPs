#include <stdio.h>
#include "xil_io.h"
#include "sleep.h"
#include "xil_io.h"

int main(){

    uint8_t string_tx[] = "Esto es una prueba de la uart 0123456789ABCDRF";
    uint8_t string_rx[40] = {0};
    uint32_t status;
    int var;

    // TX test
    // read control fifo rx should be empty
    status = Xil_In32(0x1000C);

    // read control fifo tx should be empty
    status = Xil_In32(0x10004);

    // full fifo TX (Esto es una prueba de la uart 012)
    for (var = 0; var < sizeof(string_tx); ++var) {
            Xil_Out32(0x10000, (uint32_t)string_tx[var]);
    }

    // read control fifo tx should be full
    status = Xil_In32(0x10004);

    usleep(100000);
    // test 1 by one fifo TX
    Xil_Out32(0x10000, (uint32_t)'R');
    usleep(100000);
    Xil_Out32(0x10000, (uint32_t)'O');
    usleep(100000);
    Xil_Out32(0x10000, (uint32_t)'D');
    usleep(100000);
    Xil_Out32(0x10000, (uint32_t)'R');
    usleep(100000);
    Xil_Out32(0x10000, (uint32_t)'I');
    usleep(100000);
    Xil_Out32(0x10000, (uint32_t)'R');
    usleep(100000);
    Xil_Out32(0x10000, (uint32_t)'G');
    usleep(100000);
    Xil_Out32(0x10000, (uint32_t)'O');
    usleep(100000);

    // full fifo TX (Esto es una prueba de la uart 012)
    for (var = 0; var < sizeof(string_tx); ++var) {
            Xil_Out32(0x10000, (uint32_t)string_tx[var]);
    }

    // RX test
    var = 0;
    // hterm send "Esto es una prueba de la uart 01"
    status = Xil_In32(0x1000C);

    while(!(Xil_In32(0x1000C) & 0x01)){
    	string_rx[var] = Xil_In32(0x10008);
    	var++;
    }

    // slow stop
    status = Xil_In32(0x1000C);
    string_rx[0] = Xil_In32(0x10008);
    status = Xil_In32(0x1000C);
    string_rx[0] = Xil_In32(0x10008);
    status = Xil_In32(0x1000C);
    string_rx[0] = Xil_In32(0x10008);
    status = Xil_In32(0x1000C);
    string_rx[0] = Xil_In32(0x10008);
    status = Xil_In32(0x1000C);
    string_rx[0] = Xil_In32(0x10008);

    status = Xil_In32(0x1000C);
    // hterm send "Esto no es una prueba de la uart"
    status = Xil_In32(0x1000C);
    var = 0;
    while(!(Xil_In32(0x1000C) & 0x01)){
    	string_rx[var] = Xil_In32(0x10008);
    	var++;
    }

    return 0;
}
