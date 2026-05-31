# NES Learning Lab

A collection of NES 6502 assembly projects built with cc65.

## Projects

- `hello_world` — renders "HELLO WORLD" on screen; a working reference example
- `cgp_simple_game` — framework following *Classic Game Programming on the NES*: NMI handler, palette, OAM, gamepad, sprites
- `nes_asm` — 6502 instruction cheat sheet; step through in fceux debugger

## Quickstart

### MacOS

```sh
brew install cc65
```

### Arch Linux

```sh
sudo pacman -S cc65
```

## Build

```sh
make                   # build all projects
make hello_world       # build src/hello_world       → build/hello_world.nes
make cgp_simple_game   # build src/cgp_simple_game   → build/cgp_simple_game.nes
make nes_asm           # build src/nes_asm           → build/nes_asm.nes
make clean             # remove build/
```

To add a new project, create `src/<name>/main.s` and `src/<name>/nes.cfg`, then add `<name>` to `PROJECTS` in the Makefile.

## Running

Open `.nes` files from `build/` in [fceux](https://fceux.com).

## Links

NES Assemblers:
- https://cc65.github.io
- https://github.com/camsaul/nesasm
- https://github.com/parasyte/asm6

Emulators:
- https://fceux.com
