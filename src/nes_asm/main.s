; ============================================================
; nes_asm — 6502 / NES assembly cheat sheet
; Build:  make nes_asm  →  build/nes_asm.nes
; Run in fceux debugger and step through each example group.
; Each group is in its own file; see 01_*.s – 09_*.s.
; ============================================================

; ---- NES hardware registers ----
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
PPUADDR   = $2006
PPUDATA   = $2007

; ---- iNES header ----
.segment "HEADER"
    .byte "NES", $1A    ; magic
    .byte 2             ; 2 × 16 KB PRG banks
    .byte 0             ; 0 × 8 KB CHR banks (CHR RAM — no graphics needed)
    .byte $00           ; mapper 0, horizontal mirroring
    .byte $00
    .res 8, $00

; ---- Zero page variables shared by examples ----
.segment "ZEROPAGE"
zp_a:    .res 1         ; read scratch byte
zp_b:    .res 1         ; write scratch byte
ptr_lo:  .res 1         ; low  byte of a 16-bit pointer (for indirect examples)
ptr_hi:  .res 1         ; high byte
zp_arr:  .res 4         ; scratch array for zero-page indexed store examples

; ---- Writable RAM scratch area ----
.segment "BSS"
scratch: .res 16        ; used for absolute store examples and idioms

; ---- Read-only table in ROM — used by indexed/indirect load examples ----
.segment "RODATA"
const_table:
    .byte $11, $22, $33, $44, $55, $66, $77, $88

; ---- Example groups — each file defines one .proc ----
.segment "CODE"

.include "01_load_store.s"
.include "02_transfer.s"
.include "03_arithmetic.s"
.include "04_logic.s"
.include "05_compare_branch.s"
.include "06_jump_call.s"
.include "07_stack.s"
.include "08_flags.s"
.include "09_idioms.s"

; ---- Reset handler ----
.proc reset
    sei                 ; disable IRQ
    cld                 ; binary mode (no BCD)
    ldx #$FF
    txs                 ; stack pointer = $FF
    lda #0
    sta PPUCTRL         ; disable NMI
    sta PPUMASK         ; disable rendering

    ; Point ptr_lo/ptr_hi at scratch RAM — used by indirect addressing examples
    lda #<scratch
    sta ptr_lo
    lda #>scratch
    sta ptr_hi

    ; Run all example groups in order.
    ; Set a breakpoint at any JSR below to jump straight to that group.
    jsr examples_load_store
    jsr examples_transfer
    jsr examples_arithmetic
    jsr examples_logic
    jsr examples_compare_branch
    jsr examples_jump_call
    jsr examples_stack
    jsr examples_flags
    jsr examples_idioms

@done:
    jmp @done           ; breakpoint here = all groups finished
.endproc

nmi: rti
irq: rti

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq
