module audio_interface(
    input clk,
    input mclk_in,
    input rst_n,
    input en,
    output codec_mclk,
    input codec_lrclk,
    input codec_bclk,
    input codec_sdout,
    output codec_sdin,
    output [23:0] adc_data,
    output adc_valid_l,
    output adc_valid_r
);

// Positive edge reset
wire rst;
assign rst = ~rst_n;

assign codec_sdin = 0;

reg [2:0] lrclk_shr;
reg [2:0] bclk_shr;
reg [1:0] sdout_shr;

always @ (posedge clk) begin
    if(rst) begin
        lrclk_shr <= 0;
        bclk_shr <= 0;
        sdout_shr <= 0;
    end
    else begin
        lrclk_shr <= {lrclk_shr[1:0], codec_lrclk};
        bclk_shr <= {bclk_shr[1:0], codec_bclk};
        sdout_shr <= {sdout_shr[0], codec_sdout};
    end
end

wire lrclk_rise = (lrclk_shr[2:1] == 2'b01);
wire lrclk_fall = (lrclk_shr[2:1] == 2'b10);
wire bclk_rise = (bclk_shr[2:1] == 2'b01);
wire bclk_fall = (bclk_shr[2:1] == 2'b10);

reg [31:0] adc_data_shr;
always @ (posedge clk) begin
    if(bclk_rise) begin
        adc_data_shr <= {adc_data_shr[30:0], sdout_shr[1]};
    end
end
assign adc_data = adc_data_shr[31:8];

wire lrclk_edge = lrclk_rise | lrclk_fall;
reg [4:0] bit_cntr;
always @ (posedge clk) begin
    if(lrclk_edge) begin
        bit_cntr <= 0;
    end
    else if(bclk_rise) begin
        bit_cntr <= bit_cntr + 1;
    end
end

reg adc_valid_l_reg;
reg adc_valid_r_reg;
always @ (posedge clk) begin
    if(lrclk_shr[1] == 1 && bclk_rise == 1 && bit_cntr == 31) begin
         adc_valid_l_reg <= 1;
    end
    else begin
         adc_valid_l_reg <= 0;
    end

    if(lrclk_shr[1] == 0 && bclk_rise == 1 && bit_cntr == 31) begin
         adc_valid_r_reg <= 1;
    end
    else begin
         adc_valid_r_reg <= 0;
    end
end

assign adc_valid_l = adc_valid_l_reg & en;
assign adc_valid_r = adc_valid_r_reg & en;

ODDRE1 #(
  .IS_C_INVERTED(1'b0),           // Optional inversion for C
  .IS_D1_INVERTED(1'b0),          // Unsupported, do not use
  .IS_D2_INVERTED(1'b0),          // Unsupported, do not use
  .SRVAL(1'b0)                    // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
)
ODDRE1_inst (
  .Q(codec_mclk),   // 1-bit output: Data output to IOB
  .C(mclk_in),   // 1-bit input: High-speed clock input
  .D1(1'b1), // 1-bit input: Parallel data input 1
  .D2(1'b0), // 1-bit input: Parallel data input 2
  .SR(rst)  // 1-bit input: Active-High Async Reset
);

endmodule
