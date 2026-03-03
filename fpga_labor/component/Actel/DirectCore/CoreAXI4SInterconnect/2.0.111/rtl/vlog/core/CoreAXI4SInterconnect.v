// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 40834 $
// SVN $Date: 2022-06-30 17:35:38 +0530 (Thu, 30 Jun 2022) $
//
// Module: CoreAXI4SInterconnect
//
//
// Abstract      : (1) This is the top module of CoreAXI4SInterconnect IP. It instantiates different module baesd on the
//                     top level parameter configuration.
// Instantiation :  It instantiate following modules.
//                  CoreAXI4S_FIFO
//                  COREAXI4S_DATAWIDTHCONV
//                  CoreAXI4S_SWITCH
//
// ******************************************************************************************************/

module CoreAXI4SInterconnect #
(
  parameter         FAMILY            = 26, //Family
  parameter         NUM_INITIATORS    = 2,  //Number of Initiators
  parameter         NUM_TARGETS       = 2,  //Number of Targets
  parameter [31:0]  NUM_TARGETS_WIDTH = 1,  // Defines width for number of Target Ports(1 to 3)
  parameter [31:0]  TID_WIDTH         = 1,  //Target TID Width
  parameter [31:0]  ITID_WIDTH        = TID_WIDTH+NUM_TARGETS_WIDTH,  //Initiator TID Width
  parameter [31:0]  TDEST_WIDTH       = 1,  //TDEST Width
  parameter [31:0]  TDATA_BYTES       = 4,  //TDATA Bytes
  parameter [31:0]  TUSER_BITS_P_BYTE = 1,  //TDATA Bytes
  parameter [0:0]   ENABLE_TDATA      = 1,  //Enable TDATA
  parameter [0:0]   ENABLE_TUSER      = 1,  //Enable TUSER
  parameter [0:0]   ENABLE_TID        = 1,  //Enable TID
  parameter [0:0]   ENABLE_TDEST      = 1,  //Enable TDEST
  parameter [0:0]   ENABLE_TREADY     = 1,  //Enable TREADY
  parameter [0:0]   ENABLE_TSTRB      = 1,  //Enable TSTRB
  parameter [0:0]   ENABLE_TKEEP      = 1,  //Enable TKEEP
  parameter [0:0]   ENABLE_TLAST      = 1,  //Enable TLAST
  parameter [0:0]   ARB_TYPE          = 0,  //Arbitration Type
  parameter [10:0]  NUM_ARB_TRANS     = 1,  //Number of Transfers for Arbitration
  parameter [0:0]   ENABLE_TIMEOUT    = 0,  //Enable TREADY Timeout
  parameter [10:0]  TIMEOUT_CYCLES    = 64, //Number of Timeout Cycles

  parameter [0:0]   IR0_ENABLE_ARB    = 1,  // Enable Arbitration                     (0 , 1)
  parameter [0:0]   IR1_ENABLE_ARB    = 1,  // Enable Arbitration                     (0 , 1)
  parameter [0:0]   IR2_ENABLE_ARB    = 1,  // Enable Arbitration                     (0 , 1)
  parameter [0:0]   IR3_ENABLE_ARB    = 1,  // Enable Arbitration                     (0 , 1)
  parameter [0:0]   IR4_ENABLE_ARB    = 1,  // Enable Arbitration                     (0 , 1)
  parameter [0:0]   IR5_ENABLE_ARB    = 1,  // Enable Arbitration                     (0 , 1)
  parameter [0:0]   IR6_ENABLE_ARB    = 1,  // Enable Arbitration                     (0 , 1)
  parameter [0:0]   IR7_ENABLE_ARB    = 1,  // Enable Arbitration                     (0 , 1)

  //Target to Initiator port connectivity

  parameter [0:0] TR0_IR0_LINK      = 1,
  parameter [0:0] TR0_IR1_LINK      = 1,
  parameter [0:0] TR0_IR2_LINK      = 1,
  parameter [0:0] TR0_IR3_LINK      = 1,
  parameter [0:0] TR0_IR4_LINK      = 1,
  parameter [0:0] TR0_IR5_LINK      = 1,
  parameter [0:0] TR0_IR6_LINK      = 1,
  parameter [0:0] TR0_IR7_LINK      = 1,

  parameter [0:0] TR1_IR0_LINK      = 1,
  parameter [0:0] TR1_IR1_LINK      = 1,
  parameter [0:0] TR1_IR2_LINK      = 1,
  parameter [0:0] TR1_IR3_LINK      = 1,
  parameter [0:0] TR1_IR4_LINK      = 1,
  parameter [0:0] TR1_IR5_LINK      = 1,
  parameter [0:0] TR1_IR6_LINK      = 1,
  parameter [0:0] TR1_IR7_LINK      = 1,

  parameter [0:0] TR2_IR0_LINK      = 1,
  parameter [0:0] TR2_IR1_LINK      = 1,
  parameter [0:0] TR2_IR2_LINK      = 1,
  parameter [0:0] TR2_IR3_LINK      = 1,
  parameter [0:0] TR2_IR4_LINK      = 1,
  parameter [0:0] TR2_IR5_LINK      = 1,
  parameter [0:0] TR2_IR6_LINK      = 1,
  parameter [0:0] TR2_IR7_LINK      = 1,

  parameter [0:0] TR3_IR0_LINK      = 1,
  parameter [0:0] TR3_IR1_LINK      = 1,
  parameter [0:0] TR3_IR2_LINK      = 1,
  parameter [0:0] TR3_IR3_LINK      = 1,
  parameter [0:0] TR3_IR4_LINK      = 1,
  parameter [0:0] TR3_IR5_LINK      = 1,
  parameter [0:0] TR3_IR6_LINK      = 1,
  parameter [0:0] TR3_IR7_LINK      = 1,

  parameter [0:0] TR4_IR0_LINK      = 1,
  parameter [0:0] TR4_IR1_LINK      = 1,
  parameter [0:0] TR4_IR2_LINK      = 1,
  parameter [0:0] TR4_IR3_LINK      = 1,
  parameter [0:0] TR4_IR4_LINK      = 1,
  parameter [0:0] TR4_IR5_LINK      = 1,
  parameter [0:0] TR4_IR6_LINK      = 1,
  parameter [0:0] TR4_IR7_LINK      = 1,

  parameter [0:0] TR5_IR0_LINK      = 1,
  parameter [0:0] TR5_IR1_LINK      = 1,
  parameter [0:0] TR5_IR2_LINK      = 1,
  parameter [0:0] TR5_IR3_LINK      = 1,
  parameter [0:0] TR5_IR4_LINK      = 1,
  parameter [0:0] TR5_IR5_LINK      = 1,
  parameter [0:0] TR5_IR6_LINK      = 1,
  parameter [0:0] TR5_IR7_LINK      = 1,

  parameter [0:0] TR6_IR0_LINK      = 1,
  parameter [0:0] TR6_IR1_LINK      = 1,
  parameter [0:0] TR6_IR2_LINK      = 1,
  parameter [0:0] TR6_IR3_LINK      = 1,
  parameter [0:0] TR6_IR4_LINK      = 1,
  parameter [0:0] TR6_IR5_LINK      = 1,
  parameter [0:0] TR6_IR6_LINK      = 1,
  parameter [0:0] TR6_IR7_LINK      = 1,

  parameter [0:0] TR7_IR0_LINK      = 1,
  parameter [0:0] TR7_IR1_LINK      = 1,
  parameter [0:0] TR7_IR2_LINK      = 1,
  parameter [0:0] TR7_IR3_LINK      = 1,
  parameter [0:0] TR7_IR4_LINK      = 1,
  parameter [0:0] TR7_IR5_LINK      = 1,
  parameter [0:0] TR7_IR6_LINK      = 1,
  parameter [0:0] TR7_IR7_LINK      = 1,

  //Initiator Port TDEST Base Value

  parameter [31:0] IR0_TDEST_BASE    = 0,
  parameter [31:0] IR1_TDEST_BASE    = 1,
  parameter [31:0] IR2_TDEST_BASE    = 2,
  parameter [31:0] IR3_TDEST_BASE    = 3,
  parameter [31:0] IR4_TDEST_BASE    = 4,
  parameter [31:0] IR5_TDEST_BASE    = 5,
  parameter [31:0] IR6_TDEST_BASE    = 6,
  parameter [31:0] IR7_TDEST_BASE    = 7,

  //Initiator Port TDEST High Value

  parameter [31:0] IR0_TDEST_HIGH    = 0,
  parameter [31:0] IR1_TDEST_HIGH    = 1,
  parameter [31:0] IR2_TDEST_HIGH    = 2,
  parameter [31:0] IR3_TDEST_HIGH    = 3,
  parameter [31:0] IR4_TDEST_HIGH    = 4,
  parameter [31:0] IR5_TDEST_HIGH    = 5,
  parameter [31:0] IR6_TDEST_HIGH    = 6,
  parameter [31:0] IR7_TDEST_HIGH    = 7,

  //Clock Domain Crossing Enabled/Disabled for Initiator

  parameter [0:0] ENABLE_IR0_FIFO   = 0,   //1 - Initiator and AXI4S Switch are operating at different frequency
                                           //0 - Initiator and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_IR1_FIFO   = 0,   //1 - Initiator and AXI4S Switch are operating at different frequency
                                           //0 - Initiator and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_IR2_FIFO   = 0,   //1 - Initiator and AXI4S Switch are operating at different frequency
                                           //0 - Initiator and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_IR3_FIFO   = 0,   //1 - Initiator and AXI4S Switch are operating at different frequency
                                           //0 - Initiator and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_IR4_FIFO   = 0,   //1 - Initiator and AXI4S Switch are operating at different frequency
                                           //0 - Initiator and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_IR5_FIFO   = 0,   //1 - Initiator and AXI4S Switch are operating at different frequency
                                           //0 - Initiator and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_IR6_FIFO   = 0,   //1 - Initiator and AXI4S Switch are operating at different frequency
                                           //0 - Initiator and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_IR7_FIFO   = 0,   //1 - Initiator and AXI4S Switch are operating at different frequency
                                           //0 - Initiator and AXI4S Switch are operating at same frequency

  parameter [1:0] IR0_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] IR1_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] IR2_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] IR3_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] IR4_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] IR5_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] IR6_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] IR7_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM

  parameter [0:0] IR0_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] IR1_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] IR2_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] IR3_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] IR4_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] IR5_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] IR6_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] IR7_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO

  parameter [0:0] IR0_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] IR1_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] IR2_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] IR3_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] IR4_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] IR5_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] IR6_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] IR7_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled

  parameter [0:0] IR0_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] IR1_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] IR2_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] IR3_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] IR4_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] IR5_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] IR6_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] IR7_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled

  parameter [31:0] IR0_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] IR1_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] IR2_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] IR3_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] IR4_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] IR5_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] IR6_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] IR7_FIFO_DEPTH   = 16,   // FIFO Depth

  //Clock Domain Crossing Enabled/Disabled for Target

  parameter [0:0] ENABLE_TR0_FIFO   = 0,   //1 - Target and AXI4S Switch are operating at different frequency
                                           //0 - Target and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_TR1_FIFO   = 0,   //1 - Target and AXI4S Switch are operating at different frequency
                                           //0 - Target and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_TR2_FIFO   = 0,   //1 - Target and AXI4S Switch are operating at different frequency
                                           //0 - Target and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_TR3_FIFO   = 0,   //1 - Target and AXI4S Switch are operating at different frequency
                                           //0 - Target and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_TR4_FIFO   = 1,   //1 - Target and AXI4S Switch are operating at different frequency
                                           //0 - Target and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_TR5_FIFO   = 0,   //1 - Target and AXI4S Switch are operating at different frequency
                                           //0 - Target and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_TR6_FIFO   = 0,   //1 - Target and AXI4S Switch are operating at different frequency
                                           //0 - Target and AXI4S Switch are operating at same frequency
  parameter [0:0] ENABLE_TR7_FIFO   = 0,   //1 - Target and AXI4S Switch are operating at different frequency
                                           //0 - Target and AXI4S Switch are operating at same frequency

  parameter [1:0] TR0_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] TR1_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] TR2_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] TR3_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] TR4_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] TR5_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] TR6_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM
  parameter [1:0] TR7_RAM_TYPE      = 1,   //0 - Fabric 1 - uSRAM 2 - LSRAM

  parameter [0:0] TR0_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] TR1_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] TR2_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] TR3_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] TR4_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] TR5_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] TR6_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO
  parameter [0:0] TR7_ASYNC_FIFO    = 0,   //0 - Async FIFO 1-Sync FIFO

  parameter [0:0] TR0_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] TR1_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] TR2_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] TR3_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] TR4_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] TR5_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] TR6_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled
  parameter [0:0] TR7_FIFO_ECC      = 0,   //0 - ECC Disabled 1-ECC Enabled

  parameter [0:0] TR0_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] TR1_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] TR2_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] TR3_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] TR4_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] TR5_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] TR6_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled
  parameter [0:0] TR7_PACKET_MODE   = 0,   //0 - Packet Mode Disabled 1-Packet Mode Enabled

  parameter [31:0] TR0_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] TR1_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] TR2_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] TR3_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] TR4_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] TR5_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] TR6_FIFO_DEPTH   = 16,   // FIFO Depth
  parameter [31:0] TR7_FIFO_DEPTH   = 16,   // FIFO Depth

  //INITIATOR TDATA Bytes

  parameter [31:0] AXI4S_I0TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_I1TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_I2TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_I3TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_I4TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_I5TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_I6TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_I7TDATA_BYTES   = 4,

  //TARGET TDATA Bytes

  parameter [31:0] AXI4S_T0TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_T1TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_T2TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_T3TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_T4TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_T5TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_T6TDATA_BYTES   = 4,
  parameter [31:0] AXI4S_T7TDATA_BYTES   = 4,

  //AXI4S Switch Initiator Register Slice

  parameter [0:0] AXI4S_I0RS   = 0,
  parameter [0:0] AXI4S_I1RS   = 0,
  parameter [0:0] AXI4S_I2RS   = 0,
  parameter [0:0] AXI4S_I3RS   = 0,
  parameter [0:0] AXI4S_I4RS   = 0,
  parameter [0:0] AXI4S_I5RS   = 0,
  parameter [0:0] AXI4S_I6RS   = 0,
  parameter [0:0] AXI4S_I7RS   = 0,

  //AXI4S Switch Target Register Slice

  parameter [0:0] AXI4S_T0RS   = 0,
  parameter [0:0] AXI4S_T1RS   = 0,
  parameter [0:0] AXI4S_T2RS   = 0,
  parameter [0:0] AXI4S_T3RS   = 0,
  parameter [0:0] AXI4S_T4RS   = 0,
  parameter [0:0] AXI4S_T5RS   = 0,
  parameter [0:0] AXI4S_T6RS   = 0,
  parameter [0:0] AXI4S_T7RS   = 0,

  //AXI4S Target Side DWC Initiator Register Slice

  parameter [0:0] AXI4S_TDWC_I0RS   = 0,
  parameter [0:0] AXI4S_TDWC_I1RS   = 0,
  parameter [0:0] AXI4S_TDWC_I2RS   = 0,
  parameter [0:0] AXI4S_TDWC_I3RS   = 0,
  parameter [0:0] AXI4S_TDWC_I4RS   = 0,
  parameter [0:0] AXI4S_TDWC_I5RS   = 0,
  parameter [0:0] AXI4S_TDWC_I6RS   = 0,
  parameter [0:0] AXI4S_TDWC_I7RS   = 0,

  //AXI4S Target Side DWC Target Register Slice

  parameter [0:0] AXI4S_TDWC_T0RS   = 0,
  parameter [0:0] AXI4S_TDWC_T1RS   = 0,
  parameter [0:0] AXI4S_TDWC_T2RS   = 0,
  parameter [0:0] AXI4S_TDWC_T3RS   = 0,
  parameter [0:0] AXI4S_TDWC_T4RS   = 0,
  parameter [0:0] AXI4S_TDWC_T5RS   = 0,
  parameter [0:0] AXI4S_TDWC_T6RS   = 0,
  parameter [0:0] AXI4S_TDWC_T7RS   = 0,

  //AXI4S Initiator Side DWC Initiator Register Slice

  parameter [0:0] AXI4S_IDWC_I0RS   = 0,
  parameter [0:0] AXI4S_IDWC_I1RS   = 0,
  parameter [0:0] AXI4S_IDWC_I2RS   = 0,
  parameter [0:0] AXI4S_IDWC_I3RS   = 0,
  parameter [0:0] AXI4S_IDWC_I4RS   = 0,
  parameter [0:0] AXI4S_IDWC_I5RS   = 0,
  parameter [0:0] AXI4S_IDWC_I6RS   = 0,
  parameter [0:0] AXI4S_IDWC_I7RS   = 0,

  //AXI4S Initiator Side DWC Target Register Slice

  parameter [0:0] AXI4S_IDWC_T0RS   = 0,
  parameter [0:0] AXI4S_IDWC_T1RS   = 0,
  parameter [0:0] AXI4S_IDWC_T2RS   = 0,
  parameter [0:0] AXI4S_IDWC_T3RS   = 0,
  parameter [0:0] AXI4S_IDWC_T4RS   = 0,
  parameter [0:0] AXI4S_IDWC_T5RS   = 0,
  parameter [0:0] AXI4S_IDWC_T6RS   = 0,
  parameter [0:0] AXI4S_IDWC_T7RS   = 0,

  //AXI4S Target Side DWC LCM TDATA Bytes

  parameter [31:0] TR0_LCM_TDATA_BYTES   = 4,
  parameter [31:0] TR1_LCM_TDATA_BYTES   = 4,
  parameter [31:0] TR2_LCM_TDATA_BYTES   = 4,
  parameter [31:0] TR3_LCM_TDATA_BYTES   = 4,
  parameter [31:0] TR4_LCM_TDATA_BYTES   = 4,
  parameter [31:0] TR5_LCM_TDATA_BYTES   = 4,
  parameter [31:0] TR6_LCM_TDATA_BYTES   = 4,
  parameter [31:0] TR7_LCM_TDATA_BYTES   = 4,

  //AXI4S Initiator Side DWC LCM TDATA Bytes

  parameter [31:0] IR0_LCM_TDATA_BYTES   = 4,
  parameter [31:0] IR1_LCM_TDATA_BYTES   = 4,
  parameter [31:0] IR2_LCM_TDATA_BYTES   = 4,
  parameter [31:0] IR3_LCM_TDATA_BYTES   = 4,
  parameter [31:0] IR4_LCM_TDATA_BYTES   = 4,
  parameter [31:0] IR5_LCM_TDATA_BYTES   = 4,
  parameter [31:0] IR6_LCM_TDATA_BYTES   = 4,
  parameter [31:0] IR7_LCM_TDATA_BYTES   = 4,

  //Target TUSER_WIDTH parameters derived internally using TDATA_BYTES and TUSER_BITS_P_BYTE.

  parameter [31:0] TR0_TUSER_WIDTH   = 4,
  parameter [31:0] TR1_TUSER_WIDTH   = 4,
  parameter [31:0] TR2_TUSER_WIDTH   = 4,
  parameter [31:0] TR3_TUSER_WIDTH   = 4,
  parameter [31:0] TR4_TUSER_WIDTH   = 4,
  parameter [31:0] TR5_TUSER_WIDTH   = 4,
  parameter [31:0] TR6_TUSER_WIDTH   = 4,
  parameter [31:0] TR7_TUSER_WIDTH   = 4,

  //Switch TUSER_WIDTH parameters

  parameter [31:0] TUSER_WIDTH = 4,

  //Initiator TUSER_WIDTH parameters

  parameter [31:0] IR0_TUSER_WIDTH   = 4,
  parameter [31:0] IR1_TUSER_WIDTH   = 4,
  parameter [31:0] IR2_TUSER_WIDTH   = 4,
  parameter [31:0] IR3_TUSER_WIDTH   = 4,
  parameter [31:0] IR4_TUSER_WIDTH   = 4,
  parameter [31:0] IR5_TUSER_WIDTH   = 4,
  parameter [31:0] IR6_TUSER_WIDTH   = 4,
  parameter [31:0] IR7_TUSER_WIDTH   = 4,

  //FIFO Parameters

  parameter [2:0]  NUM_STAGES        = 2,

  parameter integer TGIGEN_DISPLAY_SYMBOL    = 1

)
(
  //Clock and Reset Ports of AXI4 Stream Switch

  input                                    ACLK,
  input                                    RESETN,

  //Clock and Reset Ports of Initiator

  input                                    AXI4S_I0CLK,
  input                                    AXI4S_I1CLK,
  input                                    AXI4S_I2CLK,
  input                                    AXI4S_I3CLK,
  input                                    AXI4S_I4CLK,
  input                                    AXI4S_I5CLK,
  input                                    AXI4S_I6CLK,
  input                                    AXI4S_I7CLK,

  input                                    AXI4S_I0RESETN,
  input                                    AXI4S_I1RESETN,
  input                                    AXI4S_I2RESETN,
  input                                    AXI4S_I3RESETN,
  input                                    AXI4S_I4RESETN,
  input                                    AXI4S_I5RESETN,
  input                                    AXI4S_I6RESETN,
  input                                    AXI4S_I7RESETN,

  //Clock and Reset Ports of Target

  input                                    AXI4S_T0CLK,
  input                                    AXI4S_T1CLK,
  input                                    AXI4S_T2CLK,
  input                                    AXI4S_T3CLK,
  input                                    AXI4S_T4CLK,
  input                                    AXI4S_T5CLK,
  input                                    AXI4S_T6CLK,
  input                                    AXI4S_T7CLK,

  input                                    AXI4S_T0RESETN,
  input                                    AXI4S_T1RESETN,
  input                                    AXI4S_T2RESETN,
  input                                    AXI4S_T3RESETN,
  input                                    AXI4S_T4RESETN,
  input                                    AXI4S_T5RESETN,
  input                                    AXI4S_T6RESETN,
  input                                    AXI4S_T7RESETN,

  //AXI4 Stream Target Ports

  input                                    AXI4S_T0TVALID,
  output                                   AXI4S_T0TREADY,
  input  [(AXI4S_T0TDATA_BYTES*8)-1:0]     AXI4S_T0TDATA,
  input  [(AXI4S_T0TDATA_BYTES)-1:0]       AXI4S_T0TSTRB,
  input  [(AXI4S_T0TDATA_BYTES)-1:0]       AXI4S_T0TKEEP,
  input                                    AXI4S_T0TLAST,
  input  [TID_WIDTH-1:0]                   AXI4S_T0TID,
  input  [TDEST_WIDTH-1:0]                 AXI4S_T0TDEST,
  input  [TR0_TUSER_WIDTH-1:0]             AXI4S_T0TUSER,

  input                                    AXI4S_T1TVALID,
  output                                   AXI4S_T1TREADY,
  input  [(AXI4S_T1TDATA_BYTES*8)-1:0]     AXI4S_T1TDATA,
  input  [(AXI4S_T1TDATA_BYTES)-1:0]       AXI4S_T1TSTRB,
  input  [(AXI4S_T1TDATA_BYTES)-1:0]       AXI4S_T1TKEEP,
  input                                    AXI4S_T1TLAST,
  input  [TID_WIDTH-1:0]                   AXI4S_T1TID,
  input  [TDEST_WIDTH-1:0]                 AXI4S_T1TDEST,
  input  [TR1_TUSER_WIDTH-1:0]             AXI4S_T1TUSER,

  input                                    AXI4S_T2TVALID,
  output                                   AXI4S_T2TREADY,
  input  [(AXI4S_T2TDATA_BYTES*8)-1:0]     AXI4S_T2TDATA,
  input  [(AXI4S_T2TDATA_BYTES)-1:0]       AXI4S_T2TSTRB,
  input  [(AXI4S_T2TDATA_BYTES)-1:0]       AXI4S_T2TKEEP,
  input                                    AXI4S_T2TLAST,
  input  [TID_WIDTH-1:0]                   AXI4S_T2TID,
  input  [TDEST_WIDTH-1:0]                 AXI4S_T2TDEST,
  input  [TR2_TUSER_WIDTH-1:0]             AXI4S_T2TUSER,

  input                                    AXI4S_T3TVALID,
  output                                   AXI4S_T3TREADY,
  input  [(AXI4S_T3TDATA_BYTES*8)-1:0]     AXI4S_T3TDATA,
  input  [(AXI4S_T3TDATA_BYTES)-1:0]       AXI4S_T3TSTRB,
  input  [(AXI4S_T3TDATA_BYTES)-1:0]       AXI4S_T3TKEEP,
  input                                    AXI4S_T3TLAST,
  input  [TID_WIDTH-1:0]                   AXI4S_T3TID,
  input  [TDEST_WIDTH-1:0]                 AXI4S_T3TDEST,
  input  [TR3_TUSER_WIDTH-1:0]             AXI4S_T3TUSER,

  input                                    AXI4S_T4TVALID,
  output                                   AXI4S_T4TREADY,
  input  [(AXI4S_T4TDATA_BYTES*8)-1:0]     AXI4S_T4TDATA,
  input  [(AXI4S_T4TDATA_BYTES)-1:0]       AXI4S_T4TSTRB,
  input  [(AXI4S_T4TDATA_BYTES)-1:0]       AXI4S_T4TKEEP,
  input                                    AXI4S_T4TLAST,
  input  [TID_WIDTH-1:0]                   AXI4S_T4TID,
  input  [TDEST_WIDTH-1:0]                 AXI4S_T4TDEST,
  input  [TR4_TUSER_WIDTH-1:0]             AXI4S_T4TUSER,

  input                                    AXI4S_T5TVALID,
  output                                   AXI4S_T5TREADY,
  input  [(AXI4S_T5TDATA_BYTES*8)-1:0]     AXI4S_T5TDATA,
  input  [(AXI4S_T5TDATA_BYTES)-1:0]       AXI4S_T5TSTRB,
  input  [(AXI4S_T5TDATA_BYTES)-1:0]       AXI4S_T5TKEEP,
  input                                    AXI4S_T5TLAST,
  input  [TID_WIDTH-1:0]                   AXI4S_T5TID,
  input  [TDEST_WIDTH-1:0]                 AXI4S_T5TDEST,
  input  [TR5_TUSER_WIDTH-1:0]             AXI4S_T5TUSER,

  input                                    AXI4S_T6TVALID,
  output                                   AXI4S_T6TREADY,
  input  [(AXI4S_T6TDATA_BYTES*8)-1:0]     AXI4S_T6TDATA,
  input  [(AXI4S_T6TDATA_BYTES)-1:0]       AXI4S_T6TSTRB,
  input  [(AXI4S_T6TDATA_BYTES)-1:0]       AXI4S_T6TKEEP,
  input                                    AXI4S_T6TLAST,
  input  [TID_WIDTH-1:0]                   AXI4S_T6TID,
  input  [TDEST_WIDTH-1:0]                 AXI4S_T6TDEST,
  input  [TR6_TUSER_WIDTH-1:0]             AXI4S_T6TUSER,

  input                                    AXI4S_T7TVALID,
  output                                   AXI4S_T7TREADY,
  input  [(AXI4S_T7TDATA_BYTES*8)-1:0]     AXI4S_T7TDATA,
  input  [(AXI4S_T7TDATA_BYTES)-1:0]       AXI4S_T7TSTRB,
  input  [(AXI4S_T7TDATA_BYTES)-1:0]       AXI4S_T7TKEEP,
  input                                    AXI4S_T7TLAST,
  input  [TID_WIDTH-1:0]                   AXI4S_T7TID,
  input  [TDEST_WIDTH-1:0]                 AXI4S_T7TDEST,
  input  [TR7_TUSER_WIDTH-1:0]             AXI4S_T7TUSER,

  //AXI4 Stream Initiator Ports

  output                                   AXI4S_I0TVALID,
  input                                    AXI4S_I0TREADY,
  output [(AXI4S_I0TDATA_BYTES*8)-1:0]     AXI4S_I0TDATA,
  output [(AXI4S_I0TDATA_BYTES)-1:0]       AXI4S_I0TSTRB,
  output [(AXI4S_I0TDATA_BYTES)-1:0]       AXI4S_I0TKEEP,
  output                                   AXI4S_I0TLAST,
  output [ITID_WIDTH-1:0]                  AXI4S_I0TID,
  output [TDEST_WIDTH-1:0]                 AXI4S_I0TDEST,
  output [IR0_TUSER_WIDTH-1:0]             AXI4S_I0TUSER,

  output                                   AXI4S_I1TVALID,
  input                                    AXI4S_I1TREADY,
  output [(AXI4S_I1TDATA_BYTES*8)-1:0]     AXI4S_I1TDATA,
  output [(AXI4S_I1TDATA_BYTES)-1:0]       AXI4S_I1TSTRB,
  output [(AXI4S_I1TDATA_BYTES)-1:0]       AXI4S_I1TKEEP,
  output                                   AXI4S_I1TLAST,
  output [ITID_WIDTH-1:0]                  AXI4S_I1TID,
  output [TDEST_WIDTH-1:0]                 AXI4S_I1TDEST,
  output [IR1_TUSER_WIDTH-1:0]             AXI4S_I1TUSER,

  output                                   AXI4S_I2TVALID,
  input                                    AXI4S_I2TREADY,
  output [(AXI4S_I2TDATA_BYTES*8)-1:0]     AXI4S_I2TDATA,
  output [(AXI4S_I2TDATA_BYTES)-1:0]       AXI4S_I2TSTRB,
  output [(AXI4S_I2TDATA_BYTES)-1:0]       AXI4S_I2TKEEP,
  output                                   AXI4S_I2TLAST,
  output [ITID_WIDTH-1:0]                  AXI4S_I2TID,
  output [TDEST_WIDTH-1:0]                 AXI4S_I2TDEST,
  output [IR2_TUSER_WIDTH-1:0]             AXI4S_I2TUSER,

  output                                   AXI4S_I3TVALID,
  input                                    AXI4S_I3TREADY,
  output [(AXI4S_I3TDATA_BYTES*8)-1:0]     AXI4S_I3TDATA,
  output [(AXI4S_I3TDATA_BYTES)-1:0]       AXI4S_I3TSTRB,
  output [(AXI4S_I3TDATA_BYTES)-1:0]       AXI4S_I3TKEEP,
  output                                   AXI4S_I3TLAST,
  output [ITID_WIDTH-1:0]                  AXI4S_I3TID,
  output [TDEST_WIDTH-1:0]                 AXI4S_I3TDEST,
  output [IR3_TUSER_WIDTH-1:0]             AXI4S_I3TUSER,

  output                                   AXI4S_I4TVALID,
  input                                    AXI4S_I4TREADY,
  output [(AXI4S_I4TDATA_BYTES*8)-1:0]     AXI4S_I4TDATA,
  output [(AXI4S_I4TDATA_BYTES)-1:0]       AXI4S_I4TSTRB,
  output [(AXI4S_I4TDATA_BYTES)-1:0]       AXI4S_I4TKEEP,
  output                                   AXI4S_I4TLAST,
  output [ITID_WIDTH-1:0]                  AXI4S_I4TID,
  output [TDEST_WIDTH-1:0]                 AXI4S_I4TDEST,
  output [IR4_TUSER_WIDTH-1:0]             AXI4S_I4TUSER,

  output                                   AXI4S_I5TVALID,
  input                                    AXI4S_I5TREADY,
  output [(AXI4S_I5TDATA_BYTES*8)-1:0]     AXI4S_I5TDATA,
  output [(AXI4S_I5TDATA_BYTES)-1:0]       AXI4S_I5TSTRB,
  output [(AXI4S_I5TDATA_BYTES)-1:0]       AXI4S_I5TKEEP,
  output                                   AXI4S_I5TLAST,
  output [ITID_WIDTH-1:0]                  AXI4S_I5TID,
  output [TDEST_WIDTH-1:0]                 AXI4S_I5TDEST,
  output [IR5_TUSER_WIDTH-1:0]             AXI4S_I5TUSER,

  output                                   AXI4S_I6TVALID,
  input                                    AXI4S_I6TREADY,
  output [(AXI4S_I6TDATA_BYTES*8)-1:0]     AXI4S_I6TDATA,
  output [(AXI4S_I6TDATA_BYTES)-1:0]       AXI4S_I6TSTRB,
  output [(AXI4S_I6TDATA_BYTES)-1:0]       AXI4S_I6TKEEP,
  output                                   AXI4S_I6TLAST,
  output [ITID_WIDTH-1:0]                  AXI4S_I6TID,
  output [TDEST_WIDTH-1:0]                 AXI4S_I6TDEST,
  output [IR6_TUSER_WIDTH-1:0]             AXI4S_I6TUSER,

  output                                   AXI4S_I7TVALID,
  input                                    AXI4S_I7TREADY,
  output [(AXI4S_I7TDATA_BYTES*8)-1:0]     AXI4S_I7TDATA,
  output [(AXI4S_I7TDATA_BYTES)-1:0]       AXI4S_I7TSTRB,
  output [(AXI4S_I7TDATA_BYTES)-1:0]       AXI4S_I7TKEEP,
  output                                   AXI4S_I7TLAST,
  output [ITID_WIDTH-1:0]                  AXI4S_I7TID,
  output [TDEST_WIDTH-1:0]                 AXI4S_I7TDEST,
  output [IR7_TUSER_WIDTH-1:0]             AXI4S_I7TUSER,

  //Decode Error from SWITCH

  output [NUM_TARGETS-1:0]                 DECODE_ERR
);
/*
  function integer calc_lcm;
    input integer first_num;
    input integer second_num;
    integer x,mult;
    begin
      for(x=1;x<second_num;x=x+1)
          begin
            mult = first_num * x;
            if((mult % second_num) == 0)
              calc_lcm = mult;
          end
      end
  endfunction
*/
  localparam MAX_TARGETS    = 8;
  localparam MAX_INITIATORS = 8;
  localparam INTEGER_SIZE   = 32;

  localparam RESET_TYPE_FIFO = (FAMILY == 25) ? 1'b1 : 1'b0;

  localparam [MAX_TARGETS-1:0]                            TFIFO_ARRAY                  = {
                                                                                           ENABLE_TR7_FIFO,
                                                                                           ENABLE_TR6_FIFO,
                                                                                           ENABLE_TR5_FIFO,
                                                                                           ENABLE_TR4_FIFO,
                                                                                           ENABLE_TR3_FIFO,
                                                                                           ENABLE_TR2_FIFO,
                                                                                           ENABLE_TR1_FIFO,
                                                                                           ENABLE_TR0_FIFO
                                                                                         };

  localparam [MAX_TARGETS-1:0]                            TASYNC_FIFO_ARRAY            = {
                                                                                           TR7_ASYNC_FIFO,
                                                                                           TR6_ASYNC_FIFO,
                                                                                           TR5_ASYNC_FIFO,
                                                                                           TR4_ASYNC_FIFO,
                                                                                           TR3_ASYNC_FIFO,
                                                                                           TR2_ASYNC_FIFO,
                                                                                           TR1_ASYNC_FIFO,
                                                                                           TR0_ASYNC_FIFO
                                                                                         };

  localparam [MAX_TARGETS-1:0]                            TFIFO_ECC_ARRAY            = {
                                                                                           TR7_FIFO_ECC,
                                                                                           TR6_FIFO_ECC,
                                                                                           TR5_FIFO_ECC,
                                                                                           TR4_FIFO_ECC,
                                                                                           TR3_FIFO_ECC,
                                                                                           TR2_FIFO_ECC,
                                                                                           TR1_FIFO_ECC,
                                                                                           TR0_FIFO_ECC
                                                                                         };

  localparam [(MAX_TARGETS*2)-1:0]                        TRAM_TYPE_ARRAY              = {
                                                                                           TR7_RAM_TYPE,
                                                                                           TR6_RAM_TYPE,
                                                                                           TR5_RAM_TYPE,
                                                                                           TR4_RAM_TYPE,
                                                                                           TR3_RAM_TYPE,
                                                                                           TR2_RAM_TYPE,
                                                                                           TR1_RAM_TYPE,
                                                                                           TR0_RAM_TYPE
                                                                                         };

  localparam [MAX_TARGETS-1:0]                            TCDC_PACKET_MODE               = {
                                                                                           TR7_PACKET_MODE,
                                                                                           TR6_PACKET_MODE,
                                                                                           TR5_PACKET_MODE,
                                                                                           TR4_PACKET_MODE,
                                                                                           TR3_PACKET_MODE,
                                                                                           TR2_PACKET_MODE,
                                                                                           TR1_PACKET_MODE,
                                                                                           TR0_PACKET_MODE
                                                                                         };

  localparam [(MAX_TARGETS*32)-1:0]                       TCDC_FIFO_DEPTH              = {
                                                                                           TR7_FIFO_DEPTH,
                                                                                           TR6_FIFO_DEPTH,
                                                                                           TR5_FIFO_DEPTH,
                                                                                           TR4_FIFO_DEPTH,
                                                                                           TR3_FIFO_DEPTH,
                                                                                           TR2_FIFO_DEPTH,
                                                                                           TR1_FIFO_DEPTH,
                                                                                           TR0_FIFO_DEPTH
                                                                                         };

  localparam [(MAX_TARGETS*32)-1:0]                       TDWC_TTDATA_BYTES_ARRAY      = {
                                                                                           AXI4S_T7TDATA_BYTES,
                                                                                           AXI4S_T6TDATA_BYTES,
                                                                                           AXI4S_T5TDATA_BYTES,
                                                                                           AXI4S_T4TDATA_BYTES,
                                                                                           AXI4S_T3TDATA_BYTES,
                                                                                           AXI4S_T2TDATA_BYTES,
                                                                                           AXI4S_T1TDATA_BYTES,
                                                                                           AXI4S_T0TDATA_BYTES
                                                                                         };

  localparam [(MAX_TARGETS*32)-1:0]                       TDWC_TLCM_TDATA_BYTES_ARRAY  = {
                                                                                           TR7_LCM_TDATA_BYTES,
                                                                                           TR6_LCM_TDATA_BYTES,
                                                                                           TR5_LCM_TDATA_BYTES,
                                                                                           TR4_LCM_TDATA_BYTES,
                                                                                           TR3_LCM_TDATA_BYTES,
                                                                                           TR2_LCM_TDATA_BYTES,
                                                                                           TR1_LCM_TDATA_BYTES,
                                                                                           TR0_LCM_TDATA_BYTES
                                                                                         };

  localparam [(MAX_TARGETS*32)-1:0]                       TDWC_TTUSER_WIDTH_ARRAY      = {
                                                                                           TR7_TUSER_WIDTH,
                                                                                           TR6_TUSER_WIDTH,
                                                                                           TR5_TUSER_WIDTH,
                                                                                           TR4_TUSER_WIDTH,
                                                                                           TR3_TUSER_WIDTH,
                                                                                           TR2_TUSER_WIDTH,
                                                                                           TR1_TUSER_WIDTH,
                                                                                           TR0_TUSER_WIDTH
                                                                                         };

  localparam [(MAX_TARGETS*32)-1:0]                       TDWC_ITUSER_WIDTH_ARRAY      = {
                                                                                           TUSER_WIDTH,
                                                                                           TUSER_WIDTH,
                                                                                           TUSER_WIDTH,
                                                                                           TUSER_WIDTH,
                                                                                           TUSER_WIDTH,
                                                                                           TUSER_WIDTH,
                                                                                           TUSER_WIDTH,
                                                                                           TUSER_WIDTH
                                                                                         };
  localparam [(MAX_TARGETS)-1:0]                          TDWC_TRS_ARRAY               = {
                                                                                           AXI4S_TDWC_T7RS,
                                                                                           AXI4S_TDWC_T6RS,
                                                                                           AXI4S_TDWC_T5RS,
                                                                                           AXI4S_TDWC_T4RS,
                                                                                           AXI4S_TDWC_T3RS,
                                                                                           AXI4S_TDWC_T2RS,
                                                                                           AXI4S_TDWC_T1RS,
                                                                                           AXI4S_TDWC_T0RS
                                                                                         };

  localparam [(MAX_TARGETS)-1:0]                          TDWC_IRS_ARRAY               = {
                                                                                           AXI4S_TDWC_I7RS,
                                                                                           AXI4S_TDWC_I6RS,
                                                                                           AXI4S_TDWC_I5RS,
                                                                                           AXI4S_TDWC_I4RS,
                                                                                           AXI4S_TDWC_I3RS,
                                                                                           AXI4S_TDWC_I2RS,
                                                                                           AXI4S_TDWC_I1RS,
                                                                                           AXI4S_TDWC_I0RS
                                                                                         };

  localparam [(MAX_INITIATORS*32)-1:0]                    IDWC_ITDATA_BYTES_ARRAY      = {
                                                                                           AXI4S_I7TDATA_BYTES,
                                                                                           AXI4S_I6TDATA_BYTES,
                                                                                           AXI4S_I5TDATA_BYTES,
                                                                                           AXI4S_I4TDATA_BYTES,
                                                                                           AXI4S_I3TDATA_BYTES,
                                                                                           AXI4S_I2TDATA_BYTES,
                                                                                           AXI4S_I1TDATA_BYTES,
                                                                                           AXI4S_I0TDATA_BYTES
                                                                                         };

  localparam [(MAX_INITIATORS*32)-1:0]                    IDWC_ILCM_IDATA_BYTES_ARRAY  = {
                                                                                           IR7_LCM_TDATA_BYTES,
                                                                                           IR6_LCM_TDATA_BYTES,
                                                                                           IR5_LCM_TDATA_BYTES,
                                                                                           IR4_LCM_TDATA_BYTES,
                                                                                           IR3_LCM_TDATA_BYTES,
                                                                                           IR2_LCM_TDATA_BYTES,
                                                                                           IR1_LCM_TDATA_BYTES,
                                                                                           IR0_LCM_TDATA_BYTES
                                                                                         };

  localparam [(MAX_INITIATORS*32)-1:0]                    IDWC_ITUSER_WIDTH_ARRAY      = {
                                                                                           IR7_TUSER_WIDTH,
                                                                                           IR6_TUSER_WIDTH,
                                                                                           IR5_TUSER_WIDTH,
                                                                                           IR4_TUSER_WIDTH,
                                                                                           IR3_TUSER_WIDTH,
                                                                                           IR2_TUSER_WIDTH,
                                                                                           IR1_TUSER_WIDTH,
                                                                                           IR0_TUSER_WIDTH
                                                                                         };

  localparam [(MAX_INITIATORS)-1:0]                       IDWC_TRS_ARRAY               = {
                                                                                           AXI4S_IDWC_T7RS,
                                                                                           AXI4S_IDWC_T6RS,
                                                                                           AXI4S_IDWC_T5RS,
                                                                                           AXI4S_IDWC_T4RS,
                                                                                           AXI4S_IDWC_T3RS,
                                                                                           AXI4S_IDWC_T2RS,
                                                                                           AXI4S_IDWC_T1RS,
                                                                                           AXI4S_IDWC_T0RS
                                                                                         };

  localparam [(MAX_INITIATORS)-1:0]                       IDWC_IRS_ARRAY               = {
                                                                                           AXI4S_IDWC_I7RS,
                                                                                           AXI4S_IDWC_I6RS,
                                                                                           AXI4S_IDWC_I5RS,
                                                                                           AXI4S_IDWC_I4RS,
                                                                                           AXI4S_IDWC_I3RS,
                                                                                           AXI4S_IDWC_I2RS,
                                                                                           AXI4S_IDWC_I1RS,
                                                                                           AXI4S_IDWC_I0RS
                                                                                         };

  localparam [MAX_INITIATORS-1:0]                         IFIFO_ARRAY                  = {
                                                                                           ENABLE_IR7_FIFO,
                                                                                           ENABLE_IR6_FIFO,
                                                                                           ENABLE_IR5_FIFO,
                                                                                           ENABLE_IR4_FIFO,
                                                                                           ENABLE_IR3_FIFO,
                                                                                           ENABLE_IR2_FIFO,
                                                                                           ENABLE_IR1_FIFO,
                                                                                           ENABLE_IR0_FIFO
                                                                                         };

  localparam [MAX_INITIATORS-1:0]                         IASYNC_FIFO_ARRAY            = {
                                                                                           IR7_ASYNC_FIFO,
                                                                                           IR6_ASYNC_FIFO,
                                                                                           IR5_ASYNC_FIFO,
                                                                                           IR4_ASYNC_FIFO,
                                                                                           IR3_ASYNC_FIFO,
                                                                                           IR2_ASYNC_FIFO,
                                                                                           IR1_ASYNC_FIFO,
                                                                                           IR0_ASYNC_FIFO
                                                                                         };

  localparam [MAX_INITIATORS-1:0]                         IFIFO_ECC_ARRAY            = {
                                                                                           IR7_FIFO_ECC,
                                                                                           IR6_FIFO_ECC,
                                                                                           IR5_FIFO_ECC,
                                                                                           IR4_FIFO_ECC,
                                                                                           IR3_FIFO_ECC,
                                                                                           IR2_FIFO_ECC,
                                                                                           IR1_FIFO_ECC,
                                                                                           IR0_FIFO_ECC
                                                                                         };

  localparam [(MAX_INITIATORS*2)-1:0]                     IRAM_TYPE_ARRAY              = {
                                                                                           IR7_RAM_TYPE,
                                                                                           IR6_RAM_TYPE,
                                                                                           IR5_RAM_TYPE,
                                                                                           IR4_RAM_TYPE,
                                                                                           IR3_RAM_TYPE,
                                                                                           IR2_RAM_TYPE,
                                                                                           IR1_RAM_TYPE,
                                                                                           IR0_RAM_TYPE
                                                                                         };

  localparam [MAX_INITIATORS-1:0]                         ICDC_PACKET_MODE               = {
                                                                                           IR7_PACKET_MODE,
                                                                                           IR6_PACKET_MODE,
                                                                                           IR5_PACKET_MODE,
                                                                                           IR4_PACKET_MODE,
                                                                                           IR3_PACKET_MODE,
                                                                                           IR2_PACKET_MODE,
                                                                                           IR1_PACKET_MODE,
                                                                                           IR0_PACKET_MODE
                                                                                         };

  localparam [(MAX_INITIATORS*32)-1:0]                    ICDC_FIFO_DEPTH              = {
                                                                                           IR7_FIFO_DEPTH,
                                                                                           IR6_FIFO_DEPTH,
                                                                                           IR5_FIFO_DEPTH,
                                                                                           IR4_FIFO_DEPTH,
                                                                                           IR3_FIFO_DEPTH,
                                                                                           IR2_FIFO_DEPTH,
                                                                                           IR1_FIFO_DEPTH,
                                                                                           IR0_FIFO_DEPTH
                                                                                         };

