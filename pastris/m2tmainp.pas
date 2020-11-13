program pastris;
{this is a turbo pascal implimentation of David Murry's Basic Tetris
 you may know him as the 8-bit Guy of youtube fame. You can visit his
 web site for original source code at www.the8bitguy.com.or his exelent
 youtube channel www.youtube.com/user/adric22.  please see pastris.txt
 for more comments they were getting large }

{$V-}

{$I gr4cus.inc}
{$I joystick.pas}
{$I sound.pas}
{$I time.pas}

const
 dbdelayfire = 150; (* debounce delays for controler in msec *)
 dbdelaydirec = 60;

 difstart = 500; { starting difficulty}
 difoffset = 50; { this is the offset each difficulty level }

 (* i am 100% certain all of these do not need to be global but lazy *)
type
 scoretype = string[8];
 inittype = string[3];
var
 GRID : array [0..10, 0..20]  of integer;
 rx,ry : array [0..4,0..4] of integer;
 PIECEX, PIECEY : array [0..4] of integer;
 level : array [0..10] of real;
 inputtbl : array [2..90] of byte;
 scores : array [1..5] of scoretype;
 T1,L,lev,S,E,P,PC,PP,ROT,X,Y,XT,YT,YY,CY,ROW,lastjoy : integer;
 temp,failout,sndbit,joybit,startloop,db : boolean;
 T2,tstamp,jcount : real;

procedure setdiftbl;
var
difficulty,dd : integer;
begin
 difficulty := difstart;
 for dd := 1 to 10 do
  begin
   level[dd] := difficulty;
   difficulty := difficulty - difoffset;
  end;
end;
 
   { creates a input lookup so that taking input from the controler
      for movement is more fluid }
procedure setinputtbl;
var
 qq : integer;
begin
 for qq := 2 to 90 do inputtbl[qq] := 0;
 (* joystick map *)
 inputtbl[2] := 2; {right}
 inputtbl[4] := 1; {left}
 inputtbl[8] := 3; {down}
 inputtbl[16] := 4; {up/fire}
 (* keyboard / Joystick shared space *)
 inputtbl[32] := 4; {up/fire/space on keyboard fire on joystick i know right?}
 (* keyboard map *)
 inputtbl[27] := 5; {esc/pause/quit}
 inputtbl[65] := 1; {A / left}
 inputtbl[68] := 2; {D / right}
 inputtbl[78] := 6; {N / sound (noise) toggle}
 inputtbl[83] := 3; {S / down}
 inputtbl[87] := 4; {W / Fire/up}
 inputtbl[90] := 3; {Z / Down}
end;
(*output ms from last tstamp*)
function timer : real;
begin
 timer := QDtimer - tstamp;
end;

{ drop a letter input widget any place on the screen }

function rollletters(x,y :integer) : inittype;
var
 letter, rcount, userin :integer;
 nextl : boolean;
 outstr : inittype;
begin
 outstr := '';
 rollletters := '';
 for rcount := 0 to 2 do
  begin
   nextl := false;
   letter := 65; {A}
   userin := 0;
   bprint(x+rcount*8,y,'A');
   while nextl = false do
    begin
     userin := inkey;
     if userin > 90 then userin := userin - 32;
     if joybit = true then if getjoy > 0 then
      begin
       userin := getjoy;
       if userin > 16 then delay(dbdelayfire+30) else delay(dbdelaydirec+30);
      end;
     case inputtbl[userin] of
          1 : begin
               letter := letter - 1;
               if letter < 65 then letter := 90; {loop to Z}
               bprint(x+rcount*8,y,chr(letter));
              end;
          2 : begin
               letter := letter + 1;
               if letter > 90 then letter := 65; {loop to A}
               bprint(x+rcount*8,y,chr(letter));
              end;
          4 : begin
               outstr := outstr + chr(letter);
               nextl := true;
               if sndbit = true then tone(3,6);
              end;
     end;
    end;
  end;
   rollletters := outstr;
end;

   { load the scores from the save file }
overlay procedure loadscores;
var
 hsfile : text;
 fcount : integer;
begin
 assign(hsfile,'ptscores.txt');
 reset(hsfile);
 for fcount := 1 to 5 do readln(hsfile,scores[fcount]);
 close(hsfile);
end;

  {write the scores to the file}
