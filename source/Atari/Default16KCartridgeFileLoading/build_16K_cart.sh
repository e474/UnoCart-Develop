#!/bin/bash

~/bin/ASM/ATASM/atasm.linux-x86-64 -r -ocart16KFL.rom -f0 cart16KFL.asm
~/bin/ASM/ATASM/atasm.linux-x86-64  -ocart16KFL.xex -f0 cart16KFL.asm

xxd -i cart16KFL.rom > cart16KFL.h