localparam [INTEGER_SIZE-1:0] T0CDC_TTDATA_UPPER = AXI4S_T0TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] T1CDC_TTDATA_UPPER = T0CDC_TTDATA_UPPER + AXI4S_T1TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] T2CDC_TTDATA_UPPER = T1CDC_TTDATA_UPPER + AXI4S_T2TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] T3CDC_TTDATA_UPPER = T2CDC_TTDATA_UPPER + AXI4S_T3TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] T4CDC_TTDATA_UPPER = T3CDC_TTDATA_UPPER + AXI4S_T4TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] T5CDC_TTDATA_UPPER = T4CDC_TTDATA_UPPER + AXI4S_T5TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] T6CDC_TTDATA_UPPER = T5CDC_TTDATA_UPPER + AXI4S_T6TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] T7CDC_TTDATA_UPPER = T6CDC_TTDATA_UPPER + AXI4S_T7TDATA_BYTES;

localparam [(MAX_TARGETS*INTEGER_SIZE)-1:0] TxCDC_TTDATA_UPPER_VEC = { T7CDC_TTDATA_UPPER, T6CDC_TTDATA_UPPER, T5CDC_TTDATA_UPPER, T4CDC_TTDATA_UPPER, 
                                                                       T3CDC_TTDATA_UPPER, T2CDC_TTDATA_UPPER, T1CDC_TTDATA_UPPER, T0CDC_TTDATA_UPPER };
