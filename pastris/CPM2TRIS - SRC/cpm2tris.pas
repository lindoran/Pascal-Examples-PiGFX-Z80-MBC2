program cpm2tris;
{this is a turbo pascal implimentation of David Murry's Basic Tetris
 you may know him as the 8-bit Guy of youtube fame. You can visit his
 web site for original source code at www.the8bitguy.com.or his exelent
 youtube channel www.youtube.com/user/adric22.  please see pastris.txt
 for more comments they were getting large

 this version SHOULD run on non MBC2 CP/M implimentations it has been
 designed to work with keyboard only / no sound but still requires
 PiGFX for Graphics.  If somebody wants to support a more standard
 version of time.pas for something like the Z80CTC or some other tick
 source; I do not have access to the hardware at present so can not.
 as such i've implimented a psudo timer which uses looping to acomplish
 this. This will also run on unmodified stock Z80MBC2, without the timer
 hack}

{$V-}

{$I gbcus.inc}
{$I faketime.inc}
{$I tpdata.inc}
{$I inp.inc }

type
 scoretype = string[8];
 inittype = string[3];
 LevType = array[0..10] of integer;
 ITType = array[2..90] of integer;

const
 (*difficulty*)
 level : LevType = (0,500,450,400,350,300,250,200,150,100,50);

 (* converters ordinal ascii value to a case statement input value *)
 inputtbl : ITType = (2,0,1,0,0,0,3,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,
                      0,0,0,5,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,
                      2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,4,0,0,3);
var
 GRID : array [0..10, 0..20]  of integer;
 scores : array [1..5] of scoretype;
 PIECEX, PIECEY : array [1..4] of integer;
 L,lev,S,ROT,X,Y,XT,YT,CY,P,T2 : integer;
 PC,PP,lastjoy : byte;
 temp,failout,startloop,db : boolean;
 tstamp : real;

(*overlay area 1 *)
  { write the scores to the file }
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

(*load the bitmaps from disk to the interface; without holding in RAM*)
overlay procedure definesprites;
var
 FilVar : text;
begin
 Assign(FilVar,'bitmaps.txt');
 reset(FilVar);
 while not Eof(FilVar) do
  begin
   readln(FilVar,statement);
   piout(statement);
  end;
 close(FilVar);
end;

{ drop a letter input widget any place on the screen }
overlay function rollletters(x,y :integer) : inittype;
var
 letter, rcount, userin, qq :integer;
 nextl : boolean;
 outstr : inittype;
 extinp : string[4];
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
     extinp := '';
     userin := inkey;
     if userin = 27 then
      begin
       for qq := 1 to 4 do extinp := extinp + chr(inkey);
       for qq := 1 to 16 do if pos(extMap[qq],extinp) = 1 then userin := qq;
      end;
     if userin > 90 then userin := userin - 32;
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
              end;
     end;
    end;
  end;
   rollletters := outstr;
end;
(* end overlay area 1 *)

(*output ms from last tstamp*)
function timer : real;
begin
 timer := QDtimer - tstamp;
end;

(* overlay two area *)
  {show all the scores}
overlay procedure showscores;
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
overlay procedure updatescores(rec : integer);
var
 inits : string[3];
 scstr: string[5];
 cnt  : integer;
begin
 GFXSetColorBG(1,1);
 inits := '';
 Inkey := 0;
 bprint(60,32,'High Score Enter Initals:');
 bprint(44,64,'press L/R = CHANGE Space/UP = NEXT');
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

{ send tetromino sqares to the interface}
procedure drawsquare(x,y,color :integer);
begin
 statement := esc + '#' + NumStr(color) + ';' + NumStr(x) + ';' + NumStr(y) + 'd';
 piout(statement);
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
   GFXSetColorFG(0,1);
   GFXDrawRectangle(182,102,31,17,1);
 end;
end;

(* overlays 3 *)
overlay procedure startscreen;
var
 err : integer;
 T1 : byte;
begin
 for X := 0 to 9 do for Y := 0 to 19 do GRID[X][Y] := 0;
 L := 0; {lines variable reset}
 S := 0; {score variable reset}
 GFXSetColorBG(1,1);
 GFXSetColorFG(7,1); { this only applies to gfx primitives }
 bprint(15,30,'Welcome To');
 bprint(15,40,'PiGFX/CPM 2+ PASTRIS');
 bprint(15,50,'Ported by D. Collins');
 bprint(15,90,'Select level difficulty');
 bprint(15,100,'between 1-10[0] default is 2');
 bprint(15,110,'10 is Ridiculous!');
 bprint(15,160,'Based on David Murray''s Basic Tetris');
 bprint(15,170,'For the Color Maximite Computer');
 GFXDrawRectangle(10,21,300,179,0);
 T2 :=0;
 RTCZeroCounter;
 While T2 = 0 do
  begin
   TimeMoves;
   T1 := inkey;
   if T1 > 90 then T1 := T1 - 32; {checks for lowercase, if so it upcases}
   if T1 = 27 then
     begin
      SetModeText;
      bios(0);
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
      TimeMoves;
     until(inkey > 0);
     exit;
    end;
 end;
 startloop := true;
end;

overlay procedure setupscreen;
var
 levstr : String[2];
