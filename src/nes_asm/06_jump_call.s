; ============================================================
; 06_jump_call.s — JMP / JSR / RTS / RTI / BRK
;
; JMP  — unconditional jump, no stack, no flags
; JSR  — push (PC+2) onto stack (hi then lo), then jump
; RTS  — pop lo then hi, add 1, set PC
; RTI  — pop flags then PC (lo then hi)  [used in NMI/IRQ handlers]
; BRK  — software interrupt: push PC+2 and flags, set B, jump via $FFFE
; ============================================================
.segment "CODE"
.proc examples_jump_call

; ---- JMP absolute ----------------------------------------------------------

    jmp @after_jmp
    lda #$FF            ; skipped
@after_jmp:

; ---- JMP indirect — jump through a 16-bit pointer in memory ----------------
; Reads two bytes from ptr_lo/ptr_hi, forms address, jumps there.
; Famous 6502 bug: if low byte of pointer is at $xxFF, high byte is read
; from $xx00 instead of $(xx+1)00 — avoid placing indirect pointers at $xxFF.

    lda #<@jmp_target
    sta ptr_lo
    lda #>@jmp_target
    sta ptr_hi
    jmp (ptr_lo)        ; PC = {mem[ptr_lo+1], mem[ptr_lo]}
    lda #$FF            ; skipped
@jmp_target:

; ---- JSR / RTS — Call subroutine and return --------------------------------

    jsr @sub
    lda #$CC            ; execution resumes here after RTS

    jmp @after_calls

@sub:
    lda #$AA            ; A = $AA inside subroutine
    rts                 ; pop return address from stack, PC = pushed addr + 1

; ---- RTI — Return from Interrupt -------------------------------------------
; Pops flags (P) then PC from stack.  Used in NMI/IRQ handlers only.
; See nmi/irq handlers in main.s for real usage.

@after_calls:

; ---- BRK — Software Interrupt ----------------------------------------------
; Pushes PC+2 and flags (with B=1) to stack, sets I, jumps via IRQ vector.
; The byte after BRK is a "signature" read by the handler to identify source.
; Uncomment to test — our irq handler just does RTI so execution continues.
;   brk
;   .byte $00           ; BRK signature byte (consumed by handler)

    rts
.endproc
