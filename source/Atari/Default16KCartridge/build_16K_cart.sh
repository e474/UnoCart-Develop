#!/bin/bash

~/bin/ASM/ATASM/atasm.linux-x86-64 -r -ocart16K.rom -f0 cart16K.asm
~/bin/ASM/ATASM/atasm.linux-x86-64  -ocart16K.xex -f0 cart16K.asm

xxd -i cart16K.rom > cart16K.h


