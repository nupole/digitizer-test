#ifndef DIGITIZER_H
#define DIGITIZER_H

#define WRITE 0x01;
#define READ  0x00;

unsigned char WriteRegister(unsigned char addr, unsigned char data);
unsigned char ReadRegister(unsigned char addr, unsigned char* data);

#endif
