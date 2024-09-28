cmake_minimum_required(VERSION 3.10)
project(DMA)

# Define el ejecutable y los archivos fuente
add_executable(dma_tb tb.c dma.c)