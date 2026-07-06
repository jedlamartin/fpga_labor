################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/platform/mpfs_hal/common/mss_axiswitch.c \
../src/platform/mpfs_hal/common/mss_beu.c \
../src/platform/mpfs_hal/common/mss_clint.c \
../src/platform/mpfs_hal/common/mss_h2f.c \
../src/platform/mpfs_hal/common/mss_irq_handler_stubs.c \
../src/platform/mpfs_hal/common/mss_l2_cache.c \
../src/platform/mpfs_hal/common/mss_mpu.c \
../src/platform/mpfs_hal/common/mss_mtrap.c \
../src/platform/mpfs_hal/common/mss_peripherals.c \
../src/platform/mpfs_hal/common/mss_plic.c \
../src/platform/mpfs_hal/common/mss_pmp.c \
../src/platform/mpfs_hal/common/mss_util.c 

OBJS += \
./src/platform/mpfs_hal/common/mss_axiswitch.o \
./src/platform/mpfs_hal/common/mss_beu.o \
./src/platform/mpfs_hal/common/mss_clint.o \
./src/platform/mpfs_hal/common/mss_h2f.o \
./src/platform/mpfs_hal/common/mss_irq_handler_stubs.o \
./src/platform/mpfs_hal/common/mss_l2_cache.o \
./src/platform/mpfs_hal/common/mss_mpu.o \
./src/platform/mpfs_hal/common/mss_mtrap.o \
./src/platform/mpfs_hal/common/mss_peripherals.o \
./src/platform/mpfs_hal/common/mss_plic.o \
./src/platform/mpfs_hal/common/mss_pmp.o \
./src/platform/mpfs_hal/common/mss_util.o 

C_DEPS += \
./src/platform/mpfs_hal/common/mss_axiswitch.d \
./src/platform/mpfs_hal/common/mss_beu.d \
./src/platform/mpfs_hal/common/mss_clint.d \
./src/platform/mpfs_hal/common/mss_h2f.d \
./src/platform/mpfs_hal/common/mss_irq_handler_stubs.d \
./src/platform/mpfs_hal/common/mss_l2_cache.d \
./src/platform/mpfs_hal/common/mss_mpu.d \
./src/platform/mpfs_hal/common/mss_mtrap.d \
./src/platform/mpfs_hal/common/mss_peripherals.d \
./src/platform/mpfs_hal/common/mss_plic.d \
./src/platform/mpfs_hal/common/mss_pmp.d \
./src/platform/mpfs_hal/common/mss_util.d 


# Each subdirectory must supply rules for building sources it contributes
src/platform/mpfs_hal/common/%.o: ../src/platform/mpfs_hal/common/%.c src/platform/mpfs_hal/common/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64imac -mabi=lp64 -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -pedantic -Wunused -Wuninitialized -Wall -Wextra -Wmissing-declarations -Wconversion -Wpointer-arith -Wpadded -Wshadow -Wlogical-op -Waggregate-return -Wfloat-equal  -g3 -DPSE=1 -DxMSS_MAC_MULTI_PHY -DG5_SOC_EMU_USE_GEM0 -DG5_SOC_EMU_USE_GEM1 -DxMSS_MAC_LWIP_USE_EMAC -DxMSS_MAC_USE_DDR=MSS_MAC_MEM_FIC0 -DxTI_PHY -DVTSS_CHIP_CU_PHY -DVTSS_FEATURE_SYNCE -DVTSS_FEATURE_PHY_TS_ONE_STEP_TXFIFO_OPTION -DVTSS_FEATURE_SERDES_MACRO_SETTINGS -DVTSS_OPT_PORT_COUNT=4 -DVTSS_OPT_VCORE_III=0 -DVTSS_PRODUCT_CHIP="PHY" -DVTSS_PHY_API_ONLY -DVTSS_OPT_TRACE=0 -DVTSS_OS_BARE_METAL_RV -DCMSIS_PROT -DxTARGET_ALOE -DTARGET_G5_SOC -DMSS_MAC_SIMPLE_TX_QUEUE -DCALCONFIGH=\"config_user.h\" -DxSIFIVE_HIFIVE_UNLEASHED -DTEST_H2F_CONTROLLER=0 -D_ZL303XX_MIV -DTARGET_DISCOVERY_KIT -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\demo\object" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\application" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\platform" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\phy_1g\common" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\mpfs-discovery-kit" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\mpfs-discovery-kit\platform_config\lim-debug" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


