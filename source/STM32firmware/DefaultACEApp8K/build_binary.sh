#!/bin/bash

/opt/Atollic_TrueSTUDIO_for_STM32_x86_64_9.3.0/ARMTools/bin/arm-atollic-eabi-objcopy -O binary Debug/DefaultACEApp8K.elf Debug/DefaultACEApp8K.bin 
cp Debug/DefaultACEApp8K.bin DAA8K.ACE