overlay procedure savescores;
var
 hsfile : text;
 fcount : integer;
begin
 assign(hsfile,'ptscores.txt');
 rewrite(hsfile);
 for fcount := 1 to 5 do writeln(hsfile,scores[fcount]);
 close(hsfile);
end;

  {show all the scores}
procedure showscores;
var
 sccount: integer;
begin
 loadscores;
 GFXSetColorBG(1,1);
 bprint(108,16,'High Scores');
 for sccount := 1 to 5 do
     begin
      mprint(6,4+sccount*2,copy(scores[sccount],1,3));
      mprint(9,4+sccount*2,'..................'+copy(scores[sccount],4,length(scores[sccount])));
     end;
 mprint(12,19,'Press Any Key');
end;
   {if highscore is detected, update}
procedure updatescores(rec : integer);
var
 inits : string[3];
 scstr: string[5];
 cnt  : integer;
begin
 GFXSetColorBG(1,1);
 inits := '';
 inkey := 0;
 bprint(60,32,'High Score Enter Initals:');
 bprint(44,64,'press A/D and space to select');
 bprint(76,72,'or L/R stick and Fire');
 inits := rollletters(148,48);
 str(S,scstr);
 cnt := 5;
 while cnt > rec do
  begin
   scores[cnt] := scores[cnt-1];
   cnt := cnt-1;
  end;
 scores[rec] := inits + scstr;
 savescores;
end;
   {check for highscore}
procedure checkscores;
var
 scount,scint,err : integer;

begin
 loadscores;
 for scount := 1 to 5 do
  begin
    val(copy(scores[scount],4,length(scores[scount])),scint,err);
    if S > scint then
     begin
       updatescores(scount);
       exit;
     end;
  end;
end;

{ play some sounds useing the CPU and Buzzer module }
procedure sndlandpiece;
var
 a:integer;
begin
 for a:=1 to 6 do
  begin
   tone(random(30)+15,random(3)+1);
   tone(random(30)+15,random(3)+1);
   tone(random(30)+15,random(3)+1);
  end;
end;

procedure sndgameover;
var
 a:integer;
begin
 for a := 1 to 5 do
  begin
   tone(12,1);
   tone(3,1);
   tone(15,2);
   tone(4,1);
   tone(12,1);
   tone(2,1);
   tone(15,2);
  end;
end;

procedure sndspinpiece;
var
 a:integer;
begin
 for a := 1 to 3 do
  begin
   tone(1,2);
   tone(15,3);
   tone(23,5);
   tone(1,2);
  end;
end;

procedure snddropgrid;
var
 a:integer;
begin
 for a := 1 to 6 do
  begin
   tone(1,10);
   tone(10,10);
  end;
end;

procedure definepiece1;
begin
  { BLUE J PIECE8}
  PIECEX[1]:=5;PIECEY[1]:=0; {each peice has a define proceadure}
  PIECEX[2]:=5;PIECEY[2]:=1; {this is the shape def.}
  PIECEX[3]:=5;PIECEY[3]:=2;
  PIECEX[4]:=4;PIECEY[4]:=2;
  rx[1][1]:=-1;ry[1][1]:=1;  {this is the rotational data}
  rx[1][2]:=0;ry[1][2]:=0;
  rx[1][3]:=1;ry[1][3]:=-1;
  rx[1][4]:=2;ry[1][4]:=0;
  rx[2][1]:=1;ry[2][1]:=1;
  rx[2][2]:=0;ry[2][2]:=0;
  rx[2][3]:=-1;ry[2][3]:=-1;
  rx[2][4]:=0;ry[2][4]:=-2;
  rx[3][1]:=1;ry[3][1]:=-1;
  rx[3][2]:=0;ry[3][2]:=0;
  rx[3][3]:=-1;ry[3][3]:=1;
  rx[3][4]:=-2;ry[3][4]:=0;
  rx[4][1]:=-1;ry[4][1]:=-1;
  rx[4][2]:=0;ry[4][2]:=0;
  rx[4][3]:=1;ry[4][3]:=1;
  rx[4][4]:=0;ry[4][4]:=2;
end;

