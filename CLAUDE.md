# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

**Prerequisite:** `brew install cc65`

```bash
make              # build all projects → build/*.nes
make hello_world  # build only src/hello_world
make cgp_simple_game  # build only src/cgp_simple_game
make nes_asm          # build only src/nes_asm
make clean        # remove build/
```

**To add a new project:** create `src/<name>/main.s` + `src/<name>/nes.cfg`, then add `<name>` to `PROJECTS` in the Makefile.

## Running

Open the generated `.nes` files from `build/` in [fceux](https://fceux.com). There is no automated test suite — correctness is verified by running the ROM in an emulator.

## Architecture

6502 assembly targeting the NES (Ricoh 2A03 CPU + PPU). Each project is a self-contained directory under `src/` with:
- `main.s` — entry point; may `.include` other `.s` files in the same directory
- `nes.cfg` — linker script defining memory layout and segment→region mapping
- Optionally `.chr` binary files for tile data

**Segment ordering in `nes.cfg` matters:** segments sharing a memory region are placed in the order they appear. A segment with a fixed `start` address (e.g. `CODE: start = $8000`) must come before any unfixed segments in the same region, or the linker will report an overflow.

**Build pipeline:** `ca65` assembles `.s` → `.o`, then `ld65` links with the `.cfg` to produce the `.nes` ROM.

### Memory map (defined in `.cfg` files)

| Region | Address | Purpose |
|--------|---------|---------|
| ZEROPAGE | $0000–$00FF | Fast-access variables (`nmi_ready`, `gamepad`, palette buffer) |
| OAM | $0200–$02FF | Sprite attributes (64 sprites × 4 bytes), DMA'd to PPU each frame |
| RAM | $0300–$07FF | General game state |
| PRG ROM | $8000–$FFFF | Code and read-only data |
| CHR ROM | $0000–$1FFF | Tile graphics (2 bitplanes × 8 bytes per tile) |
| Vectors | $FFFA–$FFFF | NMI / Reset / IRQ handler addresses |

### Key patterns

**Interrupt-driven rendering:** The NMI fires every vBlank (~60 Hz). The main loop sets `nmi_ready` and spins until the NMI handler clears it after uploading palette + OAM to the PPU. This prevents mid-frame PPU writes.

**PPU access discipline:** The PPU can only be written safely during vBlank. Use `ppu_update` (waits for next NMI) for normal frame updates, or `ppu_off` (disables rendering) for bulk initialization writes.

**Sprite OAM:** Sprites live in the $0200 CPU RAM page. Each frame the NMI handler DMA-copies the whole page to the PPU via SPRITE_DMA ($4014).

**Palette:** A 32-byte buffer in zero page (16 background + 16 sprite colors, 4 palettes × 4 colors each) is written to PPU $3F00 during NMI.

**Gamepad:** `gamepad_poll` strobes JOYPAD1 ($4016) and reads 8 bits into `gamepad`. Button constants: `PAD_A`, `PAD_B`, `PAD_SELECT`, `PAD_START`, `PAD_UP`, `PAD_DOWN`, `PAD_LEFT`, `PAD_RIGHT`.

### Projects

- **hello_world** — minimal reference: iNES header, PPU init, rendering "HELLO WORLD" with a custom tile set.
- **cgp_simple_game** — fuller framework following *Classic Game Programming on the NES*: NMI handler, palette management, OAM, gamepad input, sprite physics demo.
- **nes_asm** — 6502 instruction and idiom cheat sheet. No graphics; pure CPU code split across `01_load_store.s` through `09_idioms.s`, all `.include`d from `main.s`. Load in fceux debugger and step through each group. Uses CHR RAM (CHR bank count = 0 in header) so no `.chr` file is needed.

### Hardware register constants (defined at top of each `main.s`)

PPU: `PPUCTRL` $2000, `PPUMASK` $2001, `PPUSTATUS` $2002, `PPUADDR` $2006, `PPUDATA` $2007  
APU/DMA: `SPRITE_DMA` $4014, `APUSTATUS` $4015  
Input: `JOYPAD1` $4016, `JOYPAD2` $4017
