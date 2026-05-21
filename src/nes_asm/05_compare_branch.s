; ============================================================
; 05_compare_branch.s — CMP / CPX / CPY + all 8 branch instructions
;
; CMP/CPX/CPY compute (reg - operand) and set flags but do NOT
; store the result.
;   reg == operand  →  Z=1, C=1
;   reg >  operand  →  Z=0, C=1  (unsigned greater)
;   reg <  operand  →  Z=0, C=0  (unsigned less)
; ============================================================
.segment "CODE"
.proc examples_compare_branch

; ---- CMP — Compare Accumulator ---------------------------------------------

    lda #$40
    cmp #$40            ; Z=1, C=1  (equal)
    cmp #$20            ; Z=0, C=1  (A > operand, unsigned)
    cmp #$60            ; Z=0, C=0  (A < operand, unsigned)

; ---- CPX / CPY — Compare X or Y -------------------------------------------

    ldx #$10
    cpx #$10            ; Z=1, C=1
    cpx #$05            ; Z=0, C=1  (X > operand)
    cpx #$20            ; Z=0, C=0  (X < operand)

    ldy #$80
    cpy #$80            ; Z=1, C=1
    cpy #$90            ; Z=0, C=0  (Y < operand, unsigned)

; ---- BEQ — Branch if Equal  (Z=1) -----------------------------------------

    lda #$05
    cmp #$05            ; Z=1
    beq @equal
    lda #$FF            ; skipped
@equal:
    lda #$01            ; A = $01 after branch

; ---- BNE — Branch if Not Equal  (Z=0) -------------------------------------

    lda #$05
    cmp #$10            ; Z=0
    bne @not_equal
    lda #$FF            ; skipped
@not_equal:

; ---- BCS — Branch if Carry Set  (C=1) — unsigned >= -----------------------

    lda #$10
    cmp #$05            ; C=1  (A >= operand)
    bcs @carry_set
    lda #$FF            ; skipped
@carry_set:

; ---- BCC — Branch if Carry Clear  (C=0) — unsigned < ----------------------

    lda #$05
    cmp #$10            ; C=0  (A < operand)
    bcc @carry_clear
    lda #$FF            ; skipped
@carry_clear:

; ---- BMI — Branch if Minus  (N=1) — signed negative -----------------------

    lda #$FF            ; $FF = -1 in two's complement
    bmi @minus
    lda #$00            ; skipped
@minus:

; ---- BPL — Branch if Plus  (N=0) — signed positive or zero ----------------

    lda #$7F            ; +127
    bpl @plus
    lda #$00            ; skipped
@plus:

; ---- BVS — Branch if Overflow Set  (V=1) -----------------------------------
; Signed overflow: result went past +127 or below -128

    clc
    lda #$70            ; +112
    adc #$10            ; +112 + +16 = +128 → wraps to -128 (signed)  V=1
    bvs @overflow
    lda #$00            ; skipped
@overflow:

; ---- BVC — Branch if Overflow Clear  (V=0) ---------------------------------

    clc
    lda #$10
    adc #$10            ; $20, no signed overflow  V=0
    bvc @no_overflow
    lda #$00            ; skipped
@no_overflow:

    rts
.endproc
