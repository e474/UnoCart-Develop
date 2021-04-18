################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm

# All of the sources participating in the build are defined here
-include sources.mk
-include src/subdir.mk
-include Libraries/STM32F4xx_StdPeriph_Driver/src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(CC_DEPS)),)
-include $(CC_DEPS)
endif
ifneq ($(strip $(C++_DEPS)),)
-include $(C++_DEPS)
endif
ifneq ($(strip $(C_UPPER_DEPS)),)
-include $(C_UPPER_DEPS)
endif
ifneq ($(strip $(CXX_DEPS)),)
-include $(CXX_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
EXECUTABLES += \
USER_OBJS.elf \

SECOUTPUTBUILDVAR += \
EXECUTABLES \


# All Target
all: FirmwareUpdater\ 8bit secondary-outputs

# Tool invocations
	@echo 'No tool found that can build the extension specified with the build artifact name $@'
USER_OBJS.elf: $(OBJS) $(USER_OBJS)
	arm-atollic-eabi-g++ -o "USER_OBJS.elf" $(OBJS) $(USER_OBJS) $(LIBS) -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -T"../stm32f4_flash.ld" -specs=nosys.specs -static -Wl,-cref,-u,Reset_Handler "-Wl,-Map=FirmwareUpdater 8bit.map" -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x1000 -Wl,--start-group -lc -lm -lstdc++ -lsupc++ -Wl,--end-group -specs=nano.specs

EXECUTABLES: FirmwareUpdater\ 8bit $(EXECUTABLES)
	"/opt/Atollic_TrueSTUDIO_for_STM32_x86_64_9.3.0/ide/jre/bin/java" -jar "/opt/Atollic_TrueSTUDIO_for_STM32_x86_64_9.3.0/Tools/arm-atollic-reports.jar" sizeinfo list "FirmwareUpdater 8bit"

# Other Targets
clean:
	-$(RM) $(CC_DEPS)$(C++_DEPS)$(EXECUTABLES)$(SECOUTPUTBUILDVAR)$(OBJS)$(C_UPPER_DEPS)$(CXX_DEPS)$(C_DEPS)$(CPP_DEPS) "FirmwareUpdater 8bit"
	-@echo ' '

secondary-outputs: $(SECOUTPUTBUILDVAR)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