procedure definepiece2;
begin
  { GREEN S PIECE }
  PIECEX[1]:=4;PIECEY[1]:=0;
  PIECEX[2]:=4;PIECEY[2]:=1;
  PIECEX[3]:=5;PIECEY[3]:=1;
  PIECEX[4]:=5;PIECEY[4]:=2;
  rx[1][1]:=-1;ry[1][1]:=1;
  rx[1][2]:=0;ry[1][2]:=0;
  rx[1][3]:=-1;ry[1][3]:=-1;
  rx[1][4]:=0;ry[1][4]:=-2;
  rx[2][1]:=1;ry[2][1]:=1;
  rx[2][2]:=0;ry[2][2]:=0;
  rx[2][3]:=-1;ry[2][3]:=1;
  rx[2][4]:=-2;ry[2][4]:=0;
  rx[3][1]:=1;ry[3][1]:=-1;
  rx[3][2]:=0;ry[3][2]:=0;
  rx[3][3]:=1;ry[3][3]:=1;
  rx[3][4]:=0;ry[3][4]:=2;
  rx[4][1]:=-1;ry[4][1]:=-1;
  rx[4][2]:=0;ry[4][2]:=0;
  rx[4][3]:=1;ry[4][3]:=-1;
  rx[4][4]:=2;ry[4][4]:=0;
end;

procedure definepiece3;
begin
  { CYAN L PIECE }
  PIECEX[1]:=4;PIECEY[1]:=0;
  PIECEX[2]:=4;PIECEY[2]:=1;
  PIECEX[3]:=4;PIECEY[3]:=2;
  PIECEX[4]:=5;PIECEY[4]:=2;
  rx[1][1]:=-1;ry[1][1]:=1;
  rx[1][2]:=0;ry[1][2]:=0;
  rx[1][3]:=1;ry[1][3]:=-1;
  rx[1][4]:=0;ry[1][4]:=-2;
  rx[2][1]:=1;ry[2][1]:=1;
  rx[2][2]:=0;ry[2][2]:=0;
  rx[2][3]:=-1;ry[2][3]:=-1;
  rx[2][4]:=-2;ry[2][4]:=0;
  rx[3][1]:=1;ry[3][1]:=-1;
  rx[3][2]:=0;ry[3][2]:=0;
  rx[3][3]:=-1;ry[3][3]:=1;
  rx[3][4]:=0;ry[3][4]:=2;
  rx[4][1]:=-1;ry[4][1]:=-1;
  rx[4][2]:=0;ry[4][2]:=0;
  rx[4][3]:=1;ry[4][3]:=1;
  rx[4][4]:=2;ry[4][4]:=0;
end;

procedure definepiece4;
begin
  {RED Z PIECE}
  PIECEX[1]:=5;PIECEY[1]:=0;
  PIECEX[2]:=5;PIECEY[2]:=1;
  PIECEX[3]:=4;PIECEY[3]:=1;
  PIECEX[4]:=4;PIECEY[4]:=2;
  rx[1][1]:=-1;ry[1][1]:=1;
  rx[1][2]:=0;ry[1][2]:=0;
  rx[1][3]:=1;ry[1][3]:=1;
  rx[1][4]:=2;ry[1][4]:=0;
  rx[2][1]:=1;ry[2][1]:=-1;
  rx[2][2]:=0;ry[2][2]:=0;
  rx[2][3]:=-1;ry[2][3]:=-1;
  rx[2][4]:=-2;ry[2][4]:=0;
  rx[3][1]:=-1;ry[3][1]:=1;
  rx[3][2]:=0;ry[3][2]:=0;
  rx[3][3]:=1;ry[3][3]:=1;
  rx[3][4]:=2;ry[3][4]:=0;
  rx[4][1]:=1;ry[4][1]:=-1;
  rx[4][2]:=0;ry[4][2]:=0;
  rx[4][3]:=-1;ry[4][3]:=-1;
  rx[4][4]:=-2;ry[4][4]:=0;
end;

