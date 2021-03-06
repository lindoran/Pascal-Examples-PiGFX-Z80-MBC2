{this is a includeable file, and not a stand alone program.
(C) 2020 D. Collins, Z-80 Dad. Check youtube for detials
this code is provided as is, free to use without warentee
agaist damage or loss.  use at your own risk.  These
procedures make drawing to the screen much simpler with the
PiGFX terminal https://github.com/fbergama/pigfx.  Please
check the extensive documentation for questions useing. look at
graph4.txt to see comments they were getting quite large }

{ this is a bios call only version of the graphics library,
 which should be more compatible with non MBC computers }

{GRAPH V4.75B tiny - removes some primitives and collison detection
 and the bitmaped fonts}
{$V-}

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

startoffset = 32;    {bitmap font of starts at}
startnumoffset = 15; {reduced numbers only character set starts at}
             { these values are to a certain extent hard coded to
               the print statements, which will need to be changed
               to actually move the character sets. the standard set is
               32 - 126, the numbers only set is 15-31 and is reffenced
               useing a pregenerated array defined by setconvtable
               procedure useing both sets leaves you with 18 bitmaps
               for sprites or whatever, useing just the numbers leaves
               112 - at some point i will make the tables work for all
               functions which will allow moveing the sets around }
type
 WorkString = string[255];
 NumString = string[3];

var
 statement : string[255];

function inkey : integer;
begin
 if bios(1) = 255 then inkey := bios(2) else inkey := 0;
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
   bios(3,ord(LineToSend[counter]));
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

{draws a line from x,y 0 to x,y 1}
procedure GFXDrawLine (x0,y0,x1,y1: integer);
begin
  statement := esc + '#' + NumStr(x0) + ';' + NumStr(y0) + ';' + NumStr(x1) + ';' + NumStr(y1) + 'l';
  piout(statement);
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

                                                    