################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/middleware/mcc_tcpip_lite/ENC28J60.c \
../src/middleware/mcc_tcpip_lite/arpv4.c \
../src/middleware/mcc_tcpip_lite/dhcp_client.c \
../src/middleware/mcc_tcpip_lite/dns_client.c \
../src/middleware/mcc_tcpip_lite/icmp.c \
../src/middleware/mcc_tcpip_lite/ip_database.c \
../src/middleware/mcc_tcpip_lite/ipv4.c \
../src/middleware/mcc_tcpip_lite/lfsr.c \
../src/middleware/mcc_tcpip_lite/lldp.c \
../src/middleware/mcc_tcpip_lite/lldp_tlv_handler_table.c \
../src/middleware/mcc_tcpip_lite/log.c \
../src/middleware/mcc_tcpip_lite/log_console.c \
../src/middleware/mcc_tcpip_lite/log_syslog.c \
../src/middleware/mcc_tcpip_lite/mac_address.c \
../src/middleware/mcc_tcpip_lite/network.c \
../src/middleware/mcc_tcpip_lite/ntp.c \
../src/middleware/mcc_tcpip_lite/rtcc.c \
../src/middleware/mcc_tcpip_lite/tcpv4.c \
../src/middleware/mcc_tcpip_lite/tftp.c \
../src/middleware/mcc_tcpip_lite/udpv4.c \
../src/middleware/mcc_tcpip_lite/udpv4_port_handler_table.c 

OBJS += \
./src/middleware/mcc_tcpip_lite/ENC28J60.o \
./src/middleware/mcc_tcpip_lite/arpv4.o \
./src/middleware/mcc_tcpip_lite/dhcp_client.o \
./src/middleware/mcc_tcpip_lite/dns_client.o \
./src/middleware/mcc_tcpip_lite/icmp.o \
./src/middleware/mcc_tcpip_lite/ip_database.o \
./src/middleware/mcc_tcpip_lite/ipv4.o \
./src/middleware/mcc_tcpip_lite/lfsr.o \
./src/middleware/mcc_tcpip_lite/lldp.o \
./src/middleware/mcc_tcpip_lite/lldp_tlv_handler_table.o \
./src/middleware/mcc_tcpip_lite/log.o \
./src/middleware/mcc_tcpip_lite/log_console.o \
./src/middleware/mcc_tcpip_lite/log_syslog.o \
./src/middleware/mcc_tcpip_lite/mac_address.o \
./src/middleware/mcc_tcpip_lite/network.o \
./src/middleware/mcc_tcpip_lite/ntp.o \
./src/middleware/mcc_tcpip_lite/rtcc.o \
./src/middleware/mcc_tcpip_lite/tcpv4.o \
./src/middleware/mcc_tcpip_lite/tftp.o \
./src/middleware/mcc_tcpip_lite/udpv4.o \
./src/middleware/mcc_tcpip_lite/udpv4_port_handler_table.o 

C_DEPS += \
./src/middleware/mcc_tcpip_lite/ENC28J60.d \
./src/middleware/mcc_tcpip_lite/arpv4.d \
./src/middleware/mcc_tcpip_lite/dhcp_client.d \
./src/middleware/mcc_tcpip_lite/dns_client.d \
./src/middleware/mcc_tcpip_lite/icmp.d \
./src/middleware/mcc_tcpip_lite/ip_database.d \
./src/middleware/mcc_tcpip_lite/ipv4.d \
./src/middleware/mcc_tcpip_lite/lfsr.d \
./src/middleware/mcc_tcpip_lite/lldp.d \
./src/middleware/mcc_tcpip_lite/lldp_tlv_handler_table.d \
./src/middleware/mcc_tcpip_lite/log.d \
./src/middleware/mcc_tcpip_lite/log_console.d \
./src/middleware/mcc_tcpip_lite/log_syslog.d \
./src/middleware/mcc_tcpip_lite/mac_address.d \
./src/middleware/mcc_tcpip_lite/network.d \
./src/middleware/mcc_tcpip_lite/ntp.d \
./src/middleware/mcc_tcpip_lite/rtcc.d \
./src/middleware/mcc_tcpip_lite/tcpv4.d \
./src/middleware/mcc_tcpip_lite/tftp.d \
./src/middleware/mcc_tcpip_lite/udpv4.d \
./src/middleware/mcc_tcpip_lite/udpv4_port_handler_table.d 


# Each subdirectory must supply rules for building sources it contributes
src/middleware/mcc_tcpip_lite/%.o: ../src/middleware/mcc_tcpip_lite/%.c src/middleware/mcc_tcpip_lite/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64imac -mabi=lp64 -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -pedantic -Wunused -Wuninitialized -Wall -Wextra -Wmissing-declarations -Wconversion -Wpointer-arith -Wpadded -Wshadow -Wlogical-op -Waggregate-return -Wfloat-equal  -g3 -DPSE=1 -DxMSS_MAC_MULTI_PHY -DG5_SOC_EMU_USE_GEM0 -DG5_SOC_EMU_USE_GEM1 -DxMSS_MAC_LWIP_USE_EMAC -DxMSS_MAC_USE_DDR=MSS_MAC_MEM_FIC0 -DxTI_PHY -DVTSS_CHIP_CU_PHY -DVTSS_FEATURE_SYNCE -DVTSS_FEATURE_PHY_TS_ONE_STEP_TXFIFO_OPTION -DVTSS_FEATURE_SERDES_MACRO_SETTINGS -DVTSS_OPT_PORT_COUNT=4 -DVTSS_OPT_VCORE_III=0 -DVTSS_PRODUCT_CHIP="PHY" -DVTSS_PHY_API_ONLY -DVTSS_OPT_TRACE=0 -DVTSS_OS_BARE_METAL_RV -DCMSIS_PROT -DxTARGET_ALOE -DTARGET_G5_SOC -DMSS_MAC_SIMPLE_TX_QUEUE -DCALCONFIGH=\"config_user.h\" -DxSIFIVE_HIFIVE_UNLEASHED -DTEST_H2F_CONTROLLER=0 -D_ZL303XX_MIV -DTARGET_DISCOVERY_KIT -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\bacnet\demo\object" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\include" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\application" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\platform" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\middleware\vtss_api_lite_v1_02\phy_1g\common" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\custom_board" -I"C:\Users\zero6575\Libero\fpga_labor\fpga_labor\software\mpfs-mac-mcc-stack\src\boards\custom_board\platform_config\lim-debug" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


