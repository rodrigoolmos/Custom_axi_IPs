#include <stdio.h>
#include "xil_io.h"
#include "sleep.h"
#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"

int main()
{
    init_platform();
    char string_tx[] = "This is a test to see if my custom UART works "
            "let's hope it does, the text is very long to test the buffers "
            "but you are still going to add more things, of course, lots of words\n\r";
    char string_rx[33] = {0};
    int var;
    volatile char data;
    // wait for the RX buffer to be full

    Xil_Out32(0x41200004, 0x00000000);
    Xil_Out32(0x4120000C, 0xffffffff);

    for (var = 0; var < sizeof(string_tx); ++var) {
        Xil_Out32(0x40000000, (uint32_t)string_tx[var]);
        usleep(30000);
        data = Xil_In32(0x41200008);
        Xil_Out32(0x41200000, (uint32_t)data);
    }

    print("Write 32 chars\n\r");
    while(!(Xil_In32(0x4000000C) & 0x2));
    for (var = 0; var < 32; ++var) {
        string_rx[var] = Xil_In32(0x40000008);
    }
    printf("Data written: %s\n\r", string_rx);
    data = 0x1 & Xil_In32(0x4000000C);
    printf("Empty = %i\n\r", data);

    print("Write 32 chars\n\r");
    while(!(Xil_In32(0x4000000C) & 0x2));
    for (var = 0; var < 32; ++var) {
        string_rx[var] = Xil_In32(0x40000008);
    }
    printf("Data written: %s\n\r", string_rx);
    data = 0x1 & Xil_In32(0x4000000C);
    printf("Empty = %i\n\r", data);

    print("Press a key, I will see what you pressed 32 times\n\r");
    for (var = 0; var < 32; ++var) {

        usleep(400000);
        if(0x1 & Xil_In32(0x4000000C)){
            print("No button pressed\n\r");
            data = 0x1 & Xil_In32(0x4000000C);
            printf("Empty = %i\n\r", data);
        }
        else{
            data = 0x1 & Xil_In32(0x4000000C);
            printf("Empty = %i\n\r", data);
            data = Xil_In32(0x40000008);
            printf("Data written: %c\n\r", data);
        }

    }

    for (var = 0; var < sizeof(string_tx); ++var) {
        Xil_Out32(0x40000000, (uint32_t)string_tx[var]);
        while(Xil_In32(0x40000004) & 0x2);
    }

    for (var = 0; var < sizeof(string_tx); ++var) {
        Xil_Out32(0x40000000, (uint32_t)string_tx[var]);
        usleep(100000);
    }

    for (var = 0; var < sizeof(string_tx); ++var) {
        Xil_Out32(0x40000000, (uint32_t)string_tx[var]);
        while(Xil_In32(0x40000004) & 0x2);
    }

    print("Enter a number from 0 to 3 via UART and press a button to see it on the LEDs\n\r");
    while(1){

        if (Xil_In32(0x41200008)) {
            print("Button pressed, reading one data from the buffer every second\n\r");

            if(0x1 & Xil_In32(0x4000000C)){
                print("RX buffer empty\n\r");
            }else{
                data = Xil_In32(0x40000008);
                printf("Data read = %c\n\r", data);
                switch (data) {
                    case '0':
                        Xil_Out32(0x41200000, 0x1);
                        break;
                    case '1':
                        Xil_Out32(0x41200000, 0x2);
                        break;
                    case '2':
                        Xil_Out32(0x41200000, 0x4);
                        break;
                    case '3':
                        Xil_Out32(0x41200000, 0x8);
                        break;
                    default:
                    	print("Wrong key. Permitted keys [0, 1, 2, 3]\n\r");
                        break;

                }
            }

            sleep(1);
        }
        if(0x2 & Xil_In32(0x4000000C)){
            print("RX buffer Full, press a button\n\r");
            sleep(1);
        }
    }

    cleanup_platform();
    return 0;
}
