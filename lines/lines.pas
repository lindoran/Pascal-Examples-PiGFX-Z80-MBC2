program lines;
{ very simple lines demo - uses only the writeln commend to send the raw
  control codes. note how ^[[H is sent at the end of each sequence; this
  homes the cursor which prevents the terminal or CP/M from scrolling the
  screen up; even though the control codes are invisible they still cause
  the cursor to move.  we can avoid this by interacting directly with the
  CON: device useing CONOUT or a port command to directly write to the
  serial port this was ment to be a basic demo of the process of writeing
  codes to the screen.  also note the 60 ms delay. this was essential to
  allowing the character buffer time to catch up (CP/M is very slow, for
  something like this but it was fast enough for its time>. this can also
  be avoided by interacting directly with CONIN or C_RAWIO where E=E0FF on
  certain versions of CP/M, or again getting input directly via reading a
  port on the Z80. }


var

   color : integer;
   x1 : integer;
   y1 : integer;
   x2 : integer;
   y2 : integer;

begin
  writeln(chr(27),'[2J');
  writeln(chr(27),'[?25l');

  repeat

    color := random(255);
    x1 := random(640);
    y1 := random(480);
    x2 := random(640);
    y2 := random(480);
    writeln(chr(27),'[38;5;',color,'m',chr(27),'[H');
    writeln(chr(27),'[#',x1,';',y1,';',x2,';',y2,'l',chr(27),'[H');
    delay(60);
 until keypressed;
 writeln(chr(27),'[2J');
 writeln(chr(27),'[?25h');
 writeln(chr(27),'[38;5;255m');
end.