#include <stdio.h>
#include <stdlib.h>
#include "dma.h"

void fill_random(int *arr, int size) {
    for (int i = 0; i < size; i++) {
        arr[i] = rand();
    }
}

int verify_copy(int *src, int *dest, int size) {
    for (int i = 0; i < size; i++) {
        if (src[i] != dest[i]) {
            return 1;
        }
    }
    return 0;
}

int main() {
    int a[12345];
    int b[12345];
    int error = 0;
    int *null_ptr = (int *)0x000000;


    int test_sizes[] = {256, 1234, 7532, 4367, 123};
    int num_tests = sizeof(test_sizes) / sizeof(test_sizes[0]);

    for (int i = 0; i < num_tests; i++) {
        int size = test_sizes[i];
        fill_random(a, size);  
        dma(a, b, size);
        error |= verify_copy(a, b, size);
    }

    printf("Error = %i!\n", error);
    return 0;
}
