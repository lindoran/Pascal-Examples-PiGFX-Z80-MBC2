(* minp.inc -- Turbo pascal PiGfX input include for games *)
{ this is my games input include; it contains simple functions for reading
 input from the user; useing the port array to take input from the user or
 eventually collision data from the PiGFX terminal. it is (C)2020 D. Collins
 free for use with absolutely no warentee of quality or functionality. also
 useing this at your own risk. }
 
 {hook the joystick interface like this}  
     {   _     _ _ _ _ _    _  }
     {   |     | | | | |    |  }
     {  +5     3 4 5 6 7   Gnd }   
     {  * * * * * * * * * * GPA}
     {  * * * * * * * * * * GPB}
     {VCC 1 2 3 4 5 6 7 8 GND  }
     { Z80-MBC2 Expansion Port }

type
 keyType = string[4];
 mapType = array[1..19] of keytype;

const
 extMap : maptype = ('[[A','[C','[[B','[D','[[C','[[D','[[E','[B','[17~',
                     '[18~','[19~','[20~','[1~','[2~','[3~','[A','[4~',
                     '[5~','6~');
  (* F1,RT,F2,LF,F3,F4,F5,DN,F6,F7,F8,F9,HOM,INS,DEL,UP,END,PGUP,PGDN *)

{output the ordinal value of key pressed or 0 if no key pressed }

function inkey : integer;
var
 iobyte : integer;
begin
  iobyte := port[1];
  if iobyte = 255 then inkey := 0 else inkey := iobyte;
end;

{slightly slower but it scans the whole usable keyboard
 directional key output matches the joystick, the ordinal
 value outputed by this may overlap ctrl+key combos,
 pay attention to how you handle those interations if you
 choose to use them!}

function extinkey : integer;
var
 extinp : string[4];
 a,uinp : integer;

begin
 extinp := '';
 uinp := inkey;
 if uinp = 27 then
  begin
   for a := 1 to 4 do extinp := extinp + chr(inkey);
   for a := 1 to 19 do if pos(extMap[a],extinp) = 1 then uinp := a;
  end;
  extinkey := uinp;
end;

 (* read the value of PORT A, which will be the joystick interface *)
function GetJoy: integer;
begin
 port[1] := 129; (*read Z80-MBC2 Port A store in register*)
 GetJoy := port[0]; (* save value of Port A to function *)
end;

