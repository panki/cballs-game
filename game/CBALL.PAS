program cb;
uses crt,graph,dos;
type image=record
     w,h:word;
     p:pointer;
     end;
     player=record
     name:string[7];
     sc:string[5];
     end;
     bitmapinfo=record
     lab:array[1..2] of char;
     file_size:longint;
     r1,r2:word;
     offs:longint;
     info_size:longint;
     width,heigth:longint;
     planes:word;
     Bit:word;
     compr,size,gor,ver,colors,maincolors:longint;
     end;
     bitmap=record
     w,h:word;
     first:byte;
     p:pointer;
     pal:array[0..255,1..3] of byte;
     numcol:byte;
     end;
     rndxy=record
     y,x:byte;
     end;
     rn=array[1..18200] of rndxy;
const pic:array[1..14] of string=('11','08','06','10','12','05','04','13','03','14','02','01','09','07');
  al:string='abcdefghijklmnopqrstuvwxyz0123456789 .:!';
var j,i,gd,gm:integer;
    sh:ARRAY [1..12] OF image;
    plan:array[1..200,1..3] of byte;
    boar,bbomb_u,bbomb_d,bpause,bskel_r,bskel_l,gw,sc,shp1,shp:bitmap;
    iboar,ibomb_d,ibomb_u,work,ipause,iskel_l,iskel_r,gwi,sci,gl:image;
    alph:array[1..40] of image;
    bt:byte;
    rndd:rn;
    pole:array[0..8,0..13] of byte;
    bal:array[1..4] of byte;
    nx,b:byte;
    s:string;
    bbb:boolean;
    score,nexx,k1,k,xx,kek,sss:word;
    pri,xxx,yyy:byte;

    {rnd:array[1..2,1..18200] of byte;}
{$I cball.inc}
procedure read_bitmap(var bm:bitmap;s:string;firstcolor:byte);
type ar=array[0..320] of byte;
var f:file;
    info:bitmapinfo;
    p:^ar;
    pp:ar;
    se,os:word absolute p;
    i,j:byte;
    nn:word;
    c:integer;
    b:array[1..4] of byte;
begin
    assign(f,s);
    reset(f,1);
    blockread(f,info,sizeof(info));
    bm.w:=info.width;
    bm.h:=info.heigth;
    bm.numcol:=0;
    c:=-1;
    nn:=(info.size div info.heigth)-info.width;
    if nn>100 then nn:=0;
    bm.first:=firstcolor;
    while filepos(f)<info.offs do
    begin
    blockread(f,b,4);
    inc(c);
    bm.numcol:=bm.numcol+1;
    bm.pal[c,1]:=b[3] div 4;
    bm.pal[c,2]:=b[2] div 4;
    bm.pal[c,3]:=b[1] div 4;
    {setrgbpalette(c+firstcolor,bm.pal[c,1],bm.pal[c,2],bm.pal[c,3]);}
    end;
    bm.numcol:=c;
    getmem(bm.p,bm.w*bm.h);
    p:=bm.p;
    os:=os+bm.w*bm.h;
    {seek(f,filesize(f)-bm.h*bm.w);}
    for i:=1 to bm.h do
    begin
    os:=os-bm.w;
    blockread(f,p^,bm.w);
    if nn>0 then blockread(f,pp,nn);
    if firstcolor>0 then begin
    for j:=0 to bm.w-1 do
    p^[j]:=p^[j]+firstcolor;
    end;
    end;
    close(f);
end;
procedure load_pc(var bt:bitmap;s:string);
var f:file;
begin
  assign(f,s);
  reset(f,1);
  blockread(f,bt,sizeof(bitmap));
  getmem(bt.p,bt.w*bt.h);
  blockread(f,bt.p^,bt.w*bt.h);
  close(f);
end;


procedure set_bitmap_palette(bm:bitmap);
var p:pointer;
    f,c:byte;
begin
  p:=@bm.pal;
  f:=bm.first;
  c:=bm.numcol;
  asm
  mov ah,$10
  mov al,$12
  les dx,p
  xor bh,bh
  mov bl,f
  xor ch,ch
  mov cl,c
  int 10h
  end;
  p:=@bm.pal[bm.numcol,1];
  c:=1;
  f:=bm.numcol+bm.first;
  asm
  mov ah,$10
  mov al,$12
  les dx,p
  xor bh,bh
  mov bl,f
  xor ch,ch
  mov cl,c
  int 10h
  end;
