// ********************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2023 Microchip Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// IP Core:      COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_CoreAXI4DMAController_ctrlIFMuxCDC
// SVN Revision Information:
// SVN $Revision: 45898 $
// SVN $Date: 2024-01-25 11:34:35 +0530 (Thu, 25 Jan 2024) $
//
//
// *********************************************************************/
module COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_CoreAXI4DMAController_ctrlIFMuxCDC (
    // AXILiteTARGETCtrl inputs
    ctrlSel_AXILiteTARGETCtrl,
    ctrlWr_AXILiteTARGETCtrl,
    ctrlAddr_AXILiteTARGETCtrl,
    ctrlWrData_AXILiteTARGETCtrl,
    ctrlWrStrbs_AXILiteTARGETCtrl,
    
    // Buffer Descriptor inputs
    ctrlWrRdy_BufferDescrptrs,
    ctrlRdData_BufferDescrptrs,
    ctrlRdValid_BufferDescrptrs,
    
    // Interrupt Controller inputs
    ctrlRdData_IntController,
    ctrlRdValid_IntController,
    
    // Control Register inputs
    ctrlRdData_CtrlReg,
    ctrlRdValid_CtrlReg,
    
    // AXI4StreamTARGETCtrl inputs
    ctrlRdData_AXI4StreamTARGETCtrl,
    ctrlRdValid_AXI4StreamTARGETCtrl,
    
    // General outputs
    ctrlSel,
    ctrlWr,
    ctrlAddr,
    ctrlWrData,
    ctrlWrStrbs,
    
    // AXILiteTARGETCtrl outputs
    ctrlWrRdy,
    ctrlRdData,
    ctrlRdValid
);

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// AXILiteTARGETCtrl inputs
input               ctrlSel_AXILiteTARGETCtrl;
input               ctrlWr_AXILiteTARGETCtrl;
input   [10:0]      ctrlAddr_AXILiteTARGETCtrl;
input   [31:0]      ctrlWrData_AXILiteTARGETCtrl;
input   [3:0]       ctrlWrStrbs_AXILiteTARGETCtrl;

// Buffer Descriptor inputs
input               ctrlWrRdy_BufferDescrptrs;
input   [31:0]      ctrlRdData_BufferDescrptrs;
input               ctrlRdValid_BufferDescrptrs;

// Interrupt Controller inputs
input   [31:0]      ctrlRdData_IntController;
input               ctrlRdValid_IntController;

// Control Register inputs
input   [31:0]      ctrlRdData_CtrlReg;
input               ctrlRdValid_CtrlReg;

// AXI4StreamTARGETCtrl inputs
input   [31:0]      ctrlRdData_AXI4StreamTARGETCtrl;
input               ctrlRdValid_AXI4StreamTARGETCtrl;

// General outputs
output              ctrlSel;
output              ctrlWr;
output  [10:0]      ctrlAddr;
output  [31:0]      ctrlWrData;
output  [3:0]       ctrlWrStrbs;

// AXILiteTARGETCtrl outputs
output              ctrlWrRdy;
output  [31:0]      ctrlRdData;
output              ctrlRdValid;

// Map control INITIATOR data from AXI-Lite INITIATOR directly to system as the AHBL
// control interface isn't yet enabled
assign ctrlSel     = ctrlSel_AXILiteTARGETCtrl;
assign ctrlWr      = ctrlWr_AXILiteTARGETCtrl;
assign ctrlAddr    = ctrlAddr_AXILiteTARGETCtrl;
assign ctrlWrData  = ctrlWrData_AXILiteTARGETCtrl;
assign ctrlWrStrbs = ctrlWrStrbs_AXILiteTARGETCtrl;

// Mux read data from Interrupt Controller and Buffer Descriptors to the control
// INITIATOR
assign ctrlRdData = (ctrlAddr[10:0] >= 11'h460) ? ctrlRdData_AXI4StreamTARGETCtrl :
                    (ctrlAddr[10:0] >= 11'h060) ? ctrlRdData_BufferDescrptrs :
                    (ctrlAddr[10:0] == 11'h0)   ? ctrlRdData_CtrlReg :
                    ctrlRdData_IntController;

assign ctrlRdValid = (ctrlAddr[10:0] >= 11'h460) ? ctrlRdValid_AXI4StreamTARGETCtrl :
                     (ctrlAddr[10:0] >= 11'h060) ? ctrlRdValid_BufferDescrptrs :
                     (ctrlAddr[10:0] == 11'h0)   ? ctrlRdValid_CtrlReg :
                     ctrlRdValid_IntController;

assign ctrlWrRdy   = (ctrlAddr[10:0] >= 11'h460) ? 1'b1 :
                     (ctrlAddr[10:0] >= 11'h060) ? ctrlWrRdy_BufferDescrptrs :
                     1'b1; // All other addressable locations are registers

endmodule // ctrlIFMuxCDC