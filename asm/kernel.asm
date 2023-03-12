org 0x2345

start:

call CLS
call PRINT_CENTER_BLOB
call PRINT_SPLASH

;;restore stack before returning to mbr;
retf

PRINT_SPLASH:
	;; Print borders
	mov dh, 04h		;Row number
	mov dl, 15h		;Column number
	call SET_CURSOR_POSITION

	;; Print top border
	call PRINT_BORDER_ROW

	call PRINT_TOP_CORNERS

	mov dh, 14h		;Row number
	mov dl, 15h		;Column number
	call SET_CURSOR_POSITION

	;; Print bottom border
	call PRINT_BORDER_ROW

	call PRINT_BOTTOM_CORNERS

	mov dl, 18 		;Set base column value for cross
	mov dh, 20
	call PRINT_CROSS

	call PRINT_CLEAR_MSG
	call PRINT_OS_MESSAGE
	call PRINT_VER
	call WAIT_FOR_KEY
	call CLS
	ret

PRINT_CROSS:
	cmp dl, 59		;Check incrementer condition
	jge EXIT
	inc dl
	inc dl
	inc dl
	dec dh

	call SET_CURSOR_POSITION

	mov ah, 0Ah				;Function to write character
	mov al, 1				;Display double horizontal line
	mov bh, 0				;Display page number
	mov bl, 0				;Ensure lower bits of register are 0
	lea cx, 1				;Number of times to write character
	int 10h

	jmp PRINT_CROSS

PRINT_CLEAR_MSG:
	mov bl,0x0E		;Set string color
	mov bh,00h		;Set background color, always set both bl and bh when pushing text
	mov ah,13h		;Function 13h (display string), XT machine only
	mov al,1		;Write mode is zero: cursor stay after last char
	mov cx,clearmsglen		;Character string length
	mov dh,22		;Position on row 0
	mov dl,27		;And column 0
	lea bp,[clearmsg]	;Load the offset address of string into BP, es:bp
					;Same as mov bp, msg
	int 10h
	ret

PRINT_OS_MESSAGE:
	mov bl,0x2E		;Set string color
	mov bh,00h		;Set background color, always set both bl and bh when pushing text
	mov ah,13h		;Function 13h (display string), XT machine only
	mov al,1		;Write mode is zero: cursor stay after last char
	mov cx,osmsglen	;Character string length
	mov dh,7		;Row
	mov dl,24		;Column
	lea bp,[osmsg]	;Load the offset address of string into BP, es:bp
					;Same as mov bp, msg
	int 10h

	mov cx,osmsgauthlen	;Character string length
	mov dh,8		;Row
	mov dl,27		;Column
	lea bp,[osmsgauth]	;Load the offset address of string into BP, es:bp
					;Same as mov bp, msg
	int 10h
	ret

;; Wait for keyboard input
WAIT_FOR_KEY:
	mov ah, 01
	int 16h
	jz WAIT_FOR_KEY
	ret

CLS:
	mov ah,06h		;Function 06h (scroll screen)
	mov al,0		;Scroll all lines
	mov bh,1eh		;Attribute (set background color, 7 stands for white for cursor color)
	mov ch,0		;Upper left row is zero
	mov cl,0		;Upper left column is zero
	mov dh,24		;Lower left row is 24
	mov dl,79		;Lower left column is 79
	int 10h			;BIOS Interrupt 10h (video services)
					;Colors from 0: Black Blue Green Cyan Red Magenta Brown White
					;Colors from 8: Gray LBlue LGreen LCyan LRed LMagenta Yellow BWhite
					;Only 8 colors for background, 16 for cursor

	mov ah,06h		;Function 06h (scroll screen)
	mov al,0		;Scroll all lines
	mov bh,01h		;Attribute (set background color, 7 stands for white for cursor color)
	mov ch,20		;Upper left row is zero
	mov cl,0		;Upper left column is zero
	mov dh,24		;Lower left row is 24
	mov dl,79		;Lower left column is 79
	int 10h			;BIOS Interrupt 10h (video services)
					;Colors from 0: Black Blue Green Cyan Red Magenta Brown White
					;Colors from 8: Gray LBlue LGreen LCyan LRed LMagenta Yellow BWhite
					;Only 8 colors for background, 16 for cursor

	mov ah,06h		;Function 06h (scroll screen)
	mov al,0		;Scroll all lines
	mov bh,01h		;Attribute (set background color, 7 stands for white for cursor color)
	mov ch,13		;Upper left row is zero
	mov cl,0		;Upper left column is zero
	mov dh,16		;Lower left row is 24
	mov dl,79		;Lower left column is 79
	int 10h			;BIOS Interrupt 10h (video services)
					;Colors from 0: Black Blue Green Cyan Red Magenta Brown White
					;Colors from 8: Gray LBlue LGreen LCyan LRed LMagenta Yellow BWhite
					;Only 8 colors for background, 16 for cursor

	mov ah,06h		;Function 06h (scroll screen)
	mov al,0		;Scroll all lines
	mov bh,01h		;Attribute (set background color, 7 stands for white for cursor color)
	mov ch,6		;Upper left row is zero
	mov cl,0		;Upper left column is zero
	mov dh,9		;Lower left row is 24
	mov dl,79		;Lower left column is 79
	int 10h			;BIOS Interrupt 10h (video services)
					;Colors from 0: Black Blue Green Cyan Red Magenta Brown White
					;Colors from 8: Gray LBlue LGreen LCyan LRed LMagenta Yellow BWhite
					;Only 8 colors for background, 16 for cursor
		
	mov ah,06h		;Function 06h (scroll screen)
	mov al,0		;Scroll all lines
	mov bh,01h		;Attribute (set background color, 7 stands for white for cursor color)
	mov ch,0		;Upper left row is zero
	mov cl,0		;Upper left column is zero
	mov dh,2		;Lower left row is 24
	mov dl,79		;Lower left column is 79
	int 10h			;BIOS Interrupt 10h (video services)
					;Colors from 0: Black Blue Green Cyan Red Magenta Brown White
					;Colors from 8: Gray LBlue LGreen LCyan LRed LMagenta Yellow BWhite
					;Only 8 colors for background, 16 for cursor
	ret