end;
procedure pix;
begin
     inc(pri);
     if pri=2 then begin
     for k1:=1 to 200 do
     begin
     if getpixel(plan[k1,1]+17,plan[k1,2]+15)=plan[k1,3] then
     putpixel(plan[k1,1]+17,plan[k1,2]+15,50);
     if plan[k1,1]>plan[k1,3]-1 then plan[k1,1]:=plan[k1,1]-plan[k1,3]+1 else plan[k1,1]:=127;
     if getpixel(plan[k1,1]+17,plan[k1,2]+15)=50 then putpixel(plan[k1,1]+17,plan[k1,2]+15,plan[k1,3]);
     end;
     pri:=0;
     end;
end;

procedure bitmap_to_image(bt:bitmap;var im:image);
begin
  im.p:=bt.p;
  im.w:=bt.w;
  im.h:=bt.h;
end;
procedure print_xy(x,y:word;s:string);
var j,i:byte;
begin
  for i:=0 to length(s)-1 do
  begin
  j:=pos(s[i+1],al);
  if j>0 then put_image1(x+i*12,y,alph[j],false);
  end;
end;
procedure scroll_left(x,y,w,h:word;s:string);
var sor:image;
    sy,c,l,n:word;
    b:boolean;
begin
  c:=0;
  sy:=1;
  b:=true;
  while (b) and (not keypressed) do
  begin
  get_image(x+2,y,w-2,h,sor);
  put_image1(x,y,sor,true);
  c:=c+2;
  put_image_wh(x+w-c,y,alph[pos(s[sy],al)],c,0,false);
  clear_image(sor);
  if c=12 then begin c:=0;sy:=sy+1;end;
  if sy>length(s) then b:=false;
  end;
  if b then begin
  for i:=1 to 9 do
  begin
  get_image(x,y,w,h-2,sor);
  put_image1(x,y+2,sor,true);
  clear_image(sor);
  end;
  end;
end;
procedure pr_sc;
const s0:string='00000';
var s:string;
begin
str(score,s);
s:=' score:'+copy(s0,1,5-length(s))+s;
scroll_left(172,165,132,18,s);
end;
procedure next;
var lv:string;
begin
if nexx=18200 then begin

                         nexx:=0;
                         rect(172,13,132,139);
                         clear_image(gl);
                         load_pc(shp,'0'+pic[nx]+'.pc');
     bitmap_to_image(shp,gl);
     set_bitmap_palette(shp);
                         end;
for i:=1 to 350 do
     if (rndd[i+nexx].x<129) and (rndd[i+nexx].y<139) then begin
     j:=rndd[i+nexx].y*129+rndd[i+nexx].x;
     asm
     push es
     les di,gl.p
     add di,j

     mov al,es:[di]

     mov bt,al
     pop es
     end;
     putpixel(rndd[i+nexx].x+173,rndd[i+nexx].y+14,bt);
     end;
     nexx:=nexx+350;
     if nexx=18200 then
     begin
     inc(nx);
                         str(nx,lv);
                         if nx>14 then nx:=1;
       get_image(30,50,100,100,work);
        put_image(30,50,ipause,false);

     while not keypressed do
     scroll_left(172,165,132,18,' congratulations ! you have fast hands ! welcome to level '+lv+' ! press any key. ');
     readkey;
     put_image1(30,50,work,false);
        clear_image(work);
     end;
end;
function coli(i,j:byte):byte;
const xy:array[1..8,1..2] of integer=((0,-1),(1,-1),(1,0),(1,1),

                                      (0,1),(-1,1),(-1,0),(-1,-1));
var i1,j1,ii,jj:integer;
    mb,ma,num,num1:byte;
    b:boolean;
begin
  num1:=0;
  ma:=pole[i,j];
  for ii:=1 to 8 do
  begin
  i1:=i;
  j1:=j;
  b:=true;
  num:=0;
  while ((i1+xy[ii,1]) in [0..8]) and ((j1+xy[ii,2]) in [0..13]) and (b) do
  begin
  i1:=i1+xy[ii,1];
  j1:=j1+xy[ii,2];
  mb:=pole[i1,j1];
  if mb>=100 then mb:=mb-100;
  if (ma=mb) then inc(num) else b:=false;
  end;
  if num>1 then
  begin
  num1:=3;
  i1:=i;
  j1:=j;
  for jj:=1 to num+1 do
  begin
  inc(pole[i1,j1],100);
  setcolor(0);
  circle(17+(i1)*14+7,(j1)*12+14+6,2);
  inc(score);
  i1:=i1+xy[ii,1];
  j1:=j1+xy[ii,2];
  end;
  end;
  end;
  coli:=num1;
