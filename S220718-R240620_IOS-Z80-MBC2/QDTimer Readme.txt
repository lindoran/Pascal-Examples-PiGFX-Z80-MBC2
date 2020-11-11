This is custom firmware for the Z80MBC2.  This will push forward a ms timer under
a custom opcode at 0x88.  it is read exactly like the RTC by selecting 0x88, and then
reading the output register for each character of an 11 character string of ascii
then those characters can be converted to number at the host computer.  it is very posible 
i will do this with bit shiftig at a later date as that is more usefull to sombody codeing 
at a much lower level.  I have done it this way to make it easyer to deal with under 
turbo pascal as there is a built in function for converting the string into a real number.

please see the Z80-MBC2 project for fuse settings if needed.

https://hackaday.io/project/159973-z80-mbc2-a-4-ics-homebrew-z80-computer