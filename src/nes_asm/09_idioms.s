; ============================================================
; 09_idioms.s — Common 6502 and NES idioms
; ============================================================
.segment "CODE"
.proc examples_idioms

; ---- Bit manipulation -------------------------------------------------------

    lda scratch
    ora #%00001000      ; set   bit 3
    sta scratch

    lda scratch
    and #%11110111      ; clear bit 3
    sta scratch

    lda scratch
    eor #%00001000      ; toggle bit 3
    sta scratch

    ; Test bit 3: after AND the Z flag tells you whether the bit was set
    lda scratch
    and #%00001000      ; Z=1 → bit was 0;  Z=0 → bit was 1
    beq @bit3_clear
    lda #1              ; bit was set
    jmp @after_bit3
@bit3_clear:
    lda #0              ; bit was clear
@after_bit3:

; ---- Multiply / divide by power of 2 (unsigned) ----------------------------

    lda #$03
    asl a               ; × 2  → $06
    asl a               ; × 4  → $0C  (from original)
    asl a               ; × 8  → $18

    lda #$18
    lsr a               ; ÷ 2  → $0C  (logical: 0 fills from the left)
    lsr a               ; ÷ 2  → $06

; ---- Two's complement negation ---------------------------------------------

    lda #$05
    eor #$FF            ; invert all bits
    clc
    adc #1              ; + 1  →  A = $FB = -5 signed

; ---- Absolute value of a signed byte ---------------------------------------

    lda #$D0            ; -48 signed ($D0)
    bpl @already_positive
    eor #$FF
    clc
    adc #1              ; negate  →  A = +48 = $30
@already_positive:

; ---- Loop N times (counting down) ------------------------------------------
; X as loop counter; fastest because DEX/BNE share the compare implicitly.

    ldx #8
@loop_down:
    ; body: X runs 8, 7, 6 … 1 (use X as index into a table etc.)
    dex
    bne @loop_down

; ---- Loop 0 to N-1 (counting up with index) --------------------------------

    ldy #0
@loop_up:
    ; body: Y runs 0, 1, 2 … 7
    iny
    cpy #8
    bne @loop_up

; ---- 16-bit increment  (lo byte in scratch+0, hi in scratch+1) -------------

    inc scratch+0
    bne @no_carry16
    inc scratch+1       ; propagate carry to high byte
@no_carry16:

; ---- 16-bit addition  (scratch[0:1] += scratch[2:3]) -----------------------

    clc
    lda scratch+0
    adc scratch+2       ; low bytes + carry in
    sta scratch+0
    lda scratch+1
    adc scratch+3       ; high bytes + carry from low
    sta scratch+1

; ---- Table lookup via index ------------------------------------------------

    ldx #3
    lda const_table, x  ; A = const_table[3] = $44

; ---- Block copy: 8 bytes from const_table → scratch ------------------------
; Count down from N-1 to 0; BPL stays in loop while X is non-negative.

    ldx #7
@copy:
    lda const_table, x
    sta scratch, x
    dex
    bpl @copy           ; exits after X wraps $00 → $FF (negative)

; ---- NES: wait for vBlank --------------------------------------------------
; Read $2002 (PPUSTATUS) — bit 7 goes high when vblank starts.
; BIT copies bit 7 of memory into N flag without changing A.

@wait_vblank:
    bit PPUSTATUS       ; N = bit 7 of $2002
    bpl @wait_vblank    ; loop while N=0 (not in vblank yet)
    ; safe to write PPU now

; ---- NES: set PPU VRAM address ($2006 / $2007) -----------------------------
; Must reset the address latch first (read $2002), then write hi then lo byte.

    bit PPUSTATUS       ; reset address latch
    lda #$3F
    sta PPUADDR         ; hi byte → $3F
    lda #$00
    sta PPUADDR         ; lo byte → $00  →  PPU pointer = $3F00 (palette)
    lda #$0F
    sta PPUDATA         ; write $0F to $3F00, PPU pointer auto-increments

    rts
.endproc
