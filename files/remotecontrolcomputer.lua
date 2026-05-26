C=component
Cl=C.list
Cp=C.proxy
K=computer
Kl=K.pullSignal
Kh=K.pushSignal
B=bit32
Bo=B.bor
Ba=B.band
Br=B.rshift
Bl=B.lshift
_mu=Cl"modem"()_m=Cp(_mu)_tnu=Cl"tunnel"()_tn=Cp(_tnu)_su=Cl"screen"()Cp(_su).turnOn()_g=Cp(Cl"gpu"())_g.bind(_su)_gs=_g.set
_d=Cp(Cl"drive"())_h=Cp(Cl"hologram"())
hs=_h.setPaletteColor
hs(1,0xFFFFFF)hs(2,255)hs(3,0xFF0000)hs=_h.set
_T=table
_Ti=_T.insert
_Tu=_T.unpack
_M=math
Mf=_M.floor
_S=string
Sb=_S.byte
Sc=_S.char
T=true
F=false
N=nil
k_v={q=T,w=T,e=T,a=T,s=T,d=T,r=T,t=T,y=T,f=T,g=T,h=T}
Am="move"At="turn"d_o={px=0,py=4,pz=8,dmu=64,ci=4084,cco=4088,sco=4092,cdat=4096}d_s={px=4,py=4,pz=4,dmu=36,ci=4,cco=4,sco=4}d_t={px="n",py="n",pz="n",dmu="s",ci="n",cco="n",sco="n"}function Sf(addr)while T do local s={Kl()}if s[2]==addr then return s end Kh(_Tu(s))end end
function Rno(o)local n=0 for i=o+1,o+4 do n=n*256+_d.readByte(i)end if Ba(n,_Bl(1,31))>0 then n=n-2^32 end return n end
function Wno(o, v)v=Br(v,0)for i= o +1, o +4 do _d.writeByte(i, v %256)v=Mf(v /256)if v==0 then break end end end
function read(k)if d_t[k]=="n"then return Rno(d_o[k])elseif d_t[k]=="s"then str=""for i=1,d_s[k]do local r=_d.readByte(i+d_o[k])if r==0 then break end str=str..Sc(r) end return str end end
function write(k,v)if d_t[k]=="n"then Wno(d_o[k],v)elseif d_t[k]=="s"then for i=1,d_s[k]do _d.writeByte(i+d_o[k],Sb(v))v=v:sub(2)end end end
function Ou()return d_o.cdat+16*read"cco"end
function Oi()write("cco",read"cco"+1)end
function si()write("sco",read"sco"+1)end
function Lt(s,v)while T do if Rno(s)==v then return T,s end local n=Rno(s+4)if n==0 then return F,s end s=n end end
sl={}function sg(x,z)x=Mf(x/4)z=Mf(z/4)if sl[x]and sl[x][z]then return sl[x][z]end
local s,X=Lt(d_o.cdat,x)if not s then local n=Ou()Oi()Wno(X+4,n)Wno(n,x)local Z=Ou()Oi()Wno(n+8,Z)Wno(Z,z)si()local sco=read"sco"Wno(Z+8,sco)return sco end local Z s,Z=Lt(X+8,z)if not s then local n=Ou()Oi()Wno(X+8,n)Wno(n,z)Wno(Z+4,n)si()local m=read"sco"Wno(n+8,m)return m end local sec=Rno(Z+8)sl[tostring(x)..""..tostring(z)]=sec return sec end
function mb(dat,bit,set)local by=Mf(bit/8)+1 local bi=Bl(1,bit%8)local split={dat:byte(1,512)}if set then split[by]=Bo(bi,split[by])else split[by]=Ba(255-bi,split[by])end return Sc(_Tu(split))end
function gb(dat,bit)local by=Mf(bit/8)local bi=Bl(bit%8)local split={dat:byte(1,512)}return Ba(split[by],bi)end
cx,cz,cs,cc=N
function wo(nx,nz)
if nx==cx and nz==cz then
 return
end
_m.open(161)
if cc then
 _m.broadcast(161,"write",cs,cc)
end
cx=nx
cz=nz
if not cx then
 cs=N
 cc=N
 return
end
cs=sg(cx,cz)
_m.broadcast(161,"read",cs)
cc=Sf(_mu)
_m.close(161)
end
function awb(inchunk)
for _,b in ipairs(inchunk)do
 cc=mb(cc,b[2]*16+(b[3]%4)*4+(b[1]%4),b[4])
end
end
if read"ci"==0 then
local o=d_o.cdat
Wno(o+8,o+16)
write("cco",2)
write("sco",1)
write("ci",1)
end

local upd
while T do
local si={Kl(1)}
sm=si[1]
if sm==N then
 _g.clear()
 _tn.send"query"
 local t={}
 while T do
   local s=Sf(_tnu)
   if not s[6]then
     break
   end
   _Ti(t,s[6])
 end
 for i,v in ipairs(t)do
   _gs(1+((i-1)%4)*20,1+Mf((i-1)/4),v)
 end
elseif sm=="modem_message"then
 local m1=si[6]
 if m1=="ping"then
   _tn.send"ping_return"
 elseif m1=="read"then
   _tn.send(read(si[7]))
 elseif m1=="write"then
    upd=T
   write(si[7],si[8])
 elseif m1=="block_start"then
   local bk={}
   while T do
     local sig=Sf(_tnu)
     if sig[6]=="end"then
       break
     end
     local k=tostring(Mf(sig[6]/4)).."."..tostring(Mf(sig[8]/4))
     bk[k]=bk[k]or{}
     _Ti(bk[k],{sig[6], sig[7], sig[8], sig[9]})
   end
   for _,v in bk do
     wo(Mf(v[1][1]/4),Mf(v[1][3]/4))
     awb(v)
   end
 end
elseif sm=="key_down"then
 kn=Sc(si[3])
 scan=si[4]
 if k_v[kn]or k_v[kn:lower()]or k_v[scan]then
   _tn.send("key_down", kn, scan)
 else
   if kn=="L"then
     wo()
     _tn.send"shutdown"
     K.shutdown()
   end
 end
end
if upd then
    upd=N
end
end