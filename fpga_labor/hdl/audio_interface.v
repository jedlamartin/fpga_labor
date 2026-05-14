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
    (* syn_keep = 1 *) output [23:0] adc_data,
    (* syn_keep = 1 *) output adc_valid_l,
    (* syn_keep = 1 *) output adc_valid_r
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

(* syn_preserve = 1 *) reg [31:0] adc_data_shr;
always @ (posedge clk) begin
    if(bclk_rise) begin
        adc_data_shr <= {adc_data_shr[30:0], sdout_shr[1]};
    end
end

assign adc_valid_l = lrclk_fall & en;
assign adc_valid_r = lrclk_rise & en;

assign adc_data = adc_data_shr[31:8];

//OUTBUF mclk_buffer_inst (
//    .D   (mclk_in),
//    .PAD (codec_mclk)
//);

assign codec_mclk = mclk_in;

endmodule
