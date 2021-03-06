program mandelbrot1;
{First demo of drawing a Mandelbrot Set. This program merely
demonstrates the basics of calculating and plotting.}

{ported to Z80 Turbo Pascal 3.01 with PiGFX calls D.Collins
 original program is written by Andrew Williams original source
 found at https://plus.maths.org/content/computing-mandelbrot-set}


{$I graph4.pas}   (* included custom graphics library for TP *)

{Note to C programmers: the variable type "real" is equivalent
to the C type "float".}

var cx,cy: real; {Where do we want to center the brot?}
    scale: real; {This is the "zoom" factor.}
    limit: integer; {Divergence check value.}
    lp: integer; {Convergence check value.}
    a1,b1,a2,b2: real; {For calculating the iterations.}
    x,y: integer; {The pixel we are drawing.}
    ax,ay: real; {The actual position of (x,y) in relation to
                  the Mandelbrot set.}


begin
    {Set up video mode.}
    SetModeGFX(20,0,0); {switching to MCGA, should be enough space}
    {Set Palette}
    SetPalette(1); { 0 xterm,1 vga,2 custom (uncomment pallet of choice), C64}
   { statement := esc + '=16;16p000000;0000AA;00AA00;00AAAA;AA0000;AA00AA;AA5500;AAAAAA;';
    statement := statement + '555555;5555FF;55FF55;55FFFF;FF5555;FF55FF;FFFF55;FFFFFF;';
    piout(statement);(* CGA / EGA color pallet *) }
   { statement := esc + '=16;16p000000;0000D7;D70000;D700D7;00D700;00D7D7;D7D700;D7D7D7;';
    statement := statement + '000000;0000FF;FF0000;FF00FF;00FF00;00FFFF;FFFF00;FFFFFF;';
    piout(statement); (* ZX Spectrum low / high intensity *) }
   { statement := esc + '=16;4p000000;55FFFF;FF55FF;FFFFFF;';
    piout(statement); (* CGA Mode 4 / Palette 1 high intensity *)}


    {Set up initial values for drawing. Try compiling the program
    with different values here if you like!}
    cx:=0; cy:=0; scale:=0.02;
    limit:=4;

    {Loop through all pixels on screen. For reasons that will become
    clear, I am counting not from (0,0) but from (-160,-100).}
    for x:=-160 to 159 do
      for y:=-120 to 120 do begin
        {What is the *mathematical* value of this point?}
        ax:=cx+x*scale; ay:=cy+y*scale;

        {And now for the magic formula!}
        a1:=ax; b1:=ay; lp:=0;
        repeat
          {Do one iteration.}
          lp:=lp+1;
          a2:=a1*a1-b1*b1+ax;
          b2:=2*a1*b1+ay;
          {This is indeed the square of a+bi, done component-wise.}
          a1:=a2; b1:=b2;
        until (lp>16) or ((a1*a1)+(b1*b1)>limit);
        {The first condition is satisfied if we have convergence.
        The second is satisfied if we have divergence.}

        {Define colour and draw pixel.}
        if lp>16 then lp:=0;
        {If the point converges, it is part of the brot and we
        draw it with colour 0, or black.}
        GFXSetColorFG(lp,1);
        GFXDrawPxl(x+160,y+120);
        if inkey > 0 then    {custom breakpoint to exit to CP/M}
         begin
          SetModeText;
          bios(0);
         end;
      end;

    {Wait for keypress and return to text mode.}
    repeat until(inkey > 0);
    SetModeText;
end.
                                                                                      