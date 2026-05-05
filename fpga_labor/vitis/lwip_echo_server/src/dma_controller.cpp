#include "init.h"
#include "xaxidma.h"
#include "xinterrupt_wrap.h"

/* Static variables internal to this file */
static XAxiDma AxiDma;
static unsigned char *g_buff;
static unsigned long g_buff_size;
static unsigned long g_transfer_size;
static unsigned char *dma_ptr_axi; // Points to the next free buffer for AXI to write in

/* Global variables shared with application.cpp via init.h */
unsigned char *dma_ptr_eth;           // Pointer for Ethernet to read from
volatile uint8_t dma_data_available = false;  // Flag: new data is ready for Ethernet

extern "C" {
    void RxIntrHandler(void *Callback) {
        XAxiDma *AxiDmaInst = (XAxiDma *)Callback;
        u32 IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DEVICE_TO_DMA);
        XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DEVICE_TO_DMA);

        if (!(IrqStatus & XAXIDMA_IRQ_IOC_MASK)) return;

        // 1. Update pointers: The block just filled is handed to Ethernet
        dma_ptr_eth = dma_ptr_axi;
        dma_data_available = true;

        // 2. Advance AXI pointer to the NEXT block in the circular buffer[cite: 17]
        dma_ptr_axi += g_transfer_size;
        if (dma_ptr_axi >= (g_buff + g_buff_size)) {
            dma_ptr_axi = g_buff; // Wrap around to the start
        }

        // 3. Start the next transfer immediately so no samples are lost[cite: 17]
        XAxiDma_SimpleTransfer(AxiDmaInst, (UINTPTR)dma_ptr_axi, g_transfer_size, XAXIDMA_DEVICE_TO_DMA);
    }

    int dma_it_init(unsigned char *buff, unsigned long buff_size, unsigned long transfer_size) {
        XAxiDma_Config *Config;
        
        // Correctly save the parameters provided by main[cite: 17]
        g_buff = buff;
        g_buff_size = buff_size;
        g_transfer_size = transfer_size;
        dma_ptr_axi = g_buff;

        Config = XAxiDma_LookupConfig(XPAR_XAXIDMA_0_BASEADDR);
        XAxiDma_CfgInitialize(&AxiDma, Config);

        // Use IntrId[1] for Receive (S2MM)[cite: 17]
        XSetupInterruptSystem(&AxiDma, (XInterruptHandler)RxIntrHandler,
                               Config->IntrId[1], Config->IntrParent,
                               XINTERRUPT_DEFAULT_PRIORITY);

        XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
        
        // Start the very first transfer[cite: 17]
        return XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)dma_ptr_axi, g_transfer_size, XAXIDMA_DEVICE_TO_DMA);
    }
}