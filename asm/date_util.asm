[BITS 16]               ;Set code generation to 16 bit mode

[ORG 100H]		;set addressing to begin at 100H

start:
    call date
    call cvtmo
    call cvtday
    call cvtcent
    call cvtyear
    call dspdate

    call time
    call cvthrs
    call cvtmin
    call cvtsec
    call dsptime

    retf ;return back to bootloader

date:
    ;Get date from the system
    mov ah,04h	 ;function 04h (get RTC date)
    int 1Ah		;BIOS Interrupt 1Ah (Read Real Time Clock)
    ret

;CH - Century
;CL - Year
;DH - Month
;DL - Day

cvtmo:
    ;Converts the system date from BCD to ASCII
    mov bh,dh ;copy contents of month (dh) to bh
    shr bh,1
    shr bh,1
    shr bh,1
    shr bh,1
    add bh,30h ;add 30h to convert to ascii
    mov [dtfld],bh
    mov bh,dh
    and bh,0fh
    add bh,30h
    mov [dtfld + 1],bh
    ret

cvtday:
    mov bh,dl ;copy contents of day (dl) to bh
    shr bh,1
    shr bh,1
    shr bh,1
    shr bh,1
    add bh,30h ;add 30h to convert to ascii
    mov [dtfld + 3],bh
    mov bh,dl
    and bh,0fh
    add bh,30h
    mov [dtfld + 4],bh
    ret

cvtcent:
    mov bh,ch ;copy contents of century (ch) to bh
    shr bh,1
    shr bh,1
    shr bh,1
    shr bh,1
    add bh,30h ;add 30h to convert to ascii
    mov [dtfld + 6],bh
    mov bh,ch
    and bh,0fh
    add bh,30h
    mov [dtfld + 7],bh
    ret

cvtyear:
    mov bh,cl ;copy contents of year (cl) to bh
    shr bh,1
    shr bh,1
    shr bh,1
    shr bh,1
    add bh,30h ;add 30h to convert to ascii
    mov [dtfld + 8],bh
    mov bh,cl
    and bh,0fh
    add bh,30h
    mov [dtfld + 9],bh
    ret

dtfld: db '00 00 0000'

dspdate:
    ;Display the system date
    mov ah,13h ;function 13h (Display String)
    mov al,0 ;Write mode is zero
    mov bh,0 ;Use video page of zero
    mov bl,0Fh ;Attribute
    mov cx,10 ;Character string is 10 long
    mov dh,22 ;position on row 4
    mov dl,35 ;and column 28
    push ds ;put ds register on stack
    pop es ;pop it into es register
    mov byte [dtfld + 2], 47
    mov byte [dtfld + 5], 47
    lea bp,[dtfld] ;load the offset address of string into BP
    int 10H
    ret

time:
    ;Get time from the system
    mov ah,02h
    int 1Ah
    ret

;CH - Hours
;CL - Minutes
;DH - Seconds

cvthrs:
    ;Converts the system time from BCD to ASCII
    mov bh,ch ;copy contents of hours (ch) to bh
    shr bh,1
    shr bh,1
    shr bh,1
    shr bh,1
    add bh,30h ;add 30h to convert to ascii
    mov [tmfld],bh
    mov bh,ch
    and bh,0fh
    add bh,30h
    mov [tmfld + 1],bh
    ret

cvtmin:
    mov bh,cl ;copy contents of minutes (cl) to bh
    shr bh,1
    shr bh,1
    shr bh,1
    shr bh,1
    add bh,30h ;add 30h to convert to ascii
    mov [tmfld + 3],bh
    mov bh,cl
    and bh,0fh
    add bh,30h
    mov [tmfld + 4],bh
    ret

cvtsec:
    mov bh,dh ;copy contents of seconds (dh) to bh
    shr bh,1
    shr bh,1
    shr bh,1
    shr bh,1
    add bh,30h ;add 30h to convert to ascii
    mov [tmfld + 6],bh
    mov bh,dh
    and bh,0fh
    add bh,30h
    mov [tmfld + 7],bh
    ret

tmfld: db '00:00:00'

dsptime:
    ;Display the system time
    mov ah,13h ;function 13h (Display String)
    mov al,0 ;Write mode is zero
    mov bh,0 ;Use video page of zero
    mov bl,0Fh ;Attribute
    mov cx,8 ;Character string is 8 long
    mov dh,21 ;position on row 4
    mov dl,36 ;and column 28
    mov byte [tmfld + 2], 58
    mov byte [tmfld + 5], 58
    push ds ;put ds register on stack
    pop es ;pop it into es register
    lea bp,[tmfld] ;load the offset address of string into BP
    int 10H
    ret
