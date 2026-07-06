################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/middleware/bacnet/src/abort.c \
../src/middleware/bacnet/src/access_rule.c \
../src/middleware/bacnet/src/address.c \
../src/middleware/bacnet/src/alarm_ack.c \
../src/middleware/bacnet/src/apdu.c \
../src/middleware/bacnet/src/arf.c \
../src/middleware/bacnet/src/assigned_access_rights.c \
../src/middleware/bacnet/src/authentication_factor.c \
../src/middleware/bacnet/src/authentication_factor_format.c \
../src/middleware/bacnet/src/awf.c \
../src/middleware/bacnet/src/bacaddr.c \
../src/middleware/bacnet/src/bacapp.c \
../src/middleware/bacnet/src/bacdcode.c \
../src/middleware/bacnet/src/bacdevobjpropref.c \
../src/middleware/bacnet/src/bacerror.c \
../src/middleware/bacnet/src/bacint.c \
../src/middleware/bacnet/src/bacprop.c \
../src/middleware/bacnet/src/bacpropstates.c \
../src/middleware/bacnet/src/bacreal.c \
../src/middleware/bacnet/src/bacsec.c \
../src/middleware/bacnet/src/bacstr.c \
../src/middleware/bacnet/src/bactext.c \
../src/middleware/bacnet/src/bactimevalue.c \
../src/middleware/bacnet/src/bigend.c \
../src/middleware/bacnet/src/bip.c \
../src/middleware/bacnet/src/bvlc.c \
../src/middleware/bacnet/src/bvlc6.c \
../src/middleware/bacnet/src/cov.c \
../src/middleware/bacnet/src/crc.c \
../src/middleware/bacnet/src/credential_authentication_factor.c \
../src/middleware/bacnet/src/datalink.c \
../src/middleware/bacnet/src/datetime.c \
../src/middleware/bacnet/src/dcc.c \
../src/middleware/bacnet/src/debug.c \
../src/middleware/bacnet/src/event.c \
../src/middleware/bacnet/src/fifo.c \
../src/middleware/bacnet/src/filename.c \
../src/middleware/bacnet/src/get_alarm_sum.c \
../src/middleware/bacnet/src/getevent.c \
../src/middleware/bacnet/src/iam.c \
../src/middleware/bacnet/src/ihave.c \
../src/middleware/bacnet/src/indtext.c \
../src/middleware/bacnet/src/key.c \
../src/middleware/bacnet/src/keylist.c \
../src/middleware/bacnet/src/lighting.c \
../src/middleware/bacnet/src/lso.c \
../src/middleware/bacnet/src/memcopy.c \
../src/middleware/bacnet/src/mstp.c \
../src/middleware/bacnet/src/mstptext.c \
../src/middleware/bacnet/src/npdu.c \
../src/middleware/bacnet/src/proplist.c \
../src/middleware/bacnet/src/ptransfer.c \
../src/middleware/bacnet/src/rd.c \
../src/middleware/bacnet/src/readrange.c \
../src/middleware/bacnet/src/reject.c \
../src/middleware/bacnet/src/ringbuf.c \
../src/middleware/bacnet/src/rp.c \
../src/middleware/bacnet/src/rpm.c \
../src/middleware/bacnet/src/sbuf.c \
../src/middleware/bacnet/src/timestamp.c \
../src/middleware/bacnet/src/timesync.c \
../src/middleware/bacnet/src/tsm.c \
../src/middleware/bacnet/src/ucix.c \
../src/middleware/bacnet/src/version.c \
../src/middleware/bacnet/src/vmac.c \
../src/middleware/bacnet/src/whohas.c \
../src/middleware/bacnet/src/whois.c \
../src/middleware/bacnet/src/wp.c \
../src/middleware/bacnet/src/wpm.c 

