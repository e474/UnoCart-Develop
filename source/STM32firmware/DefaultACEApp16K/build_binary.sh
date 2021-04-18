#!/bin/bash

/opt/Atollic_TrueSTUDIO_for_STM32_x86_64_9.3.0/ARMTools/bin/arm-atollic-eabi-objcopy -O binary Debug/DefaultACEApp16K.elf Debug/DefaultACEApp16K.bin 
cp Debug/DefaultACEApp16K.bin DAA16K.ACE

