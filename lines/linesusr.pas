program linesusr;
{Written by D. Collins -- Z80Dad                                             }
{https://www.youtube.com/channel/UCjZ2WbeE613IUGZslI0kFfw		     }
{(C) 2020 David Collins, Permission given to distribute freely with no       }
{warrentee of quality, or against loss or damages.                           }
{                                                                            }
{This is a demo lines program for the Z80-MBC2 with the PiGFX interface.     }
{This program uses the user button on the Z80-MBC for user input, and        }
{displays random overlaping lines in color until the user button is pressed. }
{the user will note autoscroll must be managed to prevent the display from   }
{automatically scrolling the lines up the screen. this is done by sending    }
{the control code "^[[H" to the PiGFX via standard output, with each         }
{respective line press,  In this way we can control the full screen in a     }
{Psudo bitmaped mode.  The cursur must also be dissabled \ enabled via       }
{sending "^[[?25l" and "^[[?25h" respectively. We Save on string space by    }
{storing the escape sequence to its own 2 byte string.                       }
{Input can be taken off the user keyboard with use of 'keypressed' routine in}
{turbo pascal, however, a delay of almost 60 ms was required to allow for the}
{serial interface to properly transfer the keypress with any reliability.    }
{Takeing keypresses from OPcodes is very fast and                            }
{happens along side the serial terminal interface, in this way we can insert }
{a loop break without slowing the program down to check for keypresses.      }
{in this case we read the whole port 0x81 and use a case table to determine  } 
{program flow control with two tac swtiches wired with 10k pull downs        }

const
  {Z80-MBC2 IOS opcodes and port addresses}
  USERKEY_ReadOpcode = 129; {Opcode for 0x081, B-Port on the GPIO}
  STORE_Opcode_Port = 1;
  EXECUTE_ReadOpcode_Port =0;
  dbdelay = 150;
var
   color : integer;
   x1 : integer;
   y1 : integer;
   x2 : integer;
   y2 : integer;
   EscBr : string[2];
   btnval : integer;

function  userKey: boolean;
{Return TRUE if the User key is currently pressed, FALSE if not}
begin
   userKey:= false;
   port[STORE_Opcode_Port]:= USERKEY_READOpcode; {select B port OPCODE}
   btnval := port[EXECUTE_ReadOpcode_Port]; {read entire port}
   case (btnval) of
     0 : userkey := false;
     32 :  {if fire button is pressed}
       begin
        writeln (EscBr,'2J');
        delay(dbdelay); {wait for switch to bounce}
       end;
     else
       userkey := true; {if a direction is pressed}
   end;
end;

begin
  EscBr := ^[ + '[';
  writeln(EscBr,'2J'); {clear screen and move cursor to text mode 0,0}
  writeln(EscBr,'?25l'); {Shut off Cursor}


  repeat
    color := random(255);
    x1 := random(640);
    y1 := random(480);
    x2 := random(640);
    y2 := random(480);
 {draw a random color line, at a random location, of a random lengh and return to 0,0 to prevent terminal auto scroll}

  writeln(EscBr,'38;5;',color,'m',EscBr,'#',x1,';',y1,';',x2,';',y2,'l',EscBr,'H');
  until (userKey);

  writeln(EscBr,'2J'); {Clean up screen}
  writeln(EscBr,'?25h'); {re-enable cursor}
  writeln(EscBr,'38;5;255m'); {re-set color to white}
  writeln(btnval); {write press value to screen}
end.