begin
 bprint(9,3,'PiGFX/CPM 2+ Pastris Port by D.Collins');
 bprint(12,24,'Arrow');
 bprint(181,24,'NEXT');
 mprint(0,4,'  Keys');
 mprint(0,5,'  Move');
 bprint(12,56,'SPC/UP');
 mprint(0,8,' to Flip');
 mprint(0,9,' Z Drops');
 bprint(170,190,'ESC to');
 bprint(170,200,'PAUSE/EXIT');
 bprint(179,90,'LINES');
 bprint(179,140,'SCORE');
 bprint(3,190,'WASD ALT');
 bprint(3,200,'CONTROLS');
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

(*end overlay 3*)
procedure gameoverman;
var
 E : byte;
begin
 temp := true;
 E := 0;
 mprint(29,6,'GAME OVER');
 mprint(29,7,'---------');
 mprint(30,9,'ANOTHER');
 mprint(29,10,'GAME Y/N?');
 while E = 0 do
  begin
   E := inkey;
   IF E > 90 then E := E - 32;
   case E of
      89 : begin
            {new game Y is pressed}
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
      else E := 0;
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
 YY : integer;
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
end;
               {checking for lines or top runover}
procedure checkgrid;
var
 ROW : integer;
begin
 for CY := 0 to 19 do
  begin
   ROW := 0;
   For X := 0 to 9 do if GRID[X][CY] <> 0 then ROW := ROW + 1;
   IF ROW = 10 then dropgrid;
   if (CY = 0) and (ROW > 0) then gameoverman;
  end;
end;
              {previe new piece}
procedure preview;
begin;
 if temp = true then exit;
 GFXSetColorFG(0,1);
 GFXDrawRectangle(182,36,27,41,1);
 PP := random(7)+1;
 for P := 1 to 4 do
  begin
   PIECEX[P] := PIECEXC[PP][P];
   PIECEY[P] := PIECEYC[PP][P];
   drawsquare((PIECEX[P]*9+77)+70,(PIECEY[P]*10+22)+15,PP);
  end;
end;
              {get a new peice to the playfield}
procedure newpiece;
begin
 if temp = true then exit;
 checkgrid;
 ROT := 1;
 PC := PP;
 preview;
 for P :=  1 to 4 do
  begin
   PIECEX[P] := PIECEXC[PC][P];
   PIECEY[P] := PIECEYC[PC][P];
  end;
end;
            {pause or quit}
procedure endsub;
var
 E : byte;
begin
 if temp = true then exit;
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
if temp = true then exit;
For P := 1 to 4 do
 begin
  GRID[PIECEX[P]][PIECEY[P]] := PC;
  drawsquare((PIECEX[P]*9)+70,(PIECEY[P]*10)+15,PC);
 end;
end;
         {erase a piece from the playfield}
procedure erasepiece;
begin
if temp = true then exit;
For P := 1 to 4 do
 begin
  GRID[PIECEX[P]][PIECEY[P]] := 0;
  drawsquare(PIECEX[P]*9+70,PIECEY[P]*10+15,0);
 end;
end;
        {pice moves down}
procedure movedown;
begin
 if temp = true then exit;
 erasepiece;
 For P := 1 to 4 do if PIECEY[P] = 19 then
   begin
    drawpiece;
    newpiece;
    exit;
   end;
For P := 1 to 4 do if GRID[PIECEX[P]][PIECEY[P]+1] <> 0 then
  begin
   drawpiece;
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
   PIECEX[P] := PIECEX[P]+RX[PC][ROT][P];
   PIECEY[P] := PIECEY[P]+RY[PC][ROT][P];
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
   if PIECEX[P]+RX[PC][ROT][P] = -1 then {if it will land past left wall}
    begin
     moveright;
     rotate;
     exit
    end;
  end;
 for P:= 1 to 4 do
  begin
   if PIECEX[P]+RX[PC][ROT][P] = 10 then {if it will land past right wall}
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
 userin,qq : integer;
 extInp : string[4];
begin
  Inkey := 0;
  extInp := '';
  if temp = true then exit;
  userin := Inkey;
  if userin = 27 then
   begin
    for qq := 1 to 4 do extInp := extInp + chr(inkey);
    for qq := 1 to 16 do if pos(extMap[qq],extInp) = 1 then userin := qq;
   end;
  if userin > 90 then userin := userin - 32;
  case inputtbl[userin] of
        1 : moveleft;
        2 : moveright;
        3 : movedown;
        4 : detectwallkick;
        5 : endsub;
   end;
 if timer >= T2 then
   begin
    movedown;
    tstamp := QDtimer + L;
   end;
end;

         {main program loop}
begin
  SetModeGFX(20,0,0);
  GFXLoadMaxPal(7,1,7,0);
  write('loading');
  loadfont(false); (* load bit map font *)
  write('.');
  loadfont(true); (* load alt bit map font *)
  write('.');
  definesprites;
  write('.');
  ZeroAllTime;
  loadscores;
  write('GTG!');
  write(csh);
  failout := false;
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
    repeat
     TimeMoves;
     readkeyboard;
     TimeMoves;
    until(temp = true);
  end;
end.                                                  