procedure definepiece5;
begin
  {PURPLE T PIECE}
  PIECEX[1]:=5;PIECEY[1]:=0;
  PIECEX[2]:=4;PIECEY[2]:=1;
  PIECEX[3]:=5;PIECEY[3]:=1;
  PIECEX[4]:=6;PIECEY[4]:=1;
  rx[1][1]:=-1;ry[1][1]:=1;
  rx[1][2]:=1;ry[1][2]:=1;
  rx[1][3]:=0;ry[1][3]:=0;
  rx[1][4]:=-1;ry[1][4]:=-1;
  rx[2][1]:=1;ry[2][1]:=1;
  rx[2][2]:=1;ry[2][2]:=-1;
  rx[2][3]:=0;ry[2][3]:=0;
  rx[2][4]:=-1;ry[2][4]:=1;
  rx[3][1]:=1;ry[3][1]:=-1;
  rx[3][2]:=-1;ry[3][2]:=-1;
  rx[3][3]:=0;ry[3][3]:=0;
  rx[3][4]:=1;ry[3][4]:=1;
  rx[4][1]:=-1;ry[4][1]:=-1;
  rx[4][2]:=-1;ry[4][2]:=1;
  rx[4][3]:=0;ry[4][3]:=0;
  rx[4][4]:=1;ry[4][4]:=-1;
end;

procedure definepiece6;
begin
  {YELLOW O PIECE}
  PIECEX[1]:=4;PIECEY[1]:=0;
  PIECEX[2]:=5;PIECEY[2]:=0;
  PIECEX[3]:=4;PIECEY[3]:=1;
  PIECEX[4]:=5;PIECEY[4]:=1;
  rx[1][1]:=0;ry[1][1]:=0;
  rx[1][2]:=0;ry[1][2]:=0;
  rx[1][3]:=0;ry[1][3]:=0;
  rx[1][4]:=0;ry[1][4]:=0;
  rx[2][1]:=0;ry[2][1]:=0;
  rx[2][2]:=0;ry[2][2]:=0;
  rx[2][3]:=0;ry[2][3]:=0;
  rx[2][4]:=0;ry[2][4]:=0;
  rx[3][1]:=0;ry[3][1]:=0;
  rx[3][2]:=0;ry[3][2]:=0;
  rx[3][3]:=0;ry[3][3]:=0;
  rx[3][4]:=0;ry[3][4]:=0;
  rx[4][1]:=0;ry[4][1]:=0;
  rx[4][2]:=0;ry[4][2]:=0;
  rx[4][3]:=0;ry[4][3]:=0;
  rx[4][4]:=0;ry[4][4]:=0;
end;

procedure definepiece7;
begin
  {WHITE I PIECE}
  PIECEX[1]:=5;PIECEY[1]:=0;
  PIECEX[2]:=5;PIECEY[2]:=1;
  PIECEX[3]:=5;PIECEY[3]:=2;
  PIECEX[4]:=5;PIECEY[4]:=3;
  rx[1][1]:=-1;ry[1][1]:=1;
  rx[1][2]:=0;ry[1][2]:=0;
  rx[1][3]:=1;ry[1][3]:=-1;
  rx[1][4]:=2;ry[1][4]:=-2;
  rx[2][1]:=1;ry[2][1]:=-1;
  rx[2][2]:=0;ry[2][2]:=0;
  rx[2][3]:=-1;ry[2][3]:=1;
  rx[2][4]:=-2;ry[2][4]:=2;
  rx[3][1]:=-1;ry[3][1]:=1;
  rx[3][2]:=0;ry[3][2]:=0;
  rx[3][3]:=1;ry[3][3]:=-1;
  rx[3][4]:=2;ry[3][4]:=-2;
  rx[4][1]:=1;ry[4][1]:=-1;
  rx[4][2]:=0;ry[4][2]:=0;
  rx[4][3]:=-1;ry[4][3]:=1;
  rx[4][4]:=-2;Ry[4][4]:=2;
end;


{ send tetromino sqares to the interface}
procedure drawsquare(x,y,color :integer);
begin
 statement := esc + '#' + NumStr(color) + ';' + NumStr(x) + ';' + NumStr(y) + 'd';
 piout(statement);
end;

overlay procedure togglebits;
begin
 if sndbit = true then bprint(15,130,'(*)') else bprint(15,130,'( )');
 if joybit = true then bprint(15,140,'(*)') else bprint(15,140,'( )');
end;