localparam [(MAX_TARGETS*INTEGER_SIZE)-1:0] TxCDC_TTDATA_LOWER_VEC = { T6CDC_TTDATA_UPPER, T5CDC_TTDATA_UPPER, T4CDC_TTDATA_UPPER, T3CDC_TTDATA_UPPER,
                                                                       T2CDC_TTDATA_UPPER, T1CDC_TTDATA_UPPER, T0CDC_TTDATA_UPPER, 32'd0 };

localparam [INTEGER_SIZE-1:0] T0CDC_TTUSER_UPPER = TR0_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] T1CDC_TTUSER_UPPER = T0CDC_TTUSER_UPPER + TR1_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] T2CDC_TTUSER_UPPER = T1CDC_TTUSER_UPPER + TR2_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] T3CDC_TTUSER_UPPER = T2CDC_TTUSER_UPPER + TR3_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] T4CDC_TTUSER_UPPER = T3CDC_TTUSER_UPPER + TR4_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] T5CDC_TTUSER_UPPER = T4CDC_TTUSER_UPPER + TR5_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] T6CDC_TTUSER_UPPER = T5CDC_TTUSER_UPPER + TR6_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] T7CDC_TTUSER_UPPER = T6CDC_TTUSER_UPPER + TR7_TUSER_WIDTH;

