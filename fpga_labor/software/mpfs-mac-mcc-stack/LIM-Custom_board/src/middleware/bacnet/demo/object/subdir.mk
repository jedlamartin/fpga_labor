################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/middleware/bacnet/demo/object/ai.c \
../src/middleware/bacnet/demo/object/ao.c \
../src/middleware/bacnet/demo/object/av.c \
../src/middleware/bacnet/demo/object/bi.c \
../src/middleware/bacnet/demo/object/bo.c \
../src/middleware/bacnet/demo/object/bv.c \
../src/middleware/bacnet/demo/object/device-client.c \
../src/middleware/bacnet/demo/object/iv.c \
../src/middleware/bacnet/demo/object/netport.c \
../src/middleware/bacnet/demo/object/piv.c \
../src/middleware/bacnet/demo/object/trendlog.c 

OBJS += \
./src/middleware/bacnet/demo/object/ai.o \
./src/middleware/bacnet/demo/object/ao.o \
./src/middleware/bacnet/demo/object/av.o \
./src/middleware/bacnet/demo/object/bi.o \
./src/middleware/bacnet/demo/object/bo.o \
./src/middleware/bacnet/demo/object/bv.o \
./src/middleware/bacnet/demo/object/device-client.o \
./src/middleware/bacnet/demo/object/iv.o \
./src/middleware/bacnet/demo/object/netport.o \
./src/middleware/bacnet/demo/object/piv.o \
./src/middleware/bacnet/demo/object/trendlog.o 

C_DEPS += \
./src/middleware/bacnet/demo/object/ai.d \
./src/middleware/bacnet/demo/object/ao.d \
./src/middleware/bacnet/demo/object/av.d \
./src/middleware/bacnet/demo/object/bi.d \
./src/middleware/bacnet/demo/object/bo.d \
./src/middleware/bacnet/demo/object/bv.d \
./src/middleware/bacnet/demo/object/device-client.d \
./src/middleware/bacnet/demo/object/iv.d \
./src/middleware/bacnet/demo/object/netport.d \
./src/middleware/bacnet/demo/object/piv.d \
./src/middleware/bacnet/demo/object/trendlog.d 


# Each subdirectory must supply rules for building sources it contributes
src/middleware/bacnet/demo/object/%.o: ../src/middleware/bacnet/demo/object/%.c src/middleware/bacnet/demo/object/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64imac -mabi=lp64 -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -pedantic -Wunused -Wuninitialized -Wall -Wextra -Wmissing-declarations -Wconversion -Wpointer-arith -Wpadded -Wshadow -Wlogical-op -Waggregate-return -Wfloat-equal  -g3 -DPSE=1 -DxMSS_MAC_MULTI_PHY -DG5_SOC_EMU_USE_GEM0 -DG5_SOC_EMU_USE_GEM1 -DxMSS_MAC_LWIP_USE_EMAC -DxMSS_MAC_USE_DDR=MSS_MAC_MEM_FIC0 -DxTI_PHY -DVTSS_CHIP_CU_PHY -DVTSS_FEATURE_SYNCE -DVTSS_FEATURE_PHY_TS_ONE_STEP_TXFIFO_OPTION -DVTSS_FEATURE_SERDES_MACRO_SETTINGS -DVTSS_OPT_PORT_COUNT=4 -DVTSS_OPT_VCORE_III=0 -DVTSS_PRODUCT_CHIP="PHY" -DVTSS_PHY_API_ONLY -DVTSS_OPT_TRACE=0 -DVTSS_OS_BARE_METAL_RV -DCMSIS_PROT -DxTARGET_ALOE -DTARGET_G5_SOC -DMSS_MAC_SIMPLE_TX_QUEUE -DCALCONFIGH=\"config_user.h\" -DxSIFIVE_HIFIVE_UNLEASHED -DTEST_H2F_CONTROLLER=0 -D_ZL303XX_MIV -DTARGET_DISCOVERY_KIT -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\demo\object" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\application" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\platform" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\phy_1g\common" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\custom_board" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\custom_board\platform_config\lim-debug" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


