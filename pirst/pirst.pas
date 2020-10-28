program pirst;

(* this resets pigfx terminal to text mode *)

const

esc = ^['[';

begin
writeln(esc,'=3h');
writeln(esc,'=0m');
writeln(esc,'m');
writeln(esc,'?25h');
writeln(esc,'2J');
end.