end;
procedure cle(x,y:integer);
var x1,y1:word;
begin
  for i:=1 to 200 do
  begin
  x1:=random(14);
  y1:=random(13);
  if odd(i) then delay(1);
  putpixel(x+x1,y+y1,50);
  end;
end;
procedure dele(i,j:byte);
const xy:array[1..8,1..2] of integer=((0,-1),(1,-1),(1,0),(1,1),(0,1),(-1,1),(-1,0),(-1,-1));
var ii,jj:integer;
    num:byte;
begin
  num:=0;
  for ii:=1 to 8 do
  begin
  if ((i+xy[ii,1]) in [0..8]) and ((j+xy[ii,2]) in [0..13]) then if pole[i,j]=pole[i+xy[ii,1],j+xy[ii,2]] then
  begin
  pole[i+xy[ii,1],j+xy[ii,2]]:=0;
  cle(17+(i+xy[ii,1])*14,(j+xy[ii,2])*12+14);
  put_image1(17+(i+xy[ii,1])*14,(j+xy[ii,2])*12+14,sh[8],false);
  end;
  end;
  pole[i,j]:=0;
  cle(17+(i)*14,(j)*12+14);
  put_image1(17+(i)*14,(j)*12+14,sh[8],false);
end;
procedure delet;
var ii,jj:integer;
begin
  for ii:=0 to 8 do
  for jj:=0 to 13 do
  begin
  if pole[ii,jj]>=100 then
  begin
  pole[ii,jj]:=0;
  cle(17+(ii)*14,(jj)*12+14);
  put_image1(17+ii*14,jj*12+14,sh[8],false);
  end;
  end;
end;
function sup:boolean;
var s,ii,i,j:byte;
    b,b1:boolean;
begin
  b:=true;
  b1:=false;
  while b do
  begin
  b:=false;
  for i:=0 to 8 do
  for j:=0 to 12 do
  begin
  if (pole[i,j]>0) and (pole[i,j+1]=0) then
  begin
  s:=pole[i,j];
  pole[i,j]:=0;
  for ii:=0 to 11 do
  begin
  put_image1(17+i*14,j*12+15+ii,sh[s],false);
  delay(3);
  end;
  pole[i,j+1]:=s;
  b:=true;
  b1:=true;
  end;
  end;
  end;
  sup:=b1;
end;
function bombs:boolean;
var i1,j1,i,j,col:byte;
b:boolean;
begin
  b:=false;
  col:=255;
  for i:=0 to 8 do
  for j:=0 to 13 do
  if pole[i,j] in [9,10] then
  begin
  if j<13 then col:=pole[i,j+1] else col:=0;
  i1:=i;
  j1:=j;
  end;
  if col in [1..7] then
  begin
  for i:=0 to 8 do
  for j:=0 to 13 do
  if pole[i,j]=col then
  begin
  pole[i,j]:=0;
  cle(17+(i)*14,j*12+14);
  put_image1(17+i*14,j*12+14,sh[8],false);
  inc(score);
  end;
  pole[i1,j1]:=0;
  cle(17+(i1)*14,j1*12+14);
  put_image1(17+i1*14,j1*12+14,sh[8],false);
  b:=true;
  end;
  if col=0 then
  begin
  pole[i1,j1]:=0;
  cle(17+(i1)*14,j1*12+14);
  put_image1(17+i1*14,j1*12+14,sh[8],false);
  end;
  bombs:=b;
