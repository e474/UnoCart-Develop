
	*=$8000

	.BYTE 0							; required to get assembler to generate
									; 16K size file

;
; lower memory values as atari800 emulator won't write to cartridge area (!)
;

Z_SOURCE	= $80
Z_DEST 		= $82

VIDEO_MEMORY_BANK1		= $9000 - 4000		; 100 lines at 40 bytes for bank 1 memory

VIDEO_MEMORY_BANK2		= $9000				; bank 2 memory for remainder

TOP_LINE_TEXT   		= $3E00
BOTTOM_LINE_TEXT   		= $3F00				; don't use cartridge address space as
											; last line of display triggers ARM to
											; start work on next display frame
											; DLI sets $d5df = CART_CMD_DRAW_NEXT_FRAME

RAM_CODE_ADDRESS		= $2000

UNO_COMMAND_LOCATION = $D5DF


CART_CMD_DRAW_NEXT_FRAME			= $01
CART_DEFAULT_FILL_BACKGROUND 		= $02



	* = $A000	; CARTA



START_CARTRIDGE 
	JMP  START_CODE

	
DISPLAY_LIST						; this will be moved down in memory to $???? RAM

	.BYTE $70,$70,$70				; 3 blank lines
									; not counted in total number of scan lines

;
; total number of scan lines is 192 - De Re Atari, page 2-6
;

	.BYTE $42									; graphics zero first line for scores
												; 8 scan lines, 40 bytes

	.WORD TOP_LINE_TEXT							; graphics data served from start of cartridge space

	.BYTE $4E									; ANTIC mode E, 160 pixels wide, 4 colours
												; 1 scan line, 40 bytes
												; total scan lines so far: 
												; 		8 + 1 = 9
	
	.WORD VIDEO_MEMORY_BANK1
	.BYTE $0E									; 1 scan line, 40 bytes
												; total scan lines so far: 
												; 		9 + 1 = 10

	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		10 + 8 = 18

	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		18 + 8 = 26

	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		26 + 8 = 34
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		34 + 8 = 42

	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		42 + 8 = 50
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		50 + 8 = 58
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		58 + 8 = 66
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		66 + 8 = 74
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		74 + 8 = 82
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		82 + 8 = 90
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		90 + 8 = 98
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		98 + 8 =  106

	.BYTE $0E,$0E								; 2 scan lines, 80 bytes
												; total scan lines so far: 
												; 		106 + 2 =  108

												; but first 8 lines are from
												; 1 graphics 0 line, so now on
												; 100 lines of ANTIC mode $0E, so
												; 100 * 40 bytes = 4000 bytes 
												; need to use another LMS byte to 
												; load video memory from next block
												; of 4K	

	.BYTE $4E									; 1 scan line, 40 bytes
	.WORD VIDEO_MEMORY_BANK2
												; total scan lines so far: 
												; 		108 + 1 =  109
	.BYTE $0E									; 1 scan line, 40 bytes
												; total scan lines so far: 
												; 		109 + 1 =  110
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		110 + 8 =  118
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		118 + 8 =  126
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		126 + 8 =  134
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		134 + 8 =  142
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		142 + 8 =  150
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		150 + 8 =  158
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		158 + 8 =  166
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		166 + 8 =  174
	.BYTE $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E		; 8 scan lines, 320 bytes
												; total scan lines so far: 
												; 		174 + 8 =  182
	.BYTE $0E,$0E 								; 2 scan lines, 80 bytes
												; total scan lines so far: 
												; 		182 + 2 =  184
	.BYTE $C2									; graphics zero last line for progess
												; 8 scan lines, 40 bytes
	.WORD BOTTOM_LINE_TEXT						; total scan lines so far: 
												; 		184 + 8 =  192
	
												
	.BYTE $41									; ANTIC jump to start of display list
	.WORD DISPLAY_LIST

DISPLAY_LIST_LOWER_MEMORY = DISPLAY_LIST - $8000
;	.WORD DISPLAY_LIST_LOWER_MEMORY


	.INCLUDE "OS.asm"
	.INCLUDE "ANTIC.asm"
	.INCLUDE "CHIPS.asm"

	
EOL = $9B

CLEAR_SCREEN_CHARS
	.BYTE 125, EOL
CLEAR_SCREEN_CHARS_LENGTH = * - CLEAR_SCREEN_CHARS
 
SCREEN_EDITOR_DEVICE_STRING
 .BYTE "S:",0
SCREEN_EDITOR_DEVICE_STRING_LENGTH = * - SCREEN_EDITOR_DEVICE_STRING


