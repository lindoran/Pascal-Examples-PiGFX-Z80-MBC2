program gametest;
{$I joystick.pas} {global variables (btnval:byte)}
{$I Sound.pas}
{$I graph4.pas} {see graphics.pas for constants}

const
dbdelay = 1;

var
menuchoice : integer;
menu,er : integer;
endout : boolean;

procedure GraphicsTest;
Var
 x,y : integer;
 color : byte;
Begin
GFXSetColorBG(0,1);

y := 0;
x := 0;
for color := 0 to 15 do
 Begin
 GFXSetColorFG(color,1);
 GFXDrawRectangle(x,y,40,200,1);
 x := x+40;
End;
x := 0;
y := 200;
for color := 0 to 127 do
 Begin
 GFXSetColorFG(color,1);
 GFXDrawRectangle(x,y,5,5,1);
 x := x+5;
 end;
x := 0;
y := 205;
for color := 128 to 255 do
 begin
 GFXSetColorFG(color,1);
 GFXDrawRectangle(x,y,5,5,1);
 x := x+5;
 end;
Writeln(esc,15,';',35,'H','<any key to continue>');
repeat;
until (inkey > 0);
inkey := 0;
end;

procedure LowResLinesDemo;
var
 x1,y1,x2,y2,color,count :integer;

begin
SetModeGFX(20,0,1);
write(esc,'1;1HLow Resoluton XOR drawing test');
repeat
 color := random(255);
 x1 := random(320);
 y1 := random(240);
 x2 := random(320);
 y2 := random(240);
 GFXSetColorFG(color,1);
 GFXDrawLine(x1,y1,x2,y2);
until(inkey > 0);
inkey := 0;
end;

procedure SoundTest;
begin
 tone(16,50);
 delay(100);
 tone(13,50);
 delay(100);
 tone(10,50);
 delay(100);
 tone(7,50);
 delay(100);
 tone(4,50);
 delay(100);
 tone(1,50);
end;

procedure JoystickTest;

var
 clearstick : boolean; {stick should be cleared}
 loopexit : integer;
 lstick : integer; {last stick}

Begin
lstick := 0;
repeat
repeat
  if GetJoy = lstick then clearstick := false else clearstick := true;
  if clearstick = true then
   begin
    GFXSetColorFG(9,1);
    GFXDrawCircle(195,224,11,1);
    GFXSetColorFG(0,1);
    GFXDrawTriangle(130,366,128,364,132,364);
    GFXDrawTriangle(54,290,56,288,56,292);
    GFXDrawTriangle(206,290,203,288,203,292);
    GFXDrawTriangle(130,214,128,216,132,216);
    clearstick := false;
    lstick := 0;
   end;
   loopexit := inkey;
 until ((getjoy > 0) or (loopexit = 3));
 case getjoy of
  32 : {Fire Button pressed}
   Begin
    GFXSetColorFG(8,1);
    GFXDrawCircle(195,224,11,1);
    lstick := 32;
   end;
  16 : {Up Button Pressed}
   Begin
    GFXSetColorFG(15,1);
    GFXDrawTriangle(130,214,128,216,132,216);
    lstick := 16;
   end;
  8 : {Down Button Pressed}
   Begin
    GFXSetColorFG(15,1);
    GFXDrawTriangle(130,366,128,364,132,364);
    lstick := 8;
   end;
  4 : {Left Button Pressed}
   Begin
    GFXSetColorFG(15,1);
    GFXDrawTriangle(54,290,56,288,56,292);
    lstick := 4;
   end;
  2: {Right Button Pressed}
   Begin
    GFXSetColorFG(15,1);
    GFXDrawTriangle(206,290,203,288,203,292);
    lstick := 2;
   end;
 end;
 delay(dbdelay);
until (loopexit = 3); {if user presses ctrl-c then exit}
GFXSetColorFG(9,1);
GFXDrawCircle(195,224,11,1);
end;

procedure menuload;
begin
SetModeGFX(18,2,0);
GFXSetColorBG(12,1);
{draw the rough joystick outline}
 GFXSetColorFG(0,1);
 GFXDrawRectangle(40,200,180,180,1);
 GFXSetColorFG(8,1);
 GFXDrawRectangle(39,199,181,181,0);
 GFXDrawRectangle(38,198,182,182,0);
 GFXSetColorFG(15,1);
 GFXDrawCircle(130,290,60,0);
 GFXDrawCircle(130,290,50,0);
 GFXDrawCircle(130,290,15,1);
 writeln(esc,2,';',6,'H','Gameport / Sound Test',hc);
 GFXDrawLine(40,40,208,40);
 GFXDrawLine(40,41,208,41);
 GFXSetColorFG(0,1);
 GFXDrawCircle(130,290,13,1);
 GFXSetColorFG(9,1);
 GFXDrawCircle(195,224,15,1);
 GFXSetColorFG(8,1);
 GFXDrawCircle(195,224,16,0);
 GFXDrawCircle(195,224,17,0);
 GFXSetColorFG(11,1);
 writeln(esc,7,';',3,'H','For Joystick Test Press Ctrl-C to Exit');

{draw the menu box}
 GFXSetColorFG(0,1);
 GFXDrawRectangle(400,82,220,300,1);
 GFXSetColorFG(15,1);
 GFXDrawRectangle(398,80,222,302,0);
 GFXDrawRectangle(399,81,221,301,0);
 GFXSetColorBG(0,0);
 writeln(esc,5,';',63,'H','Menu:',hc);
 writeln(esc,7,';',52,'H','Enter Choice:');
 writeln(esc,9,';',52,'H','1)Joystick Test.');
 writeln(esc,10,';',52,'H','2)Sound Test.');
 writeln(esc,11,';',52,'H','3)Test Pattern.');
 writeln(esc,13,';',52,'H','Any Other Key Exits!');
 writeln(esc,15,';',52,'H','Status:',sc);
end;

begin
sndsetport;
SetModeGFX(18,2,0);
writeln(esc,4,';',18,'H','Game and Sound Test for Z80-MBC2 PiGFX-Term');
writeln(esc,5,';',29,'H','By D. Collins (C)2020');
writeln(esc,10,';',32,'H','<press any key>');
repeat
until (inkey > 0);
menuload;
repeat
 GFXSetColorFG(15,1);
 GFXSetColorBG(0,0);
 writeln(rc,'Menu');
  menuchoice := 0;
  repeat
   menuchoice := inkey;
  until(menuchoice > 0);

 case (menuchoice) of
   49 :  (* option 1 *)
      Begin
       tone(17,40);
       writeln(rc,'    ');
       writeln(rc,'Joystick');
       JoystickTest;
       GFXSetColorFG(15,1);
      { GFXSetColorBG(0,0);}
       writeln(rc,'        ');
       endout := false;
       tone(17,40);
      end;
    50 : (* option 2 *)
      Begin
       writeln(rc,'    ');
       writeln(rc,'Sound');
       SoundTest;
       writeln(rc,'     ');
       endout := false;
      end;
    51 : (* option 3 *)
      Begin
       tone(20,40);
       GraphicsTest;
       delay(30);
       LowResLinesDemo;
       menuload;
       endout := false;
      end;

 else   (* any other key *)
    begin
     SetModeText;
     endout := true;
    end;
 end;
until (endout = true);
SetModeText;
end.

