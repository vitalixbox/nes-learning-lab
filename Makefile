ASM = ca65
LD  = ld65

PROJECTS = hello_world book

.PHONY: all clean $(PROJECTS)

all: $(PROJECTS)

$(PROJECTS): %: build/%.nes

build/%.nes: build/%/main.o src/%/nes.cfg
	$(LD) -C src/$*/nes.cfg $< -o $@

build/%/main.o: src/%/main.s
	@mkdir -p build/$*
	$(ASM) -o $@ $<

clean:
	rm -rf build