localparam [(MAX_TARGETS*INTEGER_SIZE)-1:0] TxCDC_TTUSER_UPPER_VEC = { T7CDC_TTUSER_UPPER, T6CDC_TTUSER_UPPER, T5CDC_TTUSER_UPPER, T4CDC_TTUSER_UPPER, 
                                                                       T3CDC_TTUSER_UPPER, T2CDC_TTUSER_UPPER, T1CDC_TTUSER_UPPER, T0CDC_TTUSER_UPPER };
localparam [(MAX_TARGETS*INTEGER_SIZE)-1:0] TxCDC_TTUSER_LOWER_VEC = { T6CDC_TTUSER_UPPER, T5CDC_TTUSER_UPPER, T4CDC_TTUSER_UPPER, T3CDC_TTUSER_UPPER,
                                                                       T2CDC_TTUSER_UPPER, T1CDC_TTUSER_UPPER, T0CDC_TTUSER_UPPER, 32'd0 };

localparam integer TxCDC_TTDATA_BYTES = (AXI4S_T0TDATA_BYTES+AXI4S_T1TDATA_BYTES+AXI4S_T2TDATA_BYTES+AXI4S_T3TDATA_BYTES+AXI4S_T4TDATA_BYTES+AXI4S_T5TDATA_BYTES+AXI4S_T6TDATA_BYTES+AXI4S_T7TDATA_BYTES);
localparam integer TxCDC_TTUSER_WIDTH = (TR0_TUSER_WIDTH+TR1_TUSER_WIDTH+TR2_TUSER_WIDTH+TR3_TUSER_WIDTH+TR4_TUSER_WIDTH+TR5_TUSER_WIDTH+TR6_TUSER_WIDTH+TR7_TUSER_WIDTH);

localparam [INTEGER_SIZE-1:0] I0CDC_ITDATA_UPPER = AXI4S_I0TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] I1CDC_ITDATA_UPPER = I0CDC_ITDATA_UPPER + AXI4S_I1TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] I2CDC_ITDATA_UPPER = I1CDC_ITDATA_UPPER + AXI4S_I2TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] I3CDC_ITDATA_UPPER = I2CDC_ITDATA_UPPER + AXI4S_I3TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] I4CDC_ITDATA_UPPER = I3CDC_ITDATA_UPPER + AXI4S_I4TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] I5CDC_ITDATA_UPPER = I4CDC_ITDATA_UPPER + AXI4S_I5TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] I6CDC_ITDATA_UPPER = I5CDC_ITDATA_UPPER + AXI4S_I6TDATA_BYTES;
localparam [INTEGER_SIZE-1:0] I7CDC_ITDATA_UPPER = I6CDC_ITDATA_UPPER + AXI4S_I7TDATA_BYTES;

localparam [(MAX_TARGETS*INTEGER_SIZE)-1:0] IxCDC_ITDATA_UPPER_VEC = { I7CDC_ITDATA_UPPER, I6CDC_ITDATA_UPPER, I5CDC_ITDATA_UPPER, I4CDC_ITDATA_UPPER, 
                                                                       I3CDC_ITDATA_UPPER, I2CDC_ITDATA_UPPER, I1CDC_ITDATA_UPPER, I0CDC_ITDATA_UPPER };
localparam [(MAX_TARGETS*INTEGER_SIZE)-1:0] IxCDC_ITDATA_LOWER_VEC = { I6CDC_ITDATA_UPPER, I5CDC_ITDATA_UPPER, I4CDC_ITDATA_UPPER, I3CDC_ITDATA_UPPER,
                                                                       I2CDC_ITDATA_UPPER, I1CDC_ITDATA_UPPER, I0CDC_ITDATA_UPPER, 32'd0 };

localparam [INTEGER_SIZE-1:0] I0CDC_ITUSER_UPPER = IR0_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] I1CDC_ITUSER_UPPER = I0CDC_ITUSER_UPPER + IR1_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] I2CDC_ITUSER_UPPER = I1CDC_ITUSER_UPPER + IR2_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] I3CDC_ITUSER_UPPER = I2CDC_ITUSER_UPPER + IR3_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] I4CDC_ITUSER_UPPER = I3CDC_ITUSER_UPPER + IR4_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] I5CDC_ITUSER_UPPER = I4CDC_ITUSER_UPPER + IR5_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] I6CDC_ITUSER_UPPER = I5CDC_ITUSER_UPPER + IR6_TUSER_WIDTH;
localparam [INTEGER_SIZE-1:0] I7CDC_ITUSER_UPPER = I6CDC_ITUSER_UPPER + IR7_TUSER_WIDTH;

localparam [(MAX_TARGETS*INTEGER_SIZE)-1:0] IxCDC_ITUSER_UPPER_VEC = { I7CDC_ITUSER_UPPER, I6CDC_ITUSER_UPPER, I5CDC_ITUSER_UPPER, I4CDC_ITUSER_UPPER, 
                                                                       I3CDC_ITUSER_UPPER, I2CDC_ITUSER_UPPER, I1CDC_ITUSER_UPPER, I0CDC_ITUSER_UPPER };
localparam [(MAX_TARGETS*INTEGER_SIZE)-1:0] IxCDC_ITUSER_LOWER_VEC = { I6CDC_ITUSER_UPPER, I5CDC_ITUSER_UPPER, I4CDC_ITUSER_UPPER, I3CDC_ITUSER_UPPER,
                                                                       I2CDC_ITUSER_UPPER, I1CDC_ITUSER_UPPER, I0CDC_ITUSER_UPPER, 32'd0 };

localparam integer IxCDC_TTDATA_BYTES = (AXI4S_I0TDATA_BYTES+AXI4S_I1TDATA_BYTES+AXI4S_I2TDATA_BYTES+AXI4S_I3TDATA_BYTES+AXI4S_I4TDATA_BYTES+AXI4S_I5TDATA_BYTES+AXI4S_I6TDATA_BYTES+AXI4S_I7TDATA_BYTES);
localparam integer IxCDC_TTUSER_WIDTH = (IR0_TUSER_WIDTH+IR1_TUSER_WIDTH+IR2_TUSER_WIDTH+IR3_TUSER_WIDTH+IR4_TUSER_WIDTH+IR5_TUSER_WIDTH+IR6_TUSER_WIDTH+IR7_TUSER_WIDTH);

localparam integer NUM_INITIATORS_WIDTH = (NUM_INITIATORS == 1) ? 1 : $clog2(NUM_INITIATORS);

  wire [MAX_TARGETS-1:0]                   T_CLK;
  wire [MAX_TARGETS-1:0]                   T_RESETN;
  wire [MAX_INITIATORS-1:0]                I_CLK;
  wire [MAX_INITIATORS-1:0]                I_RESETN;

  wire [MAX_TARGETS-1:0]                   TCDC_TTVALID;
  wire [MAX_TARGETS-1:0]                   TCDC_TTREADY;
  wire [TxCDC_TTDATA_BYTES*8-1:0]          TCDC_TTDATA ;//[MAX_TARGETS-1:0];
  wire [TxCDC_TTDATA_BYTES-1:0]            TCDC_TTSTRB ;//[MAX_TARGETS-1:0];
  wire [TxCDC_TTDATA_BYTES-1:0]            TCDC_TTKEEP ;//[MAX_TARGETS-1:0];
  wire [MAX_TARGETS-1:0]                   TCDC_TTLAST;
  wire [TID_WIDTH-1:0]                     TCDC_TTID   [MAX_TARGETS-1:0];
  wire [TDEST_WIDTH-1:0]                   TCDC_TTDEST [MAX_TARGETS-1:0];
  wire [TxCDC_TTUSER_WIDTH-1:0]            TCDC_TTUSER ;//[MAX_TARGETS-1:0];

  wire [MAX_TARGETS-1:0]                   TDWC_TTVALID;
  wire [MAX_TARGETS-1:0]                   TDWC_TTREADY;
  wire [TxCDC_TTDATA_BYTES*8-1:0]          TDWC_TTDATA ;//[MAX_TARGETS-1:0];
  wire [TxCDC_TTDATA_BYTES-1:0]            TDWC_TTSTRB ;//[MAX_TARGETS-1:0];
  wire [TxCDC_TTDATA_BYTES-1:0]            TDWC_TTKEEP ;//[MAX_TARGETS-1:0];
  wire [MAX_TARGETS-1:0]                   TDWC_TTLAST ;
  wire [TID_WIDTH-1:0]                     TDWC_TTID   [MAX_TARGETS-1:0];
  wire [TDEST_WIDTH-1:0]                   TDWC_TTDEST [MAX_TARGETS-1:0];
  wire [TxCDC_TTUSER_WIDTH-1:0]            TDWC_TTUSER ;//[MAX_TARGETS-1:0];

  wire [MAX_TARGETS-1:0]                   TDWC_ITVALID;
  wire [MAX_TARGETS-1:0]                   TDWC_ITREADY;
  wire [(TDATA_BYTES*8)-1:0]               TDWC_ITDATA [MAX_TARGETS-1:0];
  wire [TDATA_BYTES-1:0]                   TDWC_ITSTRB [MAX_TARGETS-1:0];
  wire [TDATA_BYTES-1:0]                   TDWC_ITKEEP [MAX_TARGETS-1:0];
  wire [MAX_TARGETS-1:0]                   TDWC_ITLAST;
  wire [TID_WIDTH-1:0]                     TDWC_ITID   [MAX_TARGETS-1:0];
  wire [TDEST_WIDTH-1:0]                   TDWC_ITDEST [MAX_TARGETS-1:0];
  wire [TUSER_WIDTH-1:0]                   TDWC_ITUSER [MAX_TARGETS-1:0];

  wire [MAX_INITIATORS-1:0]                SWITCH_ITVALID;
  wire [MAX_INITIATORS-1:0]                SWITCH_ITREADY;
  wire [(TDATA_BYTES*8)-1:0]               SWITCH_ITDATA [MAX_TARGETS-1:0];
  wire [TDATA_BYTES-1:0]                   SWITCH_ITSTRB [MAX_TARGETS-1:0];
  wire [TDATA_BYTES-1:0]                   SWITCH_ITKEEP [MAX_TARGETS-1:0];
  wire [MAX_INITIATORS-1:0]                SWITCH_ITLAST;
  wire [ITID_WIDTH-1:0]                    SWITCH_ITID   [MAX_TARGETS-1:0];
  wire [TDEST_WIDTH-1:0]                   SWITCH_ITDEST [MAX_TARGETS-1:0];
  wire [TUSER_WIDTH-1:0]                   SWITCH_ITUSER [MAX_TARGETS-1:0];

  wire [MAX_INITIATORS-1:0]                IDWC_ITVALID;
  wire [MAX_INITIATORS-1:0]                IDWC_ITREADY;
  wire [IxCDC_TTDATA_BYTES*8-1:0]          IDWC_ITDATA ;//[MAX_INITIATORS-1:0];
  wire [IxCDC_TTDATA_BYTES-1:0]            IDWC_ITSTRB ;//[MAX_INITIATORS-1:0];
  wire [IxCDC_TTDATA_BYTES-1:0]            IDWC_ITKEEP ;//[MAX_INITIATORS-1:0];
  wire [MAX_INITIATORS-1:0]                IDWC_ITLAST;
  wire [ITID_WIDTH-1:0]                    IDWC_ITID   [MAX_INITIATORS-1:0];
  wire [TDEST_WIDTH-1:0]                   IDWC_ITDEST [MAX_INITIATORS-1:0];
  wire [IxCDC_TTUSER_WIDTH-1:0]            IDWC_ITUSER ;//[MAX_INITIATORS-1:0];

  wire [MAX_INITIATORS-1:0]                ICDC_ITVALID;
  wire [MAX_INITIATORS-1:0]                ICDC_ITREADY;
  wire [IxCDC_TTDATA_BYTES*8-1:0]          ICDC_ITDATA ;//[MAX_INITIATORS-1:0];
  wire [IxCDC_TTDATA_BYTES-1:0]            ICDC_ITSTRB ;//[MAX_INITIATORS-1:0];
  wire [IxCDC_TTDATA_BYTES-1:0]            ICDC_ITKEEP ;//[MAX_INITIATORS-1:0];
  wire [MAX_INITIATORS-1:0]                ICDC_ITLAST;
  wire [ITID_WIDTH-1:0]                    ICDC_ITID   [MAX_INITIATORS-1:0];
  wire [TDEST_WIDTH-1:0]                   ICDC_ITDEST [MAX_INITIATORS-1:0];
  wire [IxCDC_TTUSER_WIDTH-1:0]            ICDC_ITUSER ;//[MAX_INITIATORS-1:0];

  integer                      t;

  generate
    if(NUM_TARGETS == 1 & NUM_INITIATORS == 1)
      begin
        assign T_CLK[0] = AXI4S_T0CLK;
      end
    else
      begin
        if(ENABLE_TR0_FIFO & ~TR0_ASYNC_FIFO)
          assign T_CLK[0] = AXI4S_T0CLK;
        else
          assign T_CLK[0] = ACLK;
      end
  endgenerate

  generate
    if(ENABLE_TR1_FIFO & ~TR1_ASYNC_FIFO)
      assign T_CLK[1] = AXI4S_T1CLK;
    else
      assign T_CLK[1] = ACLK;
  endgenerate
  generate
    if(ENABLE_TR2_FIFO & ~TR2_ASYNC_FIFO)
      assign T_CLK[2] = AXI4S_T2CLK;
    else
      assign T_CLK[2] = ACLK;
  endgenerate
  generate
    if(ENABLE_TR3_FIFO & ~TR3_ASYNC_FIFO)
      assign T_CLK[3] = AXI4S_T3CLK;
    else
      assign T_CLK[3] = ACLK;
  endgenerate
  generate
    if(ENABLE_TR4_FIFO & ~TR4_ASYNC_FIFO)
      assign T_CLK[4] = AXI4S_T4CLK;
    else
      assign T_CLK[4] = ACLK;
  endgenerate
  generate
    if(ENABLE_TR5_FIFO & ~TR5_ASYNC_FIFO)
      assign T_CLK[5] = AXI4S_T5CLK;
    else
      assign T_CLK[5] = ACLK;
  endgenerate
  generate
    if(ENABLE_TR6_FIFO & ~TR6_ASYNC_FIFO)
      assign T_CLK[6] = AXI4S_T6CLK;
    else
      assign T_CLK[6] = ACLK;
  endgenerate
  generate
    if(ENABLE_TR7_FIFO & ~TR7_ASYNC_FIFO)
      assign T_CLK[7] = AXI4S_T7CLK;
    else
      assign T_CLK[7] = ACLK;
  endgenerate

  assign  T_RESETN = {
                      AXI4S_T7RESETN,
                      AXI4S_T6RESETN,
                      AXI4S_T5RESETN,
                      AXI4S_T4RESETN,
                      AXI4S_T3RESETN,
                      AXI4S_T2RESETN,
                      AXI4S_T1RESETN,
                      AXI4S_T0RESETN
                     };

  generate
    if(NUM_TARGETS == 1 & NUM_INITIATORS == 1)
      begin
          assign I_CLK[0] = AXI4S_I0CLK;
      end
    else
      begin
        if(ENABLE_IR0_FIFO & ~IR0_ASYNC_FIFO)
          assign I_CLK[0] = AXI4S_I0CLK;
        else
          assign I_CLK[0] = ACLK;
      end
  endgenerate

  generate
    if(ENABLE_IR1_FIFO & ~IR1_ASYNC_FIFO)
      assign I_CLK[1] = AXI4S_I1CLK;
    else
      assign I_CLK[1] = ACLK;
  endgenerate
  generate
    if(ENABLE_IR2_FIFO & ~IR2_ASYNC_FIFO)
      assign I_CLK[2] = AXI4S_I2CLK;
    else
      assign I_CLK[2] = ACLK;
  endgenerate
  generate
    if(ENABLE_IR3_FIFO & ~IR3_ASYNC_FIFO)
      assign I_CLK[3] = AXI4S_I3CLK;
    else
      assign I_CLK[3] = ACLK;
  endgenerate
  generate
    if(ENABLE_IR4_FIFO & ~IR4_ASYNC_FIFO)
      assign I_CLK[4] = AXI4S_I4CLK;
    else
      assign I_CLK[4] = ACLK;
  endgenerate
  generate
    if(ENABLE_IR5_FIFO & ~IR5_ASYNC_FIFO)
      assign I_CLK[5] = AXI4S_I5CLK;
    else
      assign I_CLK[5] = ACLK;
  endgenerate
  generate
    if(ENABLE_IR6_FIFO & ~IR6_ASYNC_FIFO)
      assign I_CLK[6] = AXI4S_I6CLK;
    else
      assign I_CLK[6] = ACLK;
  endgenerate
  generate
    if(ENABLE_IR7_FIFO & ~IR7_ASYNC_FIFO)
      assign I_CLK[7] = AXI4S_I7CLK;
    else
      assign I_CLK[7] = ACLK;
  endgenerate

  assign  I_RESETN = {
                      AXI4S_I7RESETN,
                      AXI4S_I6RESETN,
                      AXI4S_I5RESETN,
                      AXI4S_I4RESETN,
                      AXI4S_I3RESETN,
                      AXI4S_I2RESETN,
                      AXI4S_I1RESETN,
                      AXI4S_I0RESETN
                     };

  assign  AXI4S_T0TREADY  = TCDC_TTREADY[0];
  assign  TCDC_TTVALID[0] = AXI4S_T0TVALID;
  assign  TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]*8] = AXI4S_T0TDATA;  
  assign  TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  ] = AXI4S_T0TSTRB;
  assign  TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  ] = AXI4S_T0TKEEP;
  assign  TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  ] = AXI4S_T0TUSER;
  assign  TCDC_TTLAST[0]  = AXI4S_T0TLAST;
  assign  TCDC_TTID[0]    = AXI4S_T0TID;
  assign  TCDC_TTDEST[0]  = AXI4S_T0TDEST;

