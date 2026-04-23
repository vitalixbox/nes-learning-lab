.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01
    .byte $00
    .res 8, $00

.segment "ZEROPAGE"

.segment "OAM"
    .res 256

.segment "BSS"

.segment "CODE"

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002

reset:
    sei
    cld
    ldx #$FF
    txs

    lda #$00
    sta PPUCTRL
    sta PPUMASK

    bit PPUSTATUS
@vblank1:
    bit PPUSTATUS
    bpl @vblank1
@vblank2:
    bit PPUSTATUS
    bpl @vblank2

forever:
    jmp forever

nmi:
    rti

irq:
    rti

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
    .res 8192, $00
