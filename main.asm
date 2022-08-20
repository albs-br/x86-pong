;
; Pong in x86 assembly with VGA mode
;
; adapted from palette.asm by Oscar Toledo G. (Boot Sector Games book)
;

	cpu 8086

section .text
	org 0x0100


;---------------------- CONSTANTS
SCREEN_WIDTH                equ 320     ; Width in pixels
SCREEN_HEIGHT               equ 200     ; Height in pixels
VIDEO_MEMORY_SEGMENT        equ 0xA000
BUFFER_SEGMENT              equ 0xB000
TIMER                       equ 046Ch   ; # of timer ticks since midnight



; ;
; ; Memory screen uses 64000 pixels,
; ; this means 0xfa00 is the first byte of
; ; memory not visible on the screen.
; ;
; ball_X:    equ 0xfa00
; v_a:    equ 0xfa02
; v_b:    equ 0xfa04
; oldTime: equ 0xfa06


start:
    mov 	ax, 0x0013   ; Set mode 320x200x256
    int 	0x10        ; Video interruption vector

    ; mov 	ax, 0xa000   ; 0xa000 video segment
    ; mov 	es, ax       ; Setup extended segment
    ; ; mov 	ds, ax       ; Setup data segment

    mov 	ax, VIDEO_MEMORY_SEGMENT    ; 0xa000 video segment
    mov 	es, ax              ; Setup extended segment
    ; mov 	ax, DATA_SEGMENT    ; 0xb000 data segment
    ; mov     ax, 0
    ; mov 	ds, ax              ; Setup extended segment
    mov     ax, cs
    mov 	ds, ax              ; Setup extended segment



    cld                  ; Clear Direction flag

	; jmp     show_palette


;     mov	    bx, Image_1
;     mov 	di, (SCREEN_WIDTH * 130) + 180       ; initial vram address
;     call    Put_8x8_TileOnScreen

; .endlessLoop:
;     jmp .endlessLoop

; ---------------------- draw background

    ; first line
    mov	    bx, Tile_Bricks
    mov     cx, 40              ; number of tiles
    mov 	di, (SCREEN_WIDTH * (0 * 8)) ; initial vram address
    call    FillLineWith_8x8_Tiles

    mov     cx, 23              ; number of lines


    mov 	di, (SCREEN_WIDTH * (1 * 8)) ; initial vram address
.loop_bg:
    push    cx
        push    di
            mov	    bx, Tile_BgPattern
            mov     cx, 40              ; number of tiles
            call    FillLineWith_8x8_Tiles
        pop     di
    pop     cx

    add     di, SCREEN_WIDTH * 8

    dec     cx
    jnz     .loop_bg


    ; last line
    mov	    bx, Tile_Bricks
    mov     cx, 40              ; number of tiles
    mov 	di, (SCREEN_WIDTH * (24 * 8)) ; initial vram address
    call    FillLineWith_8x8_Tiles

; .endlessLoop:
;     jmp .endlessLoop

; ---------------------- copy background to bgBuffer

    ; MOV     SI, 0xa000
    ; MOV     DI, bgBuffer
    ; MOV     CX, SCREEN_WIDTH * SCREEN_HEIGHT
    ; REP     MOVSB  ; copy ECX bytes from DS:ESI to ES:EDI

; ---------------------- test put tile

    mov	    bx, Image_1
    mov 	di, (SCREEN_WIDTH * 130) + 180       ; initial vram address
    call    Put_8x8_TileOnScreen

; ---------------------- sprites test

    mov	    bx, Sprite_Ball
    ;mov	    bx, Image_1
    mov 	di, (SCREEN_WIDTH * 30) + 30       ; initial vram address
    call    Put_8x8_SpriteOnScreen
    ;call    Put_8x8_TileOnScreen

; ---------------------- game loop
.gameLoop:

    call    wait_frame_18hz                ; Wait a frame (18 hz)
    ;call    wait_frame_100hz                ; Wait a frame (100 hz)


    ; read keys
    mov ah, 1h   ; CHECK FOR KEYSTROKE
    int 16h
    jz .loop1     ; Jump if none pressed.
    mov ah, 0h   ; GET KEYSTROKE
    int 16h
    cmp al, 6bh  ; Check if it is 'k'.
    ;jne loop1    ; If not, continue. Keybuffer is now empty.

    ; 'k' pressed
    mov     ax, [ball_X]
    add     ax, SCREEN_WIDTH * 3
    mov     [ball_X], ax
    

.loop1:

    mov	    bx, Sprite_Ball
    ;mov	    bx, Image_1
    mov 	di, (SCREEN_WIDTH * 30) + 30       ; initial vram address
    
    mov     ax, [ball_X]
    inc     ax
    mov     [ball_X], ax

    add     ax, di

    mov     di, ax

    call    Put_8x8_SpriteOnScreen



    jmp     .gameLoop


; ---------------------- 

    jmp     exit



;
; Wait a frame (18.2 hz)
;
wait_frame_18hz:
.1:
    mov     ah, 0x00 ; Get ticks
    int     0x1a ; Call BIOS time service
    cmp     dx, [bp + oldTime] ; Same as old time?
    je      .1 ; Yes, wait.
    mov     [bp + oldTime], dx
    ret
    
;
; Wait a frame (100 hz)
;
wait_frame_100hz:
.1:
    mov     ah, 0x2c            ; Get time
    int     0x21                ; Call DOS get time (Return: CH = hour CL = minute DH = second DL = 1/100 seconds)
    ; Note: on most systems, the resolution of the system clock is about 5/100sec, so returned times generally do not increment by 1 on some systems, DL may always return 00h
    cmp     dx, [bp + oldTime] ; Same as old time?
    je      .1 ; Yes, wait.
    mov     [bp + oldTime], dx
    ret
    


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


; ------------------------ includes

%include "common-routines.asm"



section .data

%include "tiles.asm"
%include "sprites.asm"


; ------------------------ variables
section .bss


ball_X:     resw 1
v_a:        resw 1
v_b:        resw 1
oldTime:    resw 1
;bgBuffer:   resb SCREEN_WIDTH * SCREEN_HEIGHT

;bgBuffer:   equ 0xfa00

Sprite_Ball_Bg_OldAdrr:     resw 1
Sprite_Ball_Bg_Data:     resb 8*8