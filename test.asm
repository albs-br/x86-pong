;
; Tests with VGA mode
; adapted from palette.asm by Oscar Toledo G. (Boot Sector Games book)
;

	cpu 8086

section .text
	org 0x0100

        ;
        ; Memory screen uses 64000 pixels,
        ; this means 0xfa00 is the first byte of
        ; memory not visible on the screen.
        ;
v_a:    equ 0xfa00
v_b:    equ 0xfa02

start:
        mov 	ax, 0x0013   ; Set mode 320x200x256
        int 	0x10        ; Video interruption vector

        mov 	ax, 0xa000   ; 0xa000 video segment
        mov 	es, ax       ; Setup extended segment
        ;mov 	ds, ax       ; Setup data segment

        ;mov 	ax, 0x0000   
        ;mov 	ds, ax       ; Setup data segment


	jmp m4 ; show palette

        ; ---------------------- test code here
        
        mov	bx, image_1
        mov	al, [bx]
        
        ;mov 	al, 10
        
        ;mov 	al, [image_1 + 1]
                
        mov 	di, 10
        
        mov	cx, image_1.size ; 24		; counter
loop_1:        
        mov	al, [bx]
        stosb           	; Write AL into address pointed by ES:DI, increment DI
        
	inc	bx
        
        dec	word cx

	jnz	loop_1		; jump if non zero
        ;jns	loop_1         	; Is it negative? No, jump
        

        mov 	di, 320 ; second line
        mov	al, 39
        stosb           	; Write AL into address pointed by DI

	jmp exit
        
        ; ---------------------- 
        
m4:
        mov ax,127      ; 127 as row
        mov [v_a],ax    ; Save into v_a
m0:     mov ax,127      ; 127 as column
        mov [v_b],ax    ; Save into v_b

m1:
        mov ax,[v_a]    ; Get Y-coordinate
        mov dx,320      ; Multiply by 320 (size of pixel row)
        mul dx
        add ax,[v_b]    ; Add X-coordinate to result
        xchg ax,di      ; Pass AX to DI

        mov ax,[v_a]    ; Get current Y-coordinate
        and ax,0x78     ; Separate 4 bits = 16 rows
        add ax,ax       ; Value between 0x00 and 0xf0

        mov bx,[v_b]    ; Get current X-coordinate
        and bx,0x78     ; Separate 4 bits = 16 columns 
        mov cl,3        ; Shift right by 3 places
        shr bx,cl
        add ax,bx       ; Combine with previous value

        stosb           ; Write AL into address pointed by DI
        
        dec word [v_b]  ; Decrease column
        jns m1          ; Is it negative? No, jump
        
        dec word [v_a]  ; Decrease row
        jns m0          ; Is it negative? No, jump


exit:
        mov ah,0x00     ; Wait for a key
        int 0x16        ; Keyboard interruption vector.

        mov ax,0x0002   ; Set mode 80x25 text.
        int 0x10        ; Video interruption vector.

        int 0x20        ; Exit to command-line.
        

section .data

image_1:	
	db	10, 10, 10, 10, 10, 10, 10, 10
        db	39, 39, 39, 39, 39, 39, 39, 39
        db	20, 20, 20, 20, 20, 20, 20, 20
.size: equ $ - image_1
