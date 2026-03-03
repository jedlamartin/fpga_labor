// ****************************************************************************
// GENERIC TEST BENCH TO TEST AXI4 STREAM INTERCONNECT
// ****************************************************************************
//
// SVN Revision Information:
// SVN $Revision: 38556 $
// SVN $Date: 2021-07-14 18:46:05 +0530 (Wed, 14 Jul 2021) $
//
// ****************************************************************************
`timescale 1 ns / 100 ps

module testbench;

//Below Parameter are used in testbench with their default values in the RTL, ARB_TYPE is changed to 1 (based on number of transfer)
//------------------------------------------------------//
  parameter         NUM_INITIATORS          = 2;  //Number of Initiators
  parameter         NUM_TARGETS             = 2;  //Number of Targets
  parameter [31:0]  NUM_TARGETS_WIDTH       = 1;  //Defines width for number of Target Ports(1 to 3)
  parameter [31:0]  TID_WIDTH               = 1;  //Target TID Width
  parameter [31:0]  ITID_WIDTH              = TID_WIDTH+$clog2(NUM_TARGETS);  //Initiator TID Width
  parameter [31:0]  TDEST_WIDTH             = 1;  //TDEST Width
  parameter [31:0]  AXI4S_TIxTDATA_BYTES    = 4;  //TDATA Bytes for Target Converter and Initiator Converter 
  parameter [31:0]  TDATA_BYTES             = 3;  //TDATA Bytes for Switch
  parameter [31:0]  TUSER_BITS_P_BYTE       = 1;  //TDATA Bytes
  parameter [0:0]   ARB_TYPE                = 1;  //Arbitration Type
  parameter [10:0]  NUM_ARB_TRANS           = 4;  //Number of Transfers for Arbitration
  parameter [0:0]   ENABLE_TIMEOUT          = 0;  //Enable TREADY Timeout
  parameter [10:0]  TIMEOUT_CYCLES          = 64; //Number of Timeout Cycles

  parameter [0:0]   ENABLE_TR0_FIFO         = 1;
  parameter [0:0]   ENABLE_TR1_FIFO         = 1;
  parameter [0:0]   ENABLE_IR0_FIFO         = 1;
  parameter [0:0]   ENABLE_IR1_FIFO         = 1;
  
  parameter [0:0]   TR0_ASYNC_FIFO          = 0; //Default value is 0
  parameter [0:0]   TR1_ASYNC_FIFO          = 0; //Default value is 0
  parameter [0:0]   IR0_ASYNC_FIFO          = 0; //Default value is 0
  parameter [0:0]   IR1_ASYNC_FIFO          = 0; //Default value is 0
  
  parameter [0:0]   TR0_PACKET_MODE         = 0; //Default value is 0
  parameter [0:0]   TR1_PACKET_MODE         = 0; //Default value is 0
  parameter [0:0]   IR0_PACKET_MODE         = 0; //Default value is 0
  parameter [0:0]   IR1_PACKET_MODE         = 0; //Default value is 0
	
  parameter [0:0]   AXI4S_TDWC_T0RS         = 1;
  parameter [0:0]   AXI4S_TDWC_T1RS         = 1;
  parameter [0:0]   AXI4S_TDWC_I0RS         = 1;
  parameter [0:0]   AXI4S_TDWC_I1RS         = 1;

  parameter [0:0]   AXI4S_IDWC_T0RS         = 1;
  parameter [0:0]   AXI4S_IDWC_T1RS         = 1;
  parameter [0:0]   AXI4S_IDWC_I0RS         = 1;
  parameter [0:0]   AXI4S_IDWC_I1RS         = 1;

  parameter [31:0]  TR0_LCM_TDATA_BYTES     = 12;
  parameter [31:0]  TR1_LCM_TDATA_BYTES     = 12;
                                        
  parameter [31:0]  IR0_LCM_TDATA_BYTES     = 12;
  parameter [31:0]  IR1_LCM_TDATA_BYTES     = 12;

  //------------------------------------------------------//

  parameter [31:0]  TDATA_WIDTH             = AXI4S_TIxTDATA_BYTES*8;                   // Defines TDATA port width for Target Converter and Initiator Converter
  parameter [31:0]  TUSER_WIDTH             = AXI4S_TIxTDATA_BYTES*TUSER_BITS_P_BYTE;   // Defines TUSER port width for Target Converter and Initiator Converter

  parameter DATA_WIDTH                      = 1 + TUSER_WIDTH + TID_WIDTH + TDEST_WIDTH + TDATA_WIDTH;
  parameter TOTAL_TEST_CASES                = 12;
  parameter SYSCLK_PERIOD                   = 2;// 500MHZ
  parameter T0CLK_PERIOD                    = 3;// 333MHZ
  parameter T1CLK_PERIOD                    = 4;// 250MHZ
  parameter I0CLK_PERIOD                    = 5;// 200MHZ
  parameter I1CLK_PERIOD                    = 6;// 166MHZ

  parameter RESET_PERIOD                    = 10;

    reg SYSCLK;
    reg NSYSRESET;
    reg T0CLK_S;
    reg T1CLK_S;
    reg I0CLK_S;
    reg I1CLK_S;

    wire T0CLK;
    wire T1CLK;
    wire I0CLK;
    wire I1CLK;

    // AXI4 Stream interface 0
    reg                                        AXI4S_T0TVALID;
    wire                                       AXI4S_T0TREADY;
    reg  [TDATA_WIDTH-1:0]                     AXI4S_T0TDATA;
    reg  [TDATA_WIDTH/8-1:0]                   AXI4S_T0TSTRB;
    reg  [TDATA_WIDTH/8-1:0]                   AXI4S_T0TKEEP;
    reg                                        AXI4S_T0TLAST;
    reg  [TID_WIDTH-1:0]                       AXI4S_T0TID;
    reg  [TDEST_WIDTH-1:0]                     AXI4S_T0TDEST;
    reg  [TUSER_WIDTH-1:0]                     AXI4S_T0TUSER;
                                               
    // AXI4 Stream interface 1                 
    reg                                        AXI4S_T1TVALID;
    wire                                       AXI4S_T1TREADY;
    reg  [TDATA_WIDTH-1:0]                     AXI4S_T1TDATA;
    reg  [TDATA_WIDTH/8-1:0]                   AXI4S_T1TSTRB;
    reg  [TDATA_WIDTH/8-1:0]                   AXI4S_T1TKEEP;
    reg                                        AXI4S_T1TLAST;
    reg  [TID_WIDTH-1:0]                       AXI4S_T1TID;
    reg  [TDEST_WIDTH-1:0]                     AXI4S_T1TDEST;
    reg  [TUSER_WIDTH-1:0]                     AXI4S_T1TUSER;

    //================================================= Initiator Port ==================================================//
    // AXI4 Stream interface 0
    wire                                       AXI4S_I0TVALID;
    reg                                        AXI4S_I0TREADY;
    wire [TDATA_WIDTH-1:0]                     AXI4S_I0TDATA;
    wire [TDATA_WIDTH/8-1:0]                   AXI4S_I0TSTRB;
    wire [TDATA_WIDTH/8-1:0]                   AXI4S_I0TKEEP;
    wire                                       AXI4S_I0TLAST;
    wire [TID_WIDTH+NUM_TARGETS_WIDTH-1:0]     AXI4S_I0TID;
    wire [TDEST_WIDTH-1:0]                     AXI4S_I0TDEST;
    wire [TUSER_WIDTH-1:0]                     AXI4S_I0TUSER;
                                               
    // AXI4 Stream interface 1                 
    wire                                       AXI4S_I1TVALID;
    reg                                        AXI4S_I1TREADY;
    wire [TDATA_WIDTH-1:0]                     AXI4S_I1TDATA;
    wire [TDATA_WIDTH/8-1:0]                   AXI4S_I1TSTRB;
    wire [TDATA_WIDTH/8-1:0]                   AXI4S_I1TKEEP;
    wire                                       AXI4S_I1TLAST;
    wire [TID_WIDTH+NUM_TARGETS_WIDTH-1:0]     AXI4S_I1TID;
    wire [TDEST_WIDTH-1:0]                     AXI4S_I1TDEST;
    wire [TUSER_WIDTH-1:0]                     AXI4S_I1TUSER;
                                               
    wire [NUM_TARGETS-1:0]                     DECODE_ERR;

initial
begin
    SYSCLK      = 1'b0;
    NSYSRESET   = 1'b0;
    T0CLK_S     = 1'b0;
    T1CLK_S     = 1'b0;
    I0CLK_S     = 1'b0;
    I1CLK_S     = 1'b0;
end

//////////////////////////////////////////////////////////////////////
// Reset Pulse
//////////////////////////////////////////////////////////////////////
initial
begin
    #(SYSCLK_PERIOD * (RESET_PERIOD + 0.5));
    NSYSRESET = 1'b1;
end

//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;

always @(T0CLK_S)
    #(T0CLK_PERIOD / 2.0) T0CLK_S <= !T0CLK_S;

    assign T0CLK = (ENABLE_TR0_FIFO & ~TR0_ASYNC_FIFO )? T0CLK_S : SYSCLK;

always @(T1CLK_S)
    #(T1CLK_PERIOD / 2.0) T1CLK_S <= !T1CLK_S;

    assign T1CLK = (ENABLE_TR1_FIFO & ~TR1_ASYNC_FIFO) ? T1CLK_S : SYSCLK;

always @(I0CLK_S)
    #(I0CLK_PERIOD / 2.0) I0CLK_S <= !I0CLK_S;

    assign I0CLK = (ENABLE_IR0_FIFO & ~IR0_ASYNC_FIFO) ? I0CLK_S : SYSCLK;

always @(I1CLK_S)
    #(I1CLK_PERIOD / 2.0) I1CLK_S <= !I1CLK_S;

    assign I1CLK = (ENABLE_IR1_FIFO & ~IR1_ASYNC_FIFO) ? I1CLK_S : SYSCLK;

//////////////////////////////////////////////////////////////////////
// Instantiated Unit Under Test:  CoreAXI4SInterconnect
//////////////////////////////////////////////////////////////////////
CoreAXI4SInterconnect #(
    .NUM_INITIATORS         (NUM_INITIATORS         ),
    .NUM_TARGETS            (NUM_TARGETS            ),
    .NUM_TARGETS_WIDTH      (NUM_TARGETS_WIDTH      ),

    .TID_WIDTH              (TID_WIDTH              ),
    .TDEST_WIDTH            (TDEST_WIDTH            ),
    .TDATA_BYTES            (TDATA_BYTES            ),
    .AXI4S_T0TDATA_BYTES    (AXI4S_TIxTDATA_BYTES   ),
    .AXI4S_T1TDATA_BYTES    (AXI4S_TIxTDATA_BYTES   ),
    .AXI4S_I0TDATA_BYTES    (AXI4S_TIxTDATA_BYTES   ),
    .AXI4S_I1TDATA_BYTES    (AXI4S_TIxTDATA_BYTES   ),
    .TUSER_BITS_P_BYTE      (TUSER_BITS_P_BYTE      ),
    
    .ARB_TYPE               (ARB_TYPE               ),
    .NUM_ARB_TRANS          (NUM_ARB_TRANS          ),
    .ENABLE_TR0_FIFO        (ENABLE_TR0_FIFO        ),
    .ENABLE_TR1_FIFO        (ENABLE_TR1_FIFO        ),
    .ENABLE_IR0_FIFO        (ENABLE_IR0_FIFO        ),
    .ENABLE_IR1_FIFO        (ENABLE_IR1_FIFO        ),
    .TR0_ASYNC_FIFO         (TR0_ASYNC_FIFO         ),
    .TR1_ASYNC_FIFO         (TR1_ASYNC_FIFO         ),
    .IR0_ASYNC_FIFO         (IR0_ASYNC_FIFO         ),
    .IR1_ASYNC_FIFO         (IR1_ASYNC_FIFO         ),

    .TR0_PACKET_MODE        (TR0_PACKET_MODE        ),
    .TR1_PACKET_MODE        (TR1_PACKET_MODE        ),
    .IR0_PACKET_MODE        (IR0_PACKET_MODE        ),
    .IR1_PACKET_MODE        (IR1_PACKET_MODE        ),

    .AXI4S_TDWC_T0RS        (AXI4S_TDWC_T0RS        ),
    .AXI4S_TDWC_T1RS        (AXI4S_TDWC_T1RS        ),
    .AXI4S_TDWC_I0RS        (AXI4S_TDWC_I0RS        ),
    .AXI4S_TDWC_I1RS        (AXI4S_TDWC_I1RS        ),

    .AXI4S_IDWC_T0RS        (AXI4S_IDWC_T0RS        ),
    .AXI4S_IDWC_T1RS        (AXI4S_IDWC_T1RS        ),
    .AXI4S_IDWC_I0RS        (AXI4S_IDWC_I0RS        ),
    .AXI4S_IDWC_I1RS        (AXI4S_IDWC_I1RS        ),

    .TR0_LCM_TDATA_BYTES    (TR0_LCM_TDATA_BYTES    ),
    .TR1_LCM_TDATA_BYTES    (TR1_LCM_TDATA_BYTES    ),
    .IR0_LCM_TDATA_BYTES    (IR0_LCM_TDATA_BYTES    ),
    .IR1_LCM_TDATA_BYTES    (IR1_LCM_TDATA_BYTES    )
)
CoreAXI4SInterconnect
(
  .ACLK                     (SYSCLK                 ),
  .RESETN                   (NSYSRESET              ),      // active low reset synchronize to RE AClk

  .AXI4S_T0CLK              (T0CLK                  ),
  .AXI4S_T1CLK              (T1CLK                  ),
  .AXI4S_T0RESETN           (NSYSRESET              ),
  .AXI4S_T1RESETN           (NSYSRESET              ),

  .AXI4S_I0CLK              (I0CLK                  ),
  .AXI4S_I1CLK              (I1CLK                  ),
  .AXI4S_I0RESETN           (NSYSRESET              ),
  .AXI4S_I1RESETN           (NSYSRESET              ),

  .AXI4S_T0TVALID           (AXI4S_T0TVALID         ),
  .AXI4S_T0TREADY           (AXI4S_T0TREADY         ),
  .AXI4S_T0TDATA            (AXI4S_T0TDATA          ),
  .AXI4S_T0TSTRB            (AXI4S_T0TSTRB          ),
  .AXI4S_T0TKEEP            (AXI4S_T0TKEEP          ),
  .AXI4S_T0TLAST            (AXI4S_T0TLAST          ),
  .AXI4S_T0TID              (AXI4S_T0TID            ),
  .AXI4S_T0TDEST            (AXI4S_T0TDEST          ),
  .AXI4S_T0TUSER            (AXI4S_T0TUSER          ),

  .AXI4S_T1TVALID           (AXI4S_T1TVALID         ),
  .AXI4S_T1TREADY           (AXI4S_T1TREADY         ),
  .AXI4S_T1TDATA            (AXI4S_T1TDATA          ),
  .AXI4S_T1TSTRB            (AXI4S_T1TSTRB          ),
  .AXI4S_T1TKEEP            (AXI4S_T1TKEEP          ),
  .AXI4S_T1TLAST            (AXI4S_T1TLAST          ),
  .AXI4S_T1TID              (AXI4S_T1TID            ),
  .AXI4S_T1TDEST            (AXI4S_T1TDEST          ),
  .AXI4S_T1TUSER            (AXI4S_T1TUSER          ),

  .AXI4S_I0TVALID           (AXI4S_I0TVALID         ),
  .AXI4S_I0TREADY           (AXI4S_I0TREADY         ),
  .AXI4S_I0TDATA            (AXI4S_I0TDATA          ),
  .AXI4S_I0TSTRB            (AXI4S_I0TSTRB          ),
  .AXI4S_I0TKEEP            (AXI4S_I0TKEEP          ),
  .AXI4S_I0TLAST            (AXI4S_I0TLAST          ),
  .AXI4S_I0TID              (AXI4S_I0TID            ),
  .AXI4S_I0TDEST            (AXI4S_I0TDEST          ),
  .AXI4S_I0TUSER            (AXI4S_I0TUSER          ),

  .AXI4S_I1TVALID           (AXI4S_I1TVALID         ),
  .AXI4S_I1TREADY           (AXI4S_I1TREADY         ),
  .AXI4S_I1TDATA            (AXI4S_I1TDATA          ),
  .AXI4S_I1TSTRB            (AXI4S_I1TSTRB          ),
  .AXI4S_I1TKEEP            (AXI4S_I1TKEEP          ),
  .AXI4S_I1TLAST            (AXI4S_I1TLAST          ),
  .AXI4S_I1TID              (AXI4S_I1TID            ),
  .AXI4S_I1TDEST            (AXI4S_I1TDEST          ),
  .AXI4S_I1TUSER            (AXI4S_I1TUSER          ),

  .DECODE_ERR               (DECODE_ERR             )
);

                                                           //TLAST_TUSER_TID_TDEST_TDATA
wire [DATA_WIDTH-1:0] AXI4S_T0ROM [0:TOTAL_TEST_CASES-1] = {{1'b0,4'h0,1'b0,1'b0,32'hA0B0E0F0},
                                                            {1'b0,4'h1,1'b0,1'b0,32'hA0B0E1F1},
                                                            {1'b1,4'h2,1'b0,1'b0,32'hA0B0E2F2},
                                                            {1'b0,4'h3,1'b0,1'b0,32'hA0B0E3F3},
                                                            {1'b0,4'h4,1'b0,1'b0,32'hA0B0E4F4},
                                                            {1'b1,4'h5,1'b0,1'b0,32'hA0B0E5F5},
                                                            {1'b0,4'h6,1'b0,1'b1,32'hA0B1E0F0},
                                                            {1'b0,4'h7,1'b0,1'b1,32'hA0B1E1F1},
                                                            {1'b1,4'h8,1'b0,1'b1,32'hA0B1E2F2},
                                                            {1'b0,4'h9,1'b0,1'b1,32'hA0B1E3F3},
                                                            {1'b0,4'ha,1'b0,1'b1,32'hA0B1E4F4},
                                                            {1'b1,4'hb,1'b0,1'b1,32'hA0B1E5F5}};

wire [DATA_WIDTH-1:0] AXI4S_T1ROM [0:TOTAL_TEST_CASES-1] = {{1'b0,4'h0,1'b1,1'b0,32'hC1D0E0F0},
                                                            {1'b0,4'h1,1'b1,1'b0,32'hC1D0E1F1},
                                                            {1'b0,4'h2,1'b1,1'b0,32'hC1D0E2F2},
                                                            {1'b0,4'h3,1'b1,1'b0,32'hC1D0E3F3},
                                                            {1'b0,4'h4,1'b1,1'b0,32'hC1D0E4F4},
                                                            {1'b1,4'h5,1'b1,1'b0,32'hC1D0E5F5},
                                                            {1'b0,4'h6,1'b1,1'b1,32'hC1D1E0F0},
                                                            {1'b0,4'h7,1'b1,1'b1,32'hC1D1E1F1},
                                                            {1'b0,4'h8,1'b1,1'b1,32'hC1D1E2F2},
                                                            {1'b0,4'h9,1'b1,1'b1,32'hC1D1E3F3},
                                                            {1'b0,4'ha,1'b1,1'b1,32'hC1D1E4F4},
                                                            {1'b1,4'hb,1'b1,1'b1,32'hC1D1E5F5}};

reg [DATA_WIDTH:0] AXI4S_T0I0RAM [0:TOTAL_TEST_CASES/2-1];
reg [DATA_WIDTH:0] AXI4S_T0I1RAM [0:TOTAL_TEST_CASES/2-1];
reg [DATA_WIDTH:0] AXI4S_T1I0RAM [0:TOTAL_TEST_CASES/2-1];
reg [DATA_WIDTH:0] AXI4S_T1I1RAM [0:TOTAL_TEST_CASES/2-1];

                                                              //TLAST_TUSER_TID_TDEST_TDATA
wire [DATA_WIDTH  :0] T0I0RAM_EXP [0:TOTAL_TEST_CASES/2-1] = {{1'b0,4'h0,2'b00,1'b0,32'hA0B0E0F0},
                                                              {1'b0,4'h1,2'b00,1'b0,32'hA0B0E1F1},
                                                              {1'b1,4'h2,2'b00,1'b0,32'hA0B0E2F2},
                                                              {1'b0,4'h3,2'b00,1'b0,32'hA0B0E3F3},
                                                              {1'b0,4'h4,2'b00,1'b0,32'hA0B0E4F4},
                                                              {1'b1,4'h5,2'b00,1'b0,32'hA0B0E5F5}};

wire [DATA_WIDTH  :0] T0I1RAM_EXP [0:TOTAL_TEST_CASES/2-1] = {{1'b0,4'h6,2'b00,1'b1,32'hA0B1E0F0},
                                                              {1'b0,4'h7,2'b00,1'b1,32'hA0B1E1F1},
                                                              {1'b1,4'h8,2'b00,1'b1,32'hA0B1E2F2},
                                                              {1'b0,4'h9,2'b00,1'b1,32'hA0B1E3F3},
                                                              {1'b0,4'ha,2'b00,1'b1,32'hA0B1E4F4},
                                                              {1'b1,4'hb,2'b00,1'b1,32'hA0B1E5F5}};

wire [DATA_WIDTH  :0] T1I0RAM_EXP [0:TOTAL_TEST_CASES/2-1] = {{1'b0,4'h0,2'b11,1'b0,32'hC1D0E0F0},
                                                              {1'b0,4'h1,2'b11,1'b0,32'hC1D0E1F1},
                                                              {1'b0,4'h2,2'b11,1'b0,32'hC1D0E2F2},
                                                              {1'b0,4'h3,2'b11,1'b0,32'hC1D0E3F3},
                                                              {1'b0,4'h4,2'b11,1'b0,32'hC1D0E4F4},
                                                              {1'b1,4'h5,2'b11,1'b0,32'hC1D0E5F5}};

wire [DATA_WIDTH  :0] T1I1RAM_EXP [0:TOTAL_TEST_CASES/2-1] = {{1'b0,4'h6,2'b11,1'b1,32'hC1D1E0F0},
                                                              {1'b0,4'h7,2'b11,1'b1,32'hC1D1E1F1},
                                                              {1'b0,4'h8,2'b11,1'b1,32'hC1D1E2F2},
                                                              {1'b0,4'h9,2'b11,1'b1,32'hC1D1E3F3},
                                                              {1'b0,4'ha,2'b11,1'b1,32'hC1D1E4F4},
                                                              {1'b1,4'hb,2'b11,1'b1,32'hC1D1E5F5}};

reg [TOTAL_TEST_CASES-1:0] T0I0_mas_addr;
wire T0I0_mas_tx = AXI4S_I0TVALID && AXI4S_I0TREADY && (~AXI4S_I0TID[1]) && (~AXI4S_I0TDEST) && (|(AXI4S_I0TSTRB)) && (|(AXI4S_I0TKEEP));
always@(negedge I0CLK or negedge NSYSRESET)
begin
    if (~NSYSRESET)
    begin
        AXI4S_T0I0RAM            <= {{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}}};
        T0I0_mas_addr            <= {(TOTAL_TEST_CASES){1'b0}};
    end
    else if (T0I0_mas_tx)
    begin
        AXI4S_T0I0RAM[T0I0_mas_addr] <= {AXI4S_I0TLAST, AXI4S_I0TUSER, AXI4S_I0TID, AXI4S_I0TDEST, AXI4S_I0TDATA};
        T0I0_mas_addr                <= T0I0_mas_addr + 1'b1;
    end
end

reg [TOTAL_TEST_CASES-1:0] T0I1_mas_addr;
wire T0I1_mas_tx = AXI4S_I1TVALID && AXI4S_I1TREADY && (~AXI4S_I1TID[1]) && (AXI4S_I1TDEST) && (|(AXI4S_I1TSTRB)) && (|(AXI4S_I1TKEEP));
always@(negedge I1CLK or negedge NSYSRESET)
begin
    if (~NSYSRESET)
    begin
        AXI4S_T0I1RAM            <= {{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}}};
        T0I1_mas_addr            <= {(TOTAL_TEST_CASES){1'b0}};
    end
    else if (T0I1_mas_tx)
    begin
        AXI4S_T0I1RAM[T0I1_mas_addr] <= {AXI4S_I1TLAST, AXI4S_I1TUSER, AXI4S_I1TID, AXI4S_I1TDEST, AXI4S_I1TDATA};
        T0I1_mas_addr                <= T0I1_mas_addr + 1'b1;
    end
end

reg [TOTAL_TEST_CASES-1:0] T1I0_mas_addr;
wire T1I0_mas_tx = AXI4S_I0TVALID && AXI4S_I0TREADY && (AXI4S_I0TID[1]) && (~AXI4S_I0TDEST) && (|(AXI4S_I0TSTRB)) && (|(AXI4S_I0TKEEP));
always@(negedge I0CLK or negedge NSYSRESET)
begin
    if (~NSYSRESET)
    begin
        AXI4S_T1I0RAM            <= {{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}}};
        T1I0_mas_addr            <= {(TOTAL_TEST_CASES){1'b0}};
    end
    else if (T1I0_mas_tx)
    begin
        AXI4S_T1I0RAM[T1I0_mas_addr] <= {AXI4S_I0TLAST, AXI4S_I0TUSER, AXI4S_I0TID, AXI4S_I0TDEST, AXI4S_I0TDATA};
        T1I0_mas_addr                <= T1I0_mas_addr + 1'b1;
    end
end

reg [TOTAL_TEST_CASES-1:0] T1I1_mas_addr;
wire T1I1_mas_tx = AXI4S_I1TVALID && AXI4S_I1TREADY && (AXI4S_I1TID[1]) && (AXI4S_I1TDEST) && (|(AXI4S_I1TSTRB)) && (|(AXI4S_I1TKEEP));
always@(negedge I1CLK or negedge NSYSRESET)
begin
    if (~NSYSRESET)
    begin
        AXI4S_T1I1RAM            <= {{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b0}}};
        T1I1_mas_addr            <= {(TOTAL_TEST_CASES){1'b0}};
    end
    else if (T1I1_mas_tx)
    begin
        AXI4S_T1I1RAM[T1I1_mas_addr] <= {AXI4S_I1TLAST, AXI4S_I1TUSER, AXI4S_I1TID, AXI4S_I1TDEST, AXI4S_I1TDATA};
        T1I1_mas_addr                <= T1I1_mas_addr + 1'b1;
    end
end

wire  [NUM_INITIATORS    -1:0]   MASx_TVALID = {AXI4S_I1TVALID,AXI4S_I0TVALID};

integer test_slv0_count = 0;
integer test_slv1_count = 0;
integer test_mas0_count = 0;
integer test_mas1_count = 0;
integer test_fail_count = 0;
integer test_pass_count = 0;
integer T0I0_ram_addr   = 0;
integer T0I1_ram_addr   = 0;
integer T1I0_ram_addr   = 0;
integer T1I1_ram_addr   = 0;

task reset_target0_inputs;
begin
    AXI4S_T0TVALID            = 1'b0;
    AXI4S_T0TDATA             = {(TDATA_WIDTH){1'b0}};
    AXI4S_T0TSTRB             = {TDATA_WIDTH/8{1'b0}};
    AXI4S_T0TKEEP             = {TDATA_WIDTH/8{1'b0}};
    AXI4S_T0TLAST             = 1'b0;
    AXI4S_T0TID               = {(TID_WIDTH){1'b0}};
    AXI4S_T0TDEST             = {(TDEST_WIDTH){1'b0}};
    AXI4S_T0TUSER             = {(TUSER_WIDTH){1'b0}};
end
endtask

task generate_target0_inputs;
begin
    AXI4S_T0TVALID            = 1'b1;
    AXI4S_T0TDATA             = AXI4S_T0ROM[test_slv0_count][TDATA_WIDTH-1:0];
    AXI4S_T0TSTRB             = {TDATA_WIDTH/8{1'b1}};
    AXI4S_T0TKEEP             = {TDATA_WIDTH/8{1'b1}};
    AXI4S_T0TLAST             = AXI4S_T0ROM[test_slv0_count][DATA_WIDTH-1];
    AXI4S_T0TID               = AXI4S_T0ROM[test_slv0_count][(TID_WIDTH + TDEST_WIDTH + TDATA_WIDTH) -1 : TDEST_WIDTH + TDATA_WIDTH];
    AXI4S_T0TDEST             = AXI4S_T0ROM[test_slv0_count][(TDEST_WIDTH + TDATA_WIDTH) -1 : TDATA_WIDTH];
    AXI4S_T0TUSER             = AXI4S_T0ROM[test_slv0_count][DATA_WIDTH-2 : TID_WIDTH + TDEST_WIDTH + TDATA_WIDTH];
end
endtask

task reset_target1_inputs;
begin
    AXI4S_T1TVALID            = 1'b0;
    AXI4S_T1TDATA             = {(TDATA_WIDTH){1'b0}};
    AXI4S_T1TSTRB             = {TDATA_WIDTH/8{1'b0}};
    AXI4S_T1TKEEP             = {TDATA_WIDTH/8{1'b0}};
    AXI4S_T1TLAST             = 1'b0;
    AXI4S_T1TID               = {(TID_WIDTH){1'b0}};
    AXI4S_T1TDEST             = {(TDEST_WIDTH){1'b0}};
    AXI4S_T1TUSER             = {(TUSER_WIDTH){1'b0}};
end
endtask

task generate_target1_inputs;
begin
    AXI4S_T1TVALID            = 1'b1;
    AXI4S_T1TDATA             = AXI4S_T1ROM[test_slv1_count][TDATA_WIDTH-1:0];
    AXI4S_T1TSTRB             = {TDATA_WIDTH/8{1'b1}};
    AXI4S_T1TKEEP             = {TDATA_WIDTH/8{1'b1}};
    AXI4S_T1TLAST             = AXI4S_T1ROM[test_slv1_count][DATA_WIDTH-1];
    AXI4S_T1TID               = AXI4S_T1ROM[test_slv1_count][(TID_WIDTH + TDEST_WIDTH + TDATA_WIDTH) -1 : TDEST_WIDTH + TDATA_WIDTH];
    AXI4S_T1TDEST             = AXI4S_T1ROM[test_slv1_count][(TDEST_WIDTH + TDATA_WIDTH) -1 : TDATA_WIDTH];
    AXI4S_T1TUSER             = AXI4S_T1ROM[test_slv1_count][DATA_WIDTH-2 : TID_WIDTH + TDEST_WIDTH + TDATA_WIDTH];
end
endtask

initial
begin
  test_slv0_count   = 0;
  test_slv1_count   = 0;
  test_mas0_count   = 0;
  test_mas1_count   = 0;
  test_fail_count   = 0;
  test_pass_count   = 0;
  T0I0_ram_addr     = 0;
  T0I1_ram_addr     = 0;
  T1I0_ram_addr     = 0;
  T1I1_ram_addr     = 0;
end

`define SYSTEM_RESET                                                                                        \
AXI4S_T0TVALID     = 'd0;  AXI4S_T0TDATA     = 'd0;  AXI4S_T0TSTRB      = 'd0; AXI4S_T0TKEEP      = 'd0;    \
AXI4S_T0TLAST      = 'd0;  AXI4S_T0TID       = 'd0;  AXI4S_T0TDEST      = 'd0; AXI4S_T0TUSER      = 'd0;    \
AXI4S_T1TVALID     = 'd0;  AXI4S_T1TDATA     = 'd0;  AXI4S_T1TSTRB      = 'd0; AXI4S_T1TKEEP      = 'd0;    \
AXI4S_T1TLAST      = 'd0;  AXI4S_T1TID       = 'd0;  AXI4S_T1TDEST      = 'd0; AXI4S_T1TUSER      = 'd0;    \
AXI4S_I0TREADY     = 1'b0; AXI4S_I1TREADY    = 1'b0; test_mas0_count    = 'd0; test_mas1_count    = 'd0;    \
test_slv0_count    = 'd0; test_slv1_count    = 'd0;  test_pass_count    = 'd0; test_fail_count    = 'd0;

