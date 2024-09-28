#include <stdio.h>
#include "xil_io.h"
#include "sleep.h"
#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"

#define MAX7219_REG_NOOP         0x00
#define MAX7219_REG_DIGIT0       0x01
#define MAX7219_REG_DIGIT1       0x02
#define MAX7219_REG_DIGIT2       0x03
#define MAX7219_REG_DIGIT3       0x04
#define MAX7219_REG_DIGIT4       0x05
#define MAX7219_REG_DIGIT5       0x06
#define MAX7219_REG_DIGIT6       0x07
#define MAX7219_REG_DIGIT7       0x08
#define MAX7219_REG_DECODEMODE   0x09
#define MAX7219_REG_INTENSITY    0x0A
#define MAX7219_REG_SCANLIMIT    0x0B
#define MAX7219_REG_SHUTDOWN     0x0C
#define MAX7219_REG_DISPLAYTEST  0x0F

// . -> 0x80
// A -> 0x40
// B -> 0x20
// .......
// G -> 0x01

#define SEG_0 0x7E  // 0b01111110 -> A, B, C, D, E, F encendidos (G apagado)
#define SEG_1 0x30  // 0b00110000 -> B, C encendidos
#define SEG_2 0x6D  // 0b01101101 -> A, B, D, E, G encendidos
#define SEG_3 0x79  // 0b01111001 -> A, B, C, D, G encendidos
#define SEG_4 0x33  // 0b00110011 -> B, C, F, G encendidos
#define SEG_5 0x5B  // 0b01011011 -> A, C, D, F, G encendidos
#define SEG_6 0x5F  // 0b01011111 -> A, C, D, E, F, G encendidos
#define SEG_7 0x70  // 0b01110000 -> A, B, C encendidos
#define SEG_8 0x7F  // 0b01111111 -> Todos los segmentos encendidos (A, B, C, D, E, F, G)
#define SEG_9 0x7B  // 0b01111011 -> A, B, C, D, F, G encendidos
#define SEG_A 0x77  // 0b01110111 -> A, B, C, E, F, G encendidos
#define SEG_B 0x1F  // 0b00011111 -> C, D, E, F, G encendidos
#define SEG_C 0x4E  // 0b01001110 -> A, D, E, F encendidos
#define SEG_D 0x3D  // 0b00111101 -> B, C, D, E, G encendidos
#define SEG_E 0x4F  // 0b01001111 -> A, D, E, F, G encendidos
#define SEG_F 0x47  // 0b01000111 -> A, E, F, G encendidos
#define SEG_DP 0x80 // 0b10000000 -> Solo el punto decimal encendido
#define SEG_t 0x0F
#define SEG_H 0x37
#define SEG_i 0x06
#define SEG_NULL 0x00
#define SEG_Q 0xFE
#define SEG_r 0x05
#define SEG_o 0x1D
#define SEG_U 0x3E

void wait_done(){
	uint32_t ready = 0;
	while((ready & 0x01) == 0){
		ready = Xil_In32(0x40000004);
	}
}

void max7219_init(){
    Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_SHUTDOWN << 8 | 0x01));
    wait_done();
    Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DECODEMODE << 8 | 0x00));
    wait_done();
    Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_SCANLIMIT << 8 | 0x07));
    wait_done();
    Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_INTENSITY << 8 | 0x08));
    wait_done();
    Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DISPLAYTEST << 8 | 0x00));
    wait_done();
}

int main()
{
    init_platform();

    max7219_init();
    while(1){
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT5  << 8 | SEG_H));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT4  << 8 | SEG_A));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT3  << 8 | SEG_D));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT2  << 8 | SEG_i));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT1  << 8 | SEG_t));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT0  << 8 | SEG_A));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT6  << 8 | SEG_NULL));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT7  << 8 | SEG_NULL));
        wait_done();
        sleep(1);
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT5  << 8 | SEG_t));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT4  << 8 | SEG_E));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT3  << 8 | SEG_NULL));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT2  << 8 | SEG_NULL));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT1  << 8 | SEG_NULL));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT0  << 8 | SEG_NULL));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT6  << 8 | SEG_NULL));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT7  << 8 | SEG_NULL));
        wait_done();
        sleep(1);
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT5  << 8 | SEG_Q));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT4  << 8 | SEG_U));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT3  << 8 | SEG_i));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT2  << 8 | SEG_E));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT1  << 8 | SEG_r));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT0  << 8 | SEG_o));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT6  << 8 | SEG_NULL));
        wait_done();
        Xil_Out32(0x40000000, (uint32_t)(MAX7219_REG_DIGIT7  << 8 | SEG_NULL));
        wait_done();
        sleep(1);
    }


    print("Suerte para leer esto\n\r");
    cleanup_platform();
    return 0;
}


