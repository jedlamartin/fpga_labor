; ModuleID = '/mnt/work/fpga_labor/fpga_labor/vitis/fir_hls/fir_hls/hls/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

%"struct.ap_uint<16>" = type { %"struct.ap_int_base<16, false>" }
%"struct.ap_int_base<16, false>" = type { %"struct.ssdm_int<16, false>" }
%"struct.ssdm_int<16, false>" = type { i16 }
%"struct.ap_uint<3>" = type { %"struct.ap_int_base<3, false>" }
%"struct.ap_int_base<3, false>" = type { %"struct.ssdm_int<3, false>" }
%"struct.ssdm_int<3, false>" = type { i3 }
%"struct.ap_uint<9>" = type { %"struct.ap_int_base<9, false>" }
%"struct.ap_int_base<9, false>" = type { %"struct.ssdm_int<9, false>" }
%"struct.ssdm_int<9, false>" = type { i9 }
%"struct.ap_fixed<32, 1>" = type { %"struct.ap_fixed_base<32, 1>" }
%"struct.ap_fixed_base<32, 1>" = type { %"struct.ssdm_int<32, true>" }
%"struct.ssdm_int<32, true>" = type { i32 }
%"struct.ap_fixed<24, 1>" = type { %"struct.ap_fixed_base<24, 1>" }
%"struct.ap_fixed_base<24, 1>" = type { %"struct.ssdm_int<24, true>" }
%"struct.ssdm_int<24, true>" = type { i24 }
%"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>" = type { %"struct.hls::axis<ap_fixed<32, 1>>" }
%"struct.hls::axis<ap_fixed<32, 1>>" = type { %"struct.ap_fixed<32, 1>", %"struct.ap_uint<4>", %"struct.ap_uint<4>", %"struct.hls::axis_disabled_signal", %"struct.ap_uint<1>", %"struct.hls::axis_disabled_signal", %"struct.hls::axis_disabled_signal" }
%"struct.ap_uint<4>" = type { %"struct.ap_int_base<4, false>" }
%"struct.ap_int_base<4, false>" = type { %"struct.ssdm_int<4, false>" }
%"struct.ssdm_int<4, false>" = type { i4 }
%"struct.ap_uint<1>" = type { %"struct.ap_int_base<1, false>" }
%"struct.ap_int_base<1, false>" = type { %"struct.ssdm_int<1, false>" }
%"struct.ssdm_int<1, false>" = type { i1 }
%"struct.hls::axis_disabled_signal" = type { i8 }

; Function Attrs: noinline willreturn
define void @apatb_fir_hw_ir(%"struct.ap_uint<16>"* nocapture readonly %tlast_dnum, %"struct.ap_uint<3>"* nocapture readonly %smpl_rd_num, %"struct.ap_uint<9>"* nocapture readonly %tap_num_m1, %"struct.ap_fixed<32, 1>"* noalias nocapture nonnull readonly "fpga.decayed.dim.hint"="512" %coeff_hw, %"struct.ap_fixed<24, 1>"* noalias nocapture nonnull readonly %input_l, %"struct.ap_fixed<24, 1>"* noalias nocapture nonnull readonly %input_r, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* noalias nonnull align 4 dereferenceable(12) %res) local_unnamed_addr #0 {
entry:
  %0 = bitcast %"struct.ap_fixed<32, 1>"* %coeff_hw to [512 x %"struct.ap_fixed<32, 1>"]*
  %coeff_hw_copy = alloca [512 x i32], align 512
  %input_l_copy = alloca i24, align 512
  %input_r_copy = alloca i24, align 512
  %res_copy.data = alloca i32, align 512
  %res_copy.keep = alloca i4, align 512
  %res_copy.strb = alloca i4, align 512
  %res_copy.last = alloca i1, align 512
  call fastcc void @copy_in([512 x %"struct.ap_fixed<32, 1>"]* nonnull %0, [512 x i32]* nonnull align 512 %coeff_hw_copy, %"struct.ap_fixed<24, 1>"* nonnull %input_l, i24* nonnull align 512 %input_l_copy, %"struct.ap_fixed<24, 1>"* nonnull %input_r, i24* nonnull align 512 %input_r_copy, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* nonnull %res, i32* nonnull align 512 %res_copy.data, i4* nonnull align 512 %res_copy.keep, i4* nonnull align 512 %res_copy.strb, i1* nonnull align 512 %res_copy.last)
  call void @apatb_fir_hw_hw(%"struct.ap_uint<16>"* %tlast_dnum, %"struct.ap_uint<3>"* %smpl_rd_num, %"struct.ap_uint<9>"* %tap_num_m1, [512 x i32]* %coeff_hw_copy, i24* %input_l_copy, i24* %input_r_copy, i32* %res_copy.data, i4* %res_copy.keep, i4* %res_copy.strb, i1* %res_copy.last)
  call void @copy_back([512 x %"struct.ap_fixed<32, 1>"]* %0, [512 x i32]* %coeff_hw_copy, %"struct.ap_fixed<24, 1>"* %input_l, i24* %input_l_copy, %"struct.ap_fixed<24, 1>"* %input_r, i24* %input_r_copy, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %res, i32* %res_copy.data, i4* %res_copy.keep, i4* %res_copy.strb, i1* %res_copy.last)
  ret void
}

