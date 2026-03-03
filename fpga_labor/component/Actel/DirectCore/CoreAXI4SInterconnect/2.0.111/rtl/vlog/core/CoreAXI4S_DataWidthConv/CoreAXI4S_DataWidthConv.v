// *********************************************************************/
// Copyright (c) 2015 Microsemi Corporation.  All rights reserved.
//
// Any use or redistribution in part or in whole must be handled in
// accordance with the Actel license agreement and must be approved
// in advance in writing.
//
// File: COREAXI4S_DATAWIDTHCONV.v
//
// SVN Revision Information:
// SVN $Revision: 40494 $
// SVN $Date: 2022-04-22 20:31:25 +0530 (Fri, 22 Apr 2022) $
//
// Description: AXI4 Stream data width converter module perform Upsizing
// and Downsizing of TDATA signal
//
// Notes:
// *********************************************************************/
`timescale 1ns / 1ns

module COREAXI4S_DATAWIDTHCONV
    #(
    // -------------------------------------------
    // PARAMETER Declaration
    // -------------------------------------------
    parameter integer FAMILY                   = 19,

    parameter integer AXI4S_TTDATA_BYTES       = 3,                   // Defines Target TDATA port width        (1 to 512 Bytes)
    parameter integer AXI4S_ITDATA_BYTES       = 4,                   // Defines Initiator TDATA port width     (1 to 512 Bytes)
    parameter integer LCM_TDATA_BYTES          = 12,                  // Defines LCM TDATA width                (1 to 261632 Bytes)

    parameter integer AXI4S_TTDATA_WIDTH       = 24,                  // Defines Target TDATA port width        (8 to 4096)
    parameter integer AXI4S_ITDATA_WIDTH       = 32,                  // Defines Initiator TDATA port width     (8 to 4096)

    parameter integer TUSER_BITS_P_BYTE        = 1,                   // Defines TUSER port bits per TDATA byte (1 to 2048)
    parameter integer AXI4S_TTUSER_WIDTH       = 3,                   // Defines Target TUSER port width        (1 to 512 Bytes)
    parameter integer AXI4S_ITUSER_WIDTH       = 4,                   // Defines Initiator TUSER port width     (1 to 512 Bytes)

    parameter integer TID_WIDTH                = 1,                   // Defines TID port width                 (1 to 32)
    parameter integer TDEST_WIDTH              = 1,                   // Defines TDEST port width               (1 to 32)

    parameter integer ENABLE_TUSER             = 1,                   // Enable TUSER                           (0 , 1)
    parameter integer ENABLE_TID               = 1,                   // Enable TID                             (0 , 1)
    parameter integer ENABLE_TDEST             = 1,                   // Enable TDEST                           (0 , 1)
    parameter integer ENABLE_TSTRB             = 1,                   // Enable TSTRB                           (0 , 1)
    parameter integer ENABLE_TKEEP             = 1,                   // Enable TKEEP                           (0 , 1)
    parameter integer ENABLE_TLAST             = 1,                   // Enable TLAST                           (0 , 1)

    parameter [0:0]   AXI4S_TRS                = 0,                   // Target Port Register Slice             (0 , 1)
    parameter [0:0]   AXI4S_IRS                = 0                    // Initiator Port Register Slice          (0 , 1)
    )
    (
    //================================================= Global Signals  ==============================================//
    input  wire                                ACLK,
    input  wire                                RESETN,                // active low reset

    //================================================= Target Port ==================================================//
    // AXI4 Stream interface
    input  wire                                AXI4S_TTVALID,
    output wire                                AXI4S_TTREADY,
    input  wire [AXI4S_TTDATA_WIDTH-1:0]       AXI4S_TTDATA,
    input  wire [AXI4S_TTDATA_WIDTH/8-1:0]     AXI4S_TTSTRB,
    input  wire [AXI4S_TTDATA_WIDTH/8-1:0]     AXI4S_TTKEEP,
    input  wire                                AXI4S_TTLAST,
    input  wire [TID_WIDTH-1:0]                AXI4S_TTID,
    input  wire [TDEST_WIDTH-1:0]              AXI4S_TTDEST,
    input  wire [AXI4S_TTUSER_WIDTH-1:0]       AXI4S_TTUSER,

    //================================================= Initiator Port ==================================================//
    // AXI4 Stream interface
    output wire                                AXI4S_ITVALID,
    input  wire                                AXI4S_ITREADY,
    output wire [AXI4S_ITDATA_WIDTH-1:0]       AXI4S_ITDATA,
    output wire [AXI4S_ITDATA_WIDTH/8-1:0]     AXI4S_ITSTRB,
    output wire [AXI4S_ITDATA_WIDTH/8-1:0]     AXI4S_ITKEEP,
    output wire                                AXI4S_ITLAST,
    output wire [TID_WIDTH-1:0]                AXI4S_ITID,
    output wire [TDEST_WIDTH-1:0]              AXI4S_ITDEST,
    output wire [AXI4S_ITUSER_WIDTH-1:0]       AXI4S_ITUSER
    );

localparam integer INTEGER_SIZE = 32;
localparam integer BYTE_SIZE    = 8;
localparam TREADY_DEFAULT_VALUE = 1'b1;
localparam TLAST_DEFAULT_VALUE  = 1'b1;

localparam SYNC_RESET           = (FAMILY == 25) ? 1 : 0;

wire                              w_axi4s_ttvalid;
wire                              w_axi4s_ttready; 
wire [(AXI4S_TTDATA_WIDTH)-1:0]   w_axi4s_ttdata;
wire [(AXI4S_TTDATA_WIDTH/8)-1:0] w_axi4s_ttstrb; 
wire [(AXI4S_TTDATA_WIDTH/8)-1:0] w_axi4s_ttkeep;
wire                              w_axi4s_ttlast;
wire [(TID_WIDTH)-1:0]            w_axi4s_ttid;
wire [(TDEST_WIDTH)-1:0]          w_axi4s_ttdest;
wire [(AXI4S_TTUSER_WIDTH)-1:0]   w_axi4s_ttuser;

wire                              r_axi4s_ttvalid;
wire                              r_axi4s_ttready; 
wire [(AXI4S_TTDATA_WIDTH)-1:0]   r_axi4s_ttdata;
wire [(AXI4S_TTDATA_WIDTH/8)-1:0] r_axi4s_ttstrb; 
wire [(AXI4S_TTDATA_WIDTH/8)-1:0] r_axi4s_ttkeep;
wire                              r_axi4s_ttlast;
wire [(TID_WIDTH)-1:0]            r_axi4s_ttid;
wire [(TDEST_WIDTH)-1:0]          r_axi4s_ttdest;
wire [(AXI4S_TTUSER_WIDTH)-1:0]   r_axi4s_ttuser;

caxi4s_dwc_RegisterSlice
#(
.SYNC_RESET       (SYNC_RESET          ),
.ENABLE_RS        (AXI4S_TRS           ),
.TID_WIDTH        (TID_WIDTH           ),
.TDEST_WIDTH      (TDEST_WIDTH         ),
.TDATA_WIDTH      (AXI4S_TTDATA_WIDTH  ),
.TUSER_WIDTH      (AXI4S_TTUSER_WIDTH  )
)
caxi4s_dwc_RegisterSlice_ip_inst
(
//==============================================  Global Signals  ===============================================//
.aclk             (ACLK                ),
.resetn           (RESETN              ),

//================================================= Input Port ==================================================//
.src_tvalid       (w_axi4s_ttvalid     ),
.src_tready       (w_axi4s_ttready     ),
.src_tdata        (w_axi4s_ttdata      ),
.src_tstrb        (w_axi4s_ttstrb      ),
.src_tkeep        (w_axi4s_ttkeep      ),
.src_tlast        (w_axi4s_ttlast      ),
.src_tid          (w_axi4s_ttid        ),
.src_tdest        (w_axi4s_ttdest      ),
.src_tuser        (w_axi4s_ttuser      ),

//================================================= Output Port =================================================//
.dst_tvalid       (r_axi4s_ttvalid     ),
.dst_tready       (r_axi4s_ttready     ),
.dst_tdata        (r_axi4s_ttdata      ),
.dst_tstrb        (r_axi4s_ttstrb      ), 
.dst_tkeep        (r_axi4s_ttkeep      ),
.dst_tlast        (r_axi4s_ttlast      ),
.dst_tid          (r_axi4s_ttid        ),
.dst_tdest        (r_axi4s_ttdest      ),
.dst_tuser        (r_axi4s_ttuser      )
);

wire                              w_axi4s_itvalid; 
wire                              w_axi4s_itready; 
wire [(AXI4S_ITDATA_WIDTH)-1:0]   w_axi4s_itdata;
wire [(AXI4S_ITDATA_WIDTH/8)-1:0] w_axi4s_itstrb;
wire [(AXI4S_ITDATA_WIDTH/8)-1:0] w_axi4s_itkeep;
wire                              w_axi4s_itlast;
wire [(TID_WIDTH)-1:0]            w_axi4s_itid;
wire [(TDEST_WIDTH)-1:0]          w_axi4s_itdest;
wire [(AXI4S_ITUSER_WIDTH)-1:0]   w_axi4s_ituser;

wire                              r_axi4s_itvalid; 
wire                              r_axi4s_itready; 
wire [(AXI4S_ITDATA_WIDTH)-1:0]   r_axi4s_itdata;
wire [(AXI4S_ITDATA_WIDTH/8)-1:0] r_axi4s_itstrb;
wire [(AXI4S_ITDATA_WIDTH/8)-1:0] r_axi4s_itkeep;
wire                              r_axi4s_itlast;
wire [(TID_WIDTH)-1:0]            r_axi4s_itid;
wire [(TDEST_WIDTH)-1:0]          r_axi4s_itdest;
wire [(AXI4S_ITUSER_WIDTH)-1:0]   r_axi4s_ituser;

caxi4s_dwc_RegisterSlice
#(
.SYNC_RESET       (SYNC_RESET          ),
.ENABLE_RS        (AXI4S_IRS           ),
.TID_WIDTH        (TID_WIDTH           ),
.TDEST_WIDTH      (TDEST_WIDTH         ),
.TDATA_WIDTH      (AXI4S_ITDATA_WIDTH  ),
.TUSER_WIDTH      (AXI4S_ITUSER_WIDTH  )
)
caxi4s_dwc_RegisterSlice_op_inst
(
//==============================================  Global Signals  ===============================================//
.aclk             (ACLK                ),
.resetn           (RESETN              ),

//================================================= Input Port ==================================================//
.src_tvalid       (w_axi4s_itvalid     ),
.src_tready       (w_axi4s_itready     ),
.src_tdata        (w_axi4s_itdata      ),
.src_tstrb        (w_axi4s_itstrb      ),
.src_tkeep        (w_axi4s_itkeep      ),
.src_tlast        (w_axi4s_itlast      ),
.src_tid          (w_axi4s_itid        ),
.src_tdest        (w_axi4s_itdest      ),
.src_tuser        (w_axi4s_ituser      ),

//================================================= Output Port =================================================//
.dst_tvalid       (r_axi4s_itvalid     ),
.dst_tready       (r_axi4s_itready     ),
.dst_tdata        (r_axi4s_itdata      ),
.dst_tstrb        (r_axi4s_itstrb      ),
.dst_tkeep        (r_axi4s_itkeep      ),
.dst_tlast        (r_axi4s_itlast      ),
.dst_tid          (r_axi4s_itid        ),
.dst_tdest        (r_axi4s_itdest      ),
.dst_tuser        (r_axi4s_ituser      )
);

assign w_axi4s_ttvalid = AXI4S_TTVALID;
assign w_axi4s_ttdata  = AXI4S_TTDATA;
assign r_axi4s_itready = AXI4S_ITREADY;

generate
    if (ENABLE_TSTRB) begin
        assign w_axi4s_ttstrb = AXI4S_TTSTRB;
    end
    else begin
        assign w_axi4s_ttstrb = {(AXI4S_TTDATA_WIDTH/8){1'b1}};
    end
endgenerate

generate
    if (ENABLE_TKEEP) begin
        assign w_axi4s_ttkeep = AXI4S_TTKEEP;
    end
    else begin
        assign w_axi4s_ttkeep = {(AXI4S_TTDATA_WIDTH/8){1'b1}};
    end
endgenerate

generate
    if (ENABLE_TUSER) begin
        assign w_axi4s_ttuser = AXI4S_TTUSER;
    end
    else begin
        assign w_axi4s_ttuser = {(AXI4S_TTUSER_WIDTH){1'b0}};
    end
endgenerate

generate
    if (ENABLE_TLAST) begin
        assign w_axi4s_ttlast = AXI4S_TTLAST;
    end
    else begin
        assign w_axi4s_ttlast = TLAST_DEFAULT_VALUE;
    end
endgenerate

generate
    if (ENABLE_TID) begin
        assign w_axi4s_ttid   = AXI4S_TTID;
    end
    else begin
        assign w_axi4s_ttid   = {(TID_WIDTH){1'b0}};
    end
endgenerate

generate
    if (ENABLE_TDEST) begin
        assign w_axi4s_ttdest = AXI4S_TTDEST;
    end
    else begin
        assign w_axi4s_ttdest = {(TDEST_WIDTH){1'b0}};
    end
endgenerate


assign AXI4S_TTREADY = w_axi4s_ttready;

assign AXI4S_ITVALID = r_axi4s_itvalid;
assign AXI4S_ITDATA  = r_axi4s_itdata;
assign AXI4S_ITSTRB  = r_axi4s_itstrb;
assign AXI4S_ITKEEP  = r_axi4s_itkeep;
assign AXI4S_ITLAST  = r_axi4s_itlast;
assign AXI4S_ITID    = r_axi4s_itid;
assign AXI4S_ITDEST  = r_axi4s_itdest;
assign AXI4S_ITUSER  = r_axi4s_ituser;

caxi4s_dwc_CustomSizer
#(
.SYNC_RESET       (SYNC_RESET          ),
.BYTE_SIZE        (BYTE_SIZE           ),
.TID_WIDTH        (TID_WIDTH           ),
.TDEST_WIDTH      (TDEST_WIDTH         ),
.TUSER_BITS_P_BYTE(TUSER_BITS_P_BYTE   ),
.LCM_TDATA_BYTES  (LCM_TDATA_BYTES     ),
.SRC_TDATA_BYTES  (AXI4S_TTDATA_BYTES  ),
.SRC_TDATA_WIDTH  (AXI4S_TTDATA_WIDTH  ),
.SRC_TUSER_WIDTH  (AXI4S_TTUSER_WIDTH  ),
.DST_TDATA_BYTES  (AXI4S_ITDATA_BYTES  ),
.DST_TDATA_WIDTH  (AXI4S_ITDATA_WIDTH  ),
.DST_TUSER_WIDTH  (AXI4S_ITUSER_WIDTH  )
)
caxi4s_dwc_CustomSizer_inst
(
//==============================================  Global Signals  ===============================================//
.aclk             (ACLK                ),
.resetn           (RESETN              ),

//================================================= Input Port ==================================================//
.src_tvalid       (r_axi4s_ttvalid     ),
.src_tready       (r_axi4s_ttready     ),
.src_tdata        (r_axi4s_ttdata      ),
.src_tstrb        (r_axi4s_ttstrb      ),
.src_tkeep        (r_axi4s_ttkeep      ),
.src_tlast        (r_axi4s_ttlast      ),
.src_tid          (r_axi4s_ttid        ),
.src_tdest        (r_axi4s_ttdest      ),
.src_tuser        (r_axi4s_ttuser      ),

//================================================= Output Port =================================================//
.dst_tvalid       (w_axi4s_itvalid     ),
.dst_tready       (w_axi4s_itready     ),
.dst_tdata        (w_axi4s_itdata      ),
.dst_tstrb        (w_axi4s_itstrb      ),
.dst_tkeep        (w_axi4s_itkeep      ),
.dst_tlast        (w_axi4s_itlast      ),
.dst_tid          (w_axi4s_itid        ),
.dst_tdest        (w_axi4s_itdest      ),
.dst_tuser        (w_axi4s_ituser      )
);

endmodule  // COREAXI4S_DATAWIDTHCONV.v
