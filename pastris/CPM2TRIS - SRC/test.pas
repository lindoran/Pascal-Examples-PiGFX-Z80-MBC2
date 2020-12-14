program keytest;

{$I gbcus.inc}
{$I inp.inc}

const
 extDef : mapType = ('F1','RT','F2','LF','F3','F4','F5','DN','F6','F7',
                     'F8','F9','HOM','INS','DEL','UP','END','PGUP','PGDN');

        {'[[A','[C','[[B','[D','[[C','[[D','[[E','[B','[17~','[18~','[19~'
         ,'[20~','[1~','[2~','[3~','[A','[4~','[5~','6~'}
var
 k1,k2,k3,k4,k5,a: integer;
 teststring : keytype;

begin
write(csh);
writeln('Keyboard Code Explorer');
writeln('----------------------');
writeln('');
writeln('Press any key (space exits)');
write(sc);
repeat
 repeat
   k1 := inkey;
 until(k1 > 0);
 k2 := inkey;
 k3 := inkey;
 k4 := inkey;
 k5 := inkey;
 write(rc);
 write(esc,'K');
 writeln('main keypress: ',k1,'(',chr(k1),' )');
 teststring := chr(k2) + chr(k3) + chr(k4) + chr(k5);
 for a := 0 to 19 do if pos(extMap[a],teststring) = 1 then
   writeln('Extended Key Code: ',extMap[a],' (',extDef[a],')') else write(esc,'K');
until(k1 = 32);
writeln('Returning to CP/M');
end.
       