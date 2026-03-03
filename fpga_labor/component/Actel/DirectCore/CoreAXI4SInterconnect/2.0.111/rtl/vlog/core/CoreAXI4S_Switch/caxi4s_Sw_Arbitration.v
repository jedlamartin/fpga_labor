// *********************************************************************/
// Copyright (c) 2015 Microsemi Corporation.  All rights reserved.
//
// Any use or redistribution in part or in whole must be handled in
// accordance with the Actel license agreement and must be approved
// in advance in writing.
//
// File: caxi4s_Sw_Arbitration.v
//
// SVN Revision Information:
// SVN $Revision: 40600 $
// SVN $Date: 2022-05-18 11:57:41 +0530 (Wed, 18 May 2022) $
//
// Description: Submodule to AXI4 Stream Switch top, it arbitrate the request generated for 
// each initiator from multiple targets and handle transmission flow for allotted transmission slice
//
// Notes:
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4s_Sw_Arbitration
#(
    parameter integer  SYNC_RESET                 = 0,
    parameter integer  INTEGER_SIZE               = 32,
    parameter integer  NUM_REQSTS                 = 8,                                              // Defines number of Requestors           (1 to 8)
    parameter integer  NUM_REQSTS_WIDTH           = 3,

    parameter integer  ARB_TYPE                   = 0,                                              // Arbitration Type                       (0 , 1) 0 -> TLAST, 1 -> Number of Transfers
    parameter integer  NUM_ARB_TRANS              = 1,                                              // Number of Arbitration Transfers        (1 to 1024)
    parameter integer  ENABLE_TIMEOUT             = 0,                                              // Enable Timeout                         (0 , 1)
    parameter integer  TIMEOUT_CYCLES             = 64                                              // Number of Timeout cycles for tready    (16 to 1024)
    )
    (
    //================================================= Global Signals  ==============================================//
    input  wire                                   aclk,
    input  wire                                   resetn,                                           // active low reset

    //================================================= Arb control Signals  =========================================//
    input  wire [NUM_REQSTS-1:0]                  requestors,
    input  wire [NUM_REQSTS-1:0]                  extr_tlast,
    input  wire                                   extr_tready,

    output reg  [NUM_REQSTS-1:0]                  grant,
//    output reg  [NUM_REQSTS_WIDTH-1:0]            grantEnc,
    output reg                                    arbValid

)/* synthesis syn_preserve = 1 */;

localparam COUNT_WIDTH  = $clog2(NUM_ARB_TRANS)+1;
localparam TCOUNT_WIDTH = $clog2(TIMEOUT_CYCLES)+1;

