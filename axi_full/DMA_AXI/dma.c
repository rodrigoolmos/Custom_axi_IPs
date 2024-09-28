#include "dma.h"

void dma(int32_t* a, const uint32_t src , const uint32_t dest, const uint32_t length){

	#pragma HLS INTERFACE mode=s_axilite port=length bundle=control
	#pragma HLS INTERFACE mode=s_axilite port=src bundle=control
	#pragma HLS INTERFACE mode=s_axilite port=dest bundle=control
	#pragma HLS INTERFACE s_axilite port=return bundle=control

    #pragma HLS INTERFACE m_axi port = a depth = 50

    uint32_t buff[256];
    uint32_t i; 

    memcpy(buff, a, 256 * sizeof(uint32_t));
    memcpy(a, buff, 256 * sizeof(uint32_t));

} 
