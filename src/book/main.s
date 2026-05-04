; ************************************************************
; Defined values
; ************************************************************

; Define PPU Registers
PPU_CONTROL        = $2000            ; PPU control register (write)
PPU_MASK           = $2001            ; PPU mask register (write)
PPU_STATUS         = $2002            ; PPU status register (read)
PPU_SPRRAM_ADDRESS = $2003            ; PPU SPR-RAM address register (write)
PPU_SPRRAM_IO      = $2004            ; PPU SPR-RAM I/O register (write)
PPU_VRAM_ADDRESS1  = $2005            ; PPU VRAM address register 1 (write)
PPU_VRAM_ADDRESS2  = $2006            ; PPU VRAM address register 2 (write)
PPU_VRAM_IO        = $2007            ; VRAM I/O register (read/write)
SPRITE_DMA         = $4014            ; Sprite DMA register

; Define APU Registers
APU_DM_CONTROL     = $4010            ; APU delta modulation control register (write)
APU_CLOCK          = $4015            ; APU sound / vertical clock signal register (read/write)

; Joystick/Controller values
JOYPAD1            = $4016            ; Joypad 1 (read/write)
JOYPAD2            = $4017            ; Joypad 2 (read/write)

; Gamepad bit values
PAD_A              = $01              ; Button A
PAD_B              = $02              ; Button B
PAD_SELECT         = $04              ; Select button
PAD_START          = $08              ; Start button
PAD_U              = $10              ; Up
PAD_D              = $20              ; Down
PAD_L              = $40              ; Left
PAD_R              = $80              ; Right

; ************************************************************
; NES Header
; ************************************************************

.segment "HEADER"
INES_MAPPER = 0                         ; 0 = NROM
INES_MIRROR = 0                         ; 0 = Horizontal mirroring, 1 = Vertical mirroring
INES_SRAM   = 0                         ; 1 = Battery-backed SRAM at $6000-$7FFF

.byte 'N', 'E', 'S', $1A                ; ID / iNES signature
.byte $02                               ; 16K PRG bank count
.byte $01                               ; 8K CHR bank count

.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $F) << 4)
.byte (INES_MAPPER & %11110000)
; Padding
.byte $0, $0, $0, $0, $0, $0, $0, $0

; ************************************************************
; Vectors
; ************************************************************

.segment "VECTORS"
.word nmi                               ; non-maskable interrupt (vBlank)
.word reset                             ; starting point
.word irq                               ; a clock tick has occured

; ************************************************************
; 6502 Zero Page Memory (256 bytes)
; ************************************************************

.segment "ZEROPAGE"

nmi_ready: .res 1                       ; 1 = push a PPU frame update
                                        ; 2 = turn rendering off next NMI

gamepad:   .res 1                       ; Stores the current gamepad values

d_x:       .res 1                       ; X velocity of the ball
d_y:       .res 1                       ; Y velocity of the ball


; ************************************************************
; Sprite OAM Data area - copied in NMI routine
; OAM (Object Attribute Memory)
; ************************************************************

.segment "OAM"

oam: .res 256                           ; Sprite OAM data

; ************************************************************
; Our default palette table has 16 entries for tiles
; and 16 entries for sprites
; ************************************************************

.segment "RODATA"

default_palette:

.byte $0F,$15,$26,$37                   ; Background 0 = purple/pink
.byte $0F,$09,$19,$29                   ; Background 1 = green
.byte $0F,$01,$11,$21                   ; Background 2 = blue
.byte $0F,$00,$10,$30                   ; Background 3 = greyscale

.byte $0F,$18,$28,$38                   ; Sprite 0 = yellow
.byte $0F,$14,$24,$34                   ; Sprite 1 = purple
.byte $0F,$1B,$2B,$3B                   ; Sprite 2 = teal
.byte $0F,$12,$22,$32                   ; Sprite 3 = marine

welcome_txt:
.byte 'W','E','L','C','O','M','E',0     ; Null-terminated string

; ************************************************************
; Import both the background and sprite character sets
; ************************************************************

.segment "TILES"

.incbin "data.chr"                      ; Include raw CHR binary data into ROM
                                        ; Contains tile graphics for background and sprites

; ************************************************************
; Remainder of normal RAM area
; ************************************************************

.segment "BSS"

palette: .res 32                        ; The current palette buffer


; ************************************************************
; IRQ Clock Interrupt Routine
; ************************************************************

