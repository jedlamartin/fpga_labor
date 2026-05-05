#include "init.h"
#include "xaxidma.h"
#include "xinterrupt_wrap.h"

/* Static hardware instance */
static XAxiDma AxiDma;

/* Circular Buffer configuration variables */
static unsigned char *g_buff;
static unsigned long g_buff_size;
static unsigned long g_transfer_size;
static unsigned char *dma_ptr_axi; // Tracks where DMA is currently writing


extern "C" {
    /* Shared globals declared in init.h */
    unsigned char *dma_ptr_eth;    
    volatile uint8_t dma_data_available = 0;
    
    // The Interrupt Service Routine (ISR)
    void RxIntrHandler(void *Callback) {
        XAxiDma *AxiDmaInst = (XAxiDma *)Callback;
        
        // 1. Read and acknowledge interrupts
        u32 IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DEVICE_TO_DMA);
        XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DEVICE_TO_DMA);

        if (!(IrqStatus & XAXIDMA_IRQ_IOC_MASK)) return;

        // 2. Hand-off filled segment to the Ethernet task[cite: 17]
        dma_ptr_eth = dma_ptr_axi;
        dma_data_available = 1;

        // 3. Move AXI pointer to the next block in the circular buffer[cite: 17]
        dma_ptr_axi += g_transfer_size;
        if (dma_ptr_axi >= (g_buff + g_buff_size)) {
            dma_ptr_axi = g_buff; // Wrap around to start
        }

        // 4. Trigger next transfer immediately to prevent data loss[cite: 17]
        XAxiDma_SimpleTransfer(AxiDmaInst, (UINTPTR)dma_ptr_axi, g_transfer_size, XAXIDMA_DEVICE_TO_DMA);
    }

    int dma_it_init(unsigned char *buff, unsigned long buff_size, unsigned long transfer_size) {
        XAxiDma_Config *Config;
        int Status;

        g_buff = buff;
        g_buff_size = buff_size;
        g_transfer_size = transfer_size;
        dma_ptr_axi = g_buff;

        Config = XAxiDma_LookupConfig(XPAR_XAXIDMA_0_BASEADDR);
        if (!Config) return XST_FAILURE;

        Status = XAxiDma_CfgInitialize(&AxiDma, Config);
        if (Status != XST_SUCCESS) return Status;

        Status = XSetupInterruptSystem(&AxiDma, (void*)RxIntrHandler,
                               Config->IntrId[1], Config->IntrParent,
                               XINTERRUPT_DEFAULT_PRIORITY);
        if (Status != XST_SUCCESS) return Status;

        XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
        
        // Start the very first transfer[cite: 17]
        return XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)dma_ptr_axi, g_transfer_size, XAXIDMA_DEVICE_TO_DMA);
    }
}