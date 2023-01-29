{This file contains includeable source, and can not be run on its own
(C) 2020 D. Collins, Z-80 Dad - Search Youtube for more.Free to use
without warentee from damage or loss.use at your own risk. this is
designed to work with my game port adapter board the board uses 10k pull
up resistors on each pin corisponding to a switch on the classic 8 bit
controler interface (atari).  this reads the whole port to see what value
is returned.}

{ JS board should be hooked to port a as so:
 
        _     _ _ _ _ _    _
        |     | | | | |    |
       +5     3 4 5 6 7   Gnd    
        * * * * * * * * * * GPA 
        * * * * * * * * * * GPB 
      VCC 1 2 3 4 5 6 7 8 GND   
       Z80-MBC2 Expansion Port        

For hard coded values to work with this program. }

const
  {Z80-MBC2 IOS opcodes and port addresses}
  USERKEY_ReadOpcode = 129; {Opcode for 0x081, PortA on the GPIO}
  STORE_Opcode_Port = 1;
  EXECUTE_ReadOpcode_Port =0;


function GetJoy: byte; {return the value of joystick port}
begin
 port[STORE_Opcode_Port]:= USERKEY_READOpcode; {Select A port OPCODE}
 GetJoy := port[EXECUTE_ReadOpcode_Port]; {read entire port, output to func.}
end;