OBJS += \
./src/middleware/bacnet/src/abort.o \
./src/middleware/bacnet/src/access_rule.o \
./src/middleware/bacnet/src/address.o \
./src/middleware/bacnet/src/alarm_ack.o \
./src/middleware/bacnet/src/apdu.o \
./src/middleware/bacnet/src/arf.o \
./src/middleware/bacnet/src/assigned_access_rights.o \
./src/middleware/bacnet/src/authentication_factor.o \
./src/middleware/bacnet/src/authentication_factor_format.o \
./src/middleware/bacnet/src/awf.o \
./src/middleware/bacnet/src/bacaddr.o \
./src/middleware/bacnet/src/bacapp.o \
./src/middleware/bacnet/src/bacdcode.o \
./src/middleware/bacnet/src/bacdevobjpropref.o \
./src/middleware/bacnet/src/bacerror.o \
./src/middleware/bacnet/src/bacint.o \
./src/middleware/bacnet/src/bacprop.o \
./src/middleware/bacnet/src/bacpropstates.o \
./src/middleware/bacnet/src/bacreal.o \
./src/middleware/bacnet/src/bacsec.o \
./src/middleware/bacnet/src/bacstr.o \
./src/middleware/bacnet/src/bactext.o \
./src/middleware/bacnet/src/bactimevalue.o \
./src/middleware/bacnet/src/bigend.o \
./src/middleware/bacnet/src/bip.o \
./src/middleware/bacnet/src/bvlc.o \
./src/middleware/bacnet/src/bvlc6.o \
./src/middleware/bacnet/src/cov.o \
./src/middleware/bacnet/src/crc.o \
./src/middleware/bacnet/src/credential_authentication_factor.o \
./src/middleware/bacnet/src/datalink.o \
./src/middleware/bacnet/src/datetime.o \
./src/middleware/bacnet/src/dcc.o \
./src/middleware/bacnet/src/debug.o \
./src/middleware/bacnet/src/event.o \
./src/middleware/bacnet/src/fifo.o \
./src/middleware/bacnet/src/filename.o \
./src/middleware/bacnet/src/get_alarm_sum.o \
./src/middleware/bacnet/src/getevent.o \
./src/middleware/bacnet/src/iam.o \
./src/middleware/bacnet/src/ihave.o \
./src/middleware/bacnet/src/indtext.o \
./src/middleware/bacnet/src/key.o \
./src/middleware/bacnet/src/keylist.o \
./src/middleware/bacnet/src/lighting.o \
./src/middleware/bacnet/src/lso.o \
./src/middleware/bacnet/src/memcopy.o \
./src/middleware/bacnet/src/mstp.o \
./src/middleware/bacnet/src/mstptext.o \
./src/middleware/bacnet/src/npdu.o \
./src/middleware/bacnet/src/proplist.o \
./src/middleware/bacnet/src/ptransfer.o \
./src/middleware/bacnet/src/rd.o \
./src/middleware/bacnet/src/readrange.o \
./src/middleware/bacnet/src/reject.o \
./src/middleware/bacnet/src/ringbuf.o \
./src/middleware/bacnet/src/rp.o \
./src/middleware/bacnet/src/rpm.o \
./src/middleware/bacnet/src/sbuf.o \
./src/middleware/bacnet/src/timestamp.o \
./src/middleware/bacnet/src/timesync.o \
./src/middleware/bacnet/src/tsm.o \
./src/middleware/bacnet/src/ucix.o \
./src/middleware/bacnet/src/version.o \
./src/middleware/bacnet/src/vmac.o \
./src/middleware/bacnet/src/whohas.o \
./src/middleware/bacnet/src/whois.o \
./src/middleware/bacnet/src/wp.o \
./src/middleware/bacnet/src/wpm.o 

