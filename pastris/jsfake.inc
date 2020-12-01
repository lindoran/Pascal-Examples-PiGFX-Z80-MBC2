{This file contains includeable source, and can not be run on its own
(C) 2020 D. Collins, Z-80 Dad - Search Youtube for more.Free to use
without warentee from damage or loss.use at your own risk. this is
designed to work with my game port adapter board the board uses 10k pull
up resistors on each pin corisponding to a switch on the classic 8 bit
controler interface (atari).  this reads the whole port to see what value
is returned.}

(* this is a fake joystick include to null the output of the joystick *)


function GetJoy: byte; {return a null value for the joystick}
begin
 GetJoy := 0;
end;
