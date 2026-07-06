################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/platform/hal/hal_irq.c 

S_UPPER_SRCS += \
../src/platform/hal/hw_reg_access.S 

OBJS += \
./src/platform/hal/hal_irq.o \
./src/platform/hal/hw_reg_access.o 

S_UPPER_DEPS += \
./src/platform/hal/hw_reg_access.d 

C_DEPS += \
./src/platform/hal/hal_irq.d 


# Each subdirectory must supply rules for building sources it contributes
src/platform/hal/%.o: ../src/platform/hal/%.c src/platform/hal/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64imac -mabi=lp64 -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -pedantic -Wunused -Wuninitialized -Wall -Wextra -Wmissing-declarations -Wconversion -Wpointer-arith -Wpadded -Wshadow -Wlogical-op -Waggregate-return -Wfloat-equal  -g3 -DPSE=1 -DxMSS_MAC_MULTI_PHY -DG5_SOC_EMU_USE_GEM0 -DG5_SOC_EMU_USE_GEM1 -DxMSS_MAC_LWIP_USE_EMAC -DxMSS_MAC_USE_DDR=MSS_MAC_MEM_FIC0 -DxTI_PHY -DVTSS_CHIP_CU_PHY -DVTSS_FEATURE_SYNCE -DVTSS_FEATURE_PHY_TS_ONE_STEP_TXFIFO_OPTION -DVTSS_FEATURE_SERDES_MACRO_SETTINGS -DVTSS_OPT_PORT_COUNT=4 -DVTSS_OPT_VCORE_III=0 -DVTSS_PRODUCT_CHIP="PHY" -DVTSS_PHY_API_ONLY -DVTSS_OPT_TRACE=0 -DVTSS_OS_BARE_METAL_RV -DCMSIS_PROT -DxTARGET_ALOE -DTARGET_G5_SOC -DMSS_MAC_SIMPLE_TX_QUEUE -DCALCONFIGH=\"config_user.h\" -DxSIFIVE_HIFIVE_UNLEASHED -DTEST_H2F_CONTROLLER=0 -D_ZL303XX_MIV -DTARGET_DISCOVERY_KIT -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\demo\object" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\application" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\platform" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\phy_1g\common" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\mpfs-discovery-kit" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\mpfs-discovery-kit\platform_config\lim-debug" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/platform/hal/%.o: ../src/platform/hal/%.S src/platform/hal/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross Assembler'
	riscv64-unknown-elf-gcc -march=rv64imac -mabi=lp64 -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -pedantic -Wunused -Wuninitialized -Wall -Wextra -Wmissing-declarations -Wconversion -Wpointer-arith -Wpadded -Wshadow -Wlogical-op -Waggregate-return -Wfloat-equal  -g3 -x assembler-with-cpp -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\application" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\platform" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\mpfs-discovery-kit\platform_config\lim-debug" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