function [NUM_REQSTS_WIDTH-1:0] fnc_hot2enc (input [NUM_REQSTS-1:0]  one_hot);
    begin
        fnc_hot2enc[0] = |(one_hot & 8'b1010_1010);
        fnc_hot2enc[1] = |(one_hot & 8'b1100_1100);
        fnc_hot2enc[2] = |(one_hot & 8'b1111_0000);
        //fnc_hot2enc[3] = |(one_hot & 16'b1111_1111_0000_0000);
    end
endfunction

wire aresetn = (SYNC_RESET==1) ? 1'b1   : resetn;
wire sresetn = (SYNC_RESET==1) ? resetn : 1'b1;

wire tx_done;
wire tx_timeout_cnt_rst;
reg  [NUM_REQSTS_WIDTH-1:0] grantEnc;

//wire [NUM_REQSTS-1:0]       d_grant;
//reg  [NUM_REQSTS-1:0]       priorityMask; 
//reg  [NUM_REQSTS-1:0]       requestorsMasked;
//wire [NUM_REQSTS-1:0]       reqMasked, mask_higher_pri_reqs, grantMasked;
//wire [NUM_REQSTS-1:0]       unmask_higher_pri_reqs, grantUnmasked;
//wire                        no_req_masked;

wire                    request_valid     = requestors[grantEnc];
wire [2*NUM_REQSTS-1:0] double_req;
wire [2*NUM_REQSTS-1:0] double_grant;
reg  [NUM_REQSTS-1:0]   rotate_prio;
reg  [NUM_REQSTS-1:0]   rotate_prio_reg;
reg                     active_req;

generate
if (ARB_TYPE==1)
begin
    reg [COUNT_WIDTH-1:0] count_reg;
    always@(posedge aclk or negedge aresetn)
    begin
        if (~aresetn | ~sresetn)
        begin
            count_reg   <= (COUNT_WIDTH)'(0);
        end
        else if (tx_done)
        begin
            count_reg   <= (COUNT_WIDTH)'(0);
        end
        else if (arbValid && request_valid && extr_tready)
        begin
            count_reg   <= count_reg + 1'b1;
        end
    end
    assign tx_done             = (count_reg == NUM_ARB_TRANS-1'b1) & extr_tready & request_valid & arbValid;
    assign tx_timeout_cnt_rst  =  extr_tready & request_valid & arbValid;
end
else
begin
    //wire  [NUM_REQSTS-1:0] tx_status;
    //assign tx_status   = (extr_tlast >> grantEnc);
    //assign tx_done     = tx_status[0] & extr_tready & request_valid & arbValid;
    assign tx_done                = extr_tlast[grantEnc] & extr_tready & request_valid & arbValid;
    assign tx_timeout_cnt_rst     =  extr_tready & request_valid & arbValid;
end
endgenerate

generate
if (ENABLE_TIMEOUT == 1)
begin
    reg timeout_done;
    reg [TCOUNT_WIDTH-1:0] timeout_count_reg;
    always@(posedge aclk or negedge aresetn)
    begin
        if (~aresetn | ~sresetn)
        begin
            timeout_done            <= 1'b0;
            timeout_count_reg       <= (TCOUNT_WIDTH)'(0);
        end
        else if (tx_timeout_cnt_rst)
        begin
            timeout_done            <= 1'b0;
            timeout_count_reg       <= (TCOUNT_WIDTH)'(0);
        end
        else if (~timeout_done && arbValid && request_valid)
        begin
            if (timeout_count_reg == TIMEOUT_CYCLES)
            begin
                timeout_done        <= 1'b1;
                timeout_count_reg   <= (TCOUNT_WIDTH)'(0);
            end
            else
            begin
                timeout_count_reg   <= timeout_count_reg + 1'b1;
            end
        end
        else if (timeout_done)
        begin
            timeout_done            <= 1'b0;
        end
    end

    always@(*)
	  arbValid = (| grant);

    always@(posedge aclk or negedge aresetn)
    //always@(*)
    begin
        if (~aresetn | ~sresetn)
        begin
            grant           <= {(NUM_REQSTS){1'b0}};
            grantEnc        <= {(NUM_REQSTS_WIDTH){1'b0}};
            //arbValid        <= 1'b0;
        end
        else if ((tx_done) | (~arbValid) | timeout_done)
        begin
            grant           <= double_grant[NUM_REQSTS-1:0] | double_grant[2*NUM_REQSTS-1:NUM_REQSTS]              ;
			if(tx_done)
			  grant[grantEnc] <= 1'b0;			
            grantEnc        <= fnc_hot2enc(double_grant[NUM_REQSTS-1:0] | double_grant[2*NUM_REQSTS-1:NUM_REQSTS]) ;
            //arbValid        <= |(double_grant[NUM_REQSTS-1:0] | double_grant[2*NUM_REQSTS-1:NUM_REQSTS])           ;
        end
    end

end
else
begin
    always@(*)
	  arbValid = (| grant);
    always@(posedge aclk or negedge aresetn)
    //always@(*)
    begin
        if (~aresetn | ~sresetn)
        begin
            grant           <= {(NUM_REQSTS){1'b0}};
            grantEnc        <= {(NUM_REQSTS_WIDTH){1'b0}};
            //arbValid        <= 1'b0;
        end
        else if ((tx_done) | (~arbValid))
        begin
            grant           <= double_grant[NUM_REQSTS-1:0] | double_grant[2*NUM_REQSTS-1:NUM_REQSTS]             ;
			if(tx_done)
			  grant[grantEnc] <= 1'b0;
            grantEnc        <= fnc_hot2enc(double_grant[NUM_REQSTS-1:0] | double_grant[2*NUM_REQSTS-1:NUM_REQSTS]);
            //arbValid        <= |(double_grant[NUM_REQSTS-1:0] | double_grant[2*NUM_REQSTS-1:NUM_REQSTS])          ;
        end
    end

end
endgenerate
/*
assign no_req_masked     = ~( |reqMasked );
assign d_grant           = ( { NUM_REQSTS{ no_req_masked } } & grantUnmasked ) | grantMasked;

always @( * )
begin
    requestorsMasked <= { requestors & ( ~( grant & { NUM_REQSTS{arbValid} } ) ) };
end

//==============================================================================
// Simple priority arbitration for masked portion
//==============================================================================
assign reqMasked                                = requestorsMasked & priorityMask;

assign mask_higher_pri_reqs[NUM_REQSTS-1:1]     = mask_higher_pri_reqs[NUM_REQSTS-2: 0] | reqMasked[NUM_REQSTS-2:0] ;
assign mask_higher_pri_reqs[0]                  = 1'b0;
assign grantMasked[NUM_REQSTS-1:0]              = reqMasked[NUM_REQSTS-1:0] & ~mask_higher_pri_reqs[NUM_REQSTS-1:0];

//=================================================================================
// Simple priority arbitration for unmasked portion
//=================================================================================
assign unmask_higher_pri_reqs[NUM_REQSTS-1:1]   = unmask_higher_pri_reqs[NUM_REQSTS-2:0] | requestorsMasked[NUM_REQSTS-2:0];
assign unmask_higher_pri_reqs[0]                = 1'b0;
assign grantUnmasked[NUM_REQSTS-1:0]            = requestorsMasked[NUM_REQSTS-1:0] & ~unmask_higher_pri_reqs[NUM_REQSTS-1:0];

always@(posedge aclk or negedge aresetn)
begin
    if (~aresetn | ~sresetn)
    begin
        priorityMask            <= {(NUM_REQSTS){1'b1}};
    end
    else if (tx_done)
    begin
        if (|reqMasked)
        begin
            priorityMask        <= mask_higher_pri_reqs;
        end
        else
        begin
            if ( |requestorsMasked )
            begin                                           // Only update if there's a request
                priorityMask    <= unmask_higher_pri_reqs;
            end
        end
    end
end
*/
always@(posedge aclk or negedge aresetn)
  if (~aresetn | ~sresetn)
    active_req <= 0;
  else if(| requestors)
	active_req <= 1'b1;
  else 
    active_req <= 1'b0;	
	

always@(posedge aclk or negedge aresetn)
  if (~aresetn | ~sresetn)
    rotate_prio_reg <= 1;
  else 
	rotate_prio_reg <= rotate_prio;
	
//always@(posedge aclk or negedge aresetn)
always@(*)
  if (tx_done | ~active_req)
    rotate_prio = grant[NUM_REQSTS-1] | ~active_req ? 1'b1 : grant << 1;
  else 
    rotate_prio = rotate_prio_reg;
  //else 
  //	rotate_prio <= rotate_prio_reg;
  
assign  double_req    = {requestors,requestors};
assign  double_grant  = double_req & ~(double_req-rotate_prio);
	
endmodule
