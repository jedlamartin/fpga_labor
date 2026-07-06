################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/middleware/bacnet/demo/handler/dlenv.c \
../src/middleware/bacnet/demo/handler/h_alarm_ack.c \
../src/middleware/bacnet/demo/handler/h_arf.c \
../src/middleware/bacnet/demo/handler/h_arf_a.c \
../src/middleware/bacnet/demo/handler/h_awf.c \
../src/middleware/bacnet/demo/handler/h_ccov.c \
../src/middleware/bacnet/demo/handler/h_cov.c \
../src/middleware/bacnet/demo/handler/h_dcc.c \
../src/middleware/bacnet/demo/handler/h_gas_a.c \
../src/middleware/bacnet/demo/handler/h_get_alarm_sum.c \
../src/middleware/bacnet/demo/handler/h_getevent.c \
../src/middleware/bacnet/demo/handler/h_getevent_a.c \
../src/middleware/bacnet/demo/handler/h_iam.c \
../src/middleware/bacnet/demo/handler/h_ihave.c \
../src/middleware/bacnet/demo/handler/h_lso.c \
../src/middleware/bacnet/demo/handler/h_npdu.c \
../src/middleware/bacnet/demo/handler/h_pt.c \
../src/middleware/bacnet/demo/handler/h_pt_a.c \
../src/middleware/bacnet/demo/handler/h_rd.c \
../src/middleware/bacnet/demo/handler/h_routed_npdu.c \
../src/middleware/bacnet/demo/handler/h_rp.c \
../src/middleware/bacnet/demo/handler/h_rp_a.c \
../src/middleware/bacnet/demo/handler/h_rpm.c \
../src/middleware/bacnet/demo/handler/h_rpm_a.c \
../src/middleware/bacnet/demo/handler/h_rr.c \
../src/middleware/bacnet/demo/handler/h_rr_a.c \
../src/middleware/bacnet/demo/handler/h_ts.c \
../src/middleware/bacnet/demo/handler/h_ucov.c \
../src/middleware/bacnet/demo/handler/h_upt.c \
../src/middleware/bacnet/demo/handler/h_whohas.c \
../src/middleware/bacnet/demo/handler/h_whois.c \
../src/middleware/bacnet/demo/handler/h_wp.c \
../src/middleware/bacnet/demo/handler/h_wpm.c \
../src/middleware/bacnet/demo/handler/noserv.c \
../src/middleware/bacnet/demo/handler/objects.c \
../src/middleware/bacnet/demo/handler/s_abort.c \
../src/middleware/bacnet/demo/handler/s_ack_alarm.c \
../src/middleware/bacnet/demo/handler/s_arfs.c \
../src/middleware/bacnet/demo/handler/s_awfs.c \
../src/middleware/bacnet/demo/handler/s_cevent.c \
../src/middleware/bacnet/demo/handler/s_cov.c \
../src/middleware/bacnet/demo/handler/s_dcc.c \
../src/middleware/bacnet/demo/handler/s_error.c \
../src/middleware/bacnet/demo/handler/s_get_alarm_sum.c \
../src/middleware/bacnet/demo/handler/s_get_event.c \
../src/middleware/bacnet/demo/handler/s_getevent.c \
../src/middleware/bacnet/demo/handler/s_iam.c \
../src/middleware/bacnet/demo/handler/s_ihave.c \
../src/middleware/bacnet/demo/handler/s_lso.c \
../src/middleware/bacnet/demo/handler/s_ptransfer.c \
../src/middleware/bacnet/demo/handler/s_rd.c \
../src/middleware/bacnet/demo/handler/s_readrange.c \
../src/middleware/bacnet/demo/handler/s_router.c \
../src/middleware/bacnet/demo/handler/s_rp.c \
../src/middleware/bacnet/demo/handler/s_rpm.c \
../src/middleware/bacnet/demo/handler/s_ts.c \
../src/middleware/bacnet/demo/handler/s_uevent.c \
../src/middleware/bacnet/demo/handler/s_upt.c \
../src/middleware/bacnet/demo/handler/s_whohas.c \
../src/middleware/bacnet/demo/handler/s_whois.c \
../src/middleware/bacnet/demo/handler/s_wp.c \
../src/middleware/bacnet/demo/handler/s_wpm.c \
../src/middleware/bacnet/demo/handler/txbuf.c 