generate
if ( NUM_TARGETS > 1 )
begin
  assign  AXI4S_T1TREADY  = TCDC_TTREADY[1];
  assign  TCDC_TTVALID[1] = AXI4S_T1TVALID;
  assign  TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]*8] = AXI4S_T1TDATA;  
  assign  TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  ] = AXI4S_T1TSTRB;
  assign  TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  ] = AXI4S_T1TKEEP;
  assign  TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  ] = AXI4S_T1TUSER;
  assign  TCDC_TTLAST[1] = AXI4S_T1TLAST;
  assign  TCDC_TTID[1]   = AXI4S_T1TID;
  assign  TCDC_TTDEST[1] = AXI4S_T1TDEST;
end

if ( NUM_TARGETS > 2 )
begin
  assign  AXI4S_T2TREADY  = TCDC_TTREADY[2];
  assign  TCDC_TTVALID[2] = AXI4S_T2TVALID;
  assign  TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]*8] = AXI4S_T2TDATA;  
  assign  TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  ] = AXI4S_T2TSTRB;
  assign  TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  ] = AXI4S_T2TKEEP;
  assign  TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  ] = AXI4S_T2TUSER;
  assign  TCDC_TTLAST[2] = AXI4S_T2TLAST;
  assign  TCDC_TTID[2]   = AXI4S_T2TID;
  assign  TCDC_TTDEST[2] = AXI4S_T2TDEST;
end

if ( NUM_TARGETS > 3 )
begin
  assign  AXI4S_T3TREADY  = TCDC_TTREADY[3];
  assign  TCDC_TTVALID[3] = AXI4S_T3TVALID;
  assign  TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]*8] = AXI4S_T3TDATA;  
  assign  TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  ] = AXI4S_T3TSTRB;
  assign  TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  ] = AXI4S_T3TKEEP;
  assign  TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  ] = AXI4S_T3TUSER;
  assign  TCDC_TTLAST[3] = AXI4S_T3TLAST;
  assign  TCDC_TTID[3]   = AXI4S_T3TID;
  assign  TCDC_TTDEST[3] = AXI4S_T3TDEST;
end

if ( NUM_TARGETS > 4 )
begin
  assign  AXI4S_T4TREADY  = TCDC_TTREADY[4];
  assign  TCDC_TTVALID[4] = AXI4S_T4TVALID;
  assign  TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]*8] = AXI4S_T4TDATA;  
  assign  TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  ] = AXI4S_T4TSTRB;
  assign  TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  ] = AXI4S_T4TKEEP;
  assign  TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  ] = AXI4S_T4TUSER;
  assign  TCDC_TTLAST[4] = AXI4S_T4TLAST;
  assign  TCDC_TTID[4]   = AXI4S_T4TID;
  assign  TCDC_TTDEST[4] = AXI4S_T4TDEST;
end

if ( NUM_TARGETS > 5 )
begin
  assign  AXI4S_T5TREADY  = TCDC_TTREADY[5];
  assign  TCDC_TTVALID[5] = AXI4S_T5TVALID;
  assign  TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]*8] = AXI4S_T5TDATA;  
  assign  TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  ] = AXI4S_T5TSTRB;
  assign  TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  ] = AXI4S_T5TKEEP;
  assign  TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  ] = AXI4S_T5TUSER;
  assign  TCDC_TTLAST[5] = AXI4S_T5TLAST;
  assign  TCDC_TTID[5]   = AXI4S_T5TID;
  assign  TCDC_TTDEST[5] = AXI4S_T5TDEST;
end

if ( NUM_TARGETS > 6 )
begin
  assign  AXI4S_T6TREADY  = TCDC_TTREADY[6];
  assign  TCDC_TTVALID[6] = AXI4S_T6TVALID;
  assign  TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]*8] = AXI4S_T6TDATA;  
  assign  TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  ] = AXI4S_T6TSTRB;
  assign  TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  ] = AXI4S_T6TKEEP;
  assign  TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  ] = AXI4S_T6TUSER;
  assign  TCDC_TTLAST[6] = AXI4S_T6TLAST;
  assign  TCDC_TTID[6]   = AXI4S_T6TID;
  assign  TCDC_TTDEST[6] = AXI4S_T6TDEST;
end

if ( NUM_TARGETS > 7 )
begin
  assign  AXI4S_T7TREADY  = TCDC_TTREADY[7];
  assign  TCDC_TTVALID[7] = AXI4S_T7TVALID;
  assign  TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]*8] = AXI4S_T7TDATA;  
  assign  TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  ] = AXI4S_T7TSTRB;
  assign  TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  ] = AXI4S_T7TKEEP;
  assign  TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  ] = AXI4S_T7TUSER;
  assign  TCDC_TTLAST[7] = AXI4S_T7TLAST;
  assign  TCDC_TTID[7]   = AXI4S_T7TID;
  assign  TCDC_TTDEST[7] = AXI4S_T7TDEST;
end
endgenerate


  assign ICDC_ITREADY[0] = AXI4S_I0TREADY;
  assign AXI4S_I0TVALID  = ICDC_ITVALID[0];
  assign AXI4S_I0TDATA   = ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]*8];
  assign AXI4S_I0TSTRB   = ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  ];
  assign AXI4S_I0TKEEP   = ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  ];
  assign AXI4S_I0TUSER   = ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[(0+1)*INTEGER_SIZE-1:0*INTEGER_SIZE]  ];
  assign AXI4S_I0TLAST   = ICDC_ITLAST[0];
  assign AXI4S_I0TID     = ICDC_ITID[0];
  assign AXI4S_I0TDEST   = ICDC_ITDEST[0];

generate
if ( NUM_INITIATORS > 1 )
begin
  assign ICDC_ITREADY[1] = AXI4S_I1TREADY;
  assign AXI4S_I1TVALID  = ICDC_ITVALID[1];
  assign AXI4S_I1TDATA   = ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]*8];
  assign AXI4S_I1TSTRB   = ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  ];
  assign AXI4S_I1TKEEP   = ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  ];
  assign AXI4S_I1TUSER   = ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[(1+1)*INTEGER_SIZE-1:1*INTEGER_SIZE]  ];
  assign AXI4S_I1TLAST   = ICDC_ITLAST[1];
  assign AXI4S_I1TID     = ICDC_ITID[1];
  assign AXI4S_I1TDEST   = ICDC_ITDEST[1];
end

if ( NUM_INITIATORS > 2 )
begin
  assign ICDC_ITREADY[2] = AXI4S_I2TREADY;
  assign AXI4S_I2TVALID  = ICDC_ITVALID[2];
  assign AXI4S_I2TDATA   = ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]*8];
  assign AXI4S_I2TSTRB   = ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  ];
  assign AXI4S_I2TKEEP   = ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  ];
  assign AXI4S_I2TUSER   = ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[(2+1)*INTEGER_SIZE-1:2*INTEGER_SIZE]  ];
  assign AXI4S_I2TLAST   = ICDC_ITLAST[2];
  assign AXI4S_I2TID     = ICDC_ITID[2];
  assign AXI4S_I2TDEST   = ICDC_ITDEST[2];
end

if ( NUM_INITIATORS > 3 )
begin
  assign ICDC_ITREADY[3] = AXI4S_I3TREADY;
  assign AXI4S_I3TVALID  = ICDC_ITVALID[3];
  assign AXI4S_I3TDATA   = ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]*8];
  assign AXI4S_I3TSTRB   = ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  ];
  assign AXI4S_I3TKEEP   = ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  ];
  assign AXI4S_I3TUSER   = ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[(3+1)*INTEGER_SIZE-1:3*INTEGER_SIZE]  ];
  assign AXI4S_I3TLAST   = ICDC_ITLAST[3];
  assign AXI4S_I3TID     = ICDC_ITID[3];
  assign AXI4S_I3TDEST   = ICDC_ITDEST[3];
end

if ( NUM_INITIATORS > 4 )
begin
  assign ICDC_ITREADY[4] = AXI4S_I4TREADY;
  assign AXI4S_I4TVALID  = ICDC_ITVALID[4];
  assign AXI4S_I4TDATA   = ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]*8];
  assign AXI4S_I4TSTRB   = ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  ];
  assign AXI4S_I4TKEEP   = ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  ];
  assign AXI4S_I4TUSER   = ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[(4+1)*INTEGER_SIZE-1:4*INTEGER_SIZE]  ];
  assign AXI4S_I4TLAST   = ICDC_ITLAST[4];
  assign AXI4S_I4TID     = ICDC_ITID[4];
  assign AXI4S_I4TDEST   = ICDC_ITDEST[4];
end

if ( NUM_INITIATORS > 5 )
begin
  assign ICDC_ITREADY[5] = AXI4S_I5TREADY;
  assign AXI4S_I5TVALID  = ICDC_ITVALID[5];
  assign AXI4S_I5TDATA   = ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]*8];
  assign AXI4S_I5TSTRB   = ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  ];
  assign AXI4S_I5TKEEP   = ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  ];
  assign AXI4S_I5TUSER   = ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[(5+1)*INTEGER_SIZE-1:5*INTEGER_SIZE]  ];
  assign AXI4S_I5TLAST   = ICDC_ITLAST[5];
  assign AXI4S_I5TID     = ICDC_ITID[5];
  assign AXI4S_I5TDEST   = ICDC_ITDEST[5];
end

if ( NUM_INITIATORS > 6 )
begin
  assign ICDC_ITREADY[6] = AXI4S_I6TREADY;
  assign AXI4S_I6TVALID  = ICDC_ITVALID[6];
  assign AXI4S_I6TDATA   = ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]*8];
  assign AXI4S_I6TSTRB   = ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  ];
  assign AXI4S_I6TKEEP   = ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  ];
  assign AXI4S_I6TUSER   = ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[(6+1)*INTEGER_SIZE-1:6*INTEGER_SIZE]  ];
  assign AXI4S_I6TLAST   = ICDC_ITLAST[6];
  assign AXI4S_I6TID     = ICDC_ITID[6];
  assign AXI4S_I6TDEST   = ICDC_ITDEST[6];
end

if ( NUM_INITIATORS > 7 )
begin
  assign ICDC_ITREADY[7] = AXI4S_I7TREADY;
  assign AXI4S_I7TVALID  = ICDC_ITVALID[7];
  assign AXI4S_I7TDATA   = ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]*8];
  assign AXI4S_I7TSTRB   = ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  ];
  assign AXI4S_I7TKEEP   = ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  ];
  assign AXI4S_I7TUSER   = ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[(7+1)*INTEGER_SIZE-1:7*INTEGER_SIZE]  ];
  assign AXI4S_I7TLAST   = ICDC_ITLAST[7];
  assign AXI4S_I7TID     = ICDC_ITID[7];
  assign AXI4S_I7TDEST   = ICDC_ITDEST[7];
end
endgenerate

genvar tcdc;
generate
  for(tcdc=0;tcdc<NUM_TARGETS;tcdc=tcdc+1)
    begin: target_cdc
      if(~(NUM_TARGETS == 1 & NUM_INITIATORS == 1))
        begin
          if(TFIFO_ARRAY[tcdc])
            begin
              COREAXI4S_FIFO #
              (
                //Target DWC Parameters #
                .RESET_TYPE         (RESET_TYPE_FIFO                                     ),
                .SYNC               (TASYNC_FIFO_ARRAY[tcdc]                             ),
                .RAM_TYPE           (TRAM_TYPE_ARRAY[((tcdc+1)*2)-1:tcdc*2]              ),
                .ECC                (TFIFO_ECC_ARRAY[tcdc]                               ),
                .NUM_STAGES         (NUM_STAGES                                          ),
                .READ_MODE          (TCDC_PACKET_MODE[tcdc]                              ),
                                                                                         
                .FIFO_DEPTH         (TCDC_FIFO_DEPTH[((tcdc+1)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]),
                .AXIS_TDATA_WIDTH   (TDWC_TTDATA_BYTES_ARRAY[((tcdc+1)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]),
                .AXIS_TID_WIDTH     (TID_WIDTH                                           ),
                .AXIS_TDEST_WIDTH   (TDEST_WIDTH                                         ),
                .AXIS_TUSER_WIDTH   (TDWC_TTUSER_WIDTH_ARRAY[((tcdc+1)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]),
                                                                                         
                .ENABLE_TSTRB       (ENABLE_TSTRB                                        ),
                .ENABLE_TKEEP       (ENABLE_TKEEP                                        ),
                .ENABLE_TLAST       (ENABLE_TLAST                                        ),
                .ENABLE_TUSER       (ENABLE_TUSER                                        ),
                .ENABLE_TDEST       (ENABLE_TDEST                                        ),
                .ENABLE_TID         (ENABLE_TID                                          )
              ) axi4s_tcdc
              (
                 //Target Clocks and Resets
                .AXI4S_TACLK        (T_CLK[tcdc]                                         ),
                .AXI4S_TARESETN     (T_RESETN[tcdc]                                      ),

                //Switch Clock and Reset

                .AXI4S_IACLK        (ACLK                                                ),
                .AXI4S_IARESETN     (RESETN                                              ),

                 //Target Ports
                .AXI4S_TTVALID      (TCDC_TTVALID[tcdc]                                  ),
                .AXI4S_TTREADY      (TCDC_TTREADY[tcdc]                                  ),
                .AXI4S_TTDATA       (TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]*8]),
                .AXI4S_TTSTRB       (TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ]),
                .AXI4S_TTKEEP       (TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ]),
                .AXI4S_TTLAST       (TCDC_TTLAST[tcdc]                                   ),
                .AXI4S_TTID         (TCDC_TTID[tcdc]                                     ),
                .AXI4S_TTDEST       (TCDC_TTDEST[tcdc]                                   ),
                .AXI4S_TTUSER       (TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ]),

                //Initiator Ports
                .AXI4S_ITVALID      (TDWC_TTVALID[tcdc]                                  ),
                .AXI4S_ITREADY      (TDWC_TTREADY[tcdc]                                  ),
                .AXI4S_ITDATA       (TDWC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]*8]),
                .AXI4S_ITSTRB       (TDWC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ]),
                .AXI4S_ITKEEP       (TDWC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ]),
                .AXI4S_ITLAST       (TDWC_TTLAST[tcdc]                                   ),
                .AXI4S_ITID         (TDWC_TTID[tcdc]                                     ),
                .AXI4S_ITDEST       (TDWC_TTDEST[tcdc]                                   ),
                .AXI4S_ITUSER       (TDWC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ])
             );
           end
         else
           begin
              //Bypass Target DWC if Target ans SWITCH data width is equal#
              assign  TCDC_TTREADY[tcdc] = TDWC_TTREADY[tcdc];
              assign  TDWC_TTVALID[tcdc] = TCDC_TTVALID[tcdc];
              assign  TDWC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]*8]  = TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]*8];
              assign  TDWC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ]  = TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ];
              assign  TDWC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ]  = TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ];
              assign  TDWC_TTLAST[tcdc]  = TCDC_TTLAST[tcdc];
              assign  TDWC_TTDEST[tcdc]  = TCDC_TTDEST[tcdc];
              assign  TDWC_TTID[tcdc]    = TCDC_TTID[tcdc];
              assign  TDWC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ]  = TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+tcdc)*INTEGER_SIZE)-1:tcdc*INTEGER_SIZE]  ];
          end
        end // end of if (~(NUM_TARGETS ==1 & NUM_INITIATORS == 1))
    end // end of for
