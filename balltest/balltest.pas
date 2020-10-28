program balltest;
{This is a fun little demo that depicts a "ball" sprite bouncing between two
 walls.  we detect a collision useing the collision statement in the graph4 
 library which detects chr 27 (the escape code), and then a for loop 10 steps
 long to read in each character of the control code from the input buffer
 raw data. we can also pull flow control from the user useing the inkey func
 tion from the graph2 include file. this functions exactly as the mbasic com
 and, and outputs a integer value which is the ordinal dec value of the charac
 ter pressed.  We still need about a 1 ms delay to make things run smoothly;
 the inkey funcion because it uses a bdos call, seams to work better than
 pascal's keypressed function, and you get the added value of knowing the key
 that was pressed.  you can also pull in control keycodes as ctrl+key has a
 different ordinal value; so there is a small truth table at the end of the
 program that calls out different functions. there is at times a delay when
 the terminal is pulling in a control code collision from the interface; but
 the key presses are very responsive in spite of this.

 this program is free to use and distribute, but is (C) 2020 david collins.
 it is provided with out warentee of functionality or safety to your equiptment.
 use at your own risk. }

{$I sound.pas}
{$I graph4.pas}


var
loop,lp2,count,kpress : integer;
direct :char;
{outstr :string[255];
stp : string[3]; }

procedure toggle;
begin
  case direct of
     'L': begin
              direct := 'R';
              lp2 := lp2 +1;
             end;
     'R': begin
               direct := 'L';
               lp2 := lp2 +1;
              end;
  end;
end;


begin
SndSetPort;
{outstr := '';
stp := '';}
SetModeGFX(20,0,0);
statement := esc + '#1;4;4;16A9;16;'; {save 'ball' in memory useing DTE, with a Red color}
piout(statement);
statement := esc + '#2;4;20;16AB;80;'; {save 'wall' in memory useing DTE, with yellow color}
piout(statement);
write(esc,'1;11H"Fun" Sprite Demo');
write(esc,'2;8HFor The PiGFX interface');
write(esc,'3;10H(C) 2020 D. Collins');
writeln(esc,'11;1Hcollision detection proof of concept:');
write('The ball is a hardware generated sprite,which sends a collision');
write(' control code to the host computer via a keyboard signal.');
write(esc,'16;1HThe Host computer manages only the      direction the sprite moves.');
writeln(' It sends thedirection to the graphics interface,    also via control codes.');
writeln(' ');
write('Bitmaps for the sprites are stored in   memory on the interface.');
write(' After loaded,  they can be erased from memory on the');
write('   host computer');
loop := 150;     {starting position of ball}
direct := 'R';
lp2 := 0;
statement := esc + '#1;2;100;32s'; {draw the walls}
piout(statement);
statement := esc + '#2;2;200;32s';
piout(statement);
write(esc,'6;2HSprite 1 ->');
write(esc,'6;27H<- Sprite 2');
ColRawStr := '';
ColDataPt1 := 0;
ColDataPt2 := 0;
repeat        {main loop, repeats untill 5 collisons then ends}
 if direct = 'R' then loop := loop + 1 else loop := loop - 1;
 statement := esc + '#0;1;' + NumStr(loop) + ';40s'; (* draw ball*)
 piout(statement);
 delay(1);    (* this delay was needed to 'debounce' the keybuffer *)
 if Collision = true then {calls inkey function to see if the esc character is present in keybuffer}
  begin
   toggle;
   tone(30,10);
   Collision := false;
  end;
 statement := esc + '27;1HOut: ' + ColRawStr + ' Sprite ' + NumStr(ColDataPt1) + ' Col. W/ Sprite ';
 statement := statement + NumStr(ColDataPt2);
 piout(statement);
 statement := esc + '28;1HX-Pos Sprite 0: ' + NumStr(loop);
 piout(statement);
 statement := esc + '29;1HNo. of Collisions: ' + NumStr(lp2) + '/5';
 piout(statement);
 statement := esc + '30;1HDir. Toggle: ' + direct;
 piout(statement);
 statement := esc + '26;1HKey Pressed: ';
 piout(statement);
 delay(1); (* another dbounce to help make sure the charcter buffer is clear *)
 kpress := inkey;
 case  kpress of
  0 : begin
      (* do nothing! *)
      end;
  24 : begin
        lp2 := 5;
        statement := esc + '26;1Hkey Pressed: Break By User (Ctrl-X) ';
        piout(statement);
       end;
  26 : begin
        SetModeText;
        writeln('Exit to CP/M by Ctrl-Z');
        delay(200);
        bios(0); (* exit program on ctrl-Z *)
       end;
  3  : begin
        lp2 := 0;
        statement := esc + '26;1HKey Pressed: Reset Counter by Ctrl-C';
        piout(statement);
       end;
  else
   statement := esc + '26;1HKey Pressed: ' + '                        ';
   piout(statement);
   statement := esc + '26;1HKey Pressed: ' + Chr(kpress) + '(' + NumStr(kpress) + ')';
   piout(statement);
   tone(10,10);
  end;
until(lp2 = 5);
write(esc,'#0x'); {clear the ball sprite from the screen}
write(esc,'9;9H<press any key to end>');
repeat
until(inkey > 0);
SetModeText;
end.