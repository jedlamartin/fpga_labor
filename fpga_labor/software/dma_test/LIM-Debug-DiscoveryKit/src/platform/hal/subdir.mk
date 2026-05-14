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
	riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -DMPFS_DISCOVERY_KIT -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\application" -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\platform" -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\boards\mpfs-discovery-kit" -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\boards\mpfs-discovery-kit\platform_config\lim-debug" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/platform/hal/%.o: ../src/platform/hal/%.S src/platform/hal/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross Assembler'
	riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -x assembler-with-cpp -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\application" -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\platform" -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\boards\mpfs-discovery-kit" -I"C:\Users\Martin\Libero\fpga_labor\fpga_labor\software\dma_test\src\boards\mpfs-discovery-kit\platform_config\lim-debug" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


