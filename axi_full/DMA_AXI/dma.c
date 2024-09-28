#include "dma.h"

void dma(const uint32_t *src, uint32_t *dest, const uint32_t length){

	#pragma HLS INTERFACE mode=m_axi port=src bundle=gmem
	#pragma HLS INTERFACE mode=m_axi port=dest bundle=gmem

	#pragma HLS INTERFACE mode=s_axilite port=src bundle=control
	#pragma HLS INTERFACE mode=s_axilite port=dest bundle=control
    #pragma HLS INTERFACE mode=s_axilite port=length bundle=control
	#pragma HLS INTERFACE s_axilite port=return bundle=control

    #pragma HLS INTERFACE m_axi port = src offset = slave bundle = gmem max_read_burst_length = 256 max_write_burst_length = 256 depth = 2097152
	#pragma HLS INTERFACE m_axi port = dest offset = slave bundle = gmem max_read_burst_length = 256 max_write_burst_length = 256 depth = 2097152

	for (int i = 0; i < length; i++)
		dest[i] = src[i];

}