endgenerate


genvar tdwc;
generate
  for(tdwc=0;tdwc<NUM_TARGETS;tdwc=tdwc+1)
    begin: target_dwc
      if(~(NUM_TARGETS == 1 & NUM_INITIATORS == 1))
        begin
          if(TDATA_BYTES != TDWC_TTDATA_BYTES_ARRAY[((tdwc+1)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE])
            begin
              COREAXI4S_DATAWIDTHCONV #
              (
                //Target DWC Parameters #
                .FAMILY             (FAMILY                                                                                 ),
                .AXI4S_TTDATA_BYTES (TDWC_TTDATA_BYTES_ARRAY[((tdwc+1)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]                   ),
                .AXI4S_ITDATA_BYTES (TDATA_BYTES                                                                            ),
                .LCM_TDATA_BYTES    (TDWC_TLCM_TDATA_BYTES_ARRAY[((tdwc+1)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]               ),
                .AXI4S_TTDATA_WIDTH (TDWC_TTDATA_BYTES_ARRAY[((tdwc+1)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE] * 8               ),
                .AXI4S_ITDATA_WIDTH (TDATA_BYTES * 8                                                                        ),
                .TUSER_BITS_P_BYTE  (TUSER_BITS_P_BYTE                                                                      ),
                .AXI4S_TTUSER_WIDTH (TDWC_TTUSER_WIDTH_ARRAY[((tdwc+1)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]                   ),
                .AXI4S_ITUSER_WIDTH (TUSER_WIDTH                                                                            ),
                .TID_WIDTH          (TID_WIDTH                                                                              ),
                .TDEST_WIDTH        (TDEST_WIDTH                                                                            ),
                .ENABLE_TUSER       (ENABLE_TUSER                                                                           ),
                .ENABLE_TID         (ENABLE_TID                                                                             ),
                .ENABLE_TDEST       (ENABLE_TDEST                                                                           ),
                .ENABLE_TSTRB       (ENABLE_TSTRB                                                                           ),
                .ENABLE_TKEEP       (ENABLE_TKEEP                                                                           ),
                .ENABLE_TLAST       (ENABLE_TLAST                                                                           ),
                .AXI4S_TRS          (TDWC_TRS_ARRAY[tdwc]                                                                   ),
                .AXI4S_IRS          (TDWC_IRS_ARRAY[tdwc]                                                                   )
              ) axi4s_tdwc
              (
                //Target DWC I/O Ports #
                .ACLK               (ACLK                                                ),
                .RESETN             (RESETN                                              ),

                .AXI4S_TTVALID      (TDWC_TTVALID[tdwc]                                  ),
                .AXI4S_TTREADY      (TDWC_TTREADY[tdwc]                                  ),
                .AXI4S_TTDATA       (TDWC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]*8]),
                .AXI4S_TTSTRB       (TDWC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  ]),
                .AXI4S_TTKEEP       (TDWC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  ]),
                .AXI4S_TTLAST       (TDWC_TTLAST[tdwc]                                   ),
                .AXI4S_TTID         (TDWC_TTID[tdwc]                                     ),
                .AXI4S_TTDEST       (TDWC_TTDEST[tdwc]                                   ),
                .AXI4S_TTUSER       (TDWC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  ]),

                .AXI4S_ITVALID      (TDWC_ITVALID[tdwc]                                  ),
                .AXI4S_ITREADY      (TDWC_ITREADY[tdwc]                                  ),
                .AXI4S_ITDATA       (TDWC_ITDATA[tdwc]                                   ),
                .AXI4S_ITSTRB       (TDWC_ITSTRB[tdwc]                                   ),
                .AXI4S_ITKEEP       (TDWC_ITKEEP[tdwc]                                   ),
                .AXI4S_ITLAST       (TDWC_ITLAST[tdwc]                                   ),
                .AXI4S_ITID         (TDWC_ITID[tdwc]                                     ),
                .AXI4S_ITDEST       (TDWC_ITDEST[tdwc]                                   ),
                .AXI4S_ITUSER       (TDWC_ITUSER[tdwc]                                   )
              );
            end
          else
            begin
                //Bypass Target DWC if Target ans SWITCH data width is equal#
                assign  TDWC_TTREADY[tdwc] = TDWC_ITREADY[tdwc];
                assign  TDWC_ITVALID[tdwc] = TDWC_TTVALID[tdwc];
                assign  TDWC_ITDATA[tdwc]  = TDWC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]*8];
                assign  TDWC_ITSTRB[tdwc]  = TDWC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  ];
                assign  TDWC_ITKEEP[tdwc]  = TDWC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  ];
                assign  TDWC_ITLAST[tdwc]  = TDWC_TTLAST[tdwc];
                assign  TDWC_ITDEST[tdwc]  = TDWC_TTDEST[tdwc];
                assign  TDWC_ITID[tdwc]    = TDWC_TTID[tdwc];
                assign  TDWC_ITUSER[tdwc]  = TDWC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+tdwc)*INTEGER_SIZE)-1:tdwc*INTEGER_SIZE]  ];
            end
        end     // end of if (~(NUM_TARGETS ==1 & NUM_INITIATORS == 1))
    end         // end of for
endgenerate

