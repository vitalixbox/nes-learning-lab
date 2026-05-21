; ============================================================
; 07_stack.s — PHA / PLA / PHP / PLP
;
; The stack lives at $0100–$01FF.  SP starts at $FF and decrements on push.
; Push: mem[$0100 + SP] = value;  SP--
; Pull: SP++;  value = mem[$0100 + SP]
; ============================================================
.segment "CODE"
.proc examples_stack

; ---- PHA — Push Accumulator ------------------------------------------------

    lda #$42
    pha                 ; mem[$0100 + SP] = $42, SP--

; ---- PLA — Pull Accumulator  (sets N and Z from value pulled) --------------

    pla                 ; SP++, A = $42,  N=0, Z=0

    lda #$00
    pha
    pla                 ; A = $00,  Z=1

    lda #$FF
    pha
    pla                 ; A = $FF,  N=1

; ---- PHP — Push Processor Status -------------------------------------------
; Pushes the flags byte (NV-BDIZC) with bits 4 and 5 always set.

    sec                 ; C=1
    php                 ; pushes flags with C=1 (among others)

; ---- PLP — Pull Processor Status -------------------------------------------
; Restores all flags except bit 4 (B) which is cleared when pulled.

    plp                 ; flags restored: C=1

; ---- Save and restore A, X, Y across a subroutine call ---------------------
; 6502 has no multi-register push, so each reg is manually saved via A.

    lda #$10
    ldx #$20
    ldy #$30

    pha                 ; push A ($10)
    txa
    pha                 ; push X ($20)
    tya
    pha                 ; push Y ($30)

    ; subroutine clobbers everything
    lda #$FF
    ldx #$FF
    ldy #$FF

    pla
    tay                 ; restore Y = $30
    pla
    tax                 ; restore X = $20
    pla                 ; restore A = $10

    rts
.endproc
