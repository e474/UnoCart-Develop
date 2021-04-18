
	*=$8000


START_CARTRIDGE
	JMP  START_CODE

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
	.BYTE "16K test cartridge image served by",EOL
	.BYTE "loaded ARM executable.",EOL
HELLO_TEXT_LENGTH = * - HELLO_TEXT

 

START_CODE








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


