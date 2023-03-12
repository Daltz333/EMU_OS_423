org 0x7c00
jmp short start
nop

bsOEM	db "OS423 v.0.2"               ; OEM String

start:
	
;;cls
	mov ah,06h		;Function 06h (scroll screen)
	mov al,0		;Scroll all lines
	mov bh,0ah		;Attribute (lightgreen on black) 
	mov ch,0		;Upper left row is zero
	mov cl,0		;Upper left column is zero
	mov dh,24		;Lower left row is 24
	mov dl,79		;Lower left column is 79
	int 10h			;BIOS Interrupt 10h (video services)
				;Colors from 0: Black Blue Green Cyan Red Magenta Brown White
				;Colors from 8: Gray LBlue LGreen LCyan LRed LMagenta Yellow BWhite


;;;load 2nd sector and run
	mov bx, 0x0001			;es:bx input buffer, temporary set 0x0000:1234
	mov es, bx
	mov bx, 0x2345
	mov ah, 02h				;Function 02h (read sector)
	mov al, 1				;Read one sector
	mov ch, 0				;Cylinder#
	mov cl, 2				;Sector# --> 2 has program
	mov dh, 0				;Head# --> logical sector 1
	mov dl, 0				;Drive# A, 08h=C
	int 13h

	mov ax, [continue]
	add ax, 0x7c00
	push ax
	push cs
	jmp 0x0001:0x2345	;Run program on sector 1, ex:bx
	
continue:
	int 10h
	call cls

cls:
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

;;display string
	mov ah,13h		;Function 13h (display string), XT machine only
	mov al,1		;Write mode is zero: cursor stay after last char
	mov bh,0		;Use video page of zero
	mov bl,0ah		;Attribute (lightgreen on black)
	mov cx,mlen		;Character string length
	mov dh,1		;Position on row 0
	mov dl,0		;And column 0
	lea bp,[msg]	;Load the offset address of string into BP, es:bp
					;Same as mov bp, msg  
	int 10h
	ret

msg db 'OS423, a real OS, version 0.2 (c) compsci emich 2023 ...',10,13,'$'
mlen equ $-msg

padding	times 510-($-$$) db 0		;to make MBR 512 bytes
bootSig	db 0x55, 0xaa		;signature (optional)

