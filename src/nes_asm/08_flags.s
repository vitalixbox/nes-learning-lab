; ============================================================
; 08_flags.s — SEC / CLC / SEI / CLI / SED / CLD / CLV
;
; Directly set or clear individual bits of the processor status register (P).
; There is no SEV (set overflow) — V can only be set by ADC/SBC or the SO pin.
; ============================================================
.segment "CODE"
.proc examples_flags

; ---- Carry flag (C) --------------------------------------------------------

    sec                 ; C=1  — required before SBC; also seeds ROL/ROR
    clc                 ; C=0  — required before ADC; clears carry seed

; ---- Interrupt Disable flag (I) --------------------------------------------
; SEI is done at reset and before writing to PPU/APU.
; CLI re-enables IRQ — safe here since our ROM has no IRQ sources.

    sei                 ; I=1  — mask IRQ (NMI always fires regardless)
    cli                 ; I=0  — unmask IRQ
    sei                 ; I=1  — re-disable for safety

; ---- Decimal flag (D) -------------------------------------------------------
; On NES (Ricoh 2A03): BCD mode is permanently disabled in silicon.
; SED assembles and executes, but ADC/SBC still work in binary.
; CLD at startup is still good practice for portability.

    sed                 ; D=1  — enable BCD (no effect on 2A03)
    cld                 ; D=0  — binary mode

; ---- Overflow flag (V) -----------------------------------------------------
; Only CLV can clear V via software.

    clc
    lda #$70            ; +112
    adc #$10            ; +112 + +16 = -128 signed  →  V=1
    clv                 ; V=0  (the only software instruction that clears V)

    rts
.endproc
