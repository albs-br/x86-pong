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

    cld                  ; Clear Direction flag

	;jmp     show_palette

; ---------------------- test code here
    
    mov      cx, (320/8); + (200/8)

    mov 	di, (320 * 100)       ; initial vram address

.loop_fillScreen:
    push    di
        push    cx
            mov	    bx, Image_2
            call    Put_8x8_TileOnScreen
        pop     cx
    pop     di

    add     di, 8
    ; sub     di, (320 * 8) + 8     ; 320: width of screen, 8: width of tile


    ;add     cx, 8
    dec     cx
    jnz     .loop_fillScreen
    


    mov	    bx, Image_1
    mov 	di, (320 * 130) + 180       ; initial vram address
    call    Put_8x8_TileOnScreen

    jmp     exit

; Inputs:
;   BX: source address
;   ES:DI: destiny address (VRAM)
Put_8x8_TileOnScreen:
    ;mov	    al, [bx]
    
    ;mov 	al, 10
    
    ;mov 	al, [image_1 + 1]
            
    
    mov	    ch, 8 ; image_1.size		; line counter
loop_2:
    mov	    cl, 8 ; image_1.size		; column counter
loop_1:        
    ;push    di
    ;mov     dx, di
        mov	    al, [bx]
        stosb           	; Write AL into address pointed by ES:DI, increments DI
            
        inc	    bx
            
        dec	    byte cl
        jnz	    loop_1		; jump if non zero
        ;jns	loop_1         	; Is it negative? No, jump
    ;pop     di
    ;mov     di, dx
    

    ; next line
    ; mov     ax, bx
    ; add     ax, 320
    ; mov     bx, ax
    add     di, 320 - 8     ; 320: width of screen, 8: width of tile
    ;add     di, 8


    dec	    byte ch
	jnz	    loop_2		; jump if non zero




    ; mov 	di, 320 ; second line
    ; mov	    al, 39
    ; stosb           	; Write AL into address pointed by DI


	ret
    ; jmp exit
        
; ---------------------- 
        
show_palette:
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

; image_1:	
; 	db	10, 10, 10, 10, 10, 10, 10, 10
;     db	39, 39, 39, 39, 39, 39, 39, 39
;     db	20, 20, 20, 20, 20, 20, 20, 20
; .size: equ $ - image_1

%include "data.asm"