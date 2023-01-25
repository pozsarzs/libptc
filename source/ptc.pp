{ +--------------------------------------------------------------------------+ }
{ | Libptc-ptcdll-ptcppu 0.4 * Tools collection                              | }
{ | Copyright (C) 2003-2005 Pozsar Zsolt <pozsarzs@axelero.hu>               | }
{ | ptc.pp                                                                   | }
{ | Source code                                                              | }
{ +--------------------------------------------------------------------------+ }

{
 Colours:
 1: base foreground,			7: header, footer, menu foreground,
 2: base background,			8: header, footer, menu highlighted t.,
 3: message box foreground,		9: header, footer, menu background,
 4: message box background,		10: field-cursor foreground,
 5: error message box foreground,	11: field-cursor highlighted text,
 6: error message box background,	12: field-cursor background.
}

{$IFDEF GO32V2}
  {$DEFINE STATIC}
{$ENDIF}

{$IFDEF STATIC}
unit ptc;
interface
{$ELSE}
library ptc;
{$ENDIF}
uses crt, dos;
type
  itemrec = record
              i1, i2, i3, i4, i5, i6, i7, i8, i9, i10,
              i11, i12, i13, i14, i15, i16, i17, i18, i19, i20: string[50];
  end;
  fitems = array[1..1024] of string[10];
  messagerec = record
               title, message, ok, cancel, foot_message: string;
  end;
var
  colors: array[1..12] of byte;                             {Presetted colours.}
  columns: byte;                                            {Number of columns.}
  lines: byte;                                                {Number of lines.}
  b,bb, bbb: byte;                                               {General byte.}
  c: char;                                                  {General character.}
  i: integer;                                        {General integer variable.}
  s, ss: string;                                               {General string.}
const 
  alet: array[1..20] of string = ('&aacute;','&eacute;','&iacute;','&oacute;',
                                  '&uacute;','&Aacute;','&Eacute;','&Iacute;',
                                  '&Oacute;','&Uacute;','&otilde;','&Otilde;',
                                  '&ucirc;','&Ucirc;','&auml;','&ouml;','&uuml;',
                                  '&Ouml;','&Uuml;','');
                                        {Special strings for acuted characters.}
{$IFDEF LINUX}
  liniso1: string = 'en,da,fi,fr,nl,de,no,it,pt,es,sv';         {Country codes.}
  liniso2: string = 'cs,pl,hu';
  iso88591: array[1..19] of byte = (225,233,237,243,250,193,201,205,211,218,
                                    063,063,
                                    063,063,228,246,252,214,220);   {iso-8859-1}
  iso88592: array[1..19] of byte = (225,233,237,243,250,193,201,205,211,218,
                                    245,213,
                                    251,219,228,246,252,214,220);   {iso-8859-2}
{$ELSE}
  doscp437: string = 'en,nl,de,it,sv';                          {Country codes.}
  doscp850: string = 'da,fi,fr,no,pt,es';
  doscp852: string = 'cs,pl,hu';
  cp437: array[1..19] of byte = (160,130,161,162,163,063,144,063,063,063,
                                 147,063,
                                 150,063,132,148,129,153,154);          {cp 437}
  cp850: array[1..19] of byte = (160,130,161,162,163,181,144,214,224,233,
                                 139,138,
                                 251,235,132,148,129,153,154);          {cp 850}
  cp852: array[1..19] of byte = (160,130,161,162,163,181,144,214,224,233,
                                 139,138,
                                 251,235,132,148,129,153,154);          {cp 852}
{$ENDIF}

{$IFDEF STATIC}
procedure quit(halt_code: byte; message: string);
procedure console_columns(num: byte);
procedure console_lines(num: byte);
procedure background;
procedure ewrite(fg_color: byte; hl_color: byte; vtext: string);
procedure footer(title: string);
procedure header(title: string);
{$IFNDEF LINUX}
procedure dosshell(message: string);
{$ENDIF}
procedure win(x1,y1,x2,y2: byte);
procedure win3d(x1,y1,x2,y2: byte);
procedure wini3d(x1,y1,x2,y2: byte);
procedure message_box(messages: messagerec);
procedure message_box3d(messages: messagerec);
procedure error_box(messages: messagerec);
procedure error_box3d(messages: messagerec);
procedure line(x1, x2, y: byte);
function load_pal(filename: string): boolean;
function base_foreground: byte;
function base_background: byte;
function message_foreground: byte;
function message_background: byte;
function error_foreground: byte;
function error_background: byte;
function menu_foreground: byte;
function menu_highlighted: byte;
function menu_background: byte;
function button_foreground: byte;
function button_highlighted: byte;
function button_background: byte;
function menu(x1,y1: byte; menuitems: itemrec): byte;
function menu3d(x1,y1: byte; menuitems: itemrec): byte;
function fselect(x1,y1 :byte; menuitems: fitems): string;
function fselect3d(x1,y1 :byte; menuitems: fitems): string;
function inputbox(tl: byte; messages: messagerec): string;
function inputbox3d(tl: byte; messages: messagerec): string;
function rmchr1(input: string): string;
function rmchr2(input: string): string;
function rmchr3(input: string): string;
function rmchr4(input: string): string;
function stringconverter(input: string; language: string[2]): string;

implementation
{$ENDIF}

{ Exit. }
procedure quit(halt_code: byte; message: string);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  window(1,1,columns, lines);
  textcolor(lightgray); textbackground(black); clrscr;
  writeln(message);
  halt(halt_code);
