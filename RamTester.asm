.model tiny         
.data
	porta1 equ 10h
	portb1 equ 12h
	portc1 equ 14h
	creg1 equ 16h

	porta2 equ 20h
	portb2 equ 22h
	portc2 equ 24h
	creg2 equ 26h
.code
.startup

top:

	mov ax,0080h
	mov ds,ax   
	mov al,10001001b        ;load control word of 8255
	out creg1,al            ;initialise lcd
	call init_lcd           ;get data from portc1
	in al,portc1            ;get ram to be tested
	and al,00000001b
	jz r2
                            
    mov si,7ffh              ;max address of 6116
    call print6116
	jmp t

r2:	mov si,7fffh             ;max address of 62256
	call print62256
	jmp t
                             ;for writing 0s
t:	mov bh,00h               ;for writing 1s
	mov bl,01h
	mov dx,00h               
r1:	mov ah,08h                ;for 1-byte

r:	mov ch,bh                
	call memwrite             ;write to memory
	call memread              ;read from memory
	and al,bl
	cmp al,ch
	jnz pass                  ;jump to pass

	mov ch,bl
	call memwrite
	call memread
	and al,bl
	cmp al,ch
	jnz pass
	
	rol bl,01                 ; roll bl
	dec ah
	jnz r
	
	inc dx
	cmp dx,si
	jnz r1                   ;if not max address goto r1
	
	; call print6116

	call failwrt             ;ram is correct so print pass
	jmp eop

; call print6116
pass:	call passwrt         ;print fail



	

	; mov al, 'P'
	; ; dec al
	; call writecommand2
	; call delayprog
	
	; ; mov al,14h
	; ; call writecommand
	; ; call delayprog

	; mov al, 'A'
	; ; dec al
	; call writecommand2
	; call delayprog
	
	; ; mov al,14h
	; ; call writecommand
	; ; call delayprog

	; mov al, 'S'
	; ; dec al
	; call writecommand2
	; call delayprog
	
	; ; mov al,14h
	; ; call writecommand
	; ; call delayprog

	; mov al, 'S'
	; ; dec al
	; call writecommand2
	; call delayprog



	in al,portc1            ;get ram to be tested
	and al,00000001b
	mov ah, al
chk:
	in al,portc1            ;get ram to be tested
	and al,00000001b
	cmp al, ah
	je chk

	jmp top

eop: nop
    jmp eop




.exit

lcdp proc near
	pushf
	push ax
	push bx
	push cx
	push dx
	
	mov al,80h
	out porta1,al
	call clear
	
	pop dx
	pop cx
	pop bx
	pop ax
	popf
	ret
lcdp endp

init_lcd proc near                    ;initialising the lcd
    mov al,38h
    call writecommand
    call delayprog
    call delayprog
    call delayprog
	mov al,0eh
	call writecommand
	call delayprog
	mov al,01
	call writecommand
	call delayprog
	mov al,06h
	call writecommand
	call delayprog
init_lcd endp


clear proc                               ;clearing the lcd
	mov al,01
	call writecommand
	call delayprog
	call delayprog
	ret
clear endp

writecommand proc                        ;writing
	mov dx,porta1
	out dx,al
	mov dx,portb1
	mov al, 00000100b
	out dx,al
	mov al, 00000000b
	out dx,al
	ret
writecommand endp

writecommand2 proc                        ;writing
	mov dx,porta1
	out dx,al

	mov dx,portb1
	mov al, 00000101b
	out dx,al
	
	mov al, 00000001b
	out dx,al
	
	ret
writecommand2 endp

passwrt proc near
	                           ;writing 'PASS'
	mov al,'P'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'A'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'S'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'S'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	ret
passwrt endp

failwrt proc near                           ;writing 'FAIL'
	
	mov al,'F'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'A'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'I'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'L'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	ret
failwrt endp

print6116 proc near                           ;writing 'FAIL'
	call clear
	mov al,'6'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'1'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'1'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'6'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,' '
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	ret
print6116 endp


print62256 proc near                           ;writing 'FAIL'
	call clear
	mov al,'6'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'2'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'2'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'5'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,'6'
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	mov al,' '
	call writecommand2
	call delayprog
	call delayprog
	call delayprog
	ret
print62256 endp

writedata proc                               ;passing data to lcd to print
	push dx
	mov dx,porta1
	out dx,al
	mov al,00000101b   ; RS=1, R/W=0, E=1 for H-to-L pulse
	mov dx,portb1
	out dx,al
	mov al,00000001b   ; RS=1, R/W=0 and E=0 for H-to-L pulse 
	mov dx,ax
	pop dx
	ret
writedata endp

delayprog proc                              ;delaying the program
    
	mov cx,1325
w:	nop
	nop
	nop
	nop
	nop
	dec cx
	cmp cx,00
	jnz w
	ret
delayprog endp

memread proc near                              ;reading from the selected ram
	mov al,82h
	out creg2,al
	
	mov al,dl
	out porta2,al
	
	mov al,dh
	out portc2,al
	
	in al,portb2
	call delayprog
	ret
memread endp

memwrite proc near                             ;writing to the selected ram
	mov al,80h
	out creg2,al
	
	mov al,dl
	out porta2,al
	
	mov al,dh
	out portc2,al
	
	mov al,ch
	out portb2,al
	call delayprog
	ret
memwrite endp
	


end
