module corei2c_wrapper #(
    // Configuration Parameters from Handbook
    parameter OPERATING_MODE          = 0,    // 0: Full Master/Slave Tx/Rx 
    parameter BAUD_RATE_FIXED         = 0,    // 0: Use APB to set baud, 1: Fixed 
    parameter BAUD_RATE_VALUE         = 0,    // 0: PCLK/256 if fixed 
    parameter BCLK_ENABLED            = 0,    // 0: Use PCLK only, 1: Use BCLK pin 
    parameter GLITCHREG_NUM           = 3,    // 3-15: Spike suppression width 
    parameter SMB_EN                  = 0,    // 0: Standard I2C, 1: Enable SMBus 
    parameter IPMI_EN                 = 0,    // 0: Disable IPMI timeouts 
    parameter FREQUENCY               = 100,   // PCLK frequency in MHz 
    parameter FIXED_SLAVE0_ADDR_EN    = 0,    // 0: Programmable address 
    parameter FIXED_SLAVE0_ADDR_VALUE = 7'h0, // Hardcoded address 
    parameter I2C_NUM                 = 1     // Number of I2C channels
)( 
    input        presetn, // APB active low asynchronous reset
    input        pclk,    // APB System Clock
    input        bclk,    // Pulse for SCL speed control
    
    // Serial IF (Physical I2C Pins)
    inout        scl, 
    inout        sda,

    // Notation for Libero SmartDesign: <InterfaceType>:<InterfaceName>
    // APB:APBslave
    input        psel,    // APB Select
    input        penable, // APB Enable
    input        pwrite,  // APB Write/Read
    input  [8:0] paddr,   // APB address bus bits
    input  [7:0] pwdata,  // APB write data
    output [7:0] prdata,  // APB read data
    
    output       int_out  // Interrupt output
);

wire scli, sclo;
wire sdai, sdao;

// --- Bidirectional Open-Drain Logic ---
assign scl  = (sclo == 1'b0) ? 1'b0 : 1'bz;
assign scli = scl;

assign sda  = (sdao == 1'b0) ? 1'b0 : 1'bz;
assign sdai = sda;

// --- CoreI2C IP Instantiation ---
COREI2C_C0_COREI2C_C0_0_COREI2C #(
    .OPERATING_MODE           (OPERATING_MODE),
    .BAUD_RATE_FIXED          (BAUD_RATE_FIXED),
    .BAUD_RATE_VALUE          (BAUD_RATE_VALUE),
    .BCLK_ENABLED             (BCLK_ENABLED),
    .GLITCHREG_NUM            (GLITCHREG_NUM),
    .SMB_EN                   (SMB_EN),
    .IPMI_EN                  (IPMI_EN),
    .FREQUENCY                (FREQUENCY),
    .FIXED_SLAVE0_ADDR_EN     (FIXED_SLAVE0_ADDR_EN),
    .FIXED_SLAVE0_ADDR_VALUE  (FIXED_SLAVE0_ADDR_VALUE),
    .ADD_SLAVE1_ADDRESS_EN    (0), 
    .FIXED_SLAVE1_ADDR_EN     (0),
    .FIXED_SLAVE1_ADDR_VALUE  (0),
    .I2C_NUM                  (I2C_NUM)
) ui2c0 (
    .PCLK         (pclk),
    .PRESETN      (presetn),
    .BCLK         (bclk),
    .SCLI         (scli),
    .SDAI         (sdai),
    .SCLO         (sclo),
    .SDAO         (sdao),
    .INT          (int_out),
    .PWDATA       (pwdata),
    .PRDATA       (prdata),
    .PADDR        (paddr),
    .PSEL         (psel),
    .PENABLE      (penable),
    .PWRITE       (pwrite),
    .SMBALERT_NI  (1'b1),
    .SMBALERT_NO  (),
    .SMBA_INT     (),
    .SMBSUS_NI    (1'b1),
    .SMBSUS_NO    (),
    .SMBS_INT     ()
);

endmodule