HELLO_TEXT
	.BYTE "ROM file load from SD card served by",EOL
	.BYTE "loaded ARM executable.",EOL
HELLO_TEXT_LENGTH = * - HELLO_TEXT

 

START_CODE
	JSR COPY_CART_CODE_TO_RAM
	
	JMP RAM_CODE_START

RAM_CODE_START = * - START_CARTRIDGE + RAM_CODE_ADDRESS

	JSR LOWER_WAIT_ON_UNO_CART

	LDA #CART_DEFAULT_FILL_BACKGROUND
	STA UNO_COMMAND_LOCATION

	JSR LOWER_WAIT_ON_UNO_CART


	LDA #0
	STA SDMCTL
	
	LDA #<DISPLAY_LIST
	STA $230
	
	LDA #>DISPLAY_LIST
	STA $231

	LDA #<DLI_HANDER
	STA VDSLST
	LDA #>[DLI_HANDER - CARTA + RAM_CODE_ADDRESS]	; address in lower memory where
													; code is relocated to
	STA VDSLST+1

	LDA #$C0
	STA NMIEN				; https://playermissile.com/dli_tutorial/
	 
	
	LDA #$22
	STA SDMCTL
	
	LDA #0
	LDY #0
	
LOOPG
	STA TOP_LINE_TEXT,Y
;	STA VIDEO_MEMORY_BANK1,Y
;	STA VIDEO_MEMORY_BANK2,Y
	STA BOTTOM_LINE_TEXT+1,Y
	INY
	TYA
	BNE LOOPG	
	
	
	
; WAIT LOOP
LOOPT
	LDA #1
	BNE LOOPT

;	JMP (LOOPT - CARTA) + RAM_CODE_ADDRESS




COPY_CART_CODE_TO_RAM

	LDA #<START_CARTRIDGE
	STA Z_SOURCE
	LDA #>START_CARTRIDGE
	STA Z_SOURCE+1
	
	LDA #<RAM_CODE_ADDRESS
	STA Z_DEST
	LDA #>RAM_CODE_ADDRESS
	STA Z_DEST+1
	
	LDY #0
	LDX #4
	
COPY_LOOP
	LDA (Z_SOURCE),Y
	STA (Z_DEST),Y
	INY
	BNE COPY_LOOP
	INC Z_SOURCE+1
	INC Z_DEST+1
	DEX
	BNE COPY_LOOP
	RTS
		

DLI_HANDER
	PHA
	LDA #CART_CMD_DRAW_NEXT_FRAME
	STA UNO_COMMAND_LOCATION
	PLA
	RTI

 
 WAIT_ON_UNO_CART
 LOWER_WAIT_ON_UNO_CART = (* - CARTA) + RAM_CODE_ADDRESS
 	LDA $D500
 	CMP #$11
 	BNE WAIT_ON_UNO_CART
 	RTS
 

; old code, used to test if CIO screen text output works
 
               LDX #1*16
               LDA #CIO_CLOSE
            STA ICCMD,X
            JSR CIOV
              LDX #1*16
               LDA #CIO_OPEN
           STA ICCMD,X ; COMMAND
               LDA #8
              STA ICAX1,X
               LDA #0
              STA ICAX2,X
            JMP *+2+4
@F    .BYTE "E:",0
              LDA # <@F
            STA ICBAL,X
               LDA # >@F
            STA ICBAH,X
            JSR CIOV
              LDX #1*16
             LDA #CIO_PUT_BYTES
          STA ICCMD,X
             LDA # <CLEAR_SCREEN_CHARS
          STA ICBAL,X
             LDA # >CLEAR_SCREEN_CHARS
          STA ICBAH,X
            LDA # <CLEAR_SCREEN_CHARS_LENGTH
          STA ICBLL,X
             LDA # >CLEAR_SCREEN_CHARS_LENGTH
          STA ICBLH,X
          JSR CIOV
               LDX #1*16
             LDA #CIO_PUT_BYTES
          STA ICCMD,X
             LDA # <HELLO_TEXT
          STA ICBAL,X
             LDA # >HELLO_TEXT
          STA ICBAH,X
             LDA # <HELLO_TEXT_LENGTH
          STA ICBLL,X
             LDA # >HELLO_TEXT_LENGTH
          STA ICBLH,X
          JSR CIOV
PRINT_LOOP
	JMP PRINT_LOOP
INIT_CARTRIDGE
       	RTS

;
; https://atariage.com/forums/topic/256593-booting-from-cartridge/
;


	*=$BFFA
	.WORD START_CARTRIDGE
	.BYTE 0,$04
	.WORD INIT_CARTRIDGE


