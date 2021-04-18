#!/bin/bash

~/bin/ASM/ATASM/atasm.linux-x86-64 -r -ocart8K.rom -f0 cart8K.asm
~/bin/ASM/ATASM/atasm.linux-x86-64  -ocart8K.xex -f0 cart8K.asm
xxd -i cart8K.rom > cart8K.h


