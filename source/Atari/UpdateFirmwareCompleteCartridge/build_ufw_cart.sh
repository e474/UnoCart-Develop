#!/bin/bash

~/bin/ASM/ATASM/atasm.linux-x86-64 -r -ocartufw.rom -f0 cartufw.asm
~/bin/ASM/ATASM/atasm.linux-x86-64  -ocartufw.xex -f0 cartufw.asm
xxd -i cartufw.rom > cartufw.h