; Function Attrs: argmemonly noinline willreturn
define internal fastcc void @copy_in([512 x %"struct.ap_fixed<32, 1>"]* noalias readonly "unpacked"="0", [512 x i32]* noalias nocapture align 512 "unpacked"="1.0", %"struct.ap_fixed<24, 1>"* noalias readonly "unpacked"="2", i24* noalias nocapture align 512 "unpacked"="3.0", %"struct.ap_fixed<24, 1>"* noalias readonly "unpacked"="4", i24* noalias nocapture align 512 "unpacked"="5.0", %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* noalias "unpacked"="6", i32* noalias align 512 "unpacked"="7.0" %_V_data_V, i4* noalias align 512 "unpacked"="7.1" %_V_keep_V, i4* noalias align 512 "unpacked"="7.2" %_V_strb_V, i1* noalias align 512 "unpacked"="7.3" %_V_last_V) unnamed_addr #1 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a512struct.ap_fixed<32, 1>"([512 x i32]* align 512 %1, [512 x %"struct.ap_fixed<32, 1>"]* %0)
  call fastcc void @"onebyonecpy_hls.p0struct.ap_fixed<24, 1>.22"(i24* align 512 %3, %"struct.ap_fixed<24, 1>"* %2)
  call fastcc void @"onebyonecpy_hls.p0struct.ap_fixed<24, 1>.22"(i24* align 512 %5, %"struct.ap_fixed<24, 1>"* %4)
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>.43"(i32* align 512 %_V_data_V, i4* align 512 %_V_keep_V, i4* align 512 %_V_strb_V, i1* align 512 %_V_last_V, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %6)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @"onebyonecpy_hls.p0a512struct.ap_fixed<32, 1>"([512 x i32]* noalias nocapture align 512 "unpacked"="0.0" %dst, [512 x %"struct.ap_fixed<32, 1>"]* noalias readonly "unpacked"="1" %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [512 x %"struct.ap_fixed<32, 1>"]* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @"arraycpy_hls.p0a512struct.ap_fixed<32, 1>"([512 x i32]* %dst, [512 x %"struct.ap_fixed<32, 1>"]* nonnull %src, i64 512)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a512struct.ap_fixed<32, 1>"([512 x i32]* nocapture "unpacked"="0.0" %dst, [512 x %"struct.ap_fixed<32, 1>"]* readonly "unpacked"="1" %src, i64 "unpacked"="2" %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [512 x %"struct.ap_fixed<32, 1>"]* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [512 x %"struct.ap_fixed<32, 1>"], [512 x %"struct.ap_fixed<32, 1>"]* %src, i64 0, i64 %for.loop.idx2, i32 0, i32 0, i32 0
  %dst.addr.0.0.06 = getelementptr [512 x i32], [512 x i32]* %dst, i64 0, i64 %for.loop.idx2
  %1 = load i32, i32* %src.addr.0.0.05, align 4
  store i32 %1, i32* %dst.addr.0.0.06, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline willreturn
define internal fastcc void @"onebyonecpy_hls.p0class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"(%"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* noalias %dst, i32* noalias align 512 "unpacked"="1.0" %src_V_data_V, i4* noalias align 512 "unpacked"="1.1" %src_V_keep_V, i4* noalias align 512 "unpacked"="1.2" %src_V_strb_V, i1* noalias align 512 "unpacked"="1.3" %src_V_last_V) unnamed_addr #4 {
entry:
  %0 = icmp eq %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call fastcc void @"streamcpy_hls.p0class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"(%"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* nonnull %dst, i32* align 512 %src_V_data_V, i4* align 512 %src_V_keep_V, i4* align 512 %src_V_strb_V, i1* align 512 %src_V_last_V)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline willreturn
define internal fastcc void @"streamcpy_hls.p0class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"(%"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* noalias nocapture, i32* noalias nocapture align 512 "unpacked"="1.0" %_V_data_V, i4* noalias nocapture align 512 "unpacked"="1.1" %_V_keep_V, i4* noalias nocapture align 512 "unpacked"="1.2" %_V_strb_V, i1* noalias nocapture align 512 "unpacked"="1.3" %_V_last_V) unnamed_addr #5 {
entry:
  %1 = alloca i32
  %2 = alloca i4
  %3 = alloca i4
  %4 = alloca i1
  %5 = alloca %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"
  br label %empty

empty:                                            ; preds = %push, %entry
  %6 = bitcast i32* %_V_data_V to i8*
  %7 = call i1 @fpga_fifo_not_empty_4(i8* %6)
  br i1 %7, label %push, label %ret

push:                                             ; preds = %empty
  %8 = bitcast i32* %1 to i8*
  %9 = bitcast i32* %_V_data_V to i8*
  call void @fpga_fifo_pop_4(i8* %8, i8* %9)
  %10 = load volatile i32, i32* %1
  %11 = bitcast i4* %3 to i8*
  %12 = bitcast i4* %_V_keep_V to i8*
  call void @fpga_fifo_pop_1(i8* %11, i8* %12)
  %13 = bitcast i4* %3 to i8*
  %14 = load i8, i8* %13
  %15 = trunc i8 %14 to i4
  %16 = bitcast i4* %2 to i8*
  %17 = bitcast i4* %_V_strb_V to i8*
  call void @fpga_fifo_pop_1(i8* %16, i8* %17)
  %18 = bitcast i4* %2 to i8*
  %19 = load i8, i8* %18
  %20 = trunc i8 %19 to i4
  %21 = bitcast i1* %4 to i8*
  %22 = bitcast i1* %_V_last_V to i8*
  call void @fpga_fifo_pop_1(i8* %21, i8* %22)
  %23 = bitcast i1* %4 to i8*
  %24 = load i8, i8* %23
  %25 = trunc i8 %24 to i1
  %.fca.0.0.0.0.0.insert = insertvalue %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>" undef, i32 %10, 0, 0, 0, 0, 0
  %.fca.0.1.0.0.0.insert = insertvalue %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>" %.fca.0.0.0.0.0.insert, i4 %15, 0, 1, 0, 0, 0
  %.fca.0.2.0.0.0.insert = insertvalue %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>" %.fca.0.1.0.0.0.insert, i4 %20, 0, 2, 0, 0, 0
  %.fca.0.4.0.0.0.insert = insertvalue %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>" %.fca.0.2.0.0.0.insert, i1 %25, 0, 4, 0, 0, 0
  store %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>" %.fca.0.4.0.0.0.insert, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %5
  %26 = bitcast %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %5 to i8*
  %27 = bitcast %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %0 to i8*
  call void @fpga_fifo_push_12(i8* %26, i8* %27)
  br label %empty, !llvm.loop !6

ret:                                              ; preds = %empty
  ret void
}

; Function Attrs: argmemonly noinline willreturn
define internal fastcc void @copy_out([512 x %"struct.ap_fixed<32, 1>"]* noalias "unpacked"="0", [512 x i32]* noalias nocapture readonly align 512 "unpacked"="1.0", %"struct.ap_fixed<24, 1>"* noalias "unpacked"="2", i24* noalias nocapture readonly align 512 "unpacked"="3.0", %"struct.ap_fixed<24, 1>"* noalias "unpacked"="4", i24* noalias nocapture readonly align 512 "unpacked"="5.0", %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* noalias "unpacked"="6", i32* noalias align 512 "unpacked"="7.0" %_V_data_V, i4* noalias align 512 "unpacked"="7.1" %_V_keep_V, i4* noalias align 512 "unpacked"="7.2" %_V_strb_V, i1* noalias align 512 "unpacked"="7.3" %_V_last_V) unnamed_addr #6 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a512struct.ap_fixed<32, 1>.30"([512 x %"struct.ap_fixed<32, 1>"]* %0, [512 x i32]* align 512 %1)
  call fastcc void @"onebyonecpy_hls.p0struct.ap_fixed<24, 1>"(%"struct.ap_fixed<24, 1>"* %2, i24* align 512 %3)
  call fastcc void @"onebyonecpy_hls.p0struct.ap_fixed<24, 1>"(%"struct.ap_fixed<24, 1>"* %4, i24* align 512 %5)
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"(%"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %6, i32* align 512 %_V_data_V, i4* align 512 %_V_keep_V, i4* align 512 %_V_strb_V, i1* align 512 %_V_last_V)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @"onebyonecpy_hls.p0struct.ap_fixed<24, 1>"(%"struct.ap_fixed<24, 1>"* noalias "unpacked"="0" %dst, i24* noalias nocapture readonly align 512 "unpacked"="1.0" %src) unnamed_addr #2 {
entry:
  %0 = icmp eq %"struct.ap_fixed<24, 1>"* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  %dst.0.0.04 = getelementptr %"struct.ap_fixed<24, 1>", %"struct.ap_fixed<24, 1>"* %dst, i64 0, i32 0, i32 0, i32 0
  %1 = load i24, i24* %src, align 512
  store i24 %1, i24* %dst.0.0.04, align 4
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @"onebyonecpy_hls.p0struct.ap_fixed<24, 1>.22"(i24* noalias nocapture align 512 "unpacked"="0.0" %dst, %"struct.ap_fixed<24, 1>"* noalias readonly "unpacked"="1" %src) unnamed_addr #2 {
entry:
  %0 = icmp eq %"struct.ap_fixed<24, 1>"* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  %src.0.0.03 = getelementptr %"struct.ap_fixed<24, 1>", %"struct.ap_fixed<24, 1>"* %src, i64 0, i32 0, i32 0, i32 0
  %1 = load i24, i24* %src.0.0.03, align 4
  store i24 %1, i24* %dst, align 512
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @"onebyonecpy_hls.p0a512struct.ap_fixed<32, 1>.30"([512 x %"struct.ap_fixed<32, 1>"]* noalias "unpacked"="0" %dst, [512 x i32]* noalias nocapture readonly align 512 "unpacked"="1.0" %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [512 x %"struct.ap_fixed<32, 1>"]* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @"arraycpy_hls.p0a512struct.ap_fixed<32, 1>.33"([512 x %"struct.ap_fixed<32, 1>"]* nonnull %dst, [512 x i32]* %src, i64 512)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a512struct.ap_fixed<32, 1>.33"([512 x %"struct.ap_fixed<32, 1>"]* "unpacked"="0" %dst, [512 x i32]* nocapture readonly "unpacked"="1.0" %src, i64 "unpacked"="2" %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [512 x %"struct.ap_fixed<32, 1>"]* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [512 x i32], [512 x i32]* %src, i64 0, i64 %for.loop.idx2
  %dst.addr.0.0.06 = getelementptr [512 x %"struct.ap_fixed<32, 1>"], [512 x %"struct.ap_fixed<32, 1>"]* %dst, i64 0, i64 %for.loop.idx2, i32 0, i32 0, i32 0
  %1 = load i32, i32* %src.addr.0.0.05, align 4
  store i32 %1, i32* %dst.addr.0.0.06, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline willreturn
define internal fastcc void @"onebyonecpy_hls.p0class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>.43"(i32* noalias align 512 "unpacked"="0.0" %dst_V_data_V, i4* noalias align 512 "unpacked"="0.1" %dst_V_keep_V, i4* noalias align 512 "unpacked"="0.2" %dst_V_strb_V, i1* noalias align 512 "unpacked"="0.3" %dst_V_last_V, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* noalias %src) unnamed_addr #4 {
entry:
  %0 = icmp eq %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call fastcc void @"streamcpy_hls.p0class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>.46"(i32* align 512 %dst_V_data_V, i4* align 512 %dst_V_keep_V, i4* align 512 %dst_V_strb_V, i1* align 512 %dst_V_last_V, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* nonnull %src)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline willreturn
define internal fastcc void @"streamcpy_hls.p0class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>.46"(i32* noalias nocapture align 512 "unpacked"="0.0" %_V_data_V, i4* noalias nocapture align 512 "unpacked"="0.1" %_V_keep_V, i4* noalias nocapture align 512 "unpacked"="0.2" %_V_strb_V, i1* noalias nocapture align 512 "unpacked"="0.3" %_V_last_V, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* noalias nocapture) unnamed_addr #5 {
entry:
  %1 = alloca %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"
  %2 = alloca i32
  %3 = alloca i4
  %4 = alloca i4
  %5 = alloca i1
  br label %empty

empty:                                            ; preds = %push, %entry
  %6 = bitcast %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %0 to i8*
  %7 = call i1 @fpga_fifo_not_empty_12(i8* %6)
  br i1 %7, label %push, label %ret

push:                                             ; preds = %empty
  %8 = bitcast %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %1 to i8*
  %9 = bitcast %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %0 to i8*
  call void @fpga_fifo_pop_12(i8* %8, i8* %9)
  %10 = load volatile %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>", %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %1
  %.fca.0.0.0.0.0.extract = extractvalue %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>" %10, 0, 0, 0, 0, 0
  %.fca.0.1.0.0.0.extract = extractvalue %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>" %10, 0, 1, 0, 0, 0
  %.fca.0.2.0.0.0.extract = extractvalue %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>" %10, 0, 2, 0, 0, 0
  %.fca.0.4.0.0.0.extract = extractvalue %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>" %10, 0, 4, 0, 0, 0
  store i32 %.fca.0.0.0.0.0.extract, i32* %2
  %11 = bitcast i32* %2 to i8*
  %12 = bitcast i32* %_V_data_V to i8*
  call void @fpga_fifo_push_4(i8* %11, i8* %12)
  store i4 %.fca.0.1.0.0.0.extract, i4* %4
  %13 = bitcast i4* %4 to i8*
  %14 = bitcast i4* %_V_keep_V to i8*
  call void @fpga_fifo_push_1(i8* %13, i8* %14)
  store i4 %.fca.0.2.0.0.0.extract, i4* %3
  %15 = bitcast i4* %3 to i8*
  %16 = bitcast i4* %_V_strb_V to i8*
  call void @fpga_fifo_push_1(i8* %15, i8* %16)
  store i1 %.fca.0.4.0.0.0.extract, i1* %5
  %17 = bitcast i1* %5 to i8*
  %18 = bitcast i1* %_V_last_V to i8*
  call void @fpga_fifo_push_1(i8* %17, i8* %18)
  br label %empty, !llvm.loop !6

ret:                                              ; preds = %empty
  ret void
}

declare i8* @malloc(i64)

declare void @free(i8*)

declare void @apatb_fir_hw_hw(%"struct.ap_uint<16>"*, %"struct.ap_uint<3>"*, %"struct.ap_uint<9>"*, [512 x i32]*, i24*, i24*, i32*, i4*, i4*, i1*)

; Function Attrs: argmemonly noinline willreturn
define internal fastcc void @copy_back([512 x %"struct.ap_fixed<32, 1>"]* noalias "unpacked"="0", [512 x i32]* noalias nocapture readonly align 512 "unpacked"="1.0", %"struct.ap_fixed<24, 1>"* noalias "unpacked"="2", i24* noalias nocapture readonly align 512 "unpacked"="3.0", %"struct.ap_fixed<24, 1>"* noalias "unpacked"="4", i24* noalias nocapture readonly align 512 "unpacked"="5.0", %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* noalias "unpacked"="6", i32* noalias align 512 "unpacked"="7.0" %_V_data_V, i4* noalias align 512 "unpacked"="7.1" %_V_keep_V, i4* noalias align 512 "unpacked"="7.2" %_V_strb_V, i1* noalias align 512 "unpacked"="7.3" %_V_last_V) unnamed_addr #6 {
entry:
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"(%"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %6, i32* align 512 %_V_data_V, i4* align 512 %_V_keep_V, i4* align 512 %_V_strb_V, i1* align 512 %_V_last_V)
  ret void
}