procedure startscreen;
var
err : integer;
begin
 for X := 0 to 9 do  {reset positition grid}
  begin
   for Y := 0 to 19 do
    begin
     GRID[X][Y] := 0;
    end;
  end;
 
 L := 0; {lines variable reset}
 S := 0; {score variable reset}
 GFXSetColorBG(1,1);
 GFXSetColorFG(7,1); { this only applies to gfx primitives }
 bprint(15,30,'Welcome To');
 bprint(15,40,'PiGFX/Z80-MBC2 PASTRIS');
 bprint(15,50,'Ported by D. Collins');
 bprint(15,90,'Select level difficulty');
 bprint(15,100,'between 1-10[0] default is 2');
 bprint(15,110,'10 is Ridiculous!');
 bprint(15,130,'( ) Sound On (Press S)');
 bprint(15,140,'( ) Joystick (Press J)');
 bprint(15,160,'Based on David Murray''s Basic Tetris');
 bprint(15,170,'For the Color Maximite Computer');
 togglebits;
 GFXDrawRectangle(10,21,300,179,0);
 T2 :=0;
 RTCZeroCounter;
 While T2 = 0 do
  begin
   T1 := inkey;
   if T1 > 90 then T1 := T1 - 32; {checks for lowercase, if so it upcases}
   case T1 of
    83 : begin     {S Key}
          T1 := 0;
          if sndbit = true then
            begin
             sndbit := false;
             togglebits;
            end
          else
            begin
             sndbit := true;
             togglebits;
             SndSetPort;
             tone(3,6);
            end;
         end;
    74 : begin    {J key}
          T1 := 0;
          if joybit = true then
           begin
            joybit := false;
            togglebits;
           end
          else
           begin
            joybit := true;
            togglebits;
           end;
         end;
     27 : begin { esc }
           SetModeText;
           bios(0);
          end;
   end;
   if T1 = 0 then lev := 0 else val(chr(T1),lev,err);
   if T1 = 48 then lev := 10;
   T2 := level[lev];
   if RTCCounter = 10 then
    begin
     showscores;
     RTCZeroCounter;
     inkey := 0;
     repeat
      if RTCCounter = 10 then exit;
     until(inkey > 0);
     exit;
    end;
 end;
 startloop := true;
end;

       {checks to see if we need to level up?}
procedure checklevelup;
begin
 if L = 20 then
  begin
   L := 0;
   lev := lev + 1;
   if lev > 10 then lev := 10;
   T2 := level[lev];
   T1 := T1 + 1;
   GFXSetColorFG(0,1);
   GFXDrawRectangle(182,102,31,17,1);
 end;
end;

procedure setupscreen;
var
 levstr : String[2];
begin
 bprint(1,3,'PiGFX/Z80-MBC2 Pastris Port by D.Collins');
 mprint(0,3,'  WASD');
 bprint(181,24,'NEXT');
 mprint(0,4,'  Keys');
 mprint(0,5,'  Move');
 mprint(0,7,' W/Space');
 mprint(0,8,' to Flip');
 mprint(0,9,' Z Drops');
 bprint(170,190,'ESC to');
 bprint(170,200,'PAUSE/EXIT');
 bprint(179,90,'LINES');
 bprint(179,140,'SCORE');
 bprint(15,90,'LEVEL');
 bprint(4,221,'Based on David Murry''s Basic tetris for');
 bprint(4,230,'  The Color Maximite Computer and C64');
 GFXSetColorFG(7,1);
 GFXDrawRectangle(181,35,29,43,0);
 GFXDrawRectangle(68,13,92,202,0);
 GFXDrawRectangle(181,101,33,19,0);
 GFXDrawRectangle(181,151,33,19,0);
 GFXDrawRectangle(16,101,33,19,0);
 GFXSetColorFG(0,1);
 GFXDrawRectangle(69,14,90,200,1);
 {GFXSetColorFG(1,1);}
 GFXDrawRectangle(182,102,31,17,1);
 GFXDrawRectangle(182,152,31,17,1);
 GFXDrawRectangle(17,102,31,17,1);
 bprint2(182,107,NumStr(L));
 bprint2(182,157,NumStr(S));
 if lev < 10 then levstr := '0'+NumStr(lev) else levstr := NumStr(lev);
 bprint2(27,107,levstr);
end;

