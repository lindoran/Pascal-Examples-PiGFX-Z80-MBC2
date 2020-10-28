program inkeytes;
{this is a simple program that outputs the value and character pressed,
 press space to exit }

{$I bgraph4.pas}
var
 a : integer;

begin
 repeat
  repeat;
   a := inkey;
  until(a > 0);
  writeln(a,' ',chr(a));
 until(a = 32);
end.