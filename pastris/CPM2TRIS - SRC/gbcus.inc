{this is a includeable file, and not a stand alone program.
(C) 2020 D. Collins, Z-80 Dad. Check youtube for detials
this code is provided as is, free to use without warentee
agaist damage or loss.  use at your own risk.  These
procedures make drawing to the screen much simpler with the
PiGFX terminal https://github.com/fbergama/pigfx.  Please
check the extensive documentation for questions useing. look at
graph4.txt to see comments they were getting quite large }

{GRAPH5 Beta0.05 Small custom graph5 for cpm2tris}
{$V-}
type
  RBGType  = array[0..7] of String[6];
  CTType   = array[32..127] of byte;
  HCTType  = array[48..70] of byte;
  BINType  = array[0..15] of string[4];
  WorkString = string[255];
  NumString = string[3];
  wkstring = string[2];
  outstring = string[8];
  rgbstring = string[6];
  
Const
esc = ^['['; {we use this string a lot so it is expressed as constant}
hc = ^['[H'; {Sends the cursor home}
sc = ^['[s'; {saves the cursor pos}
rc = ^['[u'; {returns the cursor to the previously saved location}
csh = ^['[2J'; {clears the screen and returns the cursor home}
cr = ^['[m'; {reset's color attributes to black on white}
ic = ^['[?25l'; {turn off the cursor}
vc = ^['[?25h'; {turn on the cursor}
bc = ^['[?25b'; {blink the cursor, flip back with vc}

 (*RBG values for the color maximite fonts / pallette*)
RBGDef : RBGType  = ('000000','0000FF','00FF00','00FFFF','FF0000',
                     'FF00FF','FFFF00','FFFFFF');

 (*Conv ASCII Val to sprite loc. for 2nd font: 0-9/A-F/a-f others as 0 *)
convtbl: CTType   = (15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
                     16,17,18,19,20,21,22,23,24,15,15,15,15,15,15,15,25,
                     26,27,28,29,30,15,15,15,15,15,15,15,15,15,15,15,15,
                     15,15,15,15,15,15,15,15,15,15,15,15,15,15,25,26,27,
                     28,29,30,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
                     15,15,15,15,15,15,15,15,15,15,15);

 (* Conv ASCII HEX CHAR to Decimal Value *)
HEXDef: HCTType   = (0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0,0,10,11,12,13,14,15);

 (* Convert HEX character Values to BINARY strings *)
BINDef : BinType  = ('0000','0001','0010','0011','0100','0101','0110','0111',
                     '1000','1001','1010','1011','1100','1101','1110','1111');

 (* informational only, don't change these bprint/mprint expect these loc. *)
startoffset = 32;    {bitmap font of starts at}
startnumoffset = 15; {reduced numbers only character set starts at}

var
 statement : string[255];

{converts 2 character hex string to a 2 byte binary value string}
function hextobin(var hexstring :wkstring)  : outstring;
begin
  (* check for upper case *)
 if ord(hexstring[1]) > 90 then hexstring[1] := chr((ord(hexstring[1]) - 32));
 if ord(hexstring[2]) > 90 then hexstring[2] := chr((ord(hexstring[1]) - 32));
  (* copy binary string values to function to output *)
 hextobin := BINDef[HEXDef[ord(hexstring[1])]] + BINDef[HEXDef[ord(hexstring[2])]];
end;

{A simple function to convert a 3 digit number to a string in line}
function NumStr(Var I:Integer) : NumString;
Var S : NumString;
begin
 str(I,S);
 NumStr := S;
End;

{intertal routine which sends a string directly to the terminal,
has a hard character limit of 255 }
procedure piout(var LineToSend: WorkString);
var
 stlength,counter :integer;
 carval: char;

begin
 for counter := 1 to length(LineToSend) do (* send each character 1 at a time *)
  begin
   bios(3,ord(LineToSend[counter])); {sends character to CP/M BIOS Call CONOUT}
  end;
end;

{test routine to chage palette 0 - default, 1 - VGA(mode 13h), 2 - custom, 3 - C64}
procedure SetPalette(gfxpal: integer);
begin
 statement := esc + '=' + NumStr(gfxpal) + 'p';
 piout(statement);
end;

{set mode to grapics see README_ADD.md in PiGFX repository}
procedure SetModeGFX(gfxmode,fontmode,drawmode: integer);
begin
  statement := esc + '=' + NumStr(gfxmode) + 'h' + esc + '=' + NumStr(fontmode) + 'f';
  statement := statement + esc + NumStr(drawmode) + 'm' + ic;
  piout(statement);
end;

{sets back to default console mode}
procedure SetModeText;
begin
  statement := esc + '=3h' + esc + '=0m' + vc + cr;
  piout(statement);
  SetPalette(0);
end;

{draws a rectangle starting at x,y 0 of w/h}
{fill bit '1' to fill '0' to not fill}
procedure GFXDrawRectangle (x,y,w,h,f :integer);
begin
 case f of

  0 : begin
       statement := esc + '#' + NumStr(x) + ';' + NumStr(y) + ';' + NumStr(w) + ';' + NumStr(h) + 'R';
       piout(statement);
      end;
  1 : begin
       statement := esc + '#' + NumStr(x) + ';' + NumStr(y) + ';' + NumStr(w) + ';' + NumStr(h) + 'r';
       piout(statement);
      end;
 end;
end;


{set forgroud color see:
 https://en.wikipedia.org/wiki/file:Xterm_256color_chart.svg}
{home cursor bit 1 = home 0 = no - this functionality is depreciated but left
 in for compatablility}
procedure GFXSetColorFG(color,cs: integer);
begin
 statement := esc + '38;5;' + NumStr(color) + 'm';
 piout(statement);
end;

{set backgroud color see fg color function for url}
{home and clear bit 1 = clear, 0= no}
procedure GFXSetColorBG(color,cs: integer);
begin
 case cs of
  1 : begin
       statement := esc + '48;5;' + NumStr(color) + 'm' + csh;
       piout(statement);
      end;
  0 : begin
       statement := esc + '48;5;' + NumStr(color) + 'm';
       piout(statement);
      end;
 end;
end;


{load a custom font, false is main font true is alt this is hard coded to maximite palette}
procedure loadfont(altfont:boolean);
var
 FilVar : text;
 line : String[16];
 bytestr : string[2];
 outstr : string[8];
 bit : char;
 I,X,Z,Y: integer;
 FileName: string[14];
begin
   if altfont = false then Filename := '8font.txt' else Filename := '8fontnum.txt';
   Assign(FilVar,FileName);
   Reset(FilVar);
   if altfont = false then Y := startoffset else Y := startnumoffset; {what position to start writeing the 8x8 bit maps}
   X := 1; {hex byte location to begining of string}
   while not Eof(FilVar) do {while its not the end}
   begin
     statement := esc + '#' + NumStr(Y) + ';8;8;16a'; (* start building the bitmap *)
     Readln(FilVar,line);
      for I := 1 to 8 do  {read each line in the character }
      begin
        bytestr := copy(line,X,2); {read 2 binary words of 1 line of the charater}
        outstr := hextobin(bytestr); {output the binary 8 bit byte of the character}
        for Z := 8 downto 1 do  {flip the string, front to back 1 bit at a time}
        begin
         bit := copy(outstr,Z,1);
         if altfont = false then (* build sprite def *)
		  if bit = '0' then statement := statement + '9;' else statement := statement + '8;'
		 else 
		  if bit = '0' then statement := statement + 'B;' else statement := statement + 'A;';
        end;
        X := X + 2;
      end; {end of the character}
	  piout(statement); {send the character to the terminal}
      X := 1; {reset hex byte location for next character}
      Y := Y+1; {incriment character number}
   end; {thats the end of the file!}
   close(filvar);
end;

{load the maximite pallet}
{send color maximite pallette to the pi,+ fg/bg color for bit map font at 8 and 9
respectively. 10 and 11 are the alternitive font fg/bg. Changing while displayed
will change all fonts on screen at the same time.}
Procedure GFXLoadMaxPal(fg,bg,fga,bga :integer);
begin
   statement := esc + '=16;12p000000;0000FF;00FF00;00FFFF;FF0000;FF00FF;FFFF00;';
   statement := statement + 'FFFFFF;' + RBGDef[fg] + ';' + RBGDef[bg] + ';' + RBGDef[fga] + ';';
   statement := statement + RBGDef[bga] + ';';
   piout(statement);
   setpalette(2);
   GFXSetColorFG(7,0); {sets defalult fg to white, as it is different in the Maximite this effects
                        system fonts and graphics primitives}
end;


{ a print statement that is similar to the maximite bitmap mode print
  currently no way to ajust color }
procedure bprint(x,y :integer ; ipstring :WorkString);
var
 i,val : integer;
begin
 for i := 1 to length(ipstring) do
  begin
    val := ord(ipstring[i]);
    statement := esc + '#' +NumStr(val)+ ';' + NumStr(x) + ';' + NumStr(y) + 'd';
    piout(statement);
    x := x + 8;
  end;
end;

{prints with the secondary character set}
procedure bprint2(x,y :integer; ipstring :WorkString);
var
 i,b,val :integer;
begin
 for i := 1 to length(ipstring) do
  begin
   val := convtbl[ord(ipstring[i])];
   statement := esc + '#' +NumStr(val)+ ';' + NumStr(x) + ';' +  NumStr(y) + 'd';
   piout(statement);
   x := x+8;
  end;
end;

{prints useing col and row configureation}
procedure mprint(c,r :integer ; instring:WorkString);
var
 x,y :integer;
begin
 x := c*8;
 y := r*8;
 bprint(x,y,instring);
end;

procedure mprint2(c,r :integer; instring:WorkString);
var
 x,y :integer;
begin
 x := c*8;
 y := r*8;
 bprint2(x,y,instring);
end;                                                                        