generate
  //Bypass AXI4 Stream Switch if NUM_TARGETS and NUM_INITIATORS are 1
  if(~((NUM_TARGETS == 1) & (NUM_INITIATORS == 1)))
    begin
      COREAXI4S_SWITCH #
      (
        .FAMILY               (FAMILY                  ),
        .NUM_INITIATORS       (NUM_INITIATORS          ),
        .NUM_TARGETS          (NUM_TARGETS             ),
		.MAX_TARGETS          (MAX_TARGETS             ),
		.MAX_INITIATORS       (MAX_INITIATORS          ),
        .NUM_INITIATORS_WIDTH (NUM_INITIATORS_WIDTH    ),
        .NUM_TARGETS_WIDTH    (NUM_TARGETS_WIDTH       ),
        .TID_WIDTH            (TID_WIDTH               ),
        .TDEST_WIDTH          (TDEST_WIDTH             ),
        .TDATA_BYTES          (TDATA_BYTES             ),
        .TDATA_WIDTH          (TDATA_BYTES * 8         ),
        .TUSER_WIDTH          (TUSER_WIDTH             ),
        .ENABLE_TDATA         (ENABLE_TDATA            ),
        .ENABLE_TUSER         (ENABLE_TUSER            ),
        .ENABLE_TID           (ENABLE_TID              ),
        .ENABLE_TREADY        (ENABLE_TREADY           ),
        .ENABLE_TLAST         (ENABLE_TLAST            ),
        .ENABLE_TSTRB         (ENABLE_TSTRB            ),
        .ENABLE_TKEEP         (ENABLE_TKEEP            ),
        .ARB_TYPE             (ARB_TYPE                ),
        .NUM_ARB_TRANS        (NUM_ARB_TRANS           ),
        .ENABLE_TIMEOUT       (ENABLE_TIMEOUT          ),
        .TIMEOUT_CYCLES       (TIMEOUT_CYCLES          ),

        .IR0_ENABLE_ARB       (IR0_ENABLE_ARB          ),
        .IR1_ENABLE_ARB       (IR1_ENABLE_ARB          ),
        .IR2_ENABLE_ARB       (IR2_ENABLE_ARB          ),
        .IR3_ENABLE_ARB       (IR3_ENABLE_ARB          ),
        .IR4_ENABLE_ARB       (IR4_ENABLE_ARB          ),
        .IR5_ENABLE_ARB       (IR5_ENABLE_ARB          ),
        .IR6_ENABLE_ARB       (IR6_ENABLE_ARB          ),
        .IR7_ENABLE_ARB       (IR7_ENABLE_ARB          ),

        .TR0_IR0_LINK         (TR0_IR0_LINK            ),
        .TR0_IR1_LINK         (TR0_IR1_LINK            ),
        .TR0_IR2_LINK         (TR0_IR2_LINK            ),
        .TR0_IR3_LINK         (TR0_IR3_LINK            ),
        .TR0_IR4_LINK         (TR0_IR4_LINK            ),
        .TR0_IR5_LINK         (TR0_IR5_LINK            ),
        .TR0_IR6_LINK         (TR0_IR6_LINK            ),
        .TR0_IR7_LINK         (TR0_IR7_LINK            ),

        .TR1_IR0_LINK         (TR1_IR0_LINK            ),
        .TR1_IR1_LINK         (TR1_IR1_LINK            ),
        .TR1_IR2_LINK         (TR1_IR2_LINK            ),
        .TR1_IR3_LINK         (TR1_IR3_LINK            ),
        .TR1_IR4_LINK         (TR1_IR4_LINK            ),
        .TR1_IR5_LINK         (TR1_IR5_LINK            ),
        .TR1_IR6_LINK         (TR1_IR6_LINK            ),
        .TR1_IR7_LINK         (TR1_IR7_LINK            ),

        .TR2_IR0_LINK         (TR2_IR0_LINK            ),
        .TR2_IR1_LINK         (TR2_IR1_LINK            ),
        .TR2_IR2_LINK         (TR2_IR2_LINK            ),
        .TR2_IR3_LINK         (TR2_IR3_LINK            ),
        .TR2_IR4_LINK         (TR2_IR4_LINK            ),
        .TR2_IR5_LINK         (TR2_IR5_LINK            ),
        .TR2_IR6_LINK         (TR2_IR6_LINK            ),
        .TR2_IR7_LINK         (TR2_IR7_LINK            ),

        .TR3_IR0_LINK         (TR3_IR0_LINK            ),
        .TR3_IR1_LINK         (TR3_IR1_LINK            ),
        .TR3_IR2_LINK         (TR3_IR2_LINK            ),
        .TR3_IR3_LINK         (TR3_IR3_LINK            ),
        .TR3_IR4_LINK         (TR3_IR4_LINK            ),
        .TR3_IR5_LINK         (TR3_IR5_LINK            ),
        .TR3_IR6_LINK         (TR3_IR6_LINK            ),
        .TR3_IR7_LINK         (TR3_IR7_LINK            ),

        .TR4_IR0_LINK         (TR4_IR0_LINK            ),
        .TR4_IR1_LINK         (TR4_IR1_LINK            ),
        .TR4_IR2_LINK         (TR4_IR2_LINK            ),
        .TR4_IR3_LINK         (TR4_IR3_LINK            ),
        .TR4_IR4_LINK         (TR4_IR4_LINK            ),
        .TR4_IR5_LINK         (TR4_IR5_LINK            ),
        .TR4_IR6_LINK         (TR4_IR6_LINK            ),
        .TR4_IR7_LINK         (TR4_IR7_LINK            ),

        .TR5_IR0_LINK         (TR5_IR0_LINK            ),
        .TR5_IR1_LINK         (TR5_IR1_LINK            ),
        .TR5_IR2_LINK         (TR5_IR2_LINK            ),
        .TR5_IR3_LINK         (TR5_IR3_LINK            ),
        .TR5_IR4_LINK         (TR5_IR4_LINK            ),
        .TR5_IR5_LINK         (TR5_IR5_LINK            ),
        .TR5_IR6_LINK         (TR5_IR6_LINK            ),
        .TR5_IR7_LINK         (TR5_IR7_LINK            ),

        .TR6_IR0_LINK         (TR6_IR0_LINK            ),
        .TR6_IR1_LINK         (TR6_IR1_LINK            ),
        .TR6_IR2_LINK         (TR6_IR2_LINK            ),
        .TR6_IR3_LINK         (TR6_IR3_LINK            ),
        .TR6_IR4_LINK         (TR6_IR4_LINK            ),
        .TR6_IR5_LINK         (TR6_IR5_LINK            ),
        .TR6_IR6_LINK         (TR6_IR6_LINK            ),
        .TR6_IR7_LINK         (TR6_IR7_LINK            ),

        .TR7_IR0_LINK         (TR7_IR0_LINK            ),
        .TR7_IR1_LINK         (TR7_IR1_LINK            ),
        .TR7_IR2_LINK         (TR7_IR2_LINK            ),
        .TR7_IR3_LINK         (TR7_IR3_LINK            ),
        .TR7_IR4_LINK         (TR7_IR4_LINK            ),
        .TR7_IR5_LINK         (TR7_IR5_LINK            ),
        .TR7_IR6_LINK         (TR7_IR6_LINK            ),
        .TR7_IR7_LINK         (TR7_IR7_LINK            ),


        .IR0_TDEST_BASE       (IR0_TDEST_BASE          ),
        .IR1_TDEST_BASE       (IR1_TDEST_BASE          ),
        .IR2_TDEST_BASE       (IR2_TDEST_BASE          ),
        .IR3_TDEST_BASE       (IR3_TDEST_BASE          ),
        .IR4_TDEST_BASE       (IR4_TDEST_BASE          ),
        .IR5_TDEST_BASE       (IR5_TDEST_BASE          ),
        .IR6_TDEST_BASE       (IR6_TDEST_BASE          ),
        .IR7_TDEST_BASE       (IR7_TDEST_BASE          ),

        .IR0_TDEST_HIGH       (IR0_TDEST_HIGH          ),
        .IR1_TDEST_HIGH       (IR1_TDEST_HIGH          ),
        .IR2_TDEST_HIGH       (IR2_TDEST_HIGH          ),
        .IR3_TDEST_HIGH       (IR3_TDEST_HIGH          ),
        .IR4_TDEST_HIGH       (IR4_TDEST_HIGH          ),
        .IR5_TDEST_HIGH       (IR5_TDEST_HIGH          ),
        .IR6_TDEST_HIGH       (IR6_TDEST_HIGH          ),
        .IR7_TDEST_HIGH       (IR7_TDEST_HIGH          ),

        .AXI4S_T0RS           (AXI4S_T0RS              ),
        .AXI4S_T1RS           (AXI4S_T1RS              ),
        .AXI4S_T2RS           (AXI4S_T2RS              ),
        .AXI4S_T3RS           (AXI4S_T3RS              ),
        .AXI4S_T4RS           (AXI4S_T4RS              ),
        .AXI4S_T5RS           (AXI4S_T5RS              ),
        .AXI4S_T6RS           (AXI4S_T6RS              ),
        .AXI4S_T7RS           (AXI4S_T7RS              ),

        .AXI4S_I0RS           (AXI4S_I0RS              ),
        .AXI4S_I1RS           (AXI4S_I1RS              ),
        .AXI4S_I2RS           (AXI4S_I2RS              ),
        .AXI4S_I3RS           (AXI4S_I3RS              ),
        .AXI4S_I4RS           (AXI4S_I4RS              ),
        .AXI4S_I5RS           (AXI4S_I5RS              ),
        .AXI4S_I6RS           (AXI4S_I6RS              ),
        .AXI4S_I7RS           (AXI4S_I7RS              )
      ) axi4s_switch
      (
        .ACLK                 (ACLK                    ),
        .RESETN               (RESETN                  ),

        .AXI4S_T0TVALID       (TDWC_ITVALID[0]         ),
        .AXI4S_T0TREADY       (TDWC_ITREADY[0]         ),
        .AXI4S_T0TDATA        (TDWC_ITDATA[0]          ),
        .AXI4S_T0TSTRB        (TDWC_ITSTRB[0]          ),
        .AXI4S_T0TKEEP        (TDWC_ITKEEP[0]          ),
        .AXI4S_T0TLAST        (TDWC_ITLAST[0]          ),
        .AXI4S_T0TID          (TDWC_ITID[0]            ),
        .AXI4S_T0TDEST        (TDWC_ITDEST[0]          ),
        .AXI4S_T0TUSER        (TDWC_ITUSER[0]          ),

        .AXI4S_T1TVALID       (TDWC_ITVALID[1]         ),
        .AXI4S_T1TREADY       (TDWC_ITREADY[1]         ),
        .AXI4S_T1TDATA        (TDWC_ITDATA[1]          ),
        .AXI4S_T1TSTRB        (TDWC_ITSTRB[1]          ),
        .AXI4S_T1TKEEP        (TDWC_ITKEEP[1]          ),
        .AXI4S_T1TLAST        (TDWC_ITLAST[1]          ),
        .AXI4S_T1TID          (TDWC_ITID[1]            ),
        .AXI4S_T1TDEST        (TDWC_ITDEST[1]          ),
        .AXI4S_T1TUSER        (TDWC_ITUSER[1]          ),

        .AXI4S_T2TVALID       (TDWC_ITVALID[2]         ),
        .AXI4S_T2TREADY       (TDWC_ITREADY[2]         ),
        .AXI4S_T2TDATA        (TDWC_ITDATA[2]          ),
        .AXI4S_T2TSTRB        (TDWC_ITSTRB[2]          ),
        .AXI4S_T2TKEEP        (TDWC_ITKEEP[2]          ),
        .AXI4S_T2TLAST        (TDWC_ITLAST[2]          ),
        .AXI4S_T2TID          (TDWC_ITID[2]            ),
        .AXI4S_T2TDEST        (TDWC_ITDEST[2]          ),
        .AXI4S_T2TUSER        (TDWC_ITUSER[2]          ),

        .AXI4S_T3TVALID       (TDWC_ITVALID[3]         ),
        .AXI4S_T3TREADY       (TDWC_ITREADY[3]         ),
        .AXI4S_T3TDATA        (TDWC_ITDATA[3]          ),
        .AXI4S_T3TSTRB        (TDWC_ITSTRB[3]          ),
        .AXI4S_T3TKEEP        (TDWC_ITKEEP[3]          ),
        .AXI4S_T3TLAST        (TDWC_ITLAST[3]          ),
        .AXI4S_T3TID          (TDWC_ITID[3]            ),
        .AXI4S_T3TDEST        (TDWC_ITDEST[3]          ),
        .AXI4S_T3TUSER        (TDWC_ITUSER[3]          ),

        .AXI4S_T4TVALID       (TDWC_ITVALID[4]         ),
        .AXI4S_T4TREADY       (TDWC_ITREADY[4]         ),
        .AXI4S_T4TDATA        (TDWC_ITDATA[4]          ),
        .AXI4S_T4TSTRB        (TDWC_ITSTRB[4]          ),
        .AXI4S_T4TKEEP        (TDWC_ITKEEP[4]          ),
        .AXI4S_T4TLAST        (TDWC_ITLAST[4]          ),
        .AXI4S_T4TID          (TDWC_ITID[4]            ),
        .AXI4S_T4TDEST        (TDWC_ITDEST[4]          ),
        .AXI4S_T4TUSER        (TDWC_ITUSER[4]          ),

        .AXI4S_T5TVALID       (TDWC_ITVALID[5]         ),
        .AXI4S_T5TREADY       (TDWC_ITREADY[5]         ),
        .AXI4S_T5TDATA        (TDWC_ITDATA[5]          ),
        .AXI4S_T5TSTRB        (TDWC_ITSTRB[5]          ),
        .AXI4S_T5TKEEP        (TDWC_ITKEEP[5]          ),
        .AXI4S_T5TLAST        (TDWC_ITLAST[5]          ),
        .AXI4S_T5TID          (TDWC_ITID[5]            ),
        .AXI4S_T5TDEST        (TDWC_ITDEST[5]          ),
        .AXI4S_T5TUSER        (TDWC_ITUSER[5]          ),

        .AXI4S_T6TVALID       (TDWC_ITVALID[6]         ),
        .AXI4S_T6TREADY       (TDWC_ITREADY[6]         ),
        .AXI4S_T6TDATA        (TDWC_ITDATA[6]          ),
        .AXI4S_T6TSTRB        (TDWC_ITSTRB[6]          ),
        .AXI4S_T6TKEEP        (TDWC_ITKEEP[6]          ),
        .AXI4S_T6TLAST        (TDWC_ITLAST[6]          ),
        .AXI4S_T6TID          (TDWC_ITID[6]            ),
        .AXI4S_T6TDEST        (TDWC_ITDEST[6]          ),
        .AXI4S_T6TUSER        (TDWC_ITUSER[6]          ),

        .AXI4S_T7TVALID       (TDWC_ITVALID[7]         ),
        .AXI4S_T7TREADY       (TDWC_ITREADY[7]         ),
        .AXI4S_T7TDATA        (TDWC_ITDATA[7]          ),
        .AXI4S_T7TSTRB        (TDWC_ITSTRB[7]          ),
        .AXI4S_T7TKEEP        (TDWC_ITKEEP[7]          ),
        .AXI4S_T7TLAST        (TDWC_ITLAST[7]          ),
        .AXI4S_T7TID          (TDWC_ITID[7]            ),
        .AXI4S_T7TDEST        (TDWC_ITDEST[7]          ),
        .AXI4S_T7TUSER        (TDWC_ITUSER[7]          ),

        .AXI4S_I0TVALID       (SWITCH_ITVALID[0]       ),
        .AXI4S_I0TREADY       (SWITCH_ITREADY[0]       ),
        .AXI4S_I0TDATA        (SWITCH_ITDATA[0]        ),
        .AXI4S_I0TSTRB        (SWITCH_ITSTRB[0]        ),
        .AXI4S_I0TKEEP        (SWITCH_ITKEEP[0]        ),
        .AXI4S_I0TLAST        (SWITCH_ITLAST[0]        ),
        .AXI4S_I0TID          (SWITCH_ITID[0]          ),
        .AXI4S_I0TDEST        (SWITCH_ITDEST[0]        ),
        .AXI4S_I0TUSER        (SWITCH_ITUSER[0]        ),

        .AXI4S_I1TVALID       (SWITCH_ITVALID[1]       ),
        .AXI4S_I1TREADY       (SWITCH_ITREADY[1]       ),
        .AXI4S_I1TDATA        (SWITCH_ITDATA[1]        ),
        .AXI4S_I1TSTRB        (SWITCH_ITSTRB[1]        ),
        .AXI4S_I1TKEEP        (SWITCH_ITKEEP[1]        ),
        .AXI4S_I1TLAST        (SWITCH_ITLAST[1]        ),
        .AXI4S_I1TID          (SWITCH_ITID[1]          ),
        .AXI4S_I1TDEST        (SWITCH_ITDEST[1]        ),
        .AXI4S_I1TUSER        (SWITCH_ITUSER[1]        ),

        .AXI4S_I2TVALID       (SWITCH_ITVALID[2]       ),
        .AXI4S_I2TREADY       (SWITCH_ITREADY[2]       ),
        .AXI4S_I2TDATA        (SWITCH_ITDATA[2]        ),
        .AXI4S_I2TSTRB        (SWITCH_ITSTRB[2]        ),
        .AXI4S_I2TKEEP        (SWITCH_ITKEEP[2]        ),
        .AXI4S_I2TLAST        (SWITCH_ITLAST[2]        ),
        .AXI4S_I2TID          (SWITCH_ITID[2]          ),
        .AXI4S_I2TDEST        (SWITCH_ITDEST[2]        ),
        .AXI4S_I2TUSER        (SWITCH_ITUSER[2]        ),

        .AXI4S_I3TVALID       (SWITCH_ITVALID[3]       ),
        .AXI4S_I3TREADY       (SWITCH_ITREADY[3]       ),
        .AXI4S_I3TDATA        (SWITCH_ITDATA[3]        ),
        .AXI4S_I3TSTRB        (SWITCH_ITSTRB[3]        ),
        .AXI4S_I3TKEEP        (SWITCH_ITKEEP[3]        ),
        .AXI4S_I3TLAST        (SWITCH_ITLAST[3]        ),
        .AXI4S_I3TID          (SWITCH_ITID[3]          ),
        .AXI4S_I3TDEST        (SWITCH_ITDEST[3]        ),
        .AXI4S_I3TUSER        (SWITCH_ITUSER[3]        ),

        .AXI4S_I4TVALID       (SWITCH_ITVALID[4]       ),
        .AXI4S_I4TREADY       (SWITCH_ITREADY[4]       ),
        .AXI4S_I4TDATA        (SWITCH_ITDATA[4]        ),
        .AXI4S_I4TSTRB        (SWITCH_ITSTRB[4]        ),
        .AXI4S_I4TKEEP        (SWITCH_ITKEEP[4]        ),
        .AXI4S_I4TLAST        (SWITCH_ITLAST[4]        ),
        .AXI4S_I4TID          (SWITCH_ITID[4]          ),
        .AXI4S_I4TDEST        (SWITCH_ITDEST[4]        ),
        .AXI4S_I4TUSER        (SWITCH_ITUSER[4]        ),

        .AXI4S_I5TVALID       (SWITCH_ITVALID[5]       ),
        .AXI4S_I5TREADY       (SWITCH_ITREADY[5]       ),
        .AXI4S_I5TDATA        (SWITCH_ITDATA[5]        ),
        .AXI4S_I5TSTRB        (SWITCH_ITSTRB[5]        ),
        .AXI4S_I5TKEEP        (SWITCH_ITKEEP[5]        ),
        .AXI4S_I5TLAST        (SWITCH_ITLAST[5]        ),
        .AXI4S_I5TID          (SWITCH_ITID[5]          ),
        .AXI4S_I5TDEST        (SWITCH_ITDEST[5]        ),
        .AXI4S_I5TUSER        (SWITCH_ITUSER[5]        ),

        .AXI4S_I6TVALID       (SWITCH_ITVALID[6]       ),
        .AXI4S_I6TREADY       (SWITCH_ITREADY[6]       ),
        .AXI4S_I6TDATA        (SWITCH_ITDATA[6]        ),
        .AXI4S_I6TSTRB        (SWITCH_ITSTRB[6]        ),
        .AXI4S_I6TKEEP        (SWITCH_ITKEEP[6]        ),
        .AXI4S_I6TLAST        (SWITCH_ITLAST[6]        ),
        .AXI4S_I6TID          (SWITCH_ITID[6]          ),
        .AXI4S_I6TDEST        (SWITCH_ITDEST[6]        ),
        .AXI4S_I6TUSER        (SWITCH_ITUSER[6]        ),

        .AXI4S_I7TVALID       (SWITCH_ITVALID[7]       ),
        .AXI4S_I7TREADY       (SWITCH_ITREADY[7]       ),
        .AXI4S_I7TDATA        (SWITCH_ITDATA[7]        ),
        .AXI4S_I7TSTRB        (SWITCH_ITSTRB[7]        ),
        .AXI4S_I7TKEEP        (SWITCH_ITKEEP[7]        ),
        .AXI4S_I7TLAST        (SWITCH_ITLAST[7]        ),
        .AXI4S_I7TID          (SWITCH_ITID[7]          ),
        .AXI4S_I7TDEST        (SWITCH_ITDEST[7]        ),
        .AXI4S_I7TUSER        (SWITCH_ITUSER[7]        ),

        .DECODE_ERR           (DECODE_ERR              )

      );
    end
endgenerate

genvar idwc;
generate
  for(idwc=0;idwc<NUM_INITIATORS;idwc=idwc+1)
    begin: initiator_dwc
      if(~(NUM_TARGETS ==1 & NUM_INITIATORS == 1))
        begin
          if(TDATA_BYTES != IDWC_ITDATA_BYTES_ARRAY[((idwc+1)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE])
            begin
              COREAXI4S_DATAWIDTHCONV #
              (
                //Target DWC Parameters #
                .FAMILY             (FAMILY                                                                                 ),
                .AXI4S_TTDATA_BYTES (TDATA_BYTES                                                                            ),
                .AXI4S_ITDATA_BYTES (IDWC_ITDATA_BYTES_ARRAY[((idwc+1)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]                   ),
                .LCM_TDATA_BYTES    (IDWC_ILCM_IDATA_BYTES_ARRAY[((idwc+1)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]               ),
                .AXI4S_TTDATA_WIDTH (TDATA_BYTES * 8                                                                        ),
                .AXI4S_ITDATA_WIDTH (IDWC_ITDATA_BYTES_ARRAY[((idwc+1)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE] * 8               ),
                .TUSER_BITS_P_BYTE  (TUSER_BITS_P_BYTE                                                                      ),
                .AXI4S_TTUSER_WIDTH (TUSER_WIDTH                                                                            ),
                .AXI4S_ITUSER_WIDTH (IDWC_ITUSER_WIDTH_ARRAY[((idwc+1)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]                   ),
                .TID_WIDTH          (ITID_WIDTH                                                                             ),
                .TDEST_WIDTH        (TDEST_WIDTH                                                                            ),
                .ENABLE_TUSER       (ENABLE_TUSER                                                                           ),
                .ENABLE_TID         (ENABLE_TID                                                                             ),
                .ENABLE_TDEST       (ENABLE_TDEST                                                                           ),
                .ENABLE_TSTRB       (ENABLE_TSTRB                                                                           ),
                .ENABLE_TKEEP       (ENABLE_TKEEP                                                                           ),
                .ENABLE_TLAST       (ENABLE_TLAST                                                                           ),
                .AXI4S_TRS          (IDWC_TRS_ARRAY[idwc]                                                                   ),
                .AXI4S_IRS          (IDWC_IRS_ARRAY[idwc]                                                                   )
              ) axi4s_tdwc
              (
                //Target DWC I/O Ports #
                .ACLK               (ACLK                                                ),
                .RESETN             (RESETN                                              ),

                .AXI4S_TTVALID      (SWITCH_ITVALID[idwc]                                ),
                .AXI4S_TTREADY      (SWITCH_ITREADY[idwc]                                ),
                .AXI4S_TTDATA       (SWITCH_ITDATA[idwc]                                 ),
                .AXI4S_TTSTRB       (SWITCH_ITSTRB[idwc]                                 ),
                .AXI4S_TTKEEP       (SWITCH_ITKEEP[idwc]                                 ),
                .AXI4S_TTLAST       (SWITCH_ITLAST[idwc]                                 ),
                .AXI4S_TTID         (SWITCH_ITID[idwc]                                   ),
                .AXI4S_TTDEST       (SWITCH_ITDEST[idwc]                                 ),
                .AXI4S_TTUSER       (SWITCH_ITUSER[idwc]                                 ),

                .AXI4S_ITVALID      (IDWC_ITVALID[idwc]                                  ),
                .AXI4S_ITREADY      (IDWC_ITREADY[idwc]                                  ),
                .AXI4S_ITDATA       (IDWC_ITDATA[IxCDC_ITDATA_UPPER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]*8]),
                .AXI4S_ITSTRB       (IDWC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  ]),
                .AXI4S_ITKEEP       (IDWC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  ]),
                .AXI4S_ITLAST       (IDWC_ITLAST[idwc]                                   ),
                .AXI4S_ITID         (IDWC_ITID[idwc]                                     ),
                .AXI4S_ITDEST       (IDWC_ITDEST[idwc]                                   ),
                .AXI4S_ITUSER       (IDWC_ITUSER[IxCDC_ITUSER_UPPER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  ])
              );
            end
          else
            begin
                //Bypass Target DWC if Target ans SWITCH data width is equal#
                assign  SWITCH_ITREADY[idwc] = IDWC_ITREADY[idwc];
                assign  IDWC_ITVALID[idwc]   = SWITCH_ITVALID[idwc];
                assign  IDWC_ITDATA[IxCDC_ITDATA_UPPER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]*8]    = SWITCH_ITDATA[idwc];
                assign  IDWC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  ]    = SWITCH_ITSTRB[idwc];
                assign  IDWC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  ]    = SWITCH_ITKEEP[idwc];
                assign  IDWC_ITLAST[idwc]    = SWITCH_ITLAST[idwc];
                assign  IDWC_ITDEST[idwc]    = SWITCH_ITDEST[idwc];
                assign  IDWC_ITID[idwc]      = SWITCH_ITID[idwc];
                assign  IDWC_ITUSER[IxCDC_ITUSER_UPPER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[((1+idwc)*INTEGER_SIZE)-1:idwc*INTEGER_SIZE]  ]    = SWITCH_ITUSER[idwc];
            end
        end     // end of if (~(NUM_TARGETS ==1 & NUM_INITIATORS == 1))
    end         // end of for