PRINT_CENTER_BLOB:
	mov ah,06h		;Function 06h (scroll screen)
	mov al,0		;Scroll all lines
	mov bh,0x02		;Attribute (set background color, 7 stands for white for cursor color)
	mov ch,4		;Upper left row is zero
	mov cl,20		;Upper left column is zero
	mov dh,20		;Lower left row is 24
	mov dl,60		;Lower left column is 79
	int 10h			;BIOS Interrupt 10h (video services)
					;Colors from 0: Black Blue Green Cyan Red Magenta Brown White
					;Colors from 8: Gray LBlue LGreen LCyan LRed LMagenta Yellow BWhite
					;Only 8 colors for background, 16 for cursor

	ret

;; Use dh and dl for setting row + column
;; Example is mov dh 15h
SET_CURSOR_POSITION:
	mov ah, 02h		;Set cursor position function
	mov bh, 00h		;Page number
	int 10h
	ret

PRINT_TOP_CORNERS:
	;; Set position to top-left for ascii
	mov dh, 04h
	mov dl, 14h
	call SET_CURSOR_POSITION

	;; Print top-left corner char
	mov ah, 0Ah				;Function to write character
	mov al, 0xC9			;Display double horizontal line
	mov bh, 0				;Display page number
	mov bl, 0				;Ensure lower bits of register are 0
	lea cx, 1				;Number of times to write character
	int 10h

	;; Set position to top-right for ascii
	mov dh, 04h
	mov dl, 60
	call SET_CURSOR_POSITION

	;; Print top-right corner char
	mov ah, 0Ah				;Function to write character
	mov al, 0xBB			;Display double horizontal line
	mov bh, 0				;Display page number
	mov bl, 0				;Ensure lower bits of register are 0
	lea cx, 1				;Number of times to write character
	int 10h
	ret

PRINT_BOTTOM_CORNERS:
	;; Set position to top-left for ascii
	mov dh, 14h
	mov dl, 14h
	call SET_CURSOR_POSITION

	;; Print top-left corner char
	mov ah, 0Ah				;Function to write character
	mov al, 0xC9			;Display double horizontal line
	mov bh, 0				;Display page number
	mov bl, 0				;Ensure lower bits of register are 0
	lea cx, 1				;Number of times to write character
	int 10h

	;; Set position to top-right for ascii
	mov dh, 14h
	mov dl, 60
	call SET_CURSOR_POSITION

	;; Print top-right corner char
	mov ah, 0Ah				;Function to write character
	mov al, 0xBB			;Display double horizontal line
	mov bh, 0				;Display page number
	mov bl, 0				;Ensure lower bits of register are 0
	lea cx, 1				;Number of times to write character
	int 10h
	ret

PRINT_VER:
	mov bl,06h		;Set string color
	mov bh,00h		;Set background color, always set both bl and bh when pushing text
	mov ah,13h		;Function 13h (display string), XT machine only
	mov al,1		;Write mode is zero: cursor stay after last char
	mov cx,mlen		;Character string length
	mov dh,0		;Position on row 0
	mov dl,0		;And column 0
	lea bp,[msg]	;Load the offset address of string into BP, es:bp
					;Same as mov bp, msg
	int 10h
	ret

;; Print border, assumes that row and column have been initially set
PRINT_BORDER_ROW:
	mov ah, 0Ah				;Function to write character
	mov al, 0xCD			;Display double horizontal line
	mov bh, 0				;Display page number
	mov bl, 0				;Ensure lower bits of register are 0
	lea cx, [rowlen]		;Number of times to write character
	int 10h
	ret

;; General exit ret
EXIT:
	ret

;; Ret with logic to display a final char
PRINT_EXIT:
	mov cx, 1
	lea bp, [col]
	int 10h
	ret

ADDR dd 0x0000000
ADDR_UP dw 0000h
ADDR_BOT dw 0000h
osmsg db 'Another Unnamed OS',0
osmsglen equ $-osmsg
osmsgauth db 'Dalton Smith',0
osmsgauthlen equ $-osmsgauth
rowlen equ 39
row db '=','$'
col db '|','$'
clearmsg db 'Press any key to continue...',0
clearmsglen equ $-clearmsg
msg db 'Another Unnamed OS, version 0.1 2023 ...',0
mlen equ $-msg; 
