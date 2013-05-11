CFLAGS =	-O2 -Wall -c -s 

GCC_MIPS  = mips-sde-elf-gcc $(CFLAGS)
AS_MIPS   = mips-sde-elf-as
LD_MIPS   = mips-sde-elf-ld
DUMP_MIPS = mips-sde-elf-objdump
COPY_MIPS = mips-sde-elf-objcopy
CONVERT   = cat test.vh | perl -pe 's/([\dA-F]{2})\s+([\dA-F]{2})\s+([\dA-F]{2})\s+([\dA-F]{2})/$$1$$2$$3$$4/g;' > test.rom


LIBS =


all:	
	$(AS_MIPS) -o test.o test.asm
	$(LD_MIPS) -Ttext 0x0 -Tdata 0x200 -eentry -o test.axf test.o
	$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(COPY_MIPS) -O verilog test.axf test.vh
	$(CONVERT)

clean:
	rm -f *.o
