################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/platform/mpfs_hal/startup_gcc/subdir.mk
-include src/platform/mpfs_hal/common/nwc/subdir.mk
-include src/platform/mpfs_hal/common/subdir.mk
-include src/platform/hal/subdir.mk
-include src/platform/drivers/mss/mss_mmuart/subdir.mk
-include src/platform/drivers/mss/mss_gpio/subdir.mk
-include src/platform/drivers/mss/mss_ethernet_mac/subdir.mk
-include src/platform/drivers/mss/FU540_uart/subdir.mk
-include src/middleware/vtss_api_lite_v1_02/phy_1g/viper/subdir.mk
-include src/middleware/vtss_api_lite_v1_02/phy_1g/common/subdir.mk
-include src/middleware/mcc_tcpip_lite/subdir.mk
-include src/middleware/ftp-client/subdir.mk
-include src/middleware/bacnet/src/subdir.mk
-include src/middleware/bacnet/demo/object/subdir.mk
-include src/middleware/bacnet/demo/handler/subdir.mk
-include src/application/inc/subdir.mk
-include src/application/hart4/subdir.mk
-include src/application/hart3/subdir.mk
-include src/application/hart2/subdir.mk
-include src/application/hart1/subdir.mk
-include src/application/hart0/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

OPTIONAL_TOOL_DEPS := \
$(wildcard ../makefile.defs) \
$(wildcard ../makefile.init) \
$(wildcard ../makefile.targets) \


BUILD_ARTIFACT_NAME := mpfs-mac-mcc-stack
BUILD_ARTIFACT_EXTENSION := elf
BUILD_ARTIFACT_PREFIX :=
BUILD_ARTIFACT := $(BUILD_ARTIFACT_PREFIX)$(BUILD_ARTIFACT_NAME)$(if $(BUILD_ARTIFACT_EXTENSION),.$(BUILD_ARTIFACT_EXTENSION),)

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_FLASH += \
mpfs-mac-mcc-stack.hex \

SECONDARY_LIST += \
mpfs-mac-mcc-stack.lst \

SECONDARY_SIZE += \
mpfs-mac-mcc-stack.siz \


# All Target
all:
	+@$(MAKE) --no-print-directory pre-build && $(MAKE) --no-print-directory main-build

# Main-build Target
main-build: mpfs-mac-mcc-stack.elf secondary-outputs

# Tool invocations
mpfs-mac-mcc-stack.elf: $(OBJS) $(USER_OBJS) makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Building target: $@'
	@echo 'Invoking: GNU RISC-V Cross C Linker'
	riscv64-unknown-elf-gcc -march=rv64imac -mabi=lp64 -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -pedantic -Wunused -Wuninitialized -Wall -Wextra -Wmissing-declarations -Wconversion -Wpointer-arith -Wpadded -Wshadow -Wlogical-op -Waggregate-return -Wfloat-equal  -g3 -T "C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\custom_board\platform_config\lim-debug\linker\mpfs-lim.ld" -nostartfiles -Xlinker --gc-sections -Wl,-Map,"mpfs-mac-mcc-stack.map" --specs=nano.specs --specs=nosys.specs -o "mpfs-mac-mcc-stack.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

mpfs-mac-mcc-stack.hex: mpfs-mac-mcc-stack.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: GNU RISC-V Cross Create Flash Image'
	riscv64-unknown-elf-objcopy -O ihex "mpfs-mac-mcc-stack.elf"  "mpfs-mac-mcc-stack.hex"
	@echo 'Finished building: $@'
	@echo ' '

mpfs-mac-mcc-stack.lst: mpfs-mac-mcc-stack.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: GNU RISC-V Cross Create Listing'
	riscv64-unknown-elf-objdump --source --all-headers --demangle --line-numbers --wide "mpfs-mac-mcc-stack.elf" > "mpfs-mac-mcc-stack.lst"
	@echo 'Finished building: $@'
	@echo ' '

mpfs-mac-mcc-stack.siz: mpfs-mac-mcc-stack.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: GNU RISC-V Cross Print Size'
	riscv64-unknown-elf-size --format=sysv --radix=16 "mpfs-mac-mcc-stack.elf"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(SECONDARY_FLASH)$(SECONDARY_LIST)$(SECONDARY_SIZE)$(ASM_DEPS)$(S_UPPER_DEPS)$(C_DEPS) mpfs-mac-mcc-stack.elf
	-@echo ' '

pre-build:
	-@echo 'TODO: Generate target specific header files'
	-C:\Microchip\SoftConsole-v2022.2-RISC-V-747\/python3/python.exe ../src/platform/soc_config_generator/mpfs_configuration_generator.py ../src/boards/custom_board/fpga_design/design_description/ ../src/boards/custom_board
	-@echo ' '

secondary-outputs: $(SECONDARY_FLASH) $(SECONDARY_LIST) $(SECONDARY_SIZE)

.PHONY: all clean dependents main-build pre-build

-include ../makefile.targets
