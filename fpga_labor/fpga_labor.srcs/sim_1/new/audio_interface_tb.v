`timescale 1ns / 1ps

module audio_interface_tb;

reg clk;
reg mclk_in;
reg rst_n;
reg en;
reg codec_lrclk;
reg codec_bclk;
reg codec_sdout;

wire codec_mclk;
wire codec_sdin;
wire [23:0] adc_data;
wire adc_valid_l;
wire adc_valid_r;

audio_interface uut (
    .clk(clk),
    .mclk_in(mclk_in),
    .rst_n(rst_n),
    .en(en),
    .codec_mclk(codec_mclk),
    .codec_lrclk(codec_lrclk),
    .codec_bclk(codec_bclk),
    .codec_sdout(codec_sdout),
    .codec_sdin(codec_sdin),
    .adc_data(adc_data),
    .adc_valid_l(adc_valid_l),
    .adc_valid_r(adc_valid_r)
);

// 100 MHz -> 10ns
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst_n = 0;
    en = 0;
    mclk_in = 0;
    codec_sdout = 0;
    
    #100;
    rst_n = 1;
    en = 1;
    #50000;
    $finish;
end

initial begin
    // 192kHz -> 5208.33ns 
    codec_lrclk = 0;
    forever #2604.16 codec_lrclk = ~codec_lrclk;
end


initial begin
    // 192kHz * 32 * 2 = 12.288MHz -> 81.38ns 
    codec_bclk = 0;
    forever #40.69 codec_bclk = ~codec_bclk;
end

initial begin
    codec_sdout = 0;
    #150;
    // Generating 1s and 0s on the data line
    forever begin
        @(negedge codec_bclk);
        codec_sdout = ~codec_sdout;
    end
end
endmodule
