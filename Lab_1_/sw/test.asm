.global entry

.data                  /* data section*/
        .word 0x0001
        .word 0xFFFF   /* result goes here */
.text                  /* code goes to text section*/
.ent entry
entry:
        lw $t0, 0x200         /* t0 = 1*/
        lw $t1, 0x200         /* t1 = 1*/
        add $t0, $t0, 0xB     /* t0 = t0 + 0xB  == 0xC*/
        sub $t0, $t0, $t1     /* t0 = t0 - $t1  == 0xB*/
        or $t0, $t0, 0x10     /* t0 = t0 | 0x10 == 0x1B*/
        xor $t0, $t0, $t1     /* t0 = t0 ^ t1   == 0x1A*/
        slt $t0, $t0, $t1     /* t0 = t0 < t1   == 0*/
        add $t0, $t0, $t1     /* to = t0 + t1   == 1*/
        beq $t0, $t1, entry   /* PC = entry if t0 == t1*/
.end entry