end;
function skels:boolean;
const xy:array[1..8,1..2] of integer=((0,-1),(1,-1),(1,0),(1,1),(0,1),(-1,1),(-1,0),(-1,-1));
var i1,j1,i,j,col:byte;
b:boolean;
begin
  b:=false;
  col:=255;
  for i:=0 to 8 do
  for j:=0 to 13 do
  if pole[i,j] in [11,12] then
  begin
  if j<13 then col:=pole[i,j+1] else col:=0;
  i1:=i;
  j1:=j;
  end;
  if col in [1..7] then
  begin
  for i:=1 to 8 do
  begin
  if ((i1+xy[i,1]) in [0..8]) and ((j1+xy[i,2]) in [0..13]) then
  if pole[i1+xy[i,1],j1+xy[i,2]]>0 then
  begin
  pole[i1+xy[i,1],j1+xy[i,2]]:=0;
  cle(17+(i1+xy[i,1])*14,(j1+xy[i,2])*12+14);
  put_image1(17+(i1+xy[i,1])*14,(j1+xy[i,2])*12+14,sh[8],false);
  end;
  end;
  pole[i1,j1]:=0;
  cle(17+(i1)*14,j1*12+14);
  put_image1(17+i1*14,j1*12+14,sh[8],false);
  b:=true;
  end;
  if col=0 then
  begin
  pole[i1,j1]:=0;
  cle(17+(i1)*14,j1*12+14);
  put_image1(17+i1*14,j1*12+14,sh[8],false);
  end;
  skels:=b;
end;

function del_bal:boolean;
var i,j:byte;
    b2,b,b1:boolean;
begin
  b1:=false;
  b2:=false;

  for i:=0 to 9 do
  for j:=0 to 13 do
  begin
  if (pole[i,j]>0) and (pole[i,j]<100) then
  if coli(i,j)>2 then
  begin
  b1:=true;
  next;
  end;
  end;
  if b1 then delet;
  repeat
  until not sup;
  if bombs then b1:=true;
  if skels then b1:=true;
  repeat
  until not sup;
  if b1 then pr_sc;
  del_bal:=b1;
end;
procedure save_image(im:image;bt:bitmap;s:string);
var f:file;
begin
  assign(f,s);
  rewrite(f,1);
  bt.w:=im.w;
  bt.h:=im.h;
  blockwrite(f,bt,sizeof(bitmap));
  blockwrite(f,im.p^,im.w*im.h);
  close(f);
end;
procedure read_al;
var i:byte;
    s:string;
begin
  for i:=1 to 36 do
  begin
  if i>26 then s:='c' else s:='';
  read_bitmap(shp,s+al[i]+'.bmp',0);
  bitmap_to_image(shp,alph[i]);
  end;
  read_bitmap(shp,'pro.bmp',0);
  bitmap_to_image(shp,alph[37]);
  read_bitmap(shp,'toh.bmp',0);
  bitmap_to_image(shp,alph[38]);
  read_bitmap(shp,'dvo.bmp',0);
  bitmap_to_image(shp,alph[39]);
  read_bitmap(shp,'vos.bmp',0);
  bitmap_to_image(shp,alph[40]);
end;
function read_pl(x,y:word):string;
var n,kek:byte;
    s:string[7];

begin
  n:=0;
  s:='.......';
  repeat
  print_xy(x,y,s);
  kek:=ord(readkey);
  if pos(chr(kek),al)>0 then
  begin
  inc(n);
  if n>7 then n:=7;
  s[n]:=chr(kek);

  end;
  if (kek=8) and (n>0) then
  begin
  s[n]:='.';
  dec(n);
  end;
  until kek=13;
  read_pl:=s;
end;
procedure hi_score;
var i,g,n:byte;
    img:image;
    pl:array[1..6] of player;
    f:file of player;
    sc1,sc:word;
    ir:integer;
    ss:string;
begin
     sc:=score;
     assign(f,'hi_score.dat');
     {$I-}
     reset(f);
     {$I+}
     if ioresult<>0 then begin
     rewrite(f);
     for i:=1  to 5 do
     begin
     pl[i].name:='.......';
     pl[i].sc:='00000';
     write(f,pl[i]);
     end;
     end
     else
     begin
     for i:=1  to 5 do
     begin
     read(f,pl[i]);
     end;
     end;
     close(f);
     j:=5;
     for i:=5 downto 1 do
     begin
     val(pl[i].sc,sc1,ir);
     if sc>sc1 then begin
     dec(j);
     end;
     end;
     n:=j;
     for j:=5 downto n do pl[j+1]:=pl[j];
     if n<5 then begin
     str(sc,ss);
     ss:=copy('00000',1,5-length(ss))+ss;
     pl[n+1].sc:=ss;
     pl[n+1].name:='.......';
     end;
     read_bitmap(shp,'hi.bmp',0);
     bitmap_to_image(shp,img);
     set_bitmap_palette(shp);
     put_image1(0,0,img,true);
     for i:=1 to 5 do
     print_xy(56,(i-1)*18+69,chr(i+48)+'. '+pl[i].name+'  '+pl[i].sc);
     if n<5 then
     scroll_left(20,161,280,18,'all rigth ! you have a hi score ! enter you name and press enter.                       ');
     if n<5 then begin
     pl[n+1].name:=read_pl(92,69+n*18);
     str(sc,ss);
     ss:=copy('00000',1,5-length(ss))+ss;
     pl[n+1].sc:=ss;
     end

     else
     begin
     while not keypressed do
     scroll_left(20,161,280,18,'dont worry ! you time at forward ! press any key.                       ');
     readkey;
     end;
     assign(f,'hi_score.dat');
     rewrite(f);
     for i:=1  to 5 do
     begin
     write(f,pl[i]);
     end;
     close(f);
     clear_image(img);