OBJS += \
./src/middleware/bacnet/demo/handler/dlenv.o \
./src/middleware/bacnet/demo/handler/h_alarm_ack.o \
./src/middleware/bacnet/demo/handler/h_arf.o \
./src/middleware/bacnet/demo/handler/h_arf_a.o \
./src/middleware/bacnet/demo/handler/h_awf.o \
./src/middleware/bacnet/demo/handler/h_ccov.o \
./src/middleware/bacnet/demo/handler/h_cov.o \
./src/middleware/bacnet/demo/handler/h_dcc.o \
./src/middleware/bacnet/demo/handler/h_gas_a.o \
./src/middleware/bacnet/demo/handler/h_get_alarm_sum.o \
./src/middleware/bacnet/demo/handler/h_getevent.o \
./src/middleware/bacnet/demo/handler/h_getevent_a.o \
./src/middleware/bacnet/demo/handler/h_iam.o \
./src/middleware/bacnet/demo/handler/h_ihave.o \
./src/middleware/bacnet/demo/handler/h_lso.o \
./src/middleware/bacnet/demo/handler/h_npdu.o \
./src/middleware/bacnet/demo/handler/h_pt.o \
./src/middleware/bacnet/demo/handler/h_pt_a.o \
./src/middleware/bacnet/demo/handler/h_rd.o \
./src/middleware/bacnet/demo/handler/h_routed_npdu.o \
./src/middleware/bacnet/demo/handler/h_rp.o \
./src/middleware/bacnet/demo/handler/h_rp_a.o \
./src/middleware/bacnet/demo/handler/h_rpm.o \
./src/middleware/bacnet/demo/handler/h_rpm_a.o \
./src/middleware/bacnet/demo/handler/h_rr.o \
./src/middleware/bacnet/demo/handler/h_rr_a.o \
./src/middleware/bacnet/demo/handler/h_ts.o \
./src/middleware/bacnet/demo/handler/h_ucov.o \
./src/middleware/bacnet/demo/handler/h_upt.o \
./src/middleware/bacnet/demo/handler/h_whohas.o \
./src/middleware/bacnet/demo/handler/h_whois.o \
./src/middleware/bacnet/demo/handler/h_wp.o \
./src/middleware/bacnet/demo/handler/h_wpm.o \
./src/middleware/bacnet/demo/handler/noserv.o \
./src/middleware/bacnet/demo/handler/objects.o \
./src/middleware/bacnet/demo/handler/s_abort.o \
./src/middleware/bacnet/demo/handler/s_ack_alarm.o \
./src/middleware/bacnet/demo/handler/s_arfs.o \
./src/middleware/bacnet/demo/handler/s_awfs.o \
./src/middleware/bacnet/demo/handler/s_cevent.o \
./src/middleware/bacnet/demo/handler/s_cov.o \
./src/middleware/bacnet/demo/handler/s_dcc.o \
./src/middleware/bacnet/demo/handler/s_error.o \
./src/middleware/bacnet/demo/handler/s_get_alarm_sum.o \
./src/middleware/bacnet/demo/handler/s_get_event.o \
./src/middleware/bacnet/demo/handler/s_getevent.o \
./src/middleware/bacnet/demo/handler/s_iam.o \
./src/middleware/bacnet/demo/handler/s_ihave.o \
./src/middleware/bacnet/demo/handler/s_lso.o \
./src/middleware/bacnet/demo/handler/s_ptransfer.o \
./src/middleware/bacnet/demo/handler/s_rd.o \
./src/middleware/bacnet/demo/handler/s_readrange.o \
./src/middleware/bacnet/demo/handler/s_router.o \
./src/middleware/bacnet/demo/handler/s_rp.o \
./src/middleware/bacnet/demo/handler/s_rpm.o \
./src/middleware/bacnet/demo/handler/s_ts.o \
./src/middleware/bacnet/demo/handler/s_uevent.o \
./src/middleware/bacnet/demo/handler/s_upt.o \
./src/middleware/bacnet/demo/handler/s_whohas.o \
./src/middleware/bacnet/demo/handler/s_whois.o \
./src/middleware/bacnet/demo/handler/s_wp.o \
./src/middleware/bacnet/demo/handler/s_wpm.o \
./src/middleware/bacnet/demo/handler/txbuf.o 

