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


;;;load splash program and run
	mov bx, 0x0001			;es:bx input buffer, temporary set 0x0000:1234
	mov es, bx
	mov bx, 0x2345
	mov ah, 02h				;Function 02h (read sector)
	mov al, 2				;Read two sectors
	mov ch, 0				;Cylinder#
	mov cl, 38				;Sector# --> 37 (38-1) has program
	mov dh, 0				;Head# --> logical sector 1
	mov dl, 0				;Drive# A, 08h=C
	int 13h

	push cs
	lea ax, [after_splash]
	push ax
	jmp 0x0001:0x2345	;Run program on sector 1, ex:bx
	
after_splash:
	;;load datetime utility
	mov bx, 0x0002			;es:bx input buffer, temporary set 0x0000:1234
	mov es, bx
	mov bx, 0x3456
	mov ah, 02h				;Function 02h (read sector)
	mov al, 1				;Read two sectors
	mov ch, 1				;Cylinder#
	mov cl, 2				;Sector# --> 38 (39-1) has program
	mov dh, 0				;Head# --> logical sector 1
	mov dl, 0				;Drive# A, 08h=C
	int 13h

	push cs
	lea ax, [after_dateutil]
	push ax
	jmp 0x0002:0x3456	;Run program

after_dateutil:
	;;load message
	;;load datetime utility
	mov ax, 0 ; set up disk access parameters (disk 0)
	mov dl, 0 ; set up disk drive number
	mov cx, 1 ; set up number of sectors to read
	mov dh, 0 ; set up head number
	mov dh, 0 ; set up starting track number
	mov bx, buffer ; set up buffer for reading data
	mov ax, 02h ; set up function code for read sector
	mov es, ax ; set up ES segment register
	mov ax, 40 ; set up starting sector number
	int 13h ; call BIOS interrupt to read sector

	mov si, buffer ; set up source index to point to buffer
	mov cx, buffer_size ; set up counter for number of characters to print

	jmp print_message

print_message:
	lodsb ; load byte at [si] into AL, increment SI
    cmp al, 0 ; check if end of string (null byte)
    je done ; if null byte, exit loop

    mov ah, 0Eh ; set up function code for print character
    int 10h ; call BIOS interrupt to print character
	
    jmp print_message ; continue loop

done:
	;mp cls
	int 20h

;; CLS is a testing function
;; Basically used as "print("i'm here")"
cls:			 
  mov ah,06h	;function 06h (Scroll Screen)
  mov al,0	;scroll all lines
  mov bh,1FH	;Attribute (bright white on blue)
  mov ch,0	;Upper left row is zero
  mov cl,0	;Upper left column is zero
  mov dh,24	;Lower left row is 24
  mov dl,79	;Lower left column is 79
  int 10H	;BIOS Interrupt 10h (video services)
  ret

buffer db 256 dup (0)
buffer_size equ $-buffer
padding	times 510-($-$$) db 0		;to make MBR 512 bytes
bootSig	db 0x55, 0xaa		;signature (optional)

