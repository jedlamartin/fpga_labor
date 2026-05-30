module corei2c_wrapper
( 
    input        presetn, // APB active low asynchronous reset
    input        pclk,    // APB System Clock
    
    // Serial IF (Physical I2C Pins)
    inout        scl, 
    inout        sda,

    // APB Slave Interface
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
COREI2C_C0 ui2c0 (
    // Inputs
    .PCLK    (pclk),
    .PRESETN (presetn),
    .SCLI    (scli),
    .SDAI    (sdai),
    .PADDR   (paddr),
    .PSEL    (psel),
    .PENABLE (penable),
    .PWRITE  (pwrite),
    .PWDATA  (pwdata),
    
    // Outputs
    .SCLO    (sclo),
    .SDAO    (sdao),
    .INT     (int_out),
    .PRDATA  (prdata)
);

endmodule