end;

{Set number of columns on Linux console.}
procedure console_columns(num: byte);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  if num<40 then quit(9,'Error: Minimal console size is 40x15!');
  columns:=num;
end;

{Set number of lines on Linux console.}
procedure console_lines(num: byte);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  if num<15 then quit(9,'Error: Minimal console size is 40x15!');
  lines:=num;
end;

{ Make solid background. }
procedure background;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  window(1,1,columns,lines);
  textbackground(colors[2]);
  clrscr;
end;

{ Write with highlighted words. }
procedure ewrite(fg_color: byte; hl_color: byte; vtext: string);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  textcolor(fg_color);
  for b:=1 to length(vtext) do
  begin
    case vtext[b] of
      '<': textcolor(hl_color);
      '>': textcolor(fg_color);
    else write(vtext[b]);
    end;
  end;
end;

{ Footer. }
procedure footer(title: string);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  window(1,lines,columns,lines);
  textcolor(colors[7]); textbackground(colors[9]); clreol;
  ewrite(colors[7],colors[8],' '+title);
end;

{ Header. }
procedure header(title: string);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  window(1,1,columns,1);
  textcolor(colors[7]); textbackground(colors[9]); clreol;
  ewrite(colors[7],colors[8],' '+title);
end;

{$IFNDEF LINUX}
{ DOS shell. }
procedure dosshell(message: string);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  swapvectors;
  writeln(message);
  exec(getenv('COMSPEC'),'/c');
  if doserror<>0 then exec('c:\command.com','/c');
  swapvectors;
end;
{$ENDIF}