declare void @fir_hw_hw_stub(%"struct.ap_uint<16>"* nocapture readonly, %"struct.ap_uint<3>"* nocapture readonly, %"struct.ap_uint<9>"* nocapture readonly, %"struct.ap_fixed<32, 1>"* noalias nocapture nonnull readonly, %"struct.ap_fixed<24, 1>"* noalias nocapture nonnull readonly, %"struct.ap_fixed<24, 1>"* noalias nocapture nonnull readonly, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* noalias nonnull)

define void @fir_hw_hw_stub_wrapper(%"struct.ap_uint<16>"*, %"struct.ap_uint<3>"*, %"struct.ap_uint<9>"*, [512 x i32]*, i24*, i24*, i32*, i4*, i4*, i1*) #7 {
entry:
  %10 = call i8* @malloc(i64 2048)
  %11 = bitcast i8* %10 to [512 x %"struct.ap_fixed<32, 1>"]*
  %12 = call i8* @malloc(i64 4)
  %13 = bitcast i8* %12 to %"struct.ap_fixed<24, 1>"*
  %14 = call i8* @malloc(i64 4)
  %15 = bitcast i8* %14 to %"struct.ap_fixed<24, 1>"*
  %16 = call i8* @malloc(i64 12)
  %17 = bitcast i8* %16 to %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"*
  call void @copy_out([512 x %"struct.ap_fixed<32, 1>"]* %11, [512 x i32]* %3, %"struct.ap_fixed<24, 1>"* %13, i24* %4, %"struct.ap_fixed<24, 1>"* %15, i24* %5, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %17, i32* %6, i4* %7, i4* %8, i1* %9)
  %18 = bitcast [512 x %"struct.ap_fixed<32, 1>"]* %11 to %"struct.ap_fixed<32, 1>"*
  call void @fir_hw_hw_stub(%"struct.ap_uint<16>"* %0, %"struct.ap_uint<3>"* %1, %"struct.ap_uint<9>"* %2, %"struct.ap_fixed<32, 1>"* %18, %"struct.ap_fixed<24, 1>"* %13, %"struct.ap_fixed<24, 1>"* %15, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %17)
  call void @copy_in([512 x %"struct.ap_fixed<32, 1>"]* %11, [512 x i32]* %3, %"struct.ap_fixed<24, 1>"* %13, i24* %4, %"struct.ap_fixed<24, 1>"* %15, i24* %5, %"class.hls::stream<hls::axis<ap_fixed<32, 1, AP_TRN, AP_WRAP, 0>, 0, 0, 0, '8', false>, 0>"* %17, i32* %6, i4* %7, i4* %8, i1* %9)
  call void @free(i8* %10)
  call void @free(i8* %12)
  call void @free(i8* %14)
  call void @free(i8* %16)
  ret void
}