procedure gameoverman;
begin
 E := 0;
 mprint(29,6,'GAME OVER');
 mprint(29,7,'---------');
 mprint(30,9,'ANOTHER');
 mprint(29,10,'GAME Y/N?');
 while E = 0 do
  begin
   E := inkey;
   IF E > 90 then E := E - 32;
   IF E = 27 then E := 78;
   case E of
      89 : begin
            temp := true; {new game Y is pressed}
            checkscores;
            showscores;
            inkey := 0;
            repeat until(inkey > 0);
           end;
      78 : begin
            mprint(29,12,'THANK YOU!'); {quit to CP/M}
            delay(500);
            checkscores;
            showscores;
            inkey := 0;
            repeat until(inkey > 0);
            SetModeText;
            bios(0);
           end;
   end;
  end;
end;
                {clear the playfield}
procedure clearscreengrid;
begin
 GFXSetColorFG(0,1);
 GFXDrawRectangle(69,14,90,200,1);
end;
                 {re-draw the whole playfield}
procedure redrawscreengrid;
begin
 For Y := 0 to 19 do For X := 0 to 9 do
    begin
     XT := X*9;
     YT := Y*10;
     drawsquare(XT+70,YT+15,GRID[X][Y]);
    end;
end;
                 {line is made, drop the grid 1 line}
procedure dropgrid;
var
 levstr : string[2];
begin
 for X := 0 to 9 do for YY := CY downto 1 do GRID[X][YY] := GRID[X][YY-1];
 L := L + 1;
 checklevelup;
 S := S + lev*2;
 bprint2(182,107,NumStr(L));
 bprint2(182,157,NumStr(S));
 if lev < 10 then levstr := '0'+NumStr(lev) else levstr := NumStr(lev);
 bprint2(27,107,levstr);
 clearscreengrid;
 redrawscreengrid;
 if sndbit = true then snddropgrid;
end;
               {checking for lines or top runover}
procedure checkgrid;
begin
 for CY := 0 to 19 do
  begin
   ROW := 0;
   For X := 0 to 9 do if GRID[X][CY] <> 0 then ROW := ROW + 1;
   IF ROW = 10 then dropgrid;
   if (CY = 0) and (ROW > 0) then
    begin
      if sndbit = true then sndgameover;
      gameoverman;
    end;
  end;
end;
              {previe new piece}
procedure preview;
begin;
GFXSetColorFG(0,1);
GFXDrawRectangle(182,36,27,41,1);
PP := random(7)+1;
case PP of
         1: definepiece1;
         2: definepiece2;
         3: definepiece3;
         4: definepiece4;
         5: definepiece5;
         6: definepiece6;
         7: definepiece7;
       end;
for P := 1 to 4 do
        begin
         X := PIECEX[P];
         Y := PIECEY[P];
         XT := X*9+77;
         YT := Y*10+22;
         drawsquare(XT+70,YT+15,PP);
        end;
end;
              {get a new peice to the playfield}
procedure newpiece;
begin
 checkgrid;
 ROT := 1;
 PC := PP;
 preview;
 case PC of
           1 : definepiece1;
           2 : definepiece2;
           3 : definepiece3;
           4 : definepiece4;
           5 : definepiece5;
           6 : definepiece6;
           7 : definepiece7;
 end;
end;
            {pause or quit}
procedure endsub;
begin
 mprint(30,2,'QUITING?');
 mprint(30,3,'YOU SURE');
 mprint(30,4,'  Y/N');
 E := 0;
 while E = 0 do
  begin
   E := inkey;
   IF E > 90 then E := E - 32;
   IF E = 27 then E := 78;
   case E of
        89 : begin
              mprint(30,2,'        ');
              mprint(30,3,'        ');
              mprint(30,4,'     ');
              gameoverman;
             end;

        78 : begin
              mprint(30,2,'        ');
              mprint(30,3,'        ');
              mprint(30,4,'     ');
              exit;
             end;
   end;
 end;
end;
             {draws a piece at a position in the playfield}
procedure drawpiece;
begin
For P := 1 to 4 do
 begin
  X := PIECEX[P];
  Y := PIECEY[P];
  GRID[X][Y] := PC;
  XT := X*9;
  YT := Y*10;
  drawsquare(XT+70,YT+15,PC);
 end;
end;
         {erase a piece from the playfield}
procedure erasepiece;
begin
For P := 1 to 4 do
 begin
  X:=PIECEX[P];
  Y:=PIECEY[P];
  GRID[X][Y] := 0;
  drawsquare(X*9+70,Y*10+15,0);
 end;
end;
        {pice moves down}
