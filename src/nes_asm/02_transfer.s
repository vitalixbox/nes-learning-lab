; ============================================================
; 02_transfer.s — TAX / TAY / TXA / TYA / TSX / TXS
;
; Copy values between A, X, Y, and the stack pointer (SP).
; All set N and Z flags from the transferred value — except TXS.
; ============================================================
.segment "CODE"
.proc examples_transfer

    lda #$42
    tax                     ; A → X:    X = $42,  N=0, Z=0
    tay                     ; A → Y:    Y = $42,  N=0, Z=0

    lda #$00
    txa                     ; X → A:    A = $42,  N=0, Z=0
    tya                     ; Y → A:    A = $42,  N=0, Z=0

; ---- Flags are set from the VALUE being transferred ----

    lda #$80
    tax                     ; X = $80   N=1 (bit 7 set = negative signed)

    lda #$00
    tax                     ; X = $00   Z=1

    lda #$01
    tay                     ; Y = $01   N=0, Z=0

; ---- Stack pointer transfers ----

    tsx                     ; SP → X:   X = current stack pointer, N/Z set
    inx                     ; X = SP + 1 (to show TXS with a different value)
    txs                     ; X → SP:   SP = X  (TXS does NOT set flags!)
    dex
    txs                     ; restore SP to original value

    rts
.endproc
