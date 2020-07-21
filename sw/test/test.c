#include <stdio.h>
#include <assert.h>

#include "digitizer.h"

int main(int argc, char* argv[])
{
    unsigned char readData;

    for(unsigned int address = 0; address < 64; ++address)
    {
        for(unsigned int writeData = 0; writeData < 256; ++writeData)
        {
            WriteRegister(address, writeData);
            ReadRegister(address, &readData);
            assert(writeData == readData);
        }
    }
    return 0;
}
