################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/platform/mpfs_hal/common/nwc/mss_cfm.c \
../src/platform/mpfs_hal/common/nwc/mss_ddr.c \
../src/platform/mpfs_hal/common/nwc/mss_ddr_debug.c \
../src/platform/mpfs_hal/common/nwc/mss_ddr_test_pattern.c \
../src/platform/mpfs_hal/common/nwc/mss_io.c \
../src/platform/mpfs_hal/common/nwc/mss_nwc_init.c \
../src/platform/mpfs_hal/common/nwc/mss_pll.c \
../src/platform/mpfs_hal/common/nwc/mss_sgmii.c 

OBJS += \
./src/platform/mpfs_hal/common/nwc/mss_cfm.o \
./src/platform/mpfs_hal/common/nwc/mss_ddr.o \
./src/platform/mpfs_hal/common/nwc/mss_ddr_debug.o \
./src/platform/mpfs_hal/common/nwc/mss_ddr_test_pattern.o \
./src/platform/mpfs_hal/common/nwc/mss_io.o \
./src/platform/mpfs_hal/common/nwc/mss_nwc_init.o \
./src/platform/mpfs_hal/common/nwc/mss_pll.o \
./src/platform/mpfs_hal/common/nwc/mss_sgmii.o 

C_DEPS += \
./src/platform/mpfs_hal/common/nwc/mss_cfm.d \
./src/platform/mpfs_hal/common/nwc/mss_ddr.d \
./src/platform/mpfs_hal/common/nwc/mss_ddr_debug.d \
./src/platform/mpfs_hal/common/nwc/mss_ddr_test_pattern.d \
./src/platform/mpfs_hal/common/nwc/mss_io.d \
./src/platform/mpfs_hal/common/nwc/mss_nwc_init.d \
./src/platform/mpfs_hal/common/nwc/mss_pll.d \
./src/platform/mpfs_hal/common/nwc/mss_sgmii.d 


# Each subdirectory must supply rules for building sources it contributes
src/platform/mpfs_hal/common/nwc/%.o: ../src/platform/mpfs_hal/common/nwc/%.c src/platform/mpfs_hal/common/nwc/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -DMPFS_DISCOVERY_KIT -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\application" -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\platform" -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\boards\mpfs-discovery-kit" -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\boards\mpfs-discovery-kit\platform_config\lim-debug" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