C_DEPS += \
./src/middleware/bacnet/demo/handler/dlenv.d \
./src/middleware/bacnet/demo/handler/h_alarm_ack.d \
./src/middleware/bacnet/demo/handler/h_arf.d \
./src/middleware/bacnet/demo/handler/h_arf_a.d \
./src/middleware/bacnet/demo/handler/h_awf.d \
./src/middleware/bacnet/demo/handler/h_ccov.d \
./src/middleware/bacnet/demo/handler/h_cov.d \
./src/middleware/bacnet/demo/handler/h_dcc.d \
./src/middleware/bacnet/demo/handler/h_gas_a.d \
./src/middleware/bacnet/demo/handler/h_get_alarm_sum.d \
./src/middleware/bacnet/demo/handler/h_getevent.d \
./src/middleware/bacnet/demo/handler/h_getevent_a.d \
./src/middleware/bacnet/demo/handler/h_iam.d \
./src/middleware/bacnet/demo/handler/h_ihave.d \
./src/middleware/bacnet/demo/handler/h_lso.d \
./src/middleware/bacnet/demo/handler/h_npdu.d \
./src/middleware/bacnet/demo/handler/h_pt.d \
./src/middleware/bacnet/demo/handler/h_pt_a.d \
./src/middleware/bacnet/demo/handler/h_rd.d \
./src/middleware/bacnet/demo/handler/h_routed_npdu.d \
./src/middleware/bacnet/demo/handler/h_rp.d \
./src/middleware/bacnet/demo/handler/h_rp_a.d \
./src/middleware/bacnet/demo/handler/h_rpm.d \
./src/middleware/bacnet/demo/handler/h_rpm_a.d \
./src/middleware/bacnet/demo/handler/h_rr.d \
./src/middleware/bacnet/demo/handler/h_rr_a.d \
./src/middleware/bacnet/demo/handler/h_ts.d \
./src/middleware/bacnet/demo/handler/h_ucov.d \
./src/middleware/bacnet/demo/handler/h_upt.d \
./src/middleware/bacnet/demo/handler/h_whohas.d \
./src/middleware/bacnet/demo/handler/h_whois.d \
./src/middleware/bacnet/demo/handler/h_wp.d \
./src/middleware/bacnet/demo/handler/h_wpm.d \
./src/middleware/bacnet/demo/handler/noserv.d \
./src/middleware/bacnet/demo/handler/objects.d \
./src/middleware/bacnet/demo/handler/s_abort.d \
./src/middleware/bacnet/demo/handler/s_ack_alarm.d \
./src/middleware/bacnet/demo/handler/s_arfs.d \
./src/middleware/bacnet/demo/handler/s_awfs.d \
./src/middleware/bacnet/demo/handler/s_cevent.d \
./src/middleware/bacnet/demo/handler/s_cov.d \
./src/middleware/bacnet/demo/handler/s_dcc.d \
./src/middleware/bacnet/demo/handler/s_error.d \
./src/middleware/bacnet/demo/handler/s_get_alarm_sum.d \
./src/middleware/bacnet/demo/handler/s_get_event.d \
./src/middleware/bacnet/demo/handler/s_getevent.d \
./src/middleware/bacnet/demo/handler/s_iam.d \
./src/middleware/bacnet/demo/handler/s_ihave.d \
./src/middleware/bacnet/demo/handler/s_lso.d \
./src/middleware/bacnet/demo/handler/s_ptransfer.d \
./src/middleware/bacnet/demo/handler/s_rd.d \
./src/middleware/bacnet/demo/handler/s_readrange.d \
./src/middleware/bacnet/demo/handler/s_router.d \
./src/middleware/bacnet/demo/handler/s_rp.d \
./src/middleware/bacnet/demo/handler/s_rpm.d \
./src/middleware/bacnet/demo/handler/s_ts.d \
./src/middleware/bacnet/demo/handler/s_uevent.d \
./src/middleware/bacnet/demo/handler/s_upt.d \
./src/middleware/bacnet/demo/handler/s_whohas.d \
./src/middleware/bacnet/demo/handler/s_whois.d \
./src/middleware/bacnet/demo/handler/s_wp.d \
./src/middleware/bacnet/demo/handler/s_wpm.d \
./src/middleware/bacnet/demo/handler/txbuf.d 


# Each subdirectory must supply rules for building sources it contributes
src/middleware/bacnet/demo/handler/%.o: ../src/middleware/bacnet/demo/handler/%.c src/middleware/bacnet/demo/handler/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64imac -mabi=lp64 -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -pedantic -Wunused -Wuninitialized -Wall -Wextra -Wmissing-declarations -Wconversion -Wpointer-arith -Wpadded -Wshadow -Wlogical-op -Waggregate-return -Wfloat-equal  -g3 -DPSE=1 -DxMSS_MAC_MULTI_PHY -DG5_SOC_EMU_USE_GEM0 -DG5_SOC_EMU_USE_GEM1 -DxMSS_MAC_LWIP_USE_EMAC -DxMSS_MAC_USE_DDR=MSS_MAC_MEM_FIC0 -DxTI_PHY -DVTSS_CHIP_CU_PHY -DVTSS_FEATURE_SYNCE -DVTSS_FEATURE_PHY_TS_ONE_STEP_TXFIFO_OPTION -DVTSS_FEATURE_SERDES_MACRO_SETTINGS -DVTSS_OPT_PORT_COUNT=4 -DVTSS_OPT_VCORE_III=0 -DVTSS_PRODUCT_CHIP="PHY" -DVTSS_PHY_API_ONLY -DVTSS_OPT_TRACE=0 -DVTSS_OS_BARE_METAL_RV -DCMSIS_PROT -DxTARGET_ALOE -DTARGET_G5_SOC -DMSS_MAC_SIMPLE_TX_QUEUE -DCALCONFIGH=\"config_user.h\" -DxSIFIVE_HIFIVE_UNLEASHED -DTEST_H2F_CONTROLLER=0 -D_ZL303XX_MIV -DTARGET_DISCOVERY_KIT -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\demo\object" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\application" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\platform" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\phy_1g\common" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\custom_board" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\custom_board\platform_config\lim-debug" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


