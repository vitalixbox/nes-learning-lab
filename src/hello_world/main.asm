.segment "HEADER"
    .byte "NES", $1A   ; iNES magic
    .byte 2             ; 2x 16KB PRG ROM banks
    .byte 1             ; 1x  8KB CHR ROM bank
    .byte $01           ; mapper 0, vertical mirroring
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
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007

reset:
    sei
    cld
    ldx #$FF
    txs

    lda #$00
    sta PPUCTRL
    sta PPUMASK

    ; wait for two VBlanks so PPU warms up
    bit PPUSTATUS
@vblank1:
    bit PPUSTATUS
    bpl @vblank1
@vblank2:
    bit PPUSTATUS
    bpl @vblank2

    ; palette: color 0 = black ($0F), color 1 = white ($30)
    bit PPUSTATUS       ; reset address latch
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR
    lda #$0F
    sta PPUDATA
    lda #$30
    sta PPUDATA

    ; write "HELLO WORLD" at nametable row 13, col 10
    ; PPU addr = $2000 + 13*32 + 10 = $21AA
    bit PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$AA
    sta PPUADDR
    ldx #$00
@write:
    lda msg, x
    sta PPUDATA
    inx
    cpx #11
    bne @write

    ; reset scroll to 0,0
    bit PPUSTATUS
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    ; enable background rendering
    lda #%00001010      ; show bg + leftmost 8px column
    sta PPUMASK

forever:
    jmp forever

nmi:
    rti

irq:
    rti

; tile indices for "HELLO WORLD"
; 0=space 1=H 2=E 3=L 4=O 5=W 6=R 7=D
msg:
    .byte 1, 2, 3, 3, 4, 0, 5, 4, 6, 3, 7

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
; Each tile: 8 bytes plane 0 (pixels), 8 bytes plane 1 (all zero = 1-color)
; Bit 7 = leftmost pixel.

; tile 0: space
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
; tile 1: H  (##...##)
    .byte $C3,$C3,$C3,$FF,$C3,$C3,$C3,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
; tile 2: E  (######, ##, #####, ##, ######)
    .byte $FC,$C0,$C0,$F8,$C0,$C0,$FC,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
; tile 3: L  (##, ##, ##, ##, ##, ######)
    .byte $C0,$C0,$C0,$C0,$C0,$C0,$FC,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
; tile 4: O  (.######., ##...##)
    .byte $7E,$C3,$C3,$C3,$C3,$C3,$7E,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
; tile 5: W  (##...##, ##.##.##, ##...##)
    .byte $C3,$C3,$C3,$DB,$DB,$DB,$66,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
; tile 6: R  (######, ##...##, ######, ##.##, ##..##)
    .byte $FC,$C6,$C6,$FC,$CC,$C6,$C3,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
; tile 7: D  (#####, ##..##, ##...##, ##..##, #####)
    .byte $F8,$CC,$C6,$C6,$C6,$CC,$F8,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