endgenerate


genvar icdc;
generate
  for(icdc=0;icdc<NUM_INITIATORS;icdc=icdc+1)
    begin: initiator_cdc
      if(~(NUM_TARGETS ==1 & NUM_INITIATORS == 1))
        begin
          if(IFIFO_ARRAY[icdc])
            begin
              COREAXI4S_FIFO #
              (
            //Target DWC Parameters #
                .RESET_TYPE         (RESET_TYPE_FIFO                                                                        ),
                .SYNC               (IASYNC_FIFO_ARRAY[icdc]                                                                ),
                .RAM_TYPE           (IRAM_TYPE_ARRAY[((icdc+1)*2)-1: icdc*2]                                                ),
                .ECC                (IFIFO_ECC_ARRAY[icdc]                                                                  ),
                .NUM_STAGES         (NUM_STAGES                                                                             ),
                .READ_MODE          (ICDC_PACKET_MODE[icdc]                                                                 ),

                .FIFO_DEPTH         (ICDC_FIFO_DEPTH[((icdc+1)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]                           ),
                .AXIS_TDATA_WIDTH   (IDWC_ITDATA_BYTES_ARRAY[((icdc+1)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]                   ),
                .AXIS_TID_WIDTH     (ITID_WIDTH                                                                             ),
                .AXIS_TDEST_WIDTH   (TDEST_WIDTH                                                                            ),
                .AXIS_TUSER_WIDTH   (IDWC_ITUSER_WIDTH_ARRAY[((icdc+1)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]                   ),

                .ENABLE_TSTRB       (ENABLE_TSTRB                                                                           ),
                .ENABLE_TKEEP       (ENABLE_TKEEP                                                                           ),
                .ENABLE_TLAST       (ENABLE_TLAST                                                                           ),
                .ENABLE_TUSER       (ENABLE_TUSER                                                                           ),
                .ENABLE_TDEST       (ENABLE_TDEST                                                                           ),
                .ENABLE_TID         (ENABLE_TID                                                                             )
              ) axi4s_tcdc
              (
                 //Target Clocks and Resets
                .AXI4S_TACLK        (ACLK                                                ),
                .AXI4S_TARESETN     (RESETN                                              ),

                //Switch Clock and Reset

                .AXI4S_IACLK        (I_CLK[icdc]                                         ),
                .AXI4S_IARESETN     (I_RESETN[icdc]                                      ),

                 //Target Ports
                .AXI4S_TTVALID      (IDWC_ITVALID[icdc]                                  ),
                .AXI4S_TTREADY      (IDWC_ITREADY[icdc]                                  ),
                .AXI4S_TTDATA       (IDWC_ITDATA[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]*8]),
                .AXI4S_TTSTRB       (IDWC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ]),
                .AXI4S_TTKEEP       (IDWC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ]),
                .AXI4S_TTLAST       (IDWC_ITLAST[icdc]                                   ),
                .AXI4S_TTID         (IDWC_ITID[icdc]                                     ),
                .AXI4S_TTDEST       (IDWC_ITDEST[icdc]                                   ),
                .AXI4S_TTUSER       (IDWC_ITUSER[IxCDC_ITUSER_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ]),

                //Initiator Ports
                .AXI4S_ITVALID      (ICDC_ITVALID[icdc]                                  ),
                .AXI4S_ITREADY      (ICDC_ITREADY[icdc]                                  ),
                .AXI4S_ITDATA       (ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]*8]),
                .AXI4S_ITSTRB       (ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ]),
                .AXI4S_ITKEEP       (ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ]),
                .AXI4S_ITLAST       (ICDC_ITLAST[icdc]                                   ),
                .AXI4S_ITID         (ICDC_ITID[icdc]                                     ),
                .AXI4S_ITDEST       (ICDC_ITDEST[icdc]                                   ),
                .AXI4S_ITUSER       (ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ])
              );
            end
          else
            begin
                //Bypass Target DWC if Target ans SWITCH data width is equal#
                assign  IDWC_ITREADY[icdc] = ICDC_ITREADY[icdc];
                assign  ICDC_ITVALID[icdc] = IDWC_ITVALID[icdc];
                assign  ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]*8]  = IDWC_ITDATA[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]*8];
                assign  ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ]  = IDWC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ];
                assign  ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ]  = IDWC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ];
                assign  ICDC_ITLAST[icdc]  = IDWC_ITLAST[icdc];
                assign  ICDC_ITDEST[icdc]  = IDWC_ITDEST[icdc];
                assign  ICDC_ITID[icdc]    = IDWC_ITID[icdc];
                assign  ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ]  = IDWC_ITUSER[IxCDC_ITUSER_UPPER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[((1+icdc)*INTEGER_SIZE)-1:icdc*INTEGER_SIZE]  ];
            end
        end     // end of if (~(NUM_TARGETS ==1 & NUM_INITIATORS == 1))
    end         // end of for
endgenerate

//When NUM_TARGETS and NUM_INITIATORS both are set to 1, all the above modules are bypassed.
//FIFO will be instantiated if ENABLE_TR0_FIFO is set to 1 and similar way if TDATA_BYTES of Initiator 0 and Target 0 are
//not equal then DWC is instantiated.
//Note: In the configurator, when NUM_INITIATORS and NUM_TARGETS are set to 1, all the AXI4S_SWITCH parameters should be
//disabled and ENABLE_IR0_FIFO should also be disabled.

generate
  if(NUM_TARGETS == 1 & NUM_INITIATORS == 1)
    begin
      if(TFIFO_ARRAY[0])
        begin
          COREAXI4S_FIFO #
          (
            //Target DWC Parameters #
            .RESET_TYPE         (RESET_TYPE_FIFO                                      ),
            .SYNC               (TASYNC_FIFO_ARRAY[0]                                 ),
            .RAM_TYPE           (TRAM_TYPE_ARRAY[((0+1)*2)-1:0*2]                     ),
            .ECC                (TFIFO_ECC_ARRAY[0]                                   ),
            .NUM_STAGES         (NUM_STAGES                                           ),
            .READ_MODE          (TCDC_PACKET_MODE[0]                                  ),

            .FIFO_DEPTH         (TCDC_FIFO_DEPTH[((0+1)*INTEGER_SIZE)-1:0*INTEGER_SIZE]),
            .AXIS_TDATA_WIDTH   (TDWC_TTDATA_BYTES_ARRAY[((0+1)*INTEGER_SIZE)-1:0*INTEGER_SIZE]),
            .AXIS_TID_WIDTH     (TID_WIDTH                                            ),
            .AXIS_TDEST_WIDTH   (TDEST_WIDTH                                          ),
            .AXIS_TUSER_WIDTH   (TDWC_TTUSER_WIDTH_ARRAY[((0+1)*INTEGER_SIZE)-1:0*INTEGER_SIZE]),

            .ENABLE_TSTRB       (ENABLE_TSTRB                                         ),
            .ENABLE_TKEEP       (ENABLE_TKEEP                                         ),
            .ENABLE_TLAST       (ENABLE_TLAST                                         ),
            .ENABLE_TUSER       (ENABLE_TUSER                                         ),
            .ENABLE_TDEST       (ENABLE_TDEST                                         ),
            .ENABLE_TID         (ENABLE_TID                                           )
          ) axi4s_tcdc
          (
             //Target Clocks and Resets
            .AXI4S_TACLK        (T_CLK[0]                                             ),
            .AXI4S_TARESETN     (T_RESETN[0]                                          ),

             //Switch Clock and Reset

            .AXI4S_IACLK        (I_CLK[0]                                             ),
            .AXI4S_IARESETN     (I_RESETN[0]                                          ),

             //Target Ports
            .AXI4S_TTVALID      (TCDC_TTVALID[0]                                      ),
            .AXI4S_TTREADY      (TCDC_TTREADY[0]                                      ),
            .AXI4S_TTDATA       (TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8]),
            .AXI4S_TTSTRB       (TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]),
            .AXI4S_TTKEEP       (TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]),
            .AXI4S_TTLAST       (TCDC_TTLAST[0]                                       ),
            .AXI4S_TTID         (TCDC_TTID[0]                                         ),
            .AXI4S_TTDEST       (TCDC_TTDEST[0]                                       ),
            .AXI4S_TTUSER       (TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]),

            //Initiator Ports
            .AXI4S_ITVALID      (TDWC_TTVALID[0]                                      ),
            .AXI4S_ITREADY      (TDWC_TTREADY[0]                                      ),
            .AXI4S_ITDATA       (TDWC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8]),
            .AXI4S_ITSTRB       (TDWC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]),
            .AXI4S_ITKEEP       (TDWC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]),
            .AXI4S_ITLAST       (TDWC_TTLAST[0]                                       ),
            .AXI4S_ITID         (TDWC_TTID[0]                                         ),
            .AXI4S_ITDEST       (TDWC_TTDEST[0]                                       ),
            .AXI4S_ITUSER       (TDWC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ])
          );
        end
      else
        begin
           //Bypass Target DWC if Target ans SWITCH data width is equal#
           assign  TCDC_TTREADY[0] = TDWC_TTREADY[0];
           assign  TDWC_TTVALID[0] = TCDC_TTVALID[0];
           assign  TDWC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8]  = TCDC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8];
           assign  TDWC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]  = TCDC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ];
           assign  TDWC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]  = TCDC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ];
           assign  TDWC_TTLAST[0]  = TCDC_TTLAST[0];
           assign  TDWC_TTDEST[0]  = TCDC_TTDEST[0];
           assign  TDWC_TTID[0]    = TCDC_TTID[0];
           assign  TDWC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]  = TCDC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ];
       end

     if(IDWC_ITDATA_BYTES_ARRAY[31:0] != TDWC_TTDATA_BYTES_ARRAY[31:0])
       begin
         COREAXI4S_DATAWIDTHCONV #
         (
           //Target DWC Parameters #
           .FAMILY             (FAMILY                                                             ),
           .AXI4S_TTDATA_BYTES (TDWC_TTDATA_BYTES_ARRAY[((0+1)*INTEGER_SIZE)-1:0*INTEGER_SIZE]     ),
           .AXI4S_ITDATA_BYTES (IDWC_ITDATA_BYTES_ARRAY[((0+1)*INTEGER_SIZE)-1:0*INTEGER_SIZE]     ),
           .LCM_TDATA_BYTES    (TDWC_TLCM_TDATA_BYTES_ARRAY[((0+1)*INTEGER_SIZE)-1:0*INTEGER_SIZE] ),
           .AXI4S_TTDATA_WIDTH (TDWC_TTDATA_BYTES_ARRAY[((0+1)*INTEGER_SIZE)-1:0*INTEGER_SIZE] * 8 ),
           .AXI4S_ITDATA_WIDTH (IDWC_ITDATA_BYTES_ARRAY[((0+1)*INTEGER_SIZE)-1:0*INTEGER_SIZE] * 8 ),
           .TUSER_BITS_P_BYTE  (TUSER_BITS_P_BYTE                                                  ),
           .AXI4S_TTUSER_WIDTH (TDWC_TTUSER_WIDTH_ARRAY[((0+1)*INTEGER_SIZE)-1:0*INTEGER_SIZE]     ),
           .AXI4S_ITUSER_WIDTH (IDWC_ITUSER_WIDTH_ARRAY[((0+1)*INTEGER_SIZE)-1:0*INTEGER_SIZE]     ),
           .TID_WIDTH          (ITID_WIDTH                                                         ),
           .TDEST_WIDTH        (TDEST_WIDTH                                                        ),
           .ENABLE_TUSER       (ENABLE_TUSER                                                       ),
           .ENABLE_TID         (ENABLE_TID                                                         ),
           .ENABLE_TDEST       (ENABLE_TDEST                                                       ),
           .ENABLE_TSTRB       (ENABLE_TSTRB                                                       ),
           .ENABLE_TKEEP       (ENABLE_TKEEP                                                       ),
           .ENABLE_TLAST       (ENABLE_TLAST                                                       ),
           .AXI4S_TRS          (TDWC_TRS_ARRAY[0]                                                  ),
           .AXI4S_IRS          (TDWC_IRS_ARRAY[0]                                                  )
         ) axi4s_tdwc
         (
           //Target DWC I/O Ports #
           .ACLK               (I_CLK[0]                                         ),
           .RESETN             (I_RESETN[0]                                      ),

           .AXI4S_TTVALID      (TDWC_TTVALID[0]                                  ),
           .AXI4S_TTREADY      (TDWC_TTREADY[0]                                  ),
           .AXI4S_TTDATA       (TDWC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8]),
           .AXI4S_TTSTRB       (TDWC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]),
           .AXI4S_TTKEEP       (TDWC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]),
           .AXI4S_TTLAST       (TDWC_TTLAST[0]                                   ),
           .AXI4S_TTID         ({1'b0,TDWC_TTID[0]}                              ),
           .AXI4S_TTDEST       (TDWC_TTDEST[0]                                   ),
           .AXI4S_TTUSER       (TDWC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]),

           .AXI4S_ITVALID      (ICDC_ITVALID[0]                                  ),
           .AXI4S_ITREADY      (ICDC_ITREADY[0]                                  ),
           .AXI4S_ITDATA       (ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8]),
           .AXI4S_ITSTRB       (ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]),
           .AXI4S_ITKEEP       (ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]),
           .AXI4S_ITLAST       (ICDC_ITLAST[0]                                   ),
           .AXI4S_ITID         (ICDC_ITID[0]                                     ),
           .AXI4S_ITDEST       (ICDC_ITDEST[0]                                   ),
           .AXI4S_ITUSER       (ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ])
         );
       end
     else
       begin
           //Bypass Target DWC if Target ans SWITCH data width is equal#
           assign  TDWC_TTREADY[0] = ICDC_ITREADY[0];
           assign  ICDC_ITVALID[0] = TDWC_TTVALID[0];
           assign  ICDC_ITDATA[IxCDC_ITDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8-1:IxCDC_ITDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8]  = TDWC_TTDATA[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8-1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]*8];
           assign  ICDC_ITSTRB[IxCDC_ITDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]  = TDWC_TTSTRB[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ];
           assign  ICDC_ITKEEP[IxCDC_ITDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:IxCDC_ITDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]  = TDWC_TTKEEP[TxCDC_TTDATA_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTDATA_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ];
           assign  ICDC_ITLAST[0]  = TDWC_TTLAST[0];
           assign  ICDC_ITDEST[0]  = TDWC_TTDEST[0];
           assign  ICDC_ITID[0]    = {1'b0,TDWC_TTID[0]};
           assign  ICDC_ITUSER[IxCDC_ITUSER_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:IxCDC_ITUSER_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ]  = TDWC_TTUSER[TxCDC_TTUSER_UPPER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  -1:TxCDC_TTUSER_LOWER_VEC[((1+0)*INTEGER_SIZE)-1:0*INTEGER_SIZE]  ];
       end
    end
endgenerate
endmodule