procedure movedown;
begin
 erasepiece;
 For P := 1 to 4 do if PIECEY[P] = 19 then
   begin
    drawpiece;
    if sndbit = true then sndlandpiece;
    newpiece;
    exit;
   end;
For P := 1 to 4 do if GRID[PIECEX[P]][PIECEY[P]+1] <> 0 then
  begin
   drawpiece;
   if sndbit = true then sndlandpiece;
   newpiece;
   exit;
  end;
 For P := 1 to 4 do PIECEY[P] := PIECEY[P] + 1;
 drawpiece;
 {if A = 90 or 122 then movedown;
 A := 0;}
end;
                   {piece moves left}
procedure moveleft;
begin
 erasepiece;
 For P := 1 to 4 do if PIECEX[P] = 0 Then
  begin
   drawpiece;
   exit;
  end;
 For P := 1 to 4 do if GRID[PIECEX[P]-1][PIECEY[P]] <> 0 then
  begin
   drawpiece;
   exit;
  end;
 For P := 1 to 4 do PIECEX[P] := PIECEX[P] - 1;
 drawpiece;
end;
                  {piece moves right}
procedure moveright;
begin
 erasepiece;
 For P := 1 To 4 do if PIECEX[P] = 9 Then
  begin
   drawpiece;
   exit;
  end;
 For P := 1 to 4 do if GRID[PIECEX[P]+1][PIECEY[P]] <> 0 Then
  begin
   drawpiece;
   exit;
  end;
 For P := 1 to 4 do PIECEX[P] := PIECEX[P]+1;
 drawpiece;
end;
                {move the piece down}
procedure leavepiece;
begin
 movedown;
end;
          {this rotates the piece }
procedure rotate;
begin
 erasepiece;
 For P := 1 to 4 do
  begin
   PIECEX[P] := PIECEX[P]+RX[ROT][P];
   PIECEY[P] := PIECEY[P]+RY[ROT][P];
  end;
 ROT := ROT+1;
 IF ROT = 5 Then ROT := 1;
 drawpiece;
end;
          {this detects a wall kick before rotateing}
procedure detectwallkick;
begin
 for P := 1 to 4 do
  begin
   if PIECEX[P]+RX[ROT][P] = -1 then {if it will land past left wall}
    begin
     moveright;
     rotate;
     exit
    end;
  end;
 for P:= 1 to 4 do
  begin
   if PIECEX[P]+RX[ROT][P] = 10 then {if it will land past right wall}
    begin
     moveleft;
     rotate;
     exit;
    end;
  end;
  rotate; {we made it here, go ahead and rotate!}
end;

             {read input from user}
procedure readkeyboard;
var
 userin,jinp,dbdelay : integer;
begin
  userin := inkey;
  if userin > 90 then userin := userin - 32;
  if joybit = true then
   begin
     jinp := getjoy;
     if jinp = lastjoy then
      begin
       if inputtbl[jinp] = 4 then dbdelay := dbdelayfire else dbdelay := dbdelaydirec;
       if (QDTimer - jcount) < dbdelay then jinp := 0 else jinp := jinp;
      end;
     if jinp = 0 then userin := userin else
     begin
      lastjoy := jinp;
      userin := jinp;
      jcount := QDTimer;
    end;
   end;
   case inputtbl[userin] of
        1 : moveleft;
        2 : moveright;
        3 : movedown;
        4 : begin
             detectwallkick;
             if sndbit = true then sndspinpiece;
            end;
        5 : endsub;
        6 : if sndbit = false then sndbit := true else sndbit := false;
   end;
  if timer >= T2 then
   begin
    movedown;
    tstamp := QDtimer + L;
   end;
end;

         {main program loop}
begin
  level[0] := 0; {this tells the menu to loop if no key is pressed}
  setdiftbl;
  setinputtbl;
  loadscores;
  write(csh);
  failout := false;
  sndbit := false;
  joybit := false;
  while failout = false do  {failout is never set}
   begin
    temp := false;
    startloop := false;
    inkey := 0;
    repeat
     startscreen;
    until(startloop = true);
    statement := csh;
    piout(statement); {clear the screen}
    setupscreen;
    preview;
    newpiece;
    drawpiece;
    tstamp := QDtimer;
    jcount := QDtimer;
    repeat
     readkeyboard;
    until(temp = true);
  end;
end.