.segment "CODE"

irq:
    rti                                 ; Return from interrupt

; ************************************************************
; Main application entry point for startup/reset
; ************************************************************

.segment "CODE"
.proc reset
    ; === Disable interrupts ===
    sei                                 ; Disable interrupt (IRQ)
    lda #0
    sta PPU_CONTROL                     ; Disables NMI
    sta PPU_MASK                        ; Disables rendering
    sta APU_DM_CONTROL                  ; Disables DMC IRQ (Sound)
    lda #$40
    sta JOYPAD2                         ; Disables API framq IRQ (When writing - its about APU, not JOYPAD)

    cld                                 ; Disables decimal mode
    ldx #$FF                            ; Initialize the stack (Set to $01FF position)
    txs

    ; === Waiting for the first vBlank ===
    ; ! BIT clears flag after execution. So here we reset flag
    bit PPU_STATUS                      ; Check bit 7 ([0]000 0000), 0 - no vblank, 1 - vblank
wait_vblank:
    bit PPU_STATUS                      ; And start waiting vBlank here
    bpl wait_vblank

    ; === Clearing all RAM ===
    ; $0000 – $07FF  (2 KB)
    lda #0
    ldx #0
clear_ram:
    sta $0000,x                         ; $0000 + x
    sta $0100,x
    sta $0200,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx                                 ; x++
    bne clear_ram                       ; Continue while x != 0. 0 → 1 → 2 → ... → 255 → 0 => this loop for 256 times

    ; === Placing sprites offscreen (with position at Y = 255) ===
    ; Segment with oam is 256 bytes where each sprite:
    ;   byte 0 → Y pos
    ;   byte 1 → tile num
    ;   byte 2 → attrs
    ;   byte 3 → X pos
    lda #255
    ldx #0
clear_oam:
    sta oam,x                           ; set 255 to byte 0 of each sprite (Y pos)
    inx
    inx
    inx
    inx                                 ; x+=4, move to next sprite
    bne clear_oam

    ; === Wait vBlank again ===
wait_vblank2:
    bit PPU_STATUS
    bpl wait_vblank2

    ; === Enabling NMI interrupt ===
    lda #%10001000
    ;     |   |- get sprites from Pattern Table 1
    ;     |- enable NMI interrupt in vBlank
    ; $0000–$0FFF  → Pattern Table 0
    ; $1000–$1FFF  → Pattern Table 1
    sta PPU_CONTROL

    ; jmp main
.endproc

.segment "CODE"
.proc nmi
    ; === Save registers ===
    pha
    txa
    pha
    tya
    pha

    ; === Do we need to render? ===
    lda nmi_ready
    ; 0 - do nithing this frame
    ; 1 - push a normal PPU update
    ; 2 - turn rendering off on the next NMI
    bne :+                              ; 0 - do nothing
        jmp ppu_update_end
    :
    cmp #2                              ; 2 - turn rendering off
    bne cond_render
        lda #%00000000
        sta PPU_MASK                    ; Disable rendering
        ldx #0
        stx nmi_ready                   ; Clear nmi_ready
        jmp ppu_update_end

cond_render:
    ; === Transfer the sprite to video memory (256 bytes)
    ldx #0
    stx PPU_SPRRAM_ADDRESS
    lda #>oam
    sta SPRITE_DMA

    ; === Transfer the pallette to video memory (32 bytes)
    lda #%10001000
    sta PPU_CONTROL                     ; Ensure that NMI interrupts is still enabled
    lda PPU_STATUS                      ; Reset latch PPU (PPU waits: 1th write - hi byte, 2th write - lo byte)
    lda #$3F                            ; Set dst = 3F00
    sta PPU_VRAM_ADDRESS2
    stx PPU_VRAM_ADDRESS2
    ldx #0                              ; Loop index
loop:
    lda palette, x                      ; A = palette[X]
    sta PPU_VRAM_IO                     ; Write to PPU
    inx                                 ; X++ $3F00 → $3F01 → $3F02 → ...
    cpx #32                             ; X < 32
    bcc loop
    ; Done: $3F00–$3F1F

    lda #%00011110
    sta PPU_MASK                        ; Enable rendering

    ldx #0
    stx nmi_ready                       ; Flag the PPU update complete

ppu_update_end:
    ; === Restore registers and return ===
    pla
    tay
    pla
    tax
    pla
    rti

.endproc
