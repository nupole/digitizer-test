#include <stdio.h>
#include <stdlib.h>

#include "digitizer.h"

unsigned char WriteRegister(unsigned char addr, unsigned char data)
{
    unsigned char* inst = malloc(3);
    inst[0] = WRITE;
    inst[1] = addr;
    inst[2] = data;

    FILE* f = fopen("/dev/backplane", "w+");
    fwrite(inst, sizeof(inst[0]), 3, f);
    fclose(f);

    free(inst);

    return 0;
}

unsigned char ReadRegister(unsigned char addr, unsigned char* data)
{
    unsigned char* inst = malloc(2);
    inst[0] = READ;
    inst[1] = addr;

    FILE* f = fopen("/dev/backplane", "w+");
    fwrite(inst, sizeof(inst[0]), 2, f);
    fread(data, sizeof(data[0]), 1, f);
    fclose(f);

    free(inst);

    return 0;
}
