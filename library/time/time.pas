
{RTC Liberary (C) 2020 D. Collins This allows simple use of the RTC in turbo
 pascal. This can be included at compile time.  There are 2 global variables
 due to TP3 not letting you use array type for functions, this does allow the
 timestamps to be stored as array's and used more simply; as you can not use
 the standard port comand as such.  to update the global CurrentTime, simply
 call the RTCGetTime. As is use at own risk, free to use and distribute }

Const
 RTCOpcode = 132;
 minseconds = 60;

Type
 Timestamp = array[0..6] of byte;{seconds,minutes,hours,day,month,year,temp}

var
 CounterStart : Timestamp;
 CurrentTime : Timestamp;

{this gets the time from the Z80MBC2 RTC module}
Procedure RTCGetTime;
var
 a:integer;
begin
 port[1] := RTCOpcode;
 for a := 0 to 6 do CurrentTime[a] := port[0];
end;

{this time stamps the counter function to zero}
procedure RTCZeroCounter;
begin
 RTCGetTime;
 CounterStart := CurrentTime;
end;

{this outputs a number of seconds from the time stamp, it will output 0
 if the counter is left to go over 1 hour, this is to keep the math
 within the type limit for a basic intiger }

function RTCCounter : integer;
var
 timer : Timestamp;
 startsec,seconds : integer;

begin
 seconds := 0;
 startsec := 0;
 RTCGetTime;
 timer := CurrentTime;
 if timer[2] <> CounterStart[2] then
  begin
   RTCZeroCounter;
   RTCCounter := 0; {you will need to account for the counter resetting every hour}
   exit;
  end;
 {calculate start seconds}
 startsec := (CounterStart[1] * minseconds) + CounterStart[0];
 {calculate elapsed seconds}
 seconds := (timer[1] * minseconds) + timer[0];
 RTCCounter := seconds - startsec;
end;