declare i1 @fpga_fifo_not_empty_12(i8*)

declare i1 @fpga_fifo_not_empty_4(i8*)

declare void @fpga_fifo_pop_12(i8*, i8*)

declare void @fpga_fifo_pop_4(i8*, i8*)

declare void @fpga_fifo_pop_1(i8*, i8*)

declare void @fpga_fifo_push_12(i8*, i8*)

declare void @fpga_fifo_push_4(i8*, i8*)

declare void @fpga_fifo_push_1(i8*, i8*)

attributes #0 = { noinline willreturn "fpga.wrapper.func"="wrapper" }
attributes #1 = { argmemonly noinline willreturn "fpga.wrapper.func"="copyin" }
attributes #2 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="arraycpy_hls" }
attributes #4 = { argmemonly noinline willreturn "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #5 = { argmemonly noinline willreturn "fpga.wrapper.func"="streamcpy_hls" }
attributes #6 = { argmemonly noinline willreturn "fpga.wrapper.func"="copyout" }
attributes #7 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1}
!llvm.module.flags = !{!2, !3, !4}
!blackbox_cfg = !{!5}

!0 = !{!"AMD/Xilinx clang version 16.0.6"}
!1 = !{!"clang version 7.0.0 "}
!2 = !{i32 2, !"Dwarf Version", i32 4}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.rotate.disable"}
