{This is an includable file and not designed to run on its own,
(C) 2020 D. Collins Z-80 Dad, search youtube for more.  This is
provided without any warentee from damage or loss. use at your
own risk.  This is designed to work with a YL-44 buzzer module
or its clones.  This will sound a buzzer hooked to pin 1 of Port
B when it is also hooked to ground and +5V of the Z80-MBC2
expansion port}

const
 IODIRB_WriteOpcode = 6; {IO Direction port B OPCODE }
 IODIRB_BuzzerMask  = 127; {select only pin 8 on port B for output}
                          {binary value is 01111111}

 GPIOB_WriteOpcode = 4; {Write OPCODE port B }
 BuzzerPin_PortB = 128; {Pin Selection for buzzer binary value is 1000000}
                       {this will send a high signal to pin 8 of port B  }
                       {when sent with the port command.}


     { Z80-MBC2 Expansion Port }
     {VCC 1 2 3 4 5 6 7 8 GND  }
     {  * * * * * * * * * * GPA}
     {  * * * * * * * * * * GPB}
     {  ^VCC         I/0^ ^GND }


procedure SndSetPort; {you must set the port up first with this code}
begin
 port[1] := IODIRB_WriteOpcode;
 port[0] := IODIRB_BuzzerMask; {masks the port so only pin 8 is set for write}
end;

procedure tone (frq,delaymax :integer);
{produce tone of frq units (this is not hz) each note is 3 apart, half steps
 are 1 or 2 apart This is as fast as I can write the routite without switching to full on
 mechine code. I don't know that this would make a huge difference; basically
 because the pascal library is already loaded.}
var
   I,A : integer;
begin
 for A := 1 to delaymax do
  begin
    port[1] := GPIOB_WriteOpcode;
    port[0] := BuzzerPin_PortB;   {pin 8 is high}
    for I := 1 to frq do inline($00); {NOP loop}
    port[1] := GPIOB_WriteOpcode;
    port[0] := IODIRB_BuzzerMask; {pin 8 is low}
    for I := 1 to frq do inline($00); {NOP loop}
  end;
end;