`define CHECK_VALUE(SIGNAL,EXPECTED_VALUE)                                                                  \
if (SIGNAL != EXPECTED_VALUE) begin                                                                         \
  $display("ERROR: At %t %0s = %h ; expected value = %h ",$time, `"SIGNAL`", SIGNAL, EXPECTED_VALUE);       \
  test_fail_count = test_fail_count + 1;                                                                    \
end                                                                                                         \
else begin                                                                                                  \
  $display("PASS : At %t %0s = %h ;",$time,`"SIGNAL`",SIGNAL);                                              \
  test_pass_count = test_pass_count + 1;                                                                    \
end

`define SYSTEM_RESET_TEST                                                                                   \
`CHECK_VALUE(AXI4S_I0TVALID,1'b0)                                                                           \
`CHECK_VALUE(AXI4S_I1TVALID,1'b0)                                                                           \

always@(posedge T0CLK or negedge NSYSRESET)
begin
    if (~NSYSRESET) begin
        reset_target0_inputs;
        test_slv0_count = 0;
    end else begin
        if (test_slv0_count < TOTAL_TEST_CASES-1) begin
            if (AXI4S_T0TVALID && AXI4S_T0TREADY) begin
                test_slv0_count = test_slv0_count + 1'b1;
            end else begin
                test_slv0_count = test_slv0_count;
            end
            generate_target0_inputs;
        end else begin
            if (AXI4S_T0TVALID && AXI4S_T0TREADY) begin
                test_slv0_count = test_slv0_count + 1'b1;
                reset_target0_inputs;
            end else begin
                test_slv0_count = test_slv0_count;
            end
        end
    end
end

always@(posedge T1CLK or negedge NSYSRESET)
begin
    if (~NSYSRESET) begin
        reset_target1_inputs;
        test_slv1_count = 0;
    end else begin
        if (test_slv1_count < TOTAL_TEST_CASES-1) begin
            if (AXI4S_T1TVALID && AXI4S_T1TREADY) begin
                test_slv1_count = test_slv1_count + 1'b1;
            end else begin
                test_slv1_count = test_slv1_count;
            end
            generate_target1_inputs;
        end else begin
            if (AXI4S_T1TVALID && AXI4S_T1TREADY) begin
                test_slv1_count = test_slv1_count + 1'b1;
                reset_target1_inputs;
            end else begin
                test_slv1_count = test_slv1_count;
            end
        end
    end
end

always@(posedge I0CLK or negedge NSYSRESET)
begin
    if (~NSYSRESET) begin
        AXI4S_I0TREADY  <= 1'b0;
        test_mas0_count <= 0;
    end else begin
        if (test_mas0_count < TOTAL_TEST_CASES) begin
            AXI4S_I0TREADY  <= 1'b1;
            if (AXI4S_I0TVALID) begin
                test_mas0_count <= test_mas0_count + 1'b1;
            end else begin
                test_mas0_count <= test_mas0_count;
            end
        end
    end
end

always@(posedge I1CLK or negedge NSYSRESET)
begin
    if (~NSYSRESET) begin
        AXI4S_I1TREADY  <= 1'b0;
        test_mas1_count <= 0;
    end else begin
        if (test_mas1_count < TOTAL_TEST_CASES) begin
            AXI4S_I1TREADY  <= 1'b1;
            if (AXI4S_I1TVALID) begin
                test_mas1_count <= test_mas1_count + 1'b1;
            end else begin
                test_mas1_count <= test_mas1_count;
            end
        end
    end
end

initial begin
    $display("##*************************************************************##");
    $display("##********************* Testbench Started *********************##");
    $display("##*************************************************************##");
    #SYSCLK_PERIOD
    $display("##********************* System Reset Test *********************##");
    `SYSTEM_RESET
    #SYSCLK_PERIOD
    `SYSTEM_RESET_TEST
    wait(NSYSRESET);
    $display("##**************** System Reset Test completed ****************##");
    $display("##*************************************************************##");
    #SYSCLK_PERIOD

    wait(test_slv0_count == TOTAL_TEST_CASES);
    $display("##*************************************************************##");
    $display("##*********** Target 0 Input transactions completed ***********##");
    $display("##*************************************************************##");
    wait(test_slv1_count == TOTAL_TEST_CASES);
    $display("##*************************************************************##");
    $display("##*********** Target 1 Input transactions completed ***********##");
    $display("##*************************************************************##");
    wait(test_mas0_count == TOTAL_TEST_CASES);
    $display("##*************************************************************##");
    $display("##********* Initiator 0 output transactions completed *********##");
    $display("##*************************************************************##");
    wait(test_mas1_count == TOTAL_TEST_CASES);
    $display("##*************************************************************##");
    $display("##********* Initiator 1 output transactions completed *********##");
    $display("##*************************************************************##");
    reset_target0_inputs;
    reset_target1_inputs;

    repeat(TOTAL_TEST_CASES/2) @(posedge SYSCLK) begin
        `CHECK_VALUE(AXI4S_T0I0RAM[T0I0_ram_addr],T0I0RAM_EXP[T0I0_ram_addr]);
        T0I0_ram_addr = T0I0_ram_addr + 1;
    end
    repeat(TOTAL_TEST_CASES/2) @(posedge SYSCLK) begin
        `CHECK_VALUE(AXI4S_T0I1RAM[T0I1_ram_addr],T0I1RAM_EXP[T0I1_ram_addr]);
        T0I1_ram_addr = T0I1_ram_addr + 1;
    end
    repeat(TOTAL_TEST_CASES/2) @(posedge SYSCLK) begin
        `CHECK_VALUE(AXI4S_T1I0RAM[T1I0_ram_addr],T1I0RAM_EXP[T1I0_ram_addr]);
        T1I0_ram_addr = T1I0_ram_addr + 1;
    end
    repeat(TOTAL_TEST_CASES/2) @(posedge SYSCLK) begin
        `CHECK_VALUE(AXI4S_T1I1RAM[T1I1_ram_addr],T1I1RAM_EXP[T1I1_ram_addr]);
        T1I1_ram_addr = T1I1_ram_addr + 1;
    end

    $display("##*************************************************************##");
    if (test_fail_count > 0)
    $display("         || Verification Test Failed  :-(  ||            ");
    else
    $display("         || Verification Test Passed  :-)  ||            ");
    $display("##**** Passed Test = %d",test_pass_count);
    $display("##**** Failed Test = %d",test_fail_count);
    $display("##*************************************************************##");
    $display("##********************* Testbench completed *******************##");
    $display("##*************************************************************##");
  
    `SYSTEM_RESET
    $stop;
end

endmodule
