; ************************************************************
; Defined values
; ************************************************************

; Define PPU Registers

PPU_CONTROL        = $2000    ; PPU control register (write)
PPU_MASK           = $2001    ; PPU mask register (write)
PPU_STATUS         = $2002    ; PPU status register (read)
PPU_SPRRAM_ADDRESS = $2003    ; PPU SPR-RAM address register (write)
PPU_SPRRAM_IO      = $2004    ; PPU SPR-RAM I/O register (write)
PPU_VRAM_ADDRESS1  = $2005    ; PPU VRAM address register 1 (write)
PPU_VRAM_ADDRESS2  = $2006    ; PPU VRAM address register 2 (write)
PPU_VRAM_IO        = $2007    ; VRAM I/O register (read/write)
SPRITE_DMA         = $4014    ; Sprite DMA register

; Define APU Registers

APU_DM_CONTROL     = $4010    ; APU delta modulation control register (write)
APU_CLOCK          = $4015    ; APU sound / vertical clock signal register (read/write)

; Joystick/Controller values

JOYPAD1            = $4016    ; Joypad 1 (read/write)
JOYPAD2            = $4017    ; Joypad 2 (read/write)

; Gamepad bit values

PAD_A              = $01      ; Button A
PAD_B              = $02      ; Button B
PAD_SELECT         = $04      ; Select button
PAD_START          = $08      ; Start button
PAD_U              = $10      ; Up
PAD_D              = $20      ; Down
PAD_L              = $40      ; Left
PAD_R              = $80      ; Right

; ************************************************************
; NES Header
; ************************************************************

.segment "HEADER"
INES_MAPPER = 0      ; 0 = NROM
INES_MIRROR = 0      ; 0 = Horizontal mirroring, 1 = Vertical mirroring
INES_SRAM   = 0      ; 1 = Battery-backed SRAM at $6000-$7FFF

.byte 'N', 'E', 'S', $1A   ; ID / iNES signature
.byte $02                  ; 16K PRG bank count
.byte $01                  ; 8K CHR bank count

.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $F) << 4)
.byte (INES_MAPPER & %11110000)
; Padding
.byte $0, $0, $0, $0, $0, $0, $0, $0

; ************************************************************
; Vectors
; ************************************************************

.segment "VECTORS"
.word nmi   ; non-maskable interrupt (vBlank)
.word reset ; starting point
.word irq   ; a clock tick has occured

; ************************************************************
; 6502 Zero Page Memory (256 bytes)
; ************************************************************

.segment "ZEROPAGE"

nmi_ready: .res 1 ; 1 = push a PPU frame update
                  ; 2 = turn rendering off next NMI

gamepad:   .res 1 ; Stores the current gamepad values

d_x:       .res 1 ; X velocity of the ball
d_y:       .res 1 ; Y velocity of the ball


; ************************************************************
; Sprite OAM Data area - copied in NMI routine
; ************************************************************

.segment "OAM"

oam: .res 256        ; Sprite OAM data

; ************************************************************
; Our default palette table has 16 entries for tiles
; and 16 entries for sprites
; ************************************************************

.segment "RODATA"

default_palette:

.byte $0F,$15,$26,$37    ; Background 0 = purple/pink
.byte $0F,$09,$19,$29    ; Background 1 = green
.byte $0F,$01,$11,$21    ; Background 2 = blue
.byte $0F,$00,$10,$30    ; Background 3 = greyscale

.byte $0F,$18,$28,$38    ; Sprite 0 = yellow
.byte $0F,$14,$24,$34    ; Sprite 1 = purple
.byte $0F,$1B,$2B,$3B    ; Sprite 2 = teal
.byte $0F,$12,$22,$32    ; Sprite 3 = marine

welcome_txt:
.byte 'W','E','L','C','O','M','E',0   ; Null-terminated string

; ************************************************************
; Import both the background and sprite character sets
; ************************************************************

.segment "TILES"

.incbin "data.chr"  ; Include raw CHR binary data into ROM
                    ; Contains tile graphics for background and sprites

; ************************************************************
; Remainder of normal RAM area
; ************************************************************

.segment "BSS"

palette: .res 32      ; The current palette buffer


; ************************************************************
; IRQ Clock Interrupt Routine
; ************************************************************

.segment "CODE"

irq:
    rti               ; Return from interrupt

.segment "CODE"

reset:
    rti

.segment "CODE"

nmi:
    rti