end;
procedure wait;
begin
while keypressed do readkey;
end;
begin

     red_zap;
     initvga;
     read_al;
     read_bitmap(shp,'first.bmp',0);
     read_bitmap(bpause,'pause.bmp',0);
     read_bitmap(bskel_l,'skel_l.bmp',0);
     read_bitmap(bskel_r,'skel_r.bmp',0);
     read_bitmap(bbomb_u,'bomb_dw.bmp',0);
     read_bitmap(bbomb_d,'bomb_up.bmp',0);
     read_bitmap(boar,'board.bmp',0);
     bitmap_to_image(boar,iboar);
     bitmap_to_image(bskel_l,iskel_l);
     bitmap_to_image(bskel_r,iskel_r);
     bitmap_to_image(bbomb_d,ibomb_d);
     bitmap_to_image(bbomb_u,ibomb_u);
     bitmap_to_image(gw,gwi);
     bitmap_to_image(sc,sci);
     bitmap_to_image(bpause,ipause);

     set_bitmap_palette(shp);
     bitmap_to_image(shp,gl);
     put_image(0,0,gl,false);
     clear_image(gl);
     readkey;
     cleardevice;
     set_pal;
     cleardevice;
     hi_score;
     {for i:=1 to 20 do
     put_image1((i-1)*12,0,alph[i],false);
     for i:=1 to 16 do
     put_image1((i-1)*12,18,alph[i+20],false);
     readkey;}
     i:=1;
     {repeat
     load_pc(shp,'c:\bp\examples\work\0'+pic[i]+'.pc');
     set_bitmap_palette(shp);
     bitmap_to_image(shp,gl);
     for j:=0 to 180 do
     begin
     put_image(j,0,gl);
     delay(10);
     end;
     clear_image(gl);
     inc(i);
     readkey;
     until i=15;}
     {get_image(0,0,129,139,gl);
     save_image(gl,shp,'014.pc');

     readkey;
     halt;}
     
     cleardevice;
     {put_image1(0,0,gwi,false);}

     nexx:=0;
     nx:=1;
     score:=0;
     load_pc(shp,'0'+pic[nx]+'.pc');
     bitmap_to_image(shp,gl);
     set_bitmap_palette(shp);
     setfillstyle(1,33);
     bar(0,0,300,200);
     sss:=0;
     setfillstyle(1,50);
     bar(0,0,320,20);
     for j:=1 to 7 do
     begin
     for i:=9 downto 5 do
     begin
     setcolor(j*10+13+9-i);
     circle(j*15-8,6,i-3);
     if i-3>1 then begin
     setfillstyle(1,j*10+13+9-i);
     floodfill(j*15-8,7,j*10+13+9-i);
     end;
     {print(1,100,3,s);}
     setcolor(j*10+18);
     putpixel(j*15-8,6,j*10+17);
     end;
     end;
     put_image(150,0,ibomb_u,false);
     put_image(165,0,ibomb_d,false);
     put_image(120,0,iskel_l,false);
     put_image(135,0,iskel_r,false);
     FOR I:=0 TO 11 DO get_image(I*15,0,15,13,sh[I+1]);
     clear_image(ibomb_u);
     clear_image(ibomb_d);
     clear_image(iskel_l);
     clear_image(iskel_r);

     cleardevice;
     {for i:=0 to 5 do
     begin
     setfillstyle(1,i+50);
     bar(i+3,i+2,319-i-3,199-i-6);
     end;}
     put_image1(0,0,iboar,true);
     clear_image(iboar);
     setfillstyle(1,50);
     bar(15,13,145,182);
     {rect(15,13,130,169);
     rect(156,13,5,169);
     rect(172,13,132,139);
     rect(172,164,132,18);}
     
     print_xy(172,165,'           ');
     scroll_left(172,165,132,18,'welcom to super sex fantasies ! now you score:00000');
     pri:=0;
     randomize;
     for j:=2 to 6 do
     for i:=1 to 40 do
     begin
     xxx:=random(128);
     yyy:=random(168);
     plan[i+j*40,1]:=xxx;
     plan[i+j*40,2]:=yyy;
     plan[i+j*40,3]:=j;
     end;
     {w=14,h=12,x=17,y=15}
     randomize;

     for i:=0 to 8 do
     for j:=0 to 13 do pole[i,j]:=0;
     repeat
     for i:=1 to 3 do bal[i]:=random(7)+1;
     if random(10)=0 then bal[random(3)+1]:=random(4)+9;
     xx:=4;
     while keypressed do readkey;
     bbb:=false;
     i:=0;
     if pole[xx,3]=0 then begin
     while (i<=10) and (pole[xx,i+3]=0) do
     begin

     wait_s;
     for j:=0 to 11 do
     begin
     if j div 3=j/3 then
     for k1:=1 to 3 do
     begin
     if bal[k1]=11 then bal[k1]:=12 else begin if bal[k1]=12 then bal[k1]:=11;end;
     if bal[k1]=9 then bal[k1]:=10 else begin if bal[k1]=10 then bal[k1]:=9;end;
     end;
     put_image1(17+xx*14,i*12+15+j,sh[bal[1]],false);
     put_image1(17+xx*14,i*12+27+j,sh[bal[2]],false);
     put_image1(17+xx*14,i*12+39+j,sh[bal[3]],false);
     if not bbb then delay((25)*2) else delay(10);
     if odd(j) then pix;
     for  k1:=1 to 1 do
     IF (KEYPRESSED) and (not bbb) then
     begin
     kek:=ord(readkey);
     sss:=xx;
     case kek of
     27:begin
        get_image(30,50,100,100,work);
        put_image(30,50,ipause,false);
        readkey;
        put_image1(30,50,work,false);
        clear_image(work);
        end;
     32:bbb:=true;
     75:if xx>0 then
        begin
        if (pole[xx-1,i+1]=0) and (pole[xx-1,i+2]=0) and (pole[xx-1,i+3]=0) then
        xx:=xx-1;
        end;
     77:if xx<8 then
        begin
        if (pole[xx+1,i+1]=0) and (pole[xx+1,i+2]=0) and (pole[xx+1,i+3]=0) then
         xx:=xx+1;
         end;
     72:begin
           BAL[4]:=BAL[1];
           BAL[1]:=BAL[2];
           BAL[2]:=BAL[3];
           BAL[3]:=BAL[4];
           END;
     80:begin
           BAL[4]:=BAL[3];
           BAL[3]:=BAL[2];
           BAL[2]:=BAL[1];
           BAL[1]:=BAL[4];
           END;
     end;
     if sss>xx then begin
     sss:=sss*14;
     for k:=1 to 14 do
     begin
     sss:=sss-1;
     put_image1(17+sss,i*12+15+j,sh[bal[1]],false);
     put_image1(17+sss,i*12+27+j,sh[bal[2]],false);
     put_image1(17+sss,i*12+39+j,sh[bal[3]],false);
     delay(6);
     end;
     end;
     if sss<xx then begin
     sss:=sss*14;
     for k:=1 to 14 do
     begin
     sss:=sss+1;
     put_image1(17+sss,i*12+15+j,sh[bal[1]],false);
     put_image1(17+sss,i*12+27+j,sh[bal[2]],false);
     put_image1(17+sss,i*12+39+j,sh[bal[3]],false);
     delay(6);
     end;
     end;
     sss:=xx;
     end;
     end;
     inc(i);
     end;
     for j:=1 to 3 do
     pole[xx,i+j-1]:=bal[j];
     repeat
     until not del_bal;
     end else kek:=27;
     until kek=27;
     FOR I:=0 TO 7 DO CLEAR_image(sh[I+1]);
     clear_image(gl);
     wait;
     read_bitmap(shp1,'gameo256.bmp',0);
     set_bitmap_palette(shp1);
     bitmap_to_image(shp1,gl);
     put_image1(0,0,gl,true);
     readkey;
     clear_image(gl);
     cleardevice;
     set_pal;
     hi_score;
     closegraph;
end.