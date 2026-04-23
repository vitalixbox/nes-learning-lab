# NES Learning Lab

A collection of NES 6502 assembly projects built with cc65.

## Projects

- `hello_world` — renders "HELLO WORLD" on screen; a working reference example
- `book` — scratch space for code from _Classic Game Programming on the NES_

## Quickstart

### MacOS

```sh
brew install cc65
```

## Build

```sh
make                   # build all projects
make hello_world       # build src/hello_world → build/hello_world.nes
make book              # build src/book        → build/book.nes
make clean             # remove build/
```

To add a new project, create `src/<name>/main.asm` and `src/<name>/nes.cfg`, then add `<name>` to `PROJECTS` in the Makefile.

## Links

NES Assemblers:
- https://cc65.github.io
- https://github.com/camsaul/nesasm
- https://github.com/parasyte/asm6

Emulators:
- https://github.com/SourMesen/Mesen2