C_DEPS += \
./src/middleware/bacnet/src/abort.d \
./src/middleware/bacnet/src/access_rule.d \
./src/middleware/bacnet/src/address.d \
./src/middleware/bacnet/src/alarm_ack.d \
./src/middleware/bacnet/src/apdu.d \
./src/middleware/bacnet/src/arf.d \
./src/middleware/bacnet/src/assigned_access_rights.d \
./src/middleware/bacnet/src/authentication_factor.d \
./src/middleware/bacnet/src/authentication_factor_format.d \
./src/middleware/bacnet/src/awf.d \
./src/middleware/bacnet/src/bacaddr.d \
./src/middleware/bacnet/src/bacapp.d \
./src/middleware/bacnet/src/bacdcode.d \
./src/middleware/bacnet/src/bacdevobjpropref.d \
./src/middleware/bacnet/src/bacerror.d \
./src/middleware/bacnet/src/bacint.d \
./src/middleware/bacnet/src/bacprop.d \
./src/middleware/bacnet/src/bacpropstates.d \
./src/middleware/bacnet/src/bacreal.d \
./src/middleware/bacnet/src/bacsec.d \
./src/middleware/bacnet/src/bacstr.d \
./src/middleware/bacnet/src/bactext.d \
./src/middleware/bacnet/src/bactimevalue.d \
./src/middleware/bacnet/src/bigend.d \
./src/middleware/bacnet/src/bip.d \
./src/middleware/bacnet/src/bvlc.d \
./src/middleware/bacnet/src/bvlc6.d \
./src/middleware/bacnet/src/cov.d \
./src/middleware/bacnet/src/crc.d \
./src/middleware/bacnet/src/credential_authentication_factor.d \
./src/middleware/bacnet/src/datalink.d \
./src/middleware/bacnet/src/datetime.d \
./src/middleware/bacnet/src/dcc.d \
./src/middleware/bacnet/src/debug.d \
./src/middleware/bacnet/src/event.d \
./src/middleware/bacnet/src/fifo.d \
./src/middleware/bacnet/src/filename.d \
./src/middleware/bacnet/src/get_alarm_sum.d \
./src/middleware/bacnet/src/getevent.d \
./src/middleware/bacnet/src/iam.d \
./src/middleware/bacnet/src/ihave.d \
./src/middleware/bacnet/src/indtext.d \
./src/middleware/bacnet/src/key.d \
./src/middleware/bacnet/src/keylist.d \
./src/middleware/bacnet/src/lighting.d \
./src/middleware/bacnet/src/lso.d \
./src/middleware/bacnet/src/memcopy.d \
./src/middleware/bacnet/src/mstp.d \
./src/middleware/bacnet/src/mstptext.d \
./src/middleware/bacnet/src/npdu.d \
./src/middleware/bacnet/src/proplist.d \
./src/middleware/bacnet/src/ptransfer.d \
./src/middleware/bacnet/src/rd.d \
./src/middleware/bacnet/src/readrange.d \
./src/middleware/bacnet/src/reject.d \
./src/middleware/bacnet/src/ringbuf.d \
./src/middleware/bacnet/src/rp.d \
./src/middleware/bacnet/src/rpm.d \
./src/middleware/bacnet/src/sbuf.d \
./src/middleware/bacnet/src/timestamp.d \
./src/middleware/bacnet/src/timesync.d \
./src/middleware/bacnet/src/tsm.d \
./src/middleware/bacnet/src/ucix.d \
./src/middleware/bacnet/src/version.d \
./src/middleware/bacnet/src/vmac.d \
./src/middleware/bacnet/src/whohas.d \
./src/middleware/bacnet/src/whois.d \
./src/middleware/bacnet/src/wp.d \
./src/middleware/bacnet/src/wpm.d 


# Each subdirectory must supply rules for building sources it contributes
src/middleware/bacnet/src/%.o: ../src/middleware/bacnet/src/%.c src/middleware/bacnet/src/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64imac -mabi=lp64 -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -pedantic -Wunused -Wuninitialized -Wall -Wextra -Wmissing-declarations -Wconversion -Wpointer-arith -Wpadded -Wshadow -Wlogical-op -Waggregate-return -Wfloat-equal  -g3 -DPSE=1 -DxMSS_MAC_MULTI_PHY -DG5_SOC_EMU_USE_GEM0 -DG5_SOC_EMU_USE_GEM1 -DxMSS_MAC_LWIP_USE_EMAC -DxMSS_MAC_USE_DDR=MSS_MAC_MEM_FIC0 -DxTI_PHY -DVTSS_CHIP_CU_PHY -DVTSS_FEATURE_SYNCE -DVTSS_FEATURE_PHY_TS_ONE_STEP_TXFIFO_OPTION -DVTSS_FEATURE_SERDES_MACRO_SETTINGS -DVTSS_OPT_PORT_COUNT=4 -DVTSS_OPT_VCORE_III=0 -DVTSS_PRODUCT_CHIP="PHY" -DVTSS_PHY_API_ONLY -DVTSS_OPT_TRACE=0 -DVTSS_OS_BARE_METAL_RV -DCMSIS_PROT -DxTARGET_ALOE -DTARGET_G5_SOC -DMSS_MAC_SIMPLE_TX_QUEUE -DCALCONFIGH=\"config_user.h\" -DxSIFIVE_HIFIVE_UNLEASHED -DTEST_H2F_CONTROLLER=0 -D_ZL303XX_MIV -DTARGET_DISCOVERY_KIT -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\demo\object" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\application" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\platform" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\phy_1g\common" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\mpfs-discovery-kit" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\mpfs-discovery-kit\platform_config\lim-debug" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


