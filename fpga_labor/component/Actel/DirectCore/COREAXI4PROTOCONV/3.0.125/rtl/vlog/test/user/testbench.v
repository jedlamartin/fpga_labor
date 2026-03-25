`timescale 1ns / 100ps

   module testbench ();
   // Parameters-------------------------------------------------------------------------
   // MM2S Parameters
   parameter MM2S_ENABLE             = 1;
   parameter MM2S_ADDR_WIDTH         = 32;       
   parameter MM2S_DATA_WIDTH         = 32;      
   
   // S2MM Parameters
   parameter S2MM_ENABLE             = 1;
   parameter S2MM_ADDR_WIDTH         = 32;       
   parameter S2MM_DATA_WIDTH         = 32;   

   parameter S2MM_PKT_DROP_OVF       = 0;  
   parameter S2MM_PKT_DROP_ERR       = 0;  	
   
   //------------------------------------------------------------------------------------
   
   // I/O Signals------------------------------------------------------------------------
   // Clock and Reset 
   reg                           clk;
   reg                           arst_n;
							       
   // AXI4 Stream initiator interface    
   wire                          axi4s_i_tvalid;
   wire                          axi4s_i_tready;
   wire                          axi4s_i_tlast;
   wire [S2MM_DATA_WIDTH - 1:0]  axi4s_i_tdata;
   
   // AXI4 Stream target interface    
   wire                          axi4s_t_tvalid;
   wire                          axi4s_t_tready;
   wire                          axi4s_t_tlast;
   wire [MM2S_DATA_WIDTH - 1:0]  axi4s_t_tdata;
   wire [3:0]                    axi4s_t_tkeep;

   // AXI4-Lite interface 
   reg                           axi4l_m_awvalid;
   wire                          axi4l_m_awready;
   reg  [10:0]                   axi4l_m_awaddr; 
   reg                           axi4l_m_wvalid; 
   wire                          axi4l_m_wready; 
   reg  [31:0]                   axi4l_m_wdata;  
   reg  [3:0]                    axi4l_m_wstrb;  
   wire                          axi4l_m_bvalid; 
   reg                           axi4l_m_bready; 
   wire [1:0]                    axi4l_m_bresp;  
				                 
   reg                           axi4l_m_arvalid;
   wire                          axi4l_m_arready;
   reg  [10:0]                   axi4l_m_araddr; 
   wire                          axi4l_m_rvalid; 
   reg                           axi4l_m_rready; 
   wire [31:0]                   axi4l_m_rdata;  
   wire [1:0]                    axi4l_m_rresp;  
   

   
   // AXI4 Interface 
   wire                          axi4_slave_awid;
   wire [S2MM_ADDR_WIDTH - 1:0]  axi4_slave_awaddr;  
   wire [7:0]                    axi4_slave_awlen;  
   wire [2:0]                    axi4_slave_awsize; 
   wire [1:0]                    axi4_slave_awburst;
   wire                          axi4_slave_awvalid;
   wire                          axi4_slave_awready;
				                 
   wire [S2MM_DATA_WIDTH - 1:0]  axi4_slave_wdata;
   wire [(S2MM_DATA_WIDTH/8)-1:0]axi4_slave_wstrb; 
   wire                          axi4_slave_wlast; 
   wire                          axi4_slave_wvalid;
   wire                          axi4_slave_wready;
   wire                          axi4_slave_bid;   
   wire [1:0]                    axi4_slave_bresp; 
   wire                          axi4_slave_bvalid;
   wire                          axi4_slave_bready;
				                 
   wire                          axi4_slave_arid;   
   wire [MM2S_ADDR_WIDTH - 1:0]  axi4_slave_araddr; 
   wire [7:0]                    axi4_slave_arlen;  
   wire [2:0]                    axi4_slave_arsize; 
   wire [1:0]                    axi4_slave_arburst;
   wire                          axi4_slave_arvalid;
   wire                          axi4_slave_arready;
				               
   wire [MM2S_DATA_WIDTH - 1:0]  axi4_slave_rdata;  
   wire                          axi4_slave_rlast;  
   wire                          axi4_slave_rvalid; 
   wire                          axi4_slave_rready; 
   wire                          axi4_slave_rid;    
   wire [1:0]                    axi4_slave_rresp;
   
   //Interrupt signals-------------------------------------------------------------------
   wire 						 s2mm_int;
   wire							 s2mm_err_int;
   reg							 s2mm_pkt_err = 1'b0;
   
   wire 						 mm2s_int;
   wire							 mm2s_err_int;
   
   //------------------------------------------------------------------------------------
   
   // Internal signals-------------------------------------------------------------------               
			               
   reg                         pkt_mem_clr;
				               
				               
   reg                         error;
				               
   reg                         s2mm_pkt_mem_write  = 0;
   reg  [15:0]                 s2mm_pkt_mem_wraddr = 0;
   reg  [S2MM_DATA_WIDTH-1:0]  s2mm_pkt_mem_wrdata = 0;
   wire [15:0]                 s2mm_pkt_mem_rdaddr;
   wire [S2MM_DATA_WIDTH-1:0]  s2mm_pkt_mem_rddata;
   
   reg                         mm2s_pkt_mem_write  = 0;
   reg  [15:0]                 mm2s_pkt_mem_wraddr = 0;
   reg  [MM2S_DATA_WIDTH-1:0]  mm2s_pkt_mem_wrdata = 0;
   wire [15:0]                 mm2s_pkt_mem_rdaddr;
   wire [MM2S_DATA_WIDTH-1:0]  mm2s_pkt_mem_rddata;
				               
				               
   wire                        axi4s_initr_en;
   reg                         tse_txcheck_done_clr = 0;
   reg                         axi4_check_done_clr = 0;
				               
   reg  [15:0]                 pkt_mem_sa;
   reg  [15:0]                 pkt_size;
   reg  [2:0]                  num_of_cmd;
   reg  [1:0]                  burst_type;
				               
   reg  [31:0]                 reg_rddata;
   reg                         desc_clr = 0;
   reg                         axi4_read_error_en = 0;
   reg                         axi4_write_error_en = 0;
   reg                         s2mm_busy = 0;
   reg                         mm2s_busy = 0;
   reg   [15:0]                pkt_size_config = 0;
   wire  [15:0]                pkt_size_initr;
   reg                         axi4s_tready_en = 0;
   reg						   mm2s_en;
				               
				               
				               
   integer                     i,j;
   integer                     rand_data;
   
   
   localparam [10:0] S2MM_VERSNREG				= 11'h00;
   localparam [10:0] S2MM_CNTRLREG				= 11'h10;
   localparam [10:0] S2MM_STSREG				= 11'h14;
   localparam [10:0] S2MM_LENGTHREG				= 11'h18;
   localparam [10:0] S2MM_ADDRREG0				= 11'h1C;
   localparam [10:0] S2MM_ADDRREG1				= 11'h20;
   localparam [10:0] S2MM_INTRENBREG			= 11'h24;
   localparam [10:0] S2MM_INTRSRCREG			= 11'h28;
   localparam [10:0] S2MM_AXI4ERRCNTREG			= 11'h100;
   localparam [10:0] S2MM_PKTDRPERRCNTREG		= 11'h104;
   localparam [10:0] S2MM_PKTDRPOVFCNTREG		= 11'h108;
   
   localparam [10:0] MM2S_VERSNREG				= 11'h400;
   localparam [10:0] MM2S_CNTRLREG				= 11'h410;
   localparam [10:0] MM2S_STSREG				= 11'h414;
   localparam [10:0] MM2S_LENGTHREG				= 11'h418;
   localparam [10:0] MM2S_ADDRREG0				= 11'h41C;
   localparam [10:0] MM2S_ADDRREG1				= 11'h420;
   localparam [10:0] MM2S_INTRENBREG			= 11'h424;
   localparam [10:0] MM2S_INTRSRCREG			= 11'h428;
   localparam [10:0] MM2S_AXI4ERRCNTREG			= 11'h500;
   //------------------------------------------------------------------------------------
   
   // DUT Instantiation------------------------------------------------------------------
   COREAXI4PROTOCONV # 
   (
     // MM2S Parameter 
     .MM2S_ENABLE              (MM2S_ENABLE             ),
     .MM2S_DATA_WIDTH          (MM2S_DATA_WIDTH         ),
     // S2MM Parameter   
     .S2MM_ENABLE              (S2MM_ENABLE             ),
     .S2MM_DATA_WIDTH          (S2MM_DATA_WIDTH         )
   )
   dut_inst
   (
     .ACLK                     (clk                     ),
     .RESETN             	   (arst_n                  ),
     
     // AXI4-Stream Target Port Interface (S2MM_AXI4S_TRGT)  
     .T_AXI4S_TVALID           (axi4s_i_tvalid          ),
     .T_AXI4S_TREADY           (axi4s_i_tready          ),
     .T_AXI4S_TID              (1'b0                    ),
     .T_AXI4S_TDEST            ({S2MM_ADDR_WIDTH{1'b0}} ),
     .T_AXI4S_TLAST            (axi4s_i_tlast           ),
     .T_AXI4S_TDATA            (axi4s_i_tdata           ),
     .T_AXI4S_TKEEP            ({S2MM_DATA_WIDTH/8{1'b1}} ),
     .T_AXI4S_TUSER            (1'b0                    ),
      
     // AXI4-Lite Port Interface (S2MM_AXI4L_TRGT)
     // Write Address channel
     .T_AXI4L_AWVALID      (axi4l_m_awvalid ),                                 
     .T_AXI4L_AWREADY      (axi4l_m_awready ),                                 
     .T_AXI4L_AWADDR       (axi4l_m_awaddr  ),                                 
     // Write Data channel                                                          
     .T_AXI4L_WVALID       (axi4l_m_wvalid  ),                                 
     .T_AXI4L_WREADY       (axi4l_m_wready  ),                                 
     .T_AXI4L_WDATA        (axi4l_m_wdata   ),                                 
     .T_AXI4L_WSTRB        (axi4l_m_wstrb   ),                                 
     // Write Response channel                                                      
     .T_AXI4L_BVALID       (axi4l_m_bvalid  ),                                 
     .T_AXI4L_BREADY       (axi4l_m_bready  ),                                 
     .T_AXI4L_BRESP        (axi4l_m_bresp   ),                                 
                                                                                    
     // Read address channel                                                        
     .T_AXI4L_ARVALID      (axi4l_m_arvalid ),                                 
     .T_AXI4L_ARREADY      (axi4l_m_arready ),                                 
     .T_AXI4L_ARADDR       (axi4l_m_araddr  ),                                 
     // Read data channel                                                           
     .T_AXI4L_RVALID       (axi4l_m_rvalid  ),                                 
     .T_AXI4L_RREADY       (axi4l_m_rready  ),                                 
     .T_AXI4L_RDATA        (axi4l_m_rdata   ),                                 
     .T_AXI4L_RRESP        (axi4l_m_rresp   ),
      
     // AXI4 Initiator Write Interface Ports (S2MM_AXI4MM_INITR)   
     .I_S2MMAXI4_AWID          (axi4_slave_awid       ),
     .I_S2MMAXI4_AWADDR        (axi4_slave_awaddr     ),
     .I_S2MMAXI4_AWLEN         (axi4_slave_awlen      ),
     .I_S2MMAXI4_AWSIZE        (axi4_slave_awsize     ),
     .I_S2MMAXI4_AWBURST       (axi4_slave_awburst    ),
     .I_S2MMAXI4_AWVALID       (axi4_slave_awvalid    ),
     .I_S2MMAXI4_AWREADY       (axi4_slave_awready    ),
   						  
     .I_S2MMAXI4_WDATA         (axi4_slave_wdata      ),
     .I_S2MMAXI4_WSTRB         (axi4_slave_wstrb      ),
     .I_S2MMAXI4_WLAST         (axi4_slave_wlast      ),
     .I_S2MMAXI4_WVALID        (axi4_slave_wvalid     ),
     .I_S2MMAXI4_WREADY        (axi4_slave_wready     ),
     .I_S2MMAXI4_BID           (axi4_slave_bid        ),
     .I_S2MMAXI4_BRESP         (axi4_slave_bresp      ),
     .I_S2MMAXI4_BVALID        (axi4_slave_bvalid     ),
     .I_S2MMAXI4_BREADY        (axi4_slave_bready     ),
	 
	 .S2MM_INT       		   (s2mm_int		      ),
	 .S2MM_ERR_INT  	       (s2mm_err_int          ),
	 .S2MM_PKT_ERR       	   (s2mm_pkt_err          ),
     											 
     
     /* AXI4-Lite Port Interface (MM2S_AXI4L_TRGT)                
     .T_AXI4L_AWVALID      (axi4l_m_awvalid  ),              
     .T_AXI4L_AWREADY      (axi4l_m_awready  ),              
     .T_AXI4L_AWADDR       (axi4l_m_awaddr   ),              
     .T_AXI4L_WVALID       (axi4l_m_wvalid   ),              
     .T_AXI4L_WREADY       (axi4l_m_wready   ),              
     .T_AXI4L_WDATA        (axi4l_m_wdata    ),              
     .T_AXI4L_WSTRB        (axi4l_m_wstrb    ),              
     .T_AXI4L_BVALID       (axi4l_m_bvalid   ),              
     .T_AXI4L_BREADY       (axi4l_m_bready   ),              
     .T_AXI4L_BRESP        (axi4l_m_bresp    ),              
   											                      
     .T_AXI4L_ARVALID      (axi4l_m_arvalid  ),              
     .T_AXI4L_ARREADY      (axi4l_m_arready  ),              
     .T_AXI4L_ARADDR       (axi4l_m_araddr   ),              
     .T_AXI4L_RVALID       (axi4l_m_rvalid   ),              
     .T_AXI4L_RREADY       (axi4l_m_rready   ),              
     .T_AXI4L_RDATA        (axi4l_m_rdata    ),              
     .T_AXI4L_RRESP        (axi4l_m_rresp    ),      */        
                                                                  
     // AXI4 Initiator Read Interface Ports (MM2S_AXI4MM_INITR)   
     .I_MM2SAXI4_ARID          (axi4_slave_arid       ),
     .I_MM2SAXI4_ARADDR        (axi4_slave_araddr     ),
     .I_MM2SAXI4_ARLEN         (axi4_slave_arlen      ),
     .I_MM2SAXI4_ARSIZE        (axi4_slave_arsize     ),
     .I_MM2SAXI4_ARBURST       (axi4_slave_arburst    ),
     .I_MM2SAXI4_ARVALID       (axi4_slave_arvalid    ),
     .I_MM2SAXI4_ARREADY       (axi4_slave_arready    ),
   						     
     .I_MM2SAXI4_RDATA         (axi4_slave_rdata      ),
     .I_MM2SAXI4_RLAST         (axi4_slave_rlast      ),
     .I_MM2SAXI4_RVALID        (axi4_slave_rvalid     ),
     .I_MM2SAXI4_RREADY        (axi4_slave_rready     ),
     .I_MM2SAXI4_RID           (axi4_slave_rid        ),
     .I_MM2SAXI4_RRESP         (axi4_slave_rresp      ),
     
     // AXI4-Stream Initiator Port Interface (MM2S_AXI4S_INITR)
     .I_AXI4S_TVALID           (axi4s_t_tvalid        ),
     .I_AXI4S_TREADY           (axi4s_t_tready        ),
     .I_AXI4S_TLAST            (axi4s_t_tlast         ),
     .I_AXI4S_TDATA            (axi4s_t_tdata         ),
     .I_AXI4S_TKEEP            (axi4s_t_tkeep         ),
	 
	 .MM2S_INT                 (mm2s_int              ),
	 .MM2S_ERR_INT             (mm2s_err_int          )
   );
   
   axi4s_initr_model # 
   (
     .DATA_WIDTH             (S2MM_DATA_WIDTH        )
   )
   axi4s_initr_model_inst
   (
     .clk                    (clk                    ),
     .arst_n                 (arst_n                 ),
   
     .axi4s_i_tvalid         (axi4s_i_tvalid         ),
     .axi4s_i_tready         (axi4s_i_tready         ),
     .axi4s_i_tlast          (axi4s_i_tlast          ),
     .axi4s_i_tdata          (axi4s_i_tdata          ),
   
     .pkt_mem_rdaddr         (s2mm_pkt_mem_rdaddr    ),
     .pkt_mem_rddata         (s2mm_pkt_mem_rddata    ),
     
     .axi4s_initr_en         (axi4s_initr_en         ),
     .num_of_cmd             (num_of_cmd             ),
     .pkt_size               (pkt_size_initr         )
   );
   
   axi4s_trgt_model  #
   (
    .DATA_WIDTH              (MM2S_DATA_WIDTH        )         
   ) axi4s_trgt_model_inst
   (
     .clk                    (clk                    ),
     .arst_n                 (arst_n                 ),
   
     .axi4s_t_tvalid         (axi4s_t_tvalid         ),
     .axi4s_t_tready         (axi4s_t_tready         ),
     .axi4s_t_tlast          (axi4s_t_tlast          ),
     .axi4s_t_tdata          (axi4s_t_tdata          ),
     .axi4s_t_tkeep          (axi4s_t_tkeep          ),
     .axi4s_tready_en        (axi4s_tready_en        )
   );
   
   axi4mm_trgt_model # 
   (
     .S2MM_ENABLE            (S2MM_ENABLE              ),
     .MM2S_ENABLE            (MM2S_ENABLE              ),
	 .DATA_WIDTH             (S2MM_DATA_WIDTH          ),
	 .ADDR_WIDTH             (S2MM_ADDR_WIDTH          ),
	 .MM2S_DATA_WIDTH        (MM2S_DATA_WIDTH          ),
	 .MM2S_ADDR_WIDTH        (MM2S_ADDR_WIDTH          )	 
   ) axi4_trgt_model_inst
   (
     .clk                    (clk                      ),
     .arst_n                 (arst_n                   ),
     
     .axi4_slave_awid        (axi4_slave_awid          ),
     .axi4_slave_awaddr      (axi4_slave_awaddr        ), 
     .axi4_slave_awlen       (axi4_slave_awlen         ),  
     .axi4_slave_awsize      (axi4_slave_awsize        ), 
     .axi4_slave_awburst     (axi4_slave_awburst       ),
     .axi4_slave_awvalid     (axi4_slave_awvalid       ),
     .axi4_slave_awready     (axi4_slave_awready       ),
   					      
     .axi4_slave_wdata       (axi4_slave_wdata         ),
     .axi4_slave_wstrb       (axi4_slave_wstrb         ), 
     .axi4_slave_wlast       (axi4_slave_wlast         ), 
     .axi4_slave_wvalid      (axi4_slave_wvalid        ),
     .axi4_slave_wready      (axi4_slave_wready        ),
     .axi4_slave_bid         (axi4_slave_bid           ),   
     .axi4_slave_bresp       (axi4_slave_bresp         ), 
     .axi4_slave_bvalid      (axi4_slave_bvalid        ),
     .axi4_slave_bready      (axi4_slave_bready        ),
   					       				
     .axi4_slave_arid        (axi4_slave_arid          ),   
     .axi4_slave_araddr      (axi4_slave_araddr        ), 
     .axi4_slave_arlen       (axi4_slave_arlen         ),  
     .axi4_slave_arsize      (axi4_slave_arsize        ), 
     .axi4_slave_arburst     (axi4_slave_arburst       ),
     .axi4_slave_arvalid     (axi4_slave_arvalid       ),
     .axi4_slave_arready     (axi4_slave_arready       ),
   					       				
     .axi4_slave_rdata       (axi4_slave_rdata         ),  
     .axi4_slave_rlast       (axi4_slave_rlast         ),  
     .axi4_slave_rvalid      (axi4_slave_rvalid        ), 
     .axi4_slave_rready      (axi4_slave_rready        ), 
     .axi4_slave_rid         (axi4_slave_rid           ),    
     .axi4_slave_rresp       (axi4_slave_rresp         ),
     
    
     .pkt_mem_rdaddr         (mm2s_pkt_mem_rdaddr      ),
     .pkt_mem_rddata         (mm2s_pkt_mem_rddata      ),  
     .pkt_mem_clr            (pkt_mem_clr              ),  
     
     .axi4_read_error_en     (axi4_read_error_en       ),
     .axi4_write_error_en    (axi4_write_error_en      )
   
   );
   
   // S2MM Buffer memory instantiation
   buffer_mem # 
   (
     .DATA_WIDTH (S2MM_DATA_WIDTH)  
     
   ) s2mm_pkt_mem_inst
   (
     .clk    (clk                 ),
     .wren   (s2mm_pkt_mem_write  ),
     .wraddr (s2mm_pkt_mem_wraddr ),
     .wrdata (s2mm_pkt_mem_wrdata ),
     .rdaddr (s2mm_pkt_mem_rdaddr ),
     .rddata (s2mm_pkt_mem_rddata )
   );
   
   // MM2S Buffer memory instantiation
   buffer_mem # 
   (
     .DATA_WIDTH (MM2S_DATA_WIDTH)  
     
   ) mm2s_pkt_mem_inst
   (
     .clk    (clk                 ),
     .wren   (mm2s_pkt_mem_write  ),
     .wraddr (mm2s_pkt_mem_wraddr ),
     .wrdata (mm2s_pkt_mem_wrdata ),
     .rdaddr (mm2s_pkt_mem_rdaddr ),
     .rddata (mm2s_pkt_mem_rddata )
   );
   
   // S2MM checker instantiation 
   s2mm_chkr #
   (
     .DATA_WIDTH         (S2MM_DATA_WIDTH         ),
     .ADDR_WIDTH         (S2MM_ADDR_WIDTH         )
   ) s2mm_chkr_inst 
   (
     .clk                  (clk                  ),
     .arst_n               (arst_n               ),
   
     .axi4l_awvalid        ( ~mm2s_en ? axi4l_m_awvalid : 0 ),
     .axi4l_awready        ( ~mm2s_en ? axi4l_m_awready : 0 ),
     .axi4l_awaddr         ( ~mm2s_en ? axi4l_m_awaddr  : 0 ),
     .axi4l_wvalid         ( ~mm2s_en ? axi4l_m_wvalid  : 0 ),
     .axi4l_wready         ( ~mm2s_en ? axi4l_m_wready  : 0 ),
     .axi4l_wdata          ( ~mm2s_en ? axi4l_m_wdata   : 0 ),
     .axi4l_wstrb          ( ~mm2s_en ? axi4l_m_wstrb   : 0 ),
   										    
     .axi4s_i_tvalid       (axi4s_i_tvalid             ),
     .axi4s_i_tready       (axi4s_i_tready             ),
     .axi4s_i_tlast        (axi4s_i_tlast              ),
     .axi4s_i_tdata        (axi4s_i_tdata              ),
											           
     .axi4_slave_awid      (axi4_slave_awid            ),
     .axi4_slave_awaddr    (axi4_slave_awaddr          ),
     .axi4_slave_awlen     (axi4_slave_awlen           ),
     .axi4_slave_awsize    (axi4_slave_awsize          ),
     .axi4_slave_awburst   (axi4_slave_awburst         ),
     .axi4_slave_awvalid   (axi4_slave_awvalid         ),
     .axi4_slave_awready   (axi4_slave_awready         ),  
											           
     .axi4_slave_wdata     (axi4_slave_wdata           ),
     .axi4_slave_wstrb     (axi4_slave_wstrb           ),
     .axi4_slave_wlast     (axi4_slave_wlast           ),
     .axi4_slave_wvalid    (axi4_slave_wvalid          ),
     .axi4_slave_wready    (axi4_slave_wready          ),
     .axi4_slave_bvalid    (axi4_slave_bvalid          ),
     .axi4_slave_bready    (axi4_slave_bready          ),
     
     .axi4s_initr_en       (axi4s_initr_en       ), 
     .pkt_size             (pkt_size_initr       ),
     .num_of_cmd           (num_of_cmd           ) 
   );  
   
   // MM2S checker instantiation 
   mm2s_chkr #
   (
     .DATA_WIDTH          (MM2S_DATA_WIDTH     ),
     .ADDR_WIDTH          (MM2S_ADDR_WIDTH     )
   ) mm2s_chkr_inst 
   (
     .clk                 (clk                 ),
     .arst_n              (arst_n              ),
   										    
     .axi4l_awvalid       (mm2s_en ? axi4l_m_awvalid : 0  ),
     .axi4l_awready       (mm2s_en ? axi4l_m_awready : 0  ),
     .axi4l_awaddr        (mm2s_en ? axi4l_m_awaddr  : 0  ),
     .axi4l_wvalid        (mm2s_en ? axi4l_m_wvalid  : 0  ),
     .axi4l_wready        (mm2s_en ? axi4l_m_wready  : 0  ),
     .axi4l_wdata         (mm2s_en ? axi4l_m_wdata   : 0  ),
     .axi4l_wstrb         (mm2s_en ? axi4l_m_wstrb   : 0  ),   
											
     .axi4s_t_tvalid      (axi4s_t_tvalid ),
     .axi4s_t_tready      (axi4s_t_tready ),
     .axi4s_t_tlast       (axi4s_t_tlast  ),
     .axi4s_t_tdata       (axi4s_t_tdata  ),
     .axi4s_t_tkeep       (axi4s_t_tkeep  ),
											    
     .axi4_slave_arid     (axi4_slave_arid   ),
     .axi4_slave_araddr   (axi4_slave_araddr ),
     .axi4_slave_arlen    (axi4_slave_arlen  ),
     .axi4_slave_arsize   (axi4_slave_arsize ),
     .axi4_slave_arburst  (axi4_slave_arburst ),
     .axi4_slave_arvalid  (axi4_slave_arvalid ),
     .axi4_slave_arready  (axi4_slave_arready ),  
											
     .axi4_slave_rdata    (axi4_slave_rdata  ),
     .axi4_slave_rlast    (axi4_slave_rlast  ),
     .axi4_slave_rvalid   (axi4_slave_rvalid ),
     .axi4_slave_rready   (axi4_slave_rready ),

     .num_of_cmd          (num_of_cmd           )
	 
   );
   //------------------------------------------------------------------------------------
   
   // Clock generator logic-------------------------------------------------------------- 
   always 
     begin 
       #10 clk <= ~clk;
     end
   //------------------------------------------------------------------------------------
   
   // S2MM/MM2S Register Write/Read Block Task------------------------------------------------
   // To write AXI4-Lite command/Status register
   task axi4lite_write;                                         // AXI-Lite Write channel (Write address, write data, write Strobe)
     input [10:0]  wraddr;                                            // Write address
     input [31:0] wrdata;                                            // Write data
     input [3:0]  wrstrb;                                            // write Strobe
     begin 
       @(posedge clk)
   	  begin
   	    axi4l_m_awvalid = 1'b1;                                 // Valid Address received
   	    axi4l_m_awaddr  = wraddr;                               // Valid Address transmit   
   	  end                                                            
   	wait(axi4l_m_awvalid & axi4l_m_awready)                // Address Handshaking happen 
       @(posedge clk)                                                   
   	  begin                                                          
   	    axi4l_m_awvalid = 1'b0;                                 //  Valid address Low   
   		axi4l_m_wvalid  = 1'b1;                                 //  Valid data received 
   		axi4l_m_wdata   = wrdata;                               //  Valid data transmit
   		axi4l_m_wstrb   = wrstrb;                               //  Valid strobe transmit   
   	  end                                                            
   	wait(axi4l_m_wvalid & axi4l_m_wready)                  //  Data Handshaking happen   
       @(posedge clk)                                                   
   	  begin                                                          
   		axi4l_m_wvalid  = 1'b0;                                 
   		axi4l_m_bready  = 1'b1;                                 //  Response is ready 
   	  end                                                            
       wait(axi4l_m_bvalid & axi4l_m_bready)	             //  Response handshaking happen
       @(posedge clk)
   	  begin
   		axi4l_m_bready  = 1'b0;
   	  end	
     end 
   endtask 
   
   // To write AXI4-Lite write response error register
   task axi4lite_write_resperr;
     input [10:0]  wraddr;
     input [31:0] wrdata;
     output       error;
     begin 
       error = 0;
       @(posedge clk)
   	  begin
   	    axi4l_m_awvalid = 1'b1;
   	    axi4l_m_awaddr  = wraddr;
   	  end 
   	wait(axi4l_m_awvalid & axi4l_m_awready)
       @(posedge clk)
   	  begin
   	    axi4l_m_awvalid = 1'b0;
   		axi4l_m_wvalid  = 1'b1;
   		axi4l_m_wdata   = wrdata;
   		axi4l_m_wstrb   = 4'hf;
   	  end 
   	wait(axi4l_m_wvalid & axi4l_m_wready)
       @(posedge clk)
   	  begin
   		axi4l_m_wvalid  = 1'b0;
   		axi4l_m_bready  = 1'b1;
   	  end 
       wait(axi4l_m_bvalid & axi4l_m_bready)
       if(axi4l_m_bresp[1])
         error = 1;
       else  
         error = 0;
   	  
       @(posedge clk)
   	  begin
   		axi4l_m_bready  = 1'b0;
   	  end	
     end 
   endtask
   
   // To Read AXI4-Lite register
   task axi4lite_read;
     input [10:0]  rdaddr;
     input [31:0] exp_data;
     output       error;  
     begin 
       
       @(posedge clk)
       axi4l_m_arvalid = 1'b1;
       axi4l_m_araddr  = rdaddr;
   	
   	wait(axi4l_m_arready)
   	@(posedge clk)
       axi4l_m_arvalid = 1'b0;	 
       axi4l_m_rready  = 1'b1;	
   	
   	wait(axi4l_m_rvalid);
       @(posedge clk)		
   	if(exp_data != axi4l_m_rdata)
   	  begin 
   	    $display ("error detected at address = %x. read data = %x and expected data = %x", rdaddr,axi4l_m_rdata,exp_data);
   	    error = 1'b1;
   	  end 
   	else 
   	  error = 1'b0;
   
       axi4l_m_rready  = 1'b0;
     end 
   endtask 
   
   // To read AXI4 Lite  register 
   task axi4lite_read_data;
     input  [10:0]  rdaddr;
     output [31:0]  reg_rddata;  
     begin 
       
       @(posedge clk)
       axi4l_m_arvalid = 1'b1;
       axi4l_m_araddr  = rdaddr;
   	wait(axi4l_m_arready)
   	@(posedge clk)	
       axi4l_m_arvalid = 1'b0;	 
       axi4l_m_rready  = 1'b1;	
   	
   	wait(axi4l_m_rvalid)
   	@(posedge clk)		
       reg_rddata = axi4l_m_rdata;
   
       axi4l_m_rready  = 1'b0;
     end 
   endtask
   
   // To read AXI-Lite Read response error register
   task axi4lite_read_resperr;
     input [10:0] rdaddr;
     output       error;
     begin 
       error = 0;
       @(posedge clk)
       axi4l_m_arvalid = 1'b1;
       axi4l_m_araddr  = rdaddr;
   	wait(axi4l_m_arready)
   	@(posedge clk)	
       axi4l_m_arvalid = 1'b0;	 
       axi4l_m_rready  = 1'b1;	
   	wait(axi4l_m_rvalid)
   	@(posedge clk)			
   	error = axi4l_m_rresp[1];
       reg_rddata = axi4l_m_rdata;
       axi4l_m_rready  = 1'b0;
     end 
   endtask
   //------------------------------------------------------------------------------------
  
   
   // S2MM Register read/write test cases------------------------------------------------
   task s2mm_register_rdwr_test;
     begin 
    //s2mm register rdwr check 
   	
   	//Default register check 
   	axi4lite_read    (S2MM_CNTRLREG,32'h0,error);
   	if(~error)
   	  axi4lite_read  (S2MM_STSREG,32'h1,error);
   	if(~error)
   	  axi4lite_read  (S2MM_ADDRREG0,32'h0,error);
   	if(~error)
   	  axi4lite_read  (S2MM_ADDRREG1,32'h0,error);
   	if(~error)	
         axi4lite_write_resperr (11'h200,32'h0000000F,error);        // (axi4l_m_awaddr, axi4l_m_wdata, error)
   	                                                                 
       if(error)                                                         
   	  axi4lite_read_resperr (11'h200,error);                         // (axi4l_m_araddr, error) 
                                                                        
       if(error)                                                        
         begin 	                                                     
           axi4lite_write (S2MM_CNTRLREG,32'h03AB0000,4'hF);         // ((S2MM_CNTRLREG)axi4l_m_awaddr, axi4l_m_wdata, axi4l_m_wstrb)
           axi4lite_read  (S2MM_CNTRLREG,32'h03AB0000,error);        // ((S2MM_CNTRLREG)axi4l_m_araddr, exp_data, error)
   	  end                                                            
   	if(~error)                                                       
   	  begin                                                          
           axi4lite_write (S2MM_LENGTHREG,32'h76540123,4'hF);          // ((S2MM_LENGTHREG)axi4l_m_awaddr, axi4l_m_wdata, axi4l_m_wstrb)
           axi4lite_read  (S2MM_LENGTHREG,32'h76540123,error);         // ((S2MM_LENGTHREG)axi4l_m_araddr, exp_data, error)
   	  end                                                            
                                                                        
   	if(~error)                                                       
   	  begin                                                          
           axi4lite_write (S2MM_ADDRREG0,32'hFEDC89AB,4'hF);           // ((S2MM_ADDRREG0)axi4l_m_awaddr, axi4l_m_wdata, axi4l_m_wstrb)
           axi4lite_read  (S2MM_ADDRREG0,32'hFEDC89AB,error);          // ((S2MM_ADDRREG0)axi4l_m_araddr, exp_data, error)
   	  end                                                            
                                                                        
       //rx register rdwr check                                         
                                                                        
   	if(~error)                                                       
   	  begin                                                          
           axi4lite_write (S2MM_ADDRREG1,32'h3210FEDC,4'hF);           // ((S2MM_ADDRREG1)axi4l_m_awaddr, axi4l_m_wdata, axi4l_m_wstrb)
           axi4lite_read  (S2MM_ADDRREG1,32'h3210FEDC,error);          // ((S2MM_ADDRREG1)axi4l_m_araddr, exp_data, error)
   	  end                                                            
                                                                        
   	if(~error)                                                       
   	  begin                                                          
           axi4lite_write (S2MM_ADDRREG1,32'h3210FEDC,4'h0);           // ((S2MM_ADDRREG1)axi4l_m_awaddr, axi4l_m_wdata, axi4l_m_wstrb)
           axi4lite_read  (S2MM_ADDRREG1,32'h3210FEDC,error);          // ((S2MM_ADDRREG1)axi4l_m_araddr, exp_data, error)
   	  end                                                            
                                                                        
   	if(~error)                                                       
   	  begin                                                          
           axi4lite_write (S2MM_ADDRREG1,32'h126789AB,4'h1);           // ((S2MM_ADDRREG1)axi4l_m_awaddr, axi4l_m_wdata, axi4l_m_wstrb)
           axi4lite_read  (S2MM_ADDRREG1,32'h3210FEAB,error);          // ((S2MM_ADDRREG1)axi4l_m_araddr, exp_data, error)
   	  end                                                            
                                                                        
   	if(~error)                                                       
   	  begin                                                          
           axi4lite_write (S2MM_ADDRREG1,32'h126789AB,4'h2);           // ((S2MM_ADDRREG1)axi4l_m_awaddr, axi4l_m_wdata, axi4l_m_wstrb) 
           axi4lite_read  (S2MM_ADDRREG1,32'h321089AB,error);          // ((S2MM_ADDRREG1)axi4l_m_araddr, exp_data, error)
   	  end 
   	  
   	if(~error)
   	  $display ("register read write test pass successfully\n");
   	else 
   	  begin 
        $display ("register read write test failed\n");
   		$stop;
   	  end 
     end 
   endtask
   
   // Register configured
   task s2mm_cmds_write;
     input [15:0] 	pkt_buff_start_addr;
     input [2:0]  	num_of_cmd;                                                                         // Number of command transmitted 
     input [15:0] 	pkt_size;     
	 input [1:0] 	burst_type;
     reg   [15:0] 	pkt_size_config;                                                                                           
     reg   [15:0] 	pkt_addr;   
     reg   [9:0]  	id_cnt;	 
     begin 
	   pkt_addr = 	pkt_buff_start_addr;	
	   pkt_addr[($clog2(S2MM_DATA_WIDTH))-3:0] = 0;			 
       id_cnt = 0;	   

       for(i = 0; i < num_of_cmd; i = i + 1)
   	   begin 
          @(posedge clk)
   	      begin
   		    pkt_size_config = $urandom_range (S2MM_DATA_WIDTH/8,pkt_size);
			if(pkt_size_config < (S2MM_DATA_WIDTH/8))
			  pkt_size_config = S2MM_DATA_WIDTH/8;
			
   		    if(i == 0)
   			  begin
                                 // (awaddr,         wdata,                               wstrb)			  
                axi4lite_write ( S2MM_LENGTHREG,    pkt_size_config,                     4'hF);                         
   			    axi4lite_write ( S2MM_ADDRREG0,     pkt_addr,                            4'hF);
                                 //                  {cmd id,Reserved, Burst type,   start bit} 				
   			    axi4lite_write ( S2MM_CNTRLREG,   {id_cnt, 13'b0,  burst_type,        1'b1},        4'hF);                   

                if(| pkt_size_config[$clog2(S2MM_DATA_WIDTH/8)-1:0])
				  pkt_size_config = pkt_size_config + (pkt_size_config % (S2MM_DATA_WIDTH/8));
			    pkt_addr = 	pkt_addr + ((i+1) * pkt_size_config);
				pkt_addr[($clog2(S2MM_DATA_WIDTH/8))-1:0] = 0;
				id_cnt = id_cnt + 1;
   			  end 
   			else 
   			  begin
                                 // (awaddr,         wdata,                               wstrb)			  
                axi4lite_write (S2MM_LENGTHREG,     pkt_size_config,                     4'hF);      
   			    axi4lite_write (S2MM_ADDRREG0,      pkt_addr,                            4'hF); 
   				                 //                  {cmd id, Reservedd, Burst type,    start bit}
   			    axi4lite_write (S2MM_CNTRLREG,    {id_cnt, 13'b0,    burst_type,         1'b1},        4'hF);	     

                if(| pkt_size_config[$clog2(S2MM_DATA_WIDTH/8)-1:0])
				  pkt_size_config = pkt_size_config + (pkt_size_config % (S2MM_DATA_WIDTH/8));

			    pkt_addr = 	pkt_addr + ((i+1) * pkt_size_config);
				pkt_addr[($clog2(S2MM_DATA_WIDTH/8))-1:0] = 0;
				id_cnt = id_cnt + 1;

   			  end 
   	      end 
   	  end
      $display ("Number of descriptors stored in S2MM Command FIFO = %d\n",num_of_cmd);	  	  
     end 
   endtask
   
   // Field is generated for AXI4-Stream to AXI4-Memory map
   task s2mm_pkt_write;
     input [15:0]  pkt_size;
     input [2:0]   num_of_cmd;
     
     begin
     
      s2mm_pkt_mem_wraddr = ~0;
      
      for(i = 0; i < num_of_cmd; i = i + 1)
   	  begin 	    
   	    for(j = 0; j < pkt_size; j = j + 1)          
   		  begin
		    @(posedge clk)    
   		    for(rand_data = 0; rand_data < (S2MM_DATA_WIDTH/32); rand_data = rand_data + 1)			
			  begin 
   		         s2mm_pkt_mem_wrdata[32*rand_data +: 32] = $random;
			  end 
            
			s2mm_pkt_mem_write  = 1;					
   			s2mm_pkt_mem_wraddr <= s2mm_pkt_mem_wraddr + 1;			
   		  end 
   	  end
   	  @(posedge clk)
   	    s2mm_pkt_mem_write = 0;
     end 
   endtask
   
   task s2mm_test;
     input [15:0] pkt_mem_sa;
     input [15:0] pkt_size;
     input [2:0]  num_of_cmd;
	 input [1:0]  burst_type;
     
     reg   [7:0]  count;
	 reg   [9:0]  sts_id_cnt;
     
     begin
	   
   
       s2mm_pkt_write (pkt_size, num_of_cmd);
   	
       s2mm_cmds_write (pkt_mem_sa, num_of_cmd, pkt_size,burst_type);
   	
   	   s2mm_busy = 1'b1;
       
	   count = 0;
   	
	   sts_id_cnt = 0;
   	   repeat(num_of_cmd)
   	     begin  	  
   	       @(posedge clk)			
   	   	   s2mm_busy = 1;
   	   	   while (s2mm_busy)
   	   	     begin 
               axi4lite_read_data (S2MM_STSREG, reg_rddata);	
	   		   if(reg_rddata[0] == 1'b1)
   	   		     begin 
   	   	           $display ("Packet is transmitted from AXI4 Stream to AXI4 MM\n");
   	   			   s2mm_busy = 1'b0;
	   			   if(reg_rddata[25:16] != sts_id_cnt)
	   			     $display ("Status ID doesn't match with Command ID\n");
	   			   error     = ((| reg_rddata[3:2]) | (reg_rddata[25:16] != sts_id_cnt));
   	   		     end  	       
	   	     end 
			 sts_id_cnt = sts_id_cnt + 1;
   	     end 
 	
   	if(error)
	  begin 
   	    $display ("s2mm_test failed\n");	
		$stop;
	  end 
   		
     end
   endtask
   
   task s2mm_intr_test;
     input [15:0] pkt_mem_sa;
     input [15:0] pkt_size;
     input [2:0]  num_of_cmd;
	 input [1:0]  burst_type;
     
     reg   [7:0]  count;
	 reg   [9:0]  sts_id_cnt;
     
     begin
	   
	   if(num_of_cmd != 1) begin      
	     axi4lite_write (S2MM_INTRENBREG,32'h01,4'hF);
	   end else begin 
	     axi4lite_write (S2MM_INTRENBREG,32'h01,4'hF);	     
	   end 
	   
       s2mm_pkt_write (pkt_size, num_of_cmd);
   	
       s2mm_cmds_write (pkt_mem_sa, num_of_cmd, pkt_size,burst_type);
   	
   	   s2mm_busy = 1'b1;
       
	   count = 0;
   	
	   sts_id_cnt = 0;
       @(posedge clk)			
   	   wait (s2mm_int)
       axi4lite_write (S2MM_INTRSRCREG,32'hFF,4'hF);
	   repeat(num_of_cmd-1)
	     begin 
		   axi4lite_read_data (S2MM_STSREG, reg_rddata);	
	   	   if(reg_rddata[0] & ~reg_rddata[1])
   		     begin 
   		       $display ("Single Packet is transmitted from AXI4 Stream to AXI4 MM\n");   				
			   if(reg_rddata[25:16] != sts_id_cnt)
			     $display ("Status ID doesn't match with Command ID\n");
				 error     = ((| reg_rddata[3:2]) | (reg_rddata[25:16] != sts_id_cnt));
   			 end 	
           sts_id_cnt = sts_id_cnt + 1;			 
   		 end	 
	     begin 
		   axi4lite_read_data (S2MM_STSREG, reg_rddata);	
	   	   if(reg_rddata[0] & reg_rddata[1])
   		     begin 
   		       $display ("Single Packet is transmitted from AXI4 Stream to AXI4 MM\n");   				
			   if(reg_rddata[25:16] != sts_id_cnt)
			     $display ("Status ID doesn't match with Command ID\n");
				 error     = ((| reg_rddata[3:2]) | (reg_rddata[25:16] != sts_id_cnt));
   			 end 	
           sts_id_cnt = sts_id_cnt + 1;			 
   		 end	 
   	   if(error)
	     begin 
   	       $display ("s2mm interrupt test failed\n");	
	       $stop;
	     end    		
     end
   endtask
   //------------------------------------------------------------------------------------
   
   // MM2S Register read/write test cases------------------------------------------------
   task mm2S_register_rdwr_test;
     begin 
       //mm2s register rdwr check 
   	axi4lite_read    (MM2S_CNTRLREG,32'h0,error);
   	if(~error)
   	  axi4lite_read  (MM2S_STSREG,32'h1,error);
   	if(~error)
   	  axi4lite_read  (MM2S_LENGTHREG,32'h1,error);
   	if(~error)
   	  axi4lite_read  (MM2S_ADDRREG0,32'h0,error);
   	if(~error)
   	  axi4lite_read  (MM2S_ADDRREG1,32'h0,error);
   	if(~error)		
         axi4lite_write_resperr (11'h600,32'h0000000f,error);
       if(error)
   	  axi4lite_read_resperr (11'h600,error);
       
       if(error)
         begin 	
           axi4lite_write (MM2S_CNTRLREG,32'h000000E4, 4'hF);
           axi4lite_read  (MM2S_CNTRLREG,32'h000000E4,error);
   	  end 
   	if(~error)
   	  begin 
           axi4lite_write (MM2S_LENGTHREG,32'h76540123, 4'hF);
           axi4lite_read  (MM2S_LENGTHREG,32'h76540123,error);
   	  end 
   
   	if(~error)
   	  begin 
           axi4lite_write (MM2S_ADDRREG0,32'hFEDC89AB, 4'hF);
           axi4lite_read  (MM2S_ADDRREG0,32'hFEDC89AB,error);
   	  end 
   
       //rx register rdwr check 
   
   	if(~error)
   	  begin 
           axi4lite_write (MM2S_ADDRREG1,32'h3210FEDC, 4'hF);
           axi4lite_read  (MM2S_ADDRREG1,32'h3210FEDC,error);
   	  end 
   	  
   	if(~error)
   	  $display ("MM2S register read write test pass successfully\n");
   	else 
   	  begin 
        $display ("MM2S register read write test failed\n");
   		$stop;
   	  end 
     end 
   endtask 
   
    task mm2s_pkt_write;                                                                                                     
      input [15:0]  pkt_size;                                                                                                
      input [2:0]   num_of_cmd;       
      begin								
       mm2s_pkt_mem_wraddr = ~0;	  
       for(i = 0; i < num_of_cmd; i = i + 1)                                                                                 
    	  begin 	                                                                                                         
    	    for(j = 0; j < pkt_size; j = j + 1)                                                                              
			  begin 
			    @(posedge clk)                                                                                                   
    		    for(rand_data = 0; rand_data < (MM2S_DATA_WIDTH/32); rand_data = rand_data + 1)    
                  begin 				
                    mm2s_pkt_mem_wrdata[32*rand_data +: 32] = $random;                                                 
				  end 
				mm2s_pkt_mem_write  = 1;                                                            
    		    mm2s_pkt_mem_wraddr = mm2s_pkt_mem_wraddr + 1;
    		  end                                                                                                            
    	  end                                                                                                                
    	@(posedge clk)                                                                                                       
    	  mm2s_pkt_mem_write = 0;                                                                                            
      end 
    endtask
   
   task mm2s_cmds_write;                                                                                                     
     input [15:0] 	pkt_buff_start_addr;                                                                                       
     input [2:0]  	num_of_cmd;                                                                                                
     input [15:0] 	pkt_size;     //number of bytes to tx                                                                      
     input [1:0]  	burst_type;     //number of bytes to tx                                                                      
     reg   [15:0] 	pkt_size_config;      
     reg   [15:0] 	pkt_addr;	 
	 reg   [9:0]  id_cnt;
     begin                  
	   pkt_addr = 	pkt_buff_start_addr;	
	   pkt_addr[($clog2(MM2S_DATA_WIDTH))-3:0] = 0;			   			
	   id_cnt = 0;
	   
       for(i=0;i<num_of_cmd;i=i+1)                                                                                           
   	    begin                                                                                                                  
          @(posedge clk)                                                                                                    
   	      begin                                                                                                              
			  
   		    pkt_size_config = $urandom_range (MM2S_DATA_WIDTH/8,pkt_size);      
			
			if(pkt_size_config < (MM2S_DATA_WIDTH/8))
			  pkt_size_config = MM2S_DATA_WIDTH/8;
			
			
			
   		    if(i == 0)                                                                                                       
   			  begin                                                                           
                                   // (awaddr,         wdata,                               wstrb)                           
                axi4lite_write (MM2S_LENGTHREG,     pkt_size_config,                     4'hF);                             
   			    axi4lite_write (MM2S_ADDRREG0,      pkt_addr,                            4'hF);                             
   			    axi4lite_write (MM2S_CNTRLREG,    {id_cnt, 13'd0,  burst_type,        1'b1},         4'hF);    

                if(| pkt_size_config[$clog2(MM2S_DATA_WIDTH/8)-1:0])
				  pkt_size_config = pkt_size_config + (pkt_size_config % (MM2S_DATA_WIDTH/8));
			    pkt_addr = 	pkt_addr + ((i+1) * pkt_size_config);
				pkt_addr[($clog2(MM2S_DATA_WIDTH/8))-1:0] = 0;
				id_cnt = id_cnt + 1;
				
   			  end                                                                                                            
   			else                                                                                                             
   			  begin                                                                                                          
                axi4lite_write (MM2S_LENGTHREG,     pkt_size_config,                     4'hF);                             
   			    axi4lite_write (MM2S_ADDRREG0,      pkt_addr       ,                     4'hF);                             
   			    axi4lite_write (MM2S_CNTRLREG,    {id_cnt, 13'd0,  burst_type,        1'b1},        4'hF);   
				
                if(| pkt_size_config[$clog2(MM2S_DATA_WIDTH/8)-1:0])
				  pkt_size_config = pkt_size_config + (pkt_size_config % (MM2S_DATA_WIDTH/8));
			    pkt_addr = 	pkt_addr + ((i+1) * pkt_size_config);
				pkt_addr[($clog2(MM2S_DATA_WIDTH/8))-1:0] = 0;
				id_cnt = id_cnt + 1;
				
   			  end
			  
            
   	      end                                                                                                                
   	  end	    
      $display ("Number of descriptors stored in MM2S Command FIFO = %d\n",num_of_cmd);	  
     end                                                                                                                     
   endtask                                                                                         
   
    // To write and Read MM2S register 
    task mm2s_test;                                                                                                          
      input [15:0] pkt_mem_sa;                                                                                                            
      input [15:0] pkt_size_word;                                                                                            
      input [2:0]  num_of_cmd;                                                                                               
      input [1:0]  burst_type;                                                                                               
      reg   [7:0]  count;       
      reg   [9:0]  sts_id_cnt;	  
      begin                                                                                                                  
                                                                                                                             
        mm2s_pkt_write(pkt_size_word,  num_of_cmd);                                                                          
        mm2s_cmds_write (pkt_mem_sa,  num_of_cmd,   pkt_size_word,burst_type);                                                          
    	mm2s_busy = 1'b1;                                                                                                    
        count = 0;                                   
        sts_id_cnt = 0;                                   
        axi4s_tready_en = 1'b1;		
        repeat (num_of_cmd)
          begin 		
		    wait(axi4s_t_tvalid & axi4s_t_tready & axi4s_t_tlast);
			@(posedge clk);
		  end 
		
		  
        repeat (num_of_cmd)
          begin 		
		    @(posedge clk)
              mm2s_busy = 1'b1;			
    		while(mm2s_busy)                                                                                                 
    		  begin                                                                                                          
                axi4lite_read_data (MM2S_STSREG, reg_rddata);	                                                         
    		    if(reg_rddata[0] == 1'b1)                                                                                    
    			  begin                                                                                                      
    		        $display ("Packet is transmitted from AXI4 MM to AXI4 Stream\n");   
                    if(reg_rddata[25:16] != sts_id_cnt)
                      $display ("Status ID doesn't match with Command ID\n");					
    				mm2s_busy = 1'b0;             
                    error     = ((| reg_rddata[3:2]) | (reg_rddata[25:16] != sts_id_cnt));
    			  end                                                                                                        
    		  end  
            sts_id_cnt = sts_id_cnt + 1;			  
    	  end      
        
        axi4s_tready_en = 1'b0;		
    	                                                                                                                     
    	if(error)                           
          begin 		
    	    $display ("Error is detected in read response\n");	                                                                                 
			$stop;
		  end     		                                                                                                                 
      end                                                                                                                    
    endtask
	
   task mm2s_intr_test;
     input [15:0] pkt_mem_sa;
     input [15:0] pkt_size;
     input [2:0]  num_of_cmd;
	 input [1:0]  burst_type;
     
	 reg   [9:0]  sts_id_cnt;
     
     begin
	   
	   if(num_of_cmd != 1) begin      
	     axi4lite_write (MM2S_INTRENBREG,32'h01,4'hF);
	   end else begin 
	     axi4lite_write (S2MM_INTRENBREG,32'h01,4'hF);	     
	   end 
	   
       mm2s_pkt_write (pkt_size, num_of_cmd);
   	
       mm2s_cmds_write (pkt_mem_sa, num_of_cmd, pkt_size,burst_type);
   	       
	   sts_id_cnt = 0;
       @(posedge clk)			
   	   wait (mm2s_int)
       axi4lite_write (MM2S_INTRSRCREG,32'hFF,4'hF);
	   repeat(num_of_cmd-1)
	     begin 
		   axi4lite_read_data (MM2S_STSREG, reg_rddata);	
	   	   if(reg_rddata[0] & ~reg_rddata[1])
   		     begin 
   		       $display ("Single Packet is transmitted from AXI4 MM to AXI4 Stream\n");   				
			   if(reg_rddata[25:16] != sts_id_cnt)
			     $display ("Status ID doesn't match with Command ID\n");
				 error     = ((| reg_rddata[3:2]) | (reg_rddata[25:16] != sts_id_cnt));
   			 end 	
           sts_id_cnt = sts_id_cnt + 1;			 
   		 end	 
	     begin 
		   axi4lite_read_data (MM2S_STSREG, reg_rddata);	
	   	   if(reg_rddata[0] & reg_rddata[1])
   		     begin 
   		       $display ("Single Packet is transmitted from AXI4 MM to AXI4 Stream\n");   				
			   if(reg_rddata[25:16] != sts_id_cnt)
			     $display ("Status ID doesn't match with Command ID\n");
				 error     = ((| reg_rddata[3:2]) | (reg_rddata[25:16] != sts_id_cnt));
   			 end 	
           sts_id_cnt = sts_id_cnt + 1;			 
   		 end	 
   	   if(error)
	     begin 
   	       $display ("mm2s interrupt test failed\n");	
	       $stop;
	     end    		
     end
   endtask
    //-----------------------------------------------------------------------------------	
   
   // Input drive logic------------------------------------------------------------------
   initial 
     begin 
       clk                     = 0;
   	   arst_n                  = 0;
   	   axi4l_m_awvalid    = 0;
   	   axi4l_m_awaddr     = 0;
   	   axi4l_m_wvalid     = 0;
   	   axi4l_m_bready     = 0;
   	   axi4l_m_arvalid    = 0;
   	   axi4l_m_araddr     = 0;
   	   axi4l_m_rready     = 0;	
   	   error                   = 0;
   	   pkt_mem_clr             = 0;
   	
   	#100	
   	arst_n                  = 1;	
   	if(S2MM_ENABLE)
   	  begin 
	    mm2s_en = 0;
   	    $display ("////////////////////////////////////////////////////\n");
   	    $display ("//////////////////S2MM Test Initiated///////////////\n");
   	    $display ("////////////////////////////////////////////////////\n");
	  
   	    s2mm_register_rdwr_test();	
   	    
   	    #100	
   	    arst_n                  = 0;	
   	    #100 	
   	    arst_n                  = 1;	
   	    #100
   	           
   	    pkt_mem_sa     = $urandom_range(0,2048);
   	    pkt_size       = $urandom_range((S2MM_DATA_WIDTH/8),100);
   	    num_of_cmd     = 4;
		burst_type     = 2'b01;
   	    s2mm_test(pkt_mem_sa,pkt_size,num_of_cmd,burst_type);   	
        $display ("S2MM increment burst test pass \n");		
		
  	    pkt_mem_sa     = 4096-(S2MM_DATA_WIDTH/8);
   	    pkt_size       = $urandom_range((S2MM_DATA_WIDTH/8),100);
   	    num_of_cmd     = 2;
   	    s2mm_test(pkt_mem_sa,pkt_size,num_of_cmd,burst_type);   	
        $display ("S2MM increment burst with 4K boundary test pass \n");		
  
   	    pkt_mem_sa     = $urandom_range(0,2048);
   	    pkt_size       = $urandom_range((S2MM_DATA_WIDTH/8),100);
   	    num_of_cmd     = 3;
		burst_type     = 2'b00;
   	    s2mm_test(pkt_mem_sa,pkt_size,num_of_cmd,burst_type);   	
        $display ("S2MM fixed burst test pass \n");		

   	    pkt_mem_sa     = 8192-(S2MM_DATA_WIDTH/8);
   	    pkt_size       = $urandom_range((S2MM_DATA_WIDTH/8),100);
   	    num_of_cmd     = 2;
		burst_type     = 2'b00;
   	    s2mm_test(pkt_mem_sa,pkt_size,num_of_cmd,burst_type);   	
        $display ("S2MM fixed burst with 4K boundary test pass \n");		
		

		
   	    pkt_mem_sa     = $urandom_range(0,2048);
   	    pkt_size       = $urandom_range((S2MM_DATA_WIDTH/8),100);
   	    num_of_cmd     = 4;
		burst_type     = 2'b01;
   	    s2mm_intr_test(pkt_mem_sa,pkt_size,num_of_cmd,burst_type);   	
        $display ("S2MM interrupt test pass \n");		
		
		if(~error)
		  $display ("S2MM test pass \n");		
		else 		
		  $display ("S2MM test fail \n");		
		  
		  
    
     end 
   
   	if(MM2S_ENABLE)
   	  begin 
   	    mm2s_en = 1;
   	    $display ("////////////////////////////////////////////////////\n");
   	    $display ("//////////////////MM2S Test Initiated///////////////\n");
   	    $display ("////////////////////////////////////////////////////\n");
   	    
        mm2S_register_rdwr_test();			
   	    
   	    #100	
   	    arst_n                  = 0;	
   	    #100 	
   	    arst_n                  = 1;	
   	    #100
   	    
		@(posedge clk)
   	    pkt_mem_clr    = 1;
		@(posedge clk)
   	    pkt_mem_clr    = 0;
		
	
   	    pkt_mem_sa     = 0;
   	    pkt_size       = (MM2S_DATA_WIDTH/8) * 4;
   	    num_of_cmd     = 4;
		burst_type     = 2'b01;
   	    mm2s_test(pkt_mem_sa,pkt_size,num_of_cmd,burst_type);
		$display ("MM2S increment burst test pass \n");				
		
		@(posedge clk)
   	    pkt_mem_clr    = 1;
		@(posedge clk)
   	    pkt_mem_clr    = 0;
		
   	    
   	    pkt_mem_sa     = 4096-(MM2S_DATA_WIDTH/8);
   	    pkt_size       = (MM2S_DATA_WIDTH/8) * 4;
   	    num_of_cmd     = 2;
		burst_type     = 2'b01;
   	    mm2s_test(pkt_mem_sa,pkt_size,num_of_cmd,burst_type);   	
        $display ("MM2S increment burst with 4K boundary test pass \n");		
  
  		@(posedge clk)
   	    pkt_mem_clr    = 1;
		@(posedge clk)
   	    pkt_mem_clr    = 0;

   	    pkt_mem_sa     = 0;
   	    pkt_size       = (MM2S_DATA_WIDTH/8) * 2;
   	    num_of_cmd     = 3;
		burst_type     = 2'b00;
   	    mm2s_test(pkt_mem_sa,pkt_size,num_of_cmd,burst_type);   	
        $display ("MM2S fixed burst test pass \n");		

		@(posedge clk)
   	    pkt_mem_clr    = 1;
		@(posedge clk)
   	    pkt_mem_clr    = 0;

   	    pkt_mem_sa     = 4096-(MM2S_DATA_WIDTH/8);
   	    pkt_size       = (MM2S_DATA_WIDTH/8) * 2;
   	    num_of_cmd     = 2;
		burst_type     = 2'b00;
   	    mm2s_test(pkt_mem_sa,pkt_size,num_of_cmd,burst_type);   	
        $display ("MM2S fixed burst with 4K boundary test pass \n");	

   	    pkt_mem_sa     = 0;
   	    pkt_size       = (MM2S_DATA_WIDTH/8) * 4;
   	    num_of_cmd     = 4;
		burst_type     = 2'b01;
   	    mm2s_intr_test(pkt_mem_sa,pkt_size,num_of_cmd,burst_type);
		$display ("MM2S interrupt test pass \n");			
		
        if(~error)
		  $display ("MM2S test pass \n");		
		else 		
		  $display ("MM2S test fail \n");		

		
      end 
   	
   	  $stop; 
   	
     end
	 //----------------------------------------------------------------------------------

endmodule