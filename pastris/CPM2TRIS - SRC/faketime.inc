{RTC Liberary (C) 2020 D. Collins This allows simple use of the RTC in turbo
 pascal. This can be included at compile time.  There are 2 global variables
 due to TP3 not letting you use array type for functions, this does allow the
 timestamps to be stored as array's and used more simply; as you can not use
 the standard port comand as such.  to update the global CurrentTime, simply
 call the RTCGetTime. As is use at own risk, free to use and distribute }

(* this is a fake time conter for computers without a time conuter *)

Type
 Timestamp = array[0..6] of byte;{seconds,minutes,hours,day,month,year,temp}
 QDstring = string[11];

var
 CounterStart : Timestamp;
 CurrentTime : Timestamp;
 QDCurrent : QDString;
 fakems : real;
 fakesec,msseccnt : integer;

(* Zeros all time *)
procedure ZeroAllTime;
begin
 fakems := 0;
 fakesec := 0;
 msseccnt := 0;
end;

(*moves time along 1 tick*)
procedure TimeMoves;
begin
 if fakems = 9.9999999999e37 then fakems := 0; (* just incase *)
 fakems := fakems + 1;
 msseccnt := msseccnt + 1;
 if msseccnt = 1000 then
  begin
   msseccnt := 0;
   if fakesec = 32767 then fakesec := 0;
   fakesec := fakesec + 1;
  end;
end;


{get ms}
function qdtimer : real;
begin
 qdtimer := fakems;
end;

{this simulates getting time from the RTC Module it will always output 10s}
Procedure RTCGetTime;
var
 a:integer;
begin
 for a := 0 to 6 do CurrentTime[a] := 10;
end;

{this time stamps the counter function to zero}
procedure RTCZeroCounter;
begin
 fakesec := 0;
 msseccnt := 0;
end;

{this outputs a number of seconds from the fake timer. it will reset at the
 integer boundry of 32767.}

function RTCCounter : integer;
begin
 RTCCounter := fakesec;
end;