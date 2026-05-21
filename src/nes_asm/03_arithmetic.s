; ============================================================
; 03_arithmetic.s — ADC / SBC / INC / DEC / INX / DEX / INY / DEY
;
; ADC/SBC always include the carry bit — always CLC before ADC
; and SEC before SBC for a fresh operation.
; ============================================================
.segment "CODE"
.proc examples_arithmetic

; ---- ADC — Add with Carry ---------------------------------------------------

    clc
    lda #$10
    adc #$20            ; A = $10 + $20 + C(0) = $30,  C=0, Z=0, N=0

    clc
    lda #$FF
    adc #$01            ; A = $00, C=1 (unsigned overflow), Z=1

    ; Signed overflow: result crosses +127 boundary → V=1
    clc
    lda #$70            ; +112
    adc #$10            ; +112 + +16 = $80 = -128 signed  → V=1, N=1

    ; Chained 16-bit add: (scratch+1):scratch += $01FF
    clc
    lda scratch
    adc #$FF
    sta scratch
    lda scratch+1
    adc #$01            ; carry from low byte propagates here
    sta scratch+1

; ---- SBC — Subtract with Carry (borrow) -------------------------------------
; Formula: A = A - operand - (1 - C)
; SEC first so borrow bit = 0 (no borrow assumed)

    sec
    lda #$50
    sbc #$20            ; A = $50 - $20 = $30, C=1 (no borrow)

    sec
    lda #$20
    sbc #$30            ; A = $20 - $30 = $F0 (-16 signed), C=0 (borrow occurred)

    ; Signed underflow: result crosses -128 boundary → V=1
    sec
    lda #$80            ; -128
    sbc #$01            ; -128 - 1 = -129 → wraps to $7F (+127) → V=1

; ---- INC / DEC — Increment/Decrement memory --------------------------------

    lda #$05
    sta zp_a
    inc zp_a            ; mem[zp_a] = $06  (zero page)
    inc zp_a            ; mem[zp_a] = $07
    dec zp_a            ; mem[zp_a] = $06  (zero page)

    lda #$FF
    sta scratch
    inc scratch         ; mem[scratch] wraps $FF → $00, Z=1  (absolute)
    dec scratch         ; mem[scratch] = $FF, N=1

; ---- INX / DEX — Increment/Decrement X -------------------------------------

    ldx #$FE
    inx                 ; X = $FF, N=1
    inx                 ; X = $00, Z=1  (wraps)
    dex                 ; X = $FF, N=1
    dex                 ; X = $FE

; ---- INY / DEY — Increment/Decrement Y -------------------------------------

    ldy #$01
    dey                 ; Y = $00, Z=1
    dey                 ; Y = $FF, N=1  (wraps)
    iny                 ; Y = $00, Z=1

    rts
.endproc
