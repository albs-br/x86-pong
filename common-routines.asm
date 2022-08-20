; Inputs:
;   BX: source address
;   ES:DI: destiny address (VRAM)
Put_8x8_TileOnScreen:

    ; mov 	ax, VIDEO_MEMORY    ; 0xa000 video segment
    ; mov 	es, ax              ; Setup extended segment
    ; mov 	ax, DATA_SEGMENT    ; 0xb000 data segment
    ; mov 	ds, ax              ; Setup extended segment

    mov	    ch, 8 ; image_1.size		; line counter
.loop_2:
    mov	    cl, 8 ; image_1.size		; column counter
    push    di
.loop_1:        
        mov	    al, [ds:bx]
        stosb           	; Write AL into address pointed by ES:DI, increments DI
            
        inc	    bx
            
        dec	    byte cl
        jnz	    .loop_1		; jump if non zero
        ;jns	.loop_1         	; Is it negative? No, jump
    pop     di
    
    ;add     di, 320 - 8     ; 320: width of screen, 8: width of tile
    add     di, SCREEN_WIDTH         ; next line

    dec	    byte ch
	jnz	    .loop_2		; jump if non zero


	ret



; Inputs:
;   BX: address of tile pattern
;   CX: number of 8x8 tiles
;   ES:DI: destiny address (VRAM)
FillLineWith_8x8_Tiles:
.loop:
    push    bx
        push    di
            push    cx
                call    Put_8x8_TileOnScreen
            pop     cx
        pop     di
    pop     bx

    add     di, 8

    dec     cx
    jnz     .loop

    ret
        


; Inputs:
;   DX: bg buffer address
;   BX: sprite pattern source address
;   ES:DI: destiny address (VRAM)
Put_8x8_SpriteOnScreen_RestoringBg:

    push    bx
        push    es
            push    di
                ; --------- copy from BG Buffer to screen
                ;mov     ds, cs
                push    cs
                pop     ds
                mov     si, [Sprite_Ball_Bg_Data]
                ;mov     es, VIDEO_MEMORY_SEGMENT
                mov     ax, VIDEO_MEMORY_SEGMENT
                mov     es, ax
                mov     di, [Sprite_Ball_Bg_OldAdrr]
                mov     cx, 8 ;SCREEN_WIDTH * SCREEN_HEIGHT
                rep     movsb  ; copy CX bytes from DS:SI to ES:DI

            pop     di

            ; save new VRAM address
            mov     [Sprite_Ball_Bg_OldAdrr], di

            push    di
                ; --------- copy from screen to BG Buffer

                push    cs
                pop     es
                mov     di, [Sprite_Ball_Bg_Data]
                mov     cx, 8
                rep     movsb  ; copy CX bytes from DS:SI to ES:DI
            pop     di


        pop     es
    pop     bx

    call    Put_8x8_SpriteOnScreen

    ret



; Inputs:
;   BX: source address
;   ES:DI: destiny address (VRAM)
Put_8x8_SpriteOnScreen:

    ; mov 	ax, VIDEO_MEMORY    ; 0xa000 video segment
    ; mov 	es, ax              ; Setup extended segment
    ; mov 	ax, DATA_SEGMENT    ; 0xb000 data segment
    ; mov 	ds, ax              ; Setup extended segment

    mov	    ch, 8 ; image_1.size		; line counter
.loop_2:
    mov	    cl, 8 ; image_1.size		; column counter
    push    di
.loop_1:        
        mov	    al, [bx]

        ; cmp     al, 0
        or      al, al
        jz      .transparency

        stosb           	; Write AL into address pointed by ES:DI, increments DI
        jmp     .continue

.transparency:
        inc     di

.continue:
        inc	    bx
            
        dec	    byte cl
        jnz	    .loop_1		    ; jump if non zero
    pop     di
    
    add     di, SCREEN_WIDTH    ; next line

    dec	    byte ch
	jnz	    .loop_2		        ; jump if non zero


	ret
