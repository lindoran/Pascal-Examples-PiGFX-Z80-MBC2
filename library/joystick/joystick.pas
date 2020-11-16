{This file contains includeable source, and can not be run on its own
(C) 2020 D. Collins, Z-80 Dad - Search Youtube for more.Free to use
without warentee from damage or loss.use at your own risk. this is
designed to work with my game port adapter board the board uses 10k pull
up resistors on each pin corisponding to a switch on the classic 8 bit
controler interface (atari).  this reads the whole port to see what value
is returned.}

{interface in the GitHub is meant to be connected to pins 3-7 on port A 
 for it to work with the hard coded values elseware in the gethub }

const
  {Z80-MBC2 IOS opcodes and port addresses}
  USERKEY_ReadOpcode = 129; {Opcode for 0x081, B-Port on the GPIO}
  STORE_Opcode_Port = 1;
  EXECUTE_ReadOpcode_Port =0;


function GetJoy: byte; {return the value of joystick port}
begin
 port[STORE_Opcode_Port]:= USERKEY_READOpcode; {select B port OPCODE}
 GetJoy := port[EXECUTE_ReadOpcode_Port]; {read entire port, output to func.}
end;
