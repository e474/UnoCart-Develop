#!/bin/bash

~/bin/ASM/MADS/mads.linux-i386 UnoCart.asm -o:UnoCart.rom
xxd -i UnoCart.rom > rom.h
