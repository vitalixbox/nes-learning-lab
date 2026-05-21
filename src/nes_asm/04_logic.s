; ============================================================
; 04_logic.s — AND / ORA / EOR / ASL / LSR / ROL / ROR / BIT
; ============================================================
.segment "CODE"
.proc examples_logic

; ---- AND — Bitwise AND (mask = keep only these bits) ------------------------

    lda #%11001010
    and #%10101111      ; A = %10001010  (clear bits where mask = 0)

    ; Common use: isolate a field
    lda #%10110101
    and #%00001111      ; A = %00000101  (low nibble only)

; ---- ORA — Bitwise OR (set these bits) -------------------------------------

    lda #%10000000
    ora #%00000001      ; A = %10000001  (set bit 0)

; ---- EOR — Bitwise Exclusive OR (toggle these bits) ------------------------

    lda #%11110000
    eor #%10101010      ; A = %01011010

    lda #$FF
    eor #$FF            ; A = $00, Z=1  (XOR with itself clears to 0)

; ---- ASL — Arithmetic Shift Left  (bit 7 → C, 0 → bit 0) ------------------
; Multiply by 2; old bit 7 goes to carry.

    lda #%00000001
    asl a               ; A = %00000010, C=0
    asl a               ; A = %00000100, C=0

    lda #%10000001
    asl a               ; A = %00000010, C=1  (bit 7 shifted out to carry)

    ; Memory form:
    lda #$04
    sta zp_a
    asl zp_a            ; mem[zp_a] = $08  (zero page)

; ---- LSR — Logical Shift Right  (0 → bit 7, bit 0 → C) --------------------
; Divide by 2 (unsigned); old bit 0 goes to carry.

    lda #%00000110
    lsr a               ; A = %00000011, C=0
    lsr a               ; A = %00000001, C=1  (bit 0 shifted out to carry)
    lsr a               ; A = %00000000, C=1, Z=1

; ---- ROL — Rotate Left through Carry  (C → bit 0, bit 7 → C) ---------------

    clc
    lda #%10000000
    rol a               ; A = %00000000, C=1  (old bit 7 to carry, old C to bit 0)
    rol a               ; A = %00000001, C=0  (carry back into bit 0)

; ---- ROR — Rotate Right through Carry  (C → bit 7, bit 0 → C) ---------------

    sec
    lda #%00000001
    ror a               ; A = %10000000, C=1  (old C to bit 7, old bit 0 to carry)
    ror a               ; A = %11000000, C=0

; ---- BIT — Test bits without changing A ------------------------------------
; Z = !(A & mem)   (zero if AND result is non-zero)
; N = bit 7 of mem
; V = bit 6 of mem

    lda #$C0
    sta zp_a            ; mem[zp_a] = %11000000  (bit7=1, bit6=1)

    lda #%11000000
    bit zp_a            ; Z=0 (A & mem != 0), N=1 (bit7), V=1 (bit6)

    lda #%00001111
    bit zp_a            ; Z=1 (A & $C0 = 0), N=1, V=1  (N/V from mem, not A)

    rts
.endproc
