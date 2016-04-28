procedure red_zap;
var f:file of rn;
   r:rndxy;
begin
  assign(f,'random.pix');
  reset(f);
  {seek(f,filesize(f));
  r.x:=0;
  r.y:=0;
  write(f,r);
  r.x:=105;
  r.y:=16;
  write(f,r);}
  read(f,rndd);
  close(f);
end;
{procedure zap;
var t,k,num,i,j:word;
    b1,b2:byte;
    f:file of byte;
begin
   randomize;
   num:=1;
   assign(f,'random.pix');
   rewrite(f);
   repeat
   b:=random(140);
   b1:=random(130);
   t:=0;
   for j:=1 to num do
   if (rnd[1,j]=b) and (rnd[2,j]=b1) then t:=1;
   if t=0 then begin write(f,b,b1);rnd[2,num]:=b1;rnd[1,num]:=b;num:=num+1;writeln(num,'-',rnd[1,num-1],'-',rnd[2,num-1]);end;
   until num=18200;
   close(f);
end;}
procedure initvga;
begin
     gd:=installuserdriver('svga256',nil);
     gm:=0;
     initgraph(gd,gm,'');
end;
procedure set_pal;
var i:byte;
begin
{for i:=1 to 128 do setpalette(i,i);}
for i:=1 to 10 do
begin
setrgbpalette(i+19,i*6,i*6,6);
setrgbpalette(i+29,i*6,6,i*6);
setrgbpalette(i+39,6,i*6,i*6);
setrgbpalette(i+49,i*6,i*6,i*6);
setrgbpalette(i,i*6,i*6,i*6);
setrgbpalette(i+59,i*6,6,6);
setrgbpalette(i+69,6,i*6,6);
setrgbpalette(i+79,6,6,i*6);
end;
setrgbpalette(255,0,0,0);
end;
procedure clear_image(var im:image);
begin
  freemem(im.p,im.w*im.h);
end;
procedure get_image(x,y,w,h:integer;var im:image);
var size,ad:integer;
P:POINTER;
begin
  size:=w*h;
  ad:=y*320+x;
  getmem(im.p,size);
  p:=im.p;
  im.w:=w;
  im.h:=h;
  asm
  push ds
  push es
  mov ax,$a000
  mov ds,ax
  mov si,ad
  les di,p
  mov cx,h
@1:PUSH SI
push cx
  mov cx,w
  cld
  rep movsb
  pop cx
  POP SI
  ADD SI,320
  loop @1
  pop es
  pop ds
  end;
end;
procedure get_image1(x,y,w,h:integer;var im:image);
var size,ad:integer;
P:POINTER;
begin
  size:=w*h;
  ad:=y*320+x;
  p:=im.p;
  im.w:=w;
  im.h:=h;
  asm
  push ds
  push es
  mov ax,$a000
  mov ds,ax
  mov si,ad
  les di,p
  mov cx,h
@1:PUSH SI
push cx
  mov cx,w
  cld
  rep movsb
  pop cx
  POP SI
  ADD SI,320
  loop @1
  pop es
  pop ds
  end;
end;
procedure wait_s;assembler;
  asm
  mov dx,$3da
  mov ah,8
@7:in al,dx
  and al,ah
  cmp al,0
  je @7
@8:in al,dx
  and al,ah
  cmp al,0
  jne @8
  end;

procedure put_image1(x,y:word;im:image;b:boolean);
var ad:integer;
begin
  ad:=y*320+x;
  if b then wait_s;
  asm
  push ds
  push es
  mov ax,$a000
  mov es,ax
  mov di,ad
  lds si,im.p
  mov cx,im.h
@1:PUSH DI
   push cx

  mov cx,im.w
  cld
  rep movsb
  pop cx
  POP DI
  ADD DI,320
  loop @1
  pop es
  pop ds
  end;
end;
procedure put_image_wh(x,y:word;im:image;ww,hh:word;b:boolean);
var ad:integer;
    www:word;
begin
  ad:=y*320+x;
  if hh=0 then hh:=im.h;
  if ww=0 then begin ww:=im.w;www:=0;end else www:=im.w-ww;
  if b then wait_s;
  asm
  push ds
  push es
  mov ax,$a000
  mov es,ax
  mov di,ad
  lds si,im.p
  mov cx,hh
@1:PUSH DI
   push cx

  mov cx,ww
  cld
  rep movsb
  add si,www
  pop cx
  POP DI
  ADD DI,320
  loop @1
  pop es
  pop ds
  end;
end;

procedure put_image(x,y:word;im:image;b:boolean);
var ad:integer;
begin
  ad:=y*320+x;
  if b then wait_s;
  asm
  push ds
  push es
  {mov dx,$3da
  mov ah,8
@7:in al,dx
  and al,ah
  cmp al,1
  je @7
@8:in al,dx
  and al,ah
  cmp al,1
  jne @7}
  mov ax,$a000
  mov es,ax
  mov di,ad
  lds si,im.p
  mov cx,im.h
@1:PUSH DI
   push cx

  mov cx,im.w
@2:mov al,ds:[si]
   cmp al,0
   je @3
   mov es:[di],al

@3:inc si
   inc di
  loop @2
  pop cx
  POP DI
  ADD DI,320
  loop @1
  pop es
  pop ds
  end;
end;
procedure print(x,y:word;c:byte;s:string);
var ad,i,j:word;
    cc:byte;
const  col:array[1..13] of byte=(15,4,5,6,7,8,9,9,9,8,7,6,5);
begin
  settextstyle(2,0,5);
  setcolor(255);
  outtextxy(x,y,s);
  i:=textwidth(s);
  j:=textheight(s);
  ad:=x+y*320;
  cc:=c*10+10;
  asm
  jmp @5
  @6:db 9,9,9,9,9,4,5,6,7,8,9,8,7,6,5,4,3,2
  @5:
  push ds
  push es
  mov ax,$a000
  mov es,ax
  mov ax,seg @6
  mov ds,ax
  mov dx,0
  mov di,offset @6
  mov si,ad
@3:push si
  mov cx,i
@1:mov al,es:[si]
  cmp al,255
  jne @2
  cmp dx,0
  je @4
  mov dx,0
@4:mov al,byte ptr ds:[di]
  mov ah,cc
  add al,ah
  mov es:[si],al
  jmp @7
@2:
   {mov al,52
   mov es:[si],al}
@7:inc si
  loop @1
  pop si
  add si,320
  inc di
  inc dx
  cmp dx,6
  jne @3
  pop es
  pop ds
  end;
end;
procedure rect(x,y,w,h:word);
var i:byte;
begin
  for i:=5 downto 0 do
  begin
  setfillstyle(1,50+i);
  bar(x-i,y-i,x+i+w,y+i+h);
  end;
end;