{ Framed window. }
procedure win(x1,y1,x2,y2: byte);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  window(x1,y1,x2,y2);
  clrscr;
  window(x1,x2,y1,y2+1);
 {$IFDEF LINUX}
  write(#14,' l');
  for b:=1 to (x2-x1-3) do write('q');
  writeln('k');
  for b:=1 to (y2-y1-1) do writeln(' x');
  for b:=1 to (y2-y1-1) do
  begin
    gotoxy(x2-x1,b+1); writeln('x');
  end;
  gotoxy(1,y2-y1+1);
  write(' m');
  for b:=1 to (x2-x1-3) do write('q');
  write('j',#15);
 {$ELSE}
  write(' Ú');
  for b:=1 to (x2-x1-3) do write('Ä');
  writeln('¿');
  for b:=1 to (y2-y1-1) do writeln(' ³');
  for b:=1 to (y2-y1-1) do
  begin
    gotoxy(x2-x1,b+1); writeln('³');
  end;
  gotoxy(1,y2-y1+1); write(' À');
  for b:=1 to (x2-x1-3) do write('Ä');
  write('Ù');
 {$ENDIF}
end;

{ Window with 3D like frame. }
procedure win3d(x1,y1,x2,y2: byte);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  window(x1,y1,x2,y2);
  textbackground(lightgray); textcolor(black); clrscr;
  window(x1,x2,y1,y2+1);
 {$IFDEF LINUX}
  write(#14,' l');
  for b:=1 to (x2-x1-3) do write('q');
  textcolor(white); writeln('k');
  textcolor(black);
  for b:=1 to (y2-y1-1) do writeln(' x');
  textcolor(white);
  for b:=1 to (y2-y1-1) do
  begin
    gotoxy(x2-x1,b+1); writeln('x');
  end;
  gotoxy(1,y2-y1+1); write(' m');
  for b:=1 to (x2-x1-3) do write('q');
  write('j',#15);
 {$ELSE}
  write(' Ú');
  for b:=1 to (x2-x1-3) do write('Ä');
  textcolor(white); writeln('¿');
  textcolor(black);
  for b:=1 to (y2-y1-1) do writeln(' ³');
  textcolor(white);
  for b:=1 to (y2-y1-1) do
  begin
    gotoxy(x2-x1,b+1); writeln('³');
  end;
  gotoxy(1,y2-y1+1); write(' À');
  for b:=1 to (x2-x1-3) do write('Ä');
  write('Ù');
 {$ENDIF}
end;

{ Window with inverse 3D like frame. }
procedure wini3d(x1,y1,x2,y2: byte);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  window(x1,y1,x2,y2);
  textbackground(lightgray); textcolor(white); clrscr;
  window(x1,x2,y1,y2+1);
 {$IFDEF LINUX}
  write(#14,' l');
  for b:=1 to (x2-x1-3) do write('q');
  textcolor(black); writeln('k');
  textcolor(white);
  for b:=1 to (y2-y1-1) do writeln(' x');
  textcolor(black);
  for b:=1 to (y2-y1-1) do
  begin
    gotoxy(x2-x1,b+1); writeln('x');
  end;
  gotoxy(1,y2-y1+1); write(' m');
  for b:=1 to (x2-x1-3) do write('q');
  write('j',#15);
 {$ELSE}
  write(' Ú');
  for b:=1 to (x2-x1-3) do write('Ä');
  textcolor(black); writeln('¿');
  textcolor(white);
  for b:=1 to (y2-y1-1) do writeln(' ³');
  textcolor(black);
  for b:=1 to (y2-y1-1) do
  begin
    gotoxy(x2-x1,b+1); writeln('³');
  end;
  gotoxy(1,y2-y1+1); write(' À');
  for b:=1 to (x2-x1-3) do write('Ä');
  write('Ù');
 {$ENDIF}
end;

{ Message box. }
procedure message_box(messages: messagerec);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
var
  x1, y1: byte;                                                    {Top of box.}
  x2, y2: byte;                                                 {Bottom of box.}

begin
  x1:=(columns div 2)-14;
  y1:=(lines div 2)-2;
  x2:=x1+30;
  y2:=y1+5;
  footer(messages.foot_message);
  window(x1,y1,x2,y2);
  textbackground(black); clrscr;
  textbackground(colors[4]); textcolor(colors[3]);
  win(x1-2,y1-1,x2-2,y2-1);
  gotoxy(3,1); write(' ',messages.title,' ');
  window(x1+1,y1,x2-5,y2-4);
  write(messages.message);
  window(1,1,columns,lines);
  textbackground(colors[12]); textcolor(colors[10]);
  gotoxy(x1+11,y1+3); writeln('[ '+messages.ok+' ]');
  repeat
    c := readkey;
  until (c=#27) or (c=#13); {Escape, Enter}
  c := ' ';
end;

{ Message box with 3D like frame. }
procedure message_box3d(messages: messagerec);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
var
  x1, y1: byte;                                                    {Top of box.}
  x2, y2: byte;                                                 {Bottom of box.}

begin
  x1:=(columns div 2)-14;
  y1:=(lines div 2)-2;
  x2:=x1+30;
  y2:=y1+5;
  footer(messages.foot_message);
  textbackground(black);
  window(x1,y1,x2,y2); clrscr;
  wini3d(x1-2,y1-1,x2-2,y2-1);
  textbackground(lightgray); textcolor(black);
  gotoxy(3,1); write(' ',messages.title,' ');
  window(x1+1,y1,x2-5,y2-4);
  write(messages.message);
  window(1,1,columns,lines);
  textbackground(blue); textcolor(white);
  gotoxy(x1+11,y1+3); writeln('[ '+messages.ok+' ]');
  repeat
    c := readkey;
  until (c=#27) or (c=#13); {Escape, Enter}
  c := ' ';
end;

{ Error message box. }
procedure error_box(messages: messagerec);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
var
  x1, y1: byte;                                                    {Top of box.}
  x2, y2: byte;                                                 {Bottom of box.}

begin
  x1:=(columns div 2)-14;
  y1:=(lines div 2)-2;
  x2:=x1+30;
  y2:=y1+5;
  footer(messages.foot_message);
  window(x1,y1,x2,y2);
  textbackground(black); clrscr;
  textbackground(colors[6]); textcolor(colors[5]);
  win(x1-2,y1-1,x2-2,y2-1);
  gotoxy(3,1); write(' ',messages.title,' ');
  window(x1+1,y1,x2-5,y2-4);
  write(messages.message);
  window(1,1,columns,lines);
  textbackground(colors[12]); textcolor(colors[10]);
  gotoxy(x1+11,y1+3); writeln('[ '+messages.ok+' ]');
  repeat
    c := readkey;
  until (c=#27) or (c=#13); {Escape, Enter}
  c := ' ';
end;

{ Error message box with 3D like frame. }
procedure error_box3d(messages: messagerec);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
var
  x1, y1: byte;                                                    {Top of box.}
  x2, y2: byte;                                                 {Bottom of box.}

begin
  x1:=(columns div 2)-14;
  y1:=(lines div 2)-2;
  x2:=x1+30;
  y2:=y1+5;
  footer(messages.foot_message);
  textbackground(black);
  window(x1,y1,x2,y2); clrscr;
  wini3d(x1-2,y1-1,x2-2,y2-1);
  textcolor(black); textbackground(lightgray);
  gotoxy(3,1); write(' ',messages.title,' ');
  window(x1+1,y1,x2-5,y2-4);
  textcolor(red); write(messages.message);
  window(1,1,columns,lines);
  textbackground(blue); textcolor(white);
  gotoxy(x1+11,y1+3); writeln('[ '+messages.ok+' ]');
  repeat
    c := readkey;
  until (c=#27) or (c=#13); {Escape, Enter}
  c := ' ';
end;

{ Make a horysontal line. }
procedure line(x1, x2, y: byte);
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  window(1,1,columns,lines);
 {$IFDEF LINUX}
  gotoxy(x1,y); write(#14);
  repeat
    write('q');
  until wherex=x2;
  write(#15);
 {$ELSE}
  gotoxy(x1,y);
  repeat
    write('Ä');
  until wherex=x2 {$IFNDEF LINUX} -1 {$ENDIF};
 {$ENDIF}
end;

{ Read palette file. }
function load_pal(filename: string): boolean;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
var
  loaded: array[1..12] of string[12];            {Readed data in string format.}
  pal_file: text;                                                {Palette file.}

const
  names: array[0..15] of string = ('black','blue','green','cyan','red',
                                   'magenta','brown','lightgray',
                                   'darkgray','lightblue','lightgreen',
                                   'lightcyan','lightred','lightmagenta',
                                   'yellow','white');          {Possibly names.}
begin
  for b:=1 to 12 do loaded[b] := '';
  assign(pal_file,filename);
 {$I-}
  reset(pal_file);
 {$I+}
  if ioresult=0 then
  begin
    ss := '';
    bb := 1;
    repeat
      readln(pal_file,s);
      for b:=1 to length(s) do
        if (s[b]<> #32) and (s[b]<> #9) then ss := ss+s[b];
      if (length(ss)>0) and (ss[1]<>'#') then
      begin
        loaded[bb] := ss;
        bb := bb+1;
      end;
      ss := '';
    until (eof(pal_file)) or (bb=13);
    close(pal_file);
    load_pal := true;
  end
  else load_pal := false;
  for b:=1 to 12 do
    for bb:=0 to 15 do
      if loaded[b]=names[bb] then colors[b] := bb;
end;

{ Base foreground colour. }
function base_foreground: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  base_foreground := colors[1];
end;

{ Base background colour. }
function base_background: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  base_background := colors[2];
end;

{ Message box foreground colour. }
function message_foreground: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  message_foreground := colors[3];
end;

{ Message box background colour. }
function message_background: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  message_background := colors[4];
end;

{ Error message box foreground colour. }
function error_foreground: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  error_foreground := colors[5];
end;

{ Error message box background colour. }
function error_background: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  error_background := colors[6];
end;

{ Menu box foreground colour. }
function menu_foreground: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  menu_foreground := colors[7];
end;

{ Menu box highlighted text colour. }
function menu_highlighted: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  menu_highlighted := colors[8];
end;

{ Menu box background text colour. }
function menu_background: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  menu_background := colors[9];
end;

{ Button foreground colour. }
function button_foreground: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  button_foreground := colors[10];
end;

{ Button highlighted text colour. }
function button_highlighted: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  button_highlighted := colors[11];
end;

{ Button background colour. }
function button_background: byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  button_background := colors[12];
end;

{ Menu box. }
function menu(x1,y1: byte; menuitems: itemrec): byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
Var
  items: array[1..20] of string[50];                                   {Labels.}
  hotkeys: array[1..20] of char;                                     {Hot keys.}
  mp, maxmp, maxl: byte;          {Menu position, line num., max. label length.}
  x2, y2: byte;                                      {Right bottom coordinates.}

procedure writeitems(redraw: boolean);
begin
  if redraw=true then
  begin
    window(x1+2,y1+1,x2+3,y2+1);
    textbackground(black); clrscr;
    textbackground(colors[9]); textcolor(colors[7]);
    win(x1,y1,x2+1,y2);
  end;
  for bb:=1 to maxmp do
  begin
    window(x1,y1+1,x2+1,y2);
    textbackground(colors[9]);
    if items[bb]='-' then
    begin
      textcolor(colors[7]); line(x1+2,x2+1,bb+y1);
    end else
    begin
      gotoxy(3,bb); ewrite(colors[7],colors[8],' '+items[bb]);
      for b:=length(items[bb]) to maxl do write(' ');
    end;
  end;
end;

procedure highlighted;
begin
  window(x1,y1+1,x2+1,y2);
  textbackground(colors[12]); gotoxy(3,mp);
  ewrite(colors[10],colors[11],' '+items[mp]);
  for b:=length(items[mp]) to maxl do write(' ');
end;

begin
  for b:=1 to 20 do items[b] := '';
  x2 := 0; y2 := 0;
  with menuitems do
  begin
    items[1] := i1;
    items[2] := i2;
    items[3] := i3;
    items[4] := i4;
    items[5] := i5;
    items[6] := i6;
    items[7] := i7;
    items[8] := i8;
    items[9] := i9;
    items[10] := i10;
    items[11] := i11;
    items[12] := i12;
    items[13] := i13;
    items[14] := i14;
    items[15] := i15;
    items[16] := i16;
    items[17] := i17;
    items[18] := i18;
    items[19] := i19;
    items[20] := i20;
  end;
  for b:=1 to 20 do
    for bb:=1 to length(items[b]) do
      if items[b,bb]='<' then hotkeys[b] := lowercase(items[b,bb+1]);
  b := 1;
  x2 := length(items[b]);
  for b:=2 to 20 do
    if length(items[b])>x2 then x2 := length(items[b]);
  for b:=1 to 20 do
    if length(items[b])>0 then y2 := y2+1;
  maxmp := y2; maxl := x2;
  x2 := x1+x2+2; y2 := y1+y2+1;
  mp := 1;
  c := #71;
  repeat
    writeitems(true);
    repeat
      case c of
        #72: mp := mp-1;  {Up}
        #80: mp := mp+1;  {Down}
        #71: mp := 1;     {Home}
        #79: mp := maxmp; {end}
      end;
      for b:=1 to maxmp do
        if c=hotkeys[b] then
        begin
          menu := b;
          exit;
        end;
      if c=#80 then if items[mp]='-' then mp := mp+1;
      if c=#72 then if items[mp]='-' then mp := mp-1;
      if mp=maxmp+1 then mp := maxmp;
      if mp=0 then mp := 1;
      writeitems(false);
      highlighted;
      c := readkey; if c=#0 then c := readkey;
    until (c=#13) or (c=#27);
    if c=#13 then
    begin
      menu := mp;
      exit;
    end;
  until c=#27;
  menu := 255;
end;

{ Menu box with 3D like frame. }
function menu3d(x1,y1: byte; menuitems: itemrec): byte;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
Var
  items: array[1..20] of string[50];                                   {Labels.}
  hotkeys: array[1..20] of char;                                     {Hot keys.}
  mp, maxmp, maxl: byte;          {Menu position, line num., max. label length.}
  x2, y2: byte;                                      {Right bottom coordinates.}

procedure writeitems(redraw: boolean);
begin
  if redraw=true then
  begin
    window(x1+2,y1+1,x2+3,y2+1);
    textbackground(black); clrscr;
    textbackground(lightgray); textcolor(black);
    win3d(x1,y1,x2+1,y2);
  end;
  for bb:=1 to maxmp do
  begin
    window(x1,y1+1,x2+1,y2);
    textbackground(lightgray);
    if items[bb]='-' then
    begin
      textcolor(black); line(x1+2,x2+1,bb+y1);
    end else
    begin
      gotoxy(3,bb); ewrite(black,red,' '+items[bb]);
      for b:=length(items[bb]) to maxl do write(' ');
    end;
  end;
end;

procedure highlighted;
begin
  window(x1,y1+1,x2+1,y2);
  textbackground(blue);
  gotoxy(3,mp); ewrite(white,yellow,' '+items[mp]);
  for b:=length(items[mp]) to maxl do write(' ');
end;

begin
  for b:=1 to 20 do items[b] := '';
  x2 := 0; y2 := 0;
  with menuitems do
  begin
    items[1] := i1;
    items[2] := i2;
    items[3] := i3;
    items[4] := i4;
    items[5] := i5;
    items[6] := i6;
    items[7] := i7;
    items[8] := i8;
    items[9] := i9;
    items[10] := i10;
    items[11] := i11;
    items[12] := i12;
    items[13] := i13;
    items[14] := i14;
    items[15] := i15;
    items[16] := i16;
    items[17] := i17;
    items[18] := i18;
    items[19] := i19;
    items[20] := i20;
  end;
  for b:=1 to 20 do
    for bb:=1 to length(items[b]) do
      if items[b,bb]='<' then hotkeys[b] := lowercase(items[b,bb+1]);
  b := 1;
  x2 := length(items[b]);
  for b:=2 to 20 do
    if length(items[b])>x2 then x2 := length(items[b]);
  for b:=1 to 20 do
    if length(items[b])>0 then y2 := y2+1;
  maxmp := y2; maxl := x2;
  x2 := x1+x2+2; y2 := y1+y2+1;
  mp := 1;
  c := #71;
  repeat
    writeitems(true);
    repeat
      case c of
        #72: mp := mp-1;  {Up}
        #80: mp := mp+1;  {Down}
        #71: mp := 1;     {Home}
        #79: mp := maxmp; {end}
      end;
      for b:=1 to maxmp do
        if c=hotkeys[b] then
        begin
          menu3d := b;
          exit;
        end;
      if c=#80 then if items[mp]='-' then mp := mp+1;
      if c=#72 then if items[mp]='-' then mp := mp-1;
      if mp=maxmp+1 then mp := maxmp;
      if mp=0 then mp := 1;
      writeitems(false);
      highlighted;
      c := readkey; if c=#0 then c := readkey;
    until (c=#13) or (c=#27);
    if c=#13 then
    begin
      menu3d := mp;
      exit;
    end;
  until c=#27;
  menu3d := 255;
end;

{ File select box. }
function fselect(x1,y1 :byte; menuitems: fitems): string;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
var
  lastitem: integer;                                  {Number of the last item.}
  mp: byte;                                                     {Menu position.}
  firstline: integer;                   {Number of the label in the first line.}

procedure highlighted;
begin
  gotoxy(1,mp);
  textbackground(colors[12]); textcolor(colors[10]);
  write(' '+menuitems[firstline+mp-1]);
  for b:=length(menuitems[firstline+mp-1]) to 8 do write(' ');
  textbackground(colors[9]); textcolor(colors[7]);
end;

procedure writeitems(redraw: boolean);
begin
  if redraw=true then
  begin
    window(x1+2,y1+1,x1+15,y1+12);
    textbackground(black); clrscr;
    textbackground(colors[9]); textcolor(colors[7]);
    win(x1,y1,x1+12+1,y1+11);
  end else
  begin
    window(x1+2,y1+1,x1+11,y1+10);
    clrscr;
    window(x1+2,y1+1,x1+11,y1+11);
    for i:=firstline to firstline+9 do writeln(' '+menuitems[i]);
  end;
end;

begin
  if menuitems[1]='' then
  begin
    fselect := '@';
    exit;
  end;
  for i:=1 to 1024 do if menuitems[i]<>'' then lastitem := i;
  firstline := 1;
  c := 'a';
  mp := 1;
  repeat
    writeitems(true);
    repeat
      case c of
 {Up}   #72: if mp>1 then mp := mp-1
             else if firstline>1 then firstline := firstline-1;
 {Down} #80: if (mp<10) and (lastitem>mp) then mp := mp+1
             else if lastitem>firstline+9 then firstline := firstline+1;
 {^Home}#119:begin
               mp := 1;
               firstline := 1;
             end;
 {Home} #71: mp := 1;
 {End}  #79: if lastitem<10 then mp := lastitem
             else
	      if lastitem>firstline+9 then mp := 10 else
              begin
                firstline := lastitem-9;
                mp := 10;
              end;
 {^End}  #117:if lastitem>10 then
              begin
                firstline := lastitem-9;
                mp := 10;
              end else mp := lastitem;
 {PgUp}  #73: if firstline>10 then firstline := firstline-10 else
              begin
                firstline := 1;
                mp := 1;
              end;
 {PgDn}  #81: if lastitem>10 then
               if lastitem>firstline+20
                 then firstline := firstline+10 else
                 begin
                   firstline := lastitem-9;
                   mp := 10;
                 end;
      end;
      writeitems(false);
      highlighted;
      c := readkey; if c=#0 then c := readkey;
    until (c=#13) or (c=#27);
    if c=#13 then
    begin
      fselect := menuitems[firstline+mp-1];
      exit;
    end;
  until c=#27;
  fselect := '?';
end;

{ File select box with 3D like frame. }
function fselect3d(x1,y1 :byte; menuitems: fitems): string;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
var
  lastitem: integer;                                  {Number of the last item.}
  mp: byte;                                                     {Menu position.}
  firstline: integer;                   {Number of the label in the first line.}

procedure highlighted;
begin
  gotoxy(1,mp);
  textbackground(blue); textcolor(white);
  write(' '+menuitems[firstline+mp-1]);
  for b:=length(menuitems[firstline+mp-1]) to 8 do write(' ');
  textbackground(lightgray);
  textcolor(black);
end;

procedure writeitems(redraw: boolean);
begin
  if redraw=true then
  begin
    window(x1+2,y1+1,x1+15,y1+12);
    textbackground(black); clrscr;
    textbackground(lightgray); textcolor(black);
    win3d(x1,y1,x1+12+1,y1+11);
  end else
  begin
    window(x1+2,y1+1,x1+11,y1+10);
    clrscr;
    window(x1+2,y1+1,x1+11,y1+11);
    for i:=firstline to firstline+9 do writeln(' '+menuitems[i]);
  end;
end;

begin
  if menuitems[1]='' then
  begin
    fselect3d := '@';
    exit;
  end;
  for i:=1 to 1024 do
    if menuitems[i]<>'' then lastitem := i;
  firstline := 1;
  c := 'a';
  mp := 1;
  repeat
    writeitems(true);
    repeat
      case c of
 {Up}   #72: if mp>1 then mp := mp-1 else
               if firstline>1 then firstline := firstline-1;
 {Down} #80: if (mp<10) and (lastitem>mp) then mp := mp+1 else
               if lastitem>firstline+9 then firstline := firstline+1;
 {^Home}#119:begin
               mp := 1;
               firstline := 1;
             end;
 {Home} #71: mp := 1;
 {End}  #79: if lastitem<10 then mp := lastitem else
               if lastitem>firstline+9 then mp := 10 else
               begin
                 firstline := lastitem-9;
                 mp := 10;
               end;
 {^End} #117: if lastitem>10 then
              begin
                firstline := lastitem-9;
                mp := 10;
              end else mp := lastitem;
 {PgUp}  #73: if firstline>10 then firstline := firstline-10 else
              begin
                firstline := 1;
                mp := 1;
              end;
 {PgDn}  #81: if lastitem>10 then
                if lastitem>firstline+20 then firstline := firstline+10 else
                begin
                  firstline := lastitem-9;
                  mp := 10;
                end;
      end;
      writeitems(false);
      highlighted;
      c := readkey; if c=#0 then c := readkey;
    until (c=#13) or (c=#27);
    if c=#13 then
    begin
      fselect3d := menuitems[firstline+mp-1];
      exit;
    end;
  until c=#27;
  fselect3d := '?';
end;

{ Input box. }
function inputbox(tl: byte; messages: messagerec): string;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
var
  x1, y1: byte;                                                    {Top of box.}
  x2, y2: byte;                                                 {Bottom of box.}
label back;
begin
  x1:=(columns div 2)-14;
  y1:=(lines div 2)-2;
  x2:=x1+30;
  y2:=y1+5;
  footer(messages.foot_message);
  window(x1,y1,x2,y2);
  textbackground(black); clrscr;
  textbackground(colors[4]); textcolor(colors[3]);
  win(x1-2,y1-1,x2-2,y2-1);
  gotoxy(3,1); write(' ',messages.title,' ');
  window(x1+1,y1,x2-5,y2-4);
  write(messages.message);
  window(1,1,columns,lines);
  gotoxy(x1+14,y1+3); writeln('[ '+messages.cancel+' ]');
  textbackground(colors[12]); textcolor(colors[10]);
  gotoxy(x1+3,y1+3); writeln('[ '+messages.ok+' ]');
  window(x1+1,y1+1,x2-5,y2-4);
  clrscr;
  s := '';
  b := 0;
  repeat
    back:
    c := readkey; c := upcase(c);
    if ((c>#47) and (c<#58)) or ((c>#64) and (c<#91)) then
      if length(s)>tl-1 then write('') else
      begin
        s := s+c;
        clrscr;
        write(s);
      end;
    if (c=#8) then if length(s)=0 then write('') else
    begin
      delete(s,length(s),1);
      clrscr;
      write(s);
    end;
    if (c=#9) and (b=0) then
    begin
      window(1,1,columns,lines);
      textbackground(colors[4]); textcolor(colors[3]);
      gotoxy(x1+3,y1+3); writeln('[ '+messages.ok+' ]');
      textbackground(colors[12]); textcolor(colors[10]);
      gotoxy(x1+14,y1+3); writeln('[ '+messages.cancel+' ]');
      window(x1+1,y1+1,x2-5,y2-4);
      gotoxy(length(s)+1,1);
      b := 1;
      c := #0;
    end;
    if (c=#9) and (b=1) then
    begin
      window(1,1,columns,lines);
      textbackground(colors[4]); textcolor(colors[3]);
      gotoxy(x1+14,y1+3); writeln('[ '+messages.cancel+' ]');
      textbackground(colors[12]); textcolor(colors[10]);
      gotoxy(x1+3,y1+3); writeln('[ '+messages.ok+' ]');
      window(x1+1,y1+1,x2-5,y2-4);
      gotoxy(length(s)+1,1);
      b := 0;
      c := #0;
    end;
  until (c=#13) or (c=#27);
  if (c=#13) and (length(s)=0) then inputbox := '?' else
    if (c=#13) and (b=0) then
    begin
      for b:=1 to length(s) do s[b] := lowercase(s[b]);
      inputbox := s
    end
  else inputbox := '?';
  c := ' ';
end;

{ Input box with 3D frame. }
function inputbox3d(tl: byte; messages: messagerec): string;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
var
  x1, y1: byte;                                                    {Top of box.}
  x2, y2: byte;                                                 {Bottom of box.}
label back;
begin
  x1:=(columns div 2)-14;
  y1:=(lines div 2)-2;
  x2:=x1+30;
  y2:=y1+5;
  window(x1,y1,x2,y2);
  textbackground(black); clrscr;
  textbackground(lightgray); textcolor(black);
  wini3d(x1-2,y1-1,x2-2,y2-1);
  gotoxy(3,1); write(' ',messages.title,' ');
  window(x1+1,y1,x2-5,y2-4);
  write(messages.message);
  window(1,1,columns,lines);
  gotoxy(x1+14,y1+3); writeln('[ '+messages.cancel+' ]');
  textbackground(blue); textcolor(white);
  gotoxy(x1+3,y1+3); writeln('[ '+messages.ok+' ]');
  window(x1+1,y1+1,x2-5,y2-4);
  clrscr;
  s := '';
  b := 0;
  repeat
    back:
    c := readkey; c := upcase(c);
    if ((c>#47) and (c<#58)) or ((c>#64) and (c<#91)) then
      if length(s)>tl-1 then write('') else
      begin
        s := s+c;
        clrscr;
        write(s);
      end;
    if (c=#8) then if length(s)=0 then write('') else
    begin
      delete(s,length(s),1);
      clrscr;
      write(s);
    end;
    if (c=#9) and (b=0) then
    begin
      window(1,1,80,25);
      textbackground(lightgray); textcolor(black);
      gotoxy(x1+3,y1+3); writeln('[ '+messages.ok+' ]');
      textbackground(blue); textcolor(white);
      gotoxy(x1+14,y1+3); writeln('[ '+messages.cancel+' ]');
      window(x1+1,y1+1,x2-5,y2-4);
      gotoxy(length(s)+1,1);
      b := 1;
      c := #0;
    end;
    if (c=#9) and (b=1) then
    begin
      window(1,1,80,25);
      textbackground(lightgray); textcolor(black);
      gotoxy(x1+14,y1+3); writeln('[ '+messages.cancel+' ]');
      textbackground(blue); textcolor(white);
      gotoxy(x1+3,y1+3); writeln('[ '+messages.ok+' ]');
      window(x1+1,y1+1,x2-5,y2-4);
      gotoxy(length(s)+1,1);
      b := 0;
      c := #0;
    end;
  until (c=#13) or (c=#27);
  if (c=#13) and (length(s)=0) then inputbox3d := '?' else
  if (c=#13) and (b=0) then
  begin
    for b:=1 to length(s) do s[b] := lowercase(s[b]);
    inputbox3d := s
  end else inputbox3d := '?';
  c := ' ';
end;

{ Remove all space and tabulator. }
function rmchr1(input: string): string;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  rmchr1 := '';
  for b:=1 to length(input) do
    if (input[b]<> #32) and (input[b]<> #9) then rmchr1 := rmchr1+input[b];
end;

{ Remove all characters after hash. }
function rmchr2(input: string): string;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  rmchr2 := '';
  for b:=1 to length(input) do
    if (input[b]<> #35) then rmchr2 := rmchr2+input[b] else break;
end;

{ Remove space and tabulator from start of line. }
function rmchr3(input: string): string;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  rmchr3 := '';
  while (input[1]=#9) or (input[1]=#32) do delete(input,1,1);
  rmchr3 := input;
end;

{ It removes bad characters from input string. }
function rmchr4(input: string): string;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}
begin
  input := rmchr3(input);
  if input[1]<>'#' then
  begin
    s := '';
    for b:=1 to length(input) do
      if (input[b]<> #35) then s := s+input[b] else break;
    rmchr4 := s;
  end else rmchr4 := '';
end;

{ It converts &????; codes to accentuated letters. }
function stringconverter(input: string; language: string[2]): string;
{$IFNDEF STATIC} cdecl; export; {$ENDIF}

function change(code: byte): char;
var b: byte;
begin
 {$IFDEF LINUX}
  for b:=1 to length(liniso1) do
    if language=liniso1[b]+liniso1[b+1] then change := chr(iso88591[code]);
  for b:=1 to length(liniso2) do
    if language=liniso2[b]+liniso2[b+1] then change := chr(iso88592[code]);
 {$ELSE}
  for b:=1 to length(doscp437) do
    if language=doscp437[b]+doscp437[b+1] then change := chr(cp437[code]);
  for b:=1 to length(doscp850) do
    if language=doscp850[b]+doscp850[b+1] then change := chr(cp850[code]);
  for b:=1 to length(doscp852) do
    if language=doscp852[b]+doscp852[b+1] then change := chr(cp852[code]);
 {$ENDIF}
end;

begin
  bb := 1;
  repeat
    if input[bb]='&' then
    begin
      for bbb:=1 to 13 do
        if input[bb]+input[bb+1]+input[bb+2]+input[bb+3]+input[bb+4]+
	  input[bb+5]+input[bb+6]+input[bb+7]=alet[bbb] then break;
      if bbb<13 then
      begin
        input[bb] := change(bbb);
        delete(input,bb+1,7);
      end;
    end;
    bb := bb+1;
  until (bb=255);
  bb := 1;
  repeat
    if input[bb]='&' then
    begin
      for bbb:=13 to 15 do
        if input[bb]+input[bb+1]+input[bb+2]+input[bb+3]+input[bb+4]+
	  input[bb+5]+input[bb+6]=alet[bbb] then break;
      if bbb<15 then
      begin
        input[bb] := change(bbb);
        delete(input,bb+1,6);
      end;
    end;
    bb := bb+1;
  until (bb=255);
  bb := 1;
  repeat
    if input[bb]='&' then
    begin
      for bbb:=14 to 20 do
        if input[bb]+input[bb+1]+input[bb+2]+input[bb+3]+input[bb+4]+
	  input[bb+5]=alet[bbb] then break;
      if bbb<20 then
      begin
        input[bb] := change(bbb);
        delete(input,bb+1,5);
      end;
    end;
    bb := bb+1;
  until (bb=255);
  stringconverter := input;
end;

 {$IFNDEF STATIC}
 exports console_columns {$IFDEF WIN32} name 'console_columns' {$ENDIF};
 exports console_lines {$IFDEF WIN32} name 'console_lines' {$ENDIF};
 exports background {$IFDEF WIN32} name 'background' {$ENDIF};
 exports ewrite {$IFDEF WIN32} name 'ewrite' {$ENDIF};
 exports footer {$IFDEF WIN32} name 'footer' {$ENDIF};
 exports header {$IFDEF WIN32} name 'header' {$ENDIF};
 {$IFNDEF LINUX}
 exports dosshell {$IFDEF WIN32} name 'dosshell' {$ENDIF};
 {$ENDIF}
 exports quit {$IFDEF WIN32} name 'quit' {$ENDIF};
 exports win {$IFDEF WIN32} name 'win' {$ENDIF};
 exports win3d {$IFDEF WIN32} name 'win3d' {$ENDIF};
 exports wini3d {$IFDEF WIN32} name 'wini3d' {$ENDIF};
 exports message_box {$IFDEF WIN32} name 'message_box' {$ENDIF};
 exports message_box3d {$IFDEF WIN32} name 'message_box3d' {$ENDIF};
 exports error_box {$IFDEF WIN32} name 'error_box' {$ENDIF};
 exports error_box3d {$IFDEF WIN32} name 'error_box3d' {$ENDIF};
 exports line {$IFDEF WIN32} name 'line' {$ENDIF};
 exports load_pal {$IFDEF WIN32} name 'load_pal' {$ENDIF};
 exports base_foreground {$IFDEF WIN32} name 'base_foreground' {$ENDIF};
 exports base_background {$IFDEF WIN32} name 'base_background' {$ENDIF};
 exports message_foreground {$IFDEF WIN32} name 'message_foreground' {$ENDIF};
 exports message_background {$IFDEF WIN32} name 'message_background' {$ENDIF};
 exports error_foreground {$IFDEF WIN32} name 'error_foreground' {$ENDIF};
 exports error_background {$IFDEF WIN32} name 'error_background' {$ENDIF};
 exports menu_foreground {$IFDEF WIN32} name 'menu_foreground' {$ENDIF};
 exports menu_highlighted {$IFDEF WIN32} name 'menu_highlighted' {$ENDIF};
 exports menu_background {$IFDEF WIN32} name 'menu_background' {$ENDIF};
 exports button_foreground {$IFDEF WIN32} name 'button_foreground' {$ENDIF};
 exports button_highlighted {$IFDEF WIN32} name 'button_highlighted' {$ENDIF};
 exports button_background {$IFDEF WIN32} name 'button_background' {$ENDIF};
 exports menu {$IFDEF WIN32} name 'menu' {$ENDIF};
 exports menu3d {$IFDEF WIN32} name 'menu3d' {$ENDIF};
 exports fselect {$IFDEF WIN32} name 'fselect' {$ENDIF};
 exports fselect3d {$IFDEF WIN32} name 'fselect3d' {$ENDIF};
 exports inputbox {$IFDEF WIN32} name 'inputbox' {$ENDIF};
 exports inputbox3d {$IFDEF WIN32} name 'inputbox3d' {$ENDIF};
 exports rmchr1 {$IFDEF WIN32} name 'rmchr1' {$ENDIF};
 exports rmchr2 {$IFDEF WIN32} name 'rmchr2' {$ENDIF};
 exports rmchr3 {$IFDEF WIN32} name 'rmchr3' {$ENDIF};
 exports rmchr4 {$IFDEF WIN32} name 'rmchr4' {$ENDIF};
 exports stringconverter {$IFDEF WIN32} name 'stringconverter' {$ENDIF};
 {$ENDIF}

end.
