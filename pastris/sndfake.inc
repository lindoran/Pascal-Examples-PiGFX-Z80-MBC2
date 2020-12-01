{This is an includable file and not designed to run on its own,
(C) 2020 D. Collins Z-80 Dad, search youtube for more.  This is
provided without any warentee from damage or loss. use at your
own risk.  This is designed to work with a YL-44 buzzer module
or its clones.  This will sound a buzzer hooked to pin 1 of Port
B when it is also hooked to ground and +5V of the Z80-MBC2
expansion port}

(* this is a fake sound include that nulls the output to any sound call *)

procedure SndSetPort; {you must set the port up first with this code}
var
 sndport : boolean;
begin
 sndport := true;
end;

procedure tone (lpde,delaymax :integer);
var
 tonebit : boolean;
begin
 tonebit := true;
end;