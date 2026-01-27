-- Draft 1
k = component
c = computer
r = k.proxy(k.list("robot"))

tv = 0
mv = 0
hv = 0
yv = 0

mo = r.move
tr = r.turn
du = r.durability
sw = r.swing
pl = r.place
Is = r.select
Ic = r.count
Id = r.drop
Ib = {32,1,1,1,1,1,1}

tt = {0,1,0,-1}

function BP(high, long)
  c.beep(high and 2000 or 1000, long and 1 or 0.25)
end

function hf()
  return tt[tv+1]
end

function mf()
  return -tt[4-tv]
end

function turn(clockwise)
  delta = clockwise and 1 or -1
  tv = (tv + delta) % 4
  tr(clockwise)
end

function i80()
  turn()
  turn()
end

function turnstartdir()
  for i = 1, tv do
    tr()
  end
  tv = 0
end

function tmv(dir)
  if not mo(dir) then
    sw(dir)
    return mo(dir)
  end
  return true
end

function move(back)
  if not tmv(back and 2 or 3) then
    return false
  end
  n = back and 1 or -1
  hv = hv + hf()*n
  mv = mv + mf()*n
  return true
end

function moveVertical(down)
  if not tmv(down and 0 or 1) then
    return false
  end
  yv = yv + (down and -1 or 1)
  return true
end

function righttomainline()
  turnstartdir()
  while hv ~= 0 and yv ~= 0 do
    if hv ~= 0 then
      BP(true)
      if hv < 0 then
        turn(1)
      else
        turn()
      end
      for i = 1, math.abs(hv) do
        move(3)
      end
    end
    if yv ~= 0 then
      BP(false)
      for i = 1, math.abs(yv) do
        moveVertical(yv > 0)
      end
    end
    if hv ~= 0 or yv ~= 0 then
      BP(false, true)
    end
  end
  turnstartdir()
end

function mineuseful(dropuseless, odir)
  odir = odir or 3
  if not sw(odir) then
    return false
  end
  for i,v in ipairs(Ib) do
    Is(i)
    over = Ic() - v
    if over > 0 then
      if dropuseless then
        Id(odir)
      else
        pl(odir)
      end
    end
  end
end

function mine5way()
  turn()
  mineuseful()
  i80()
  mineuseful()
  turn()
  mineuseful(false, 1)
  mineuseful(false, 0)
  mineuseful()
  BP(true)
end

function returnhome()
  righttomainline()
  i80()
  for i = 1, mv do
    move()
  end
  mv = 0
end

while 1 do
  batterycurrent = c.energy() / bmaxcap
  
  recover = batterycurrent < 0.5 or du() <= (250 + math.abs(hv) + math.abs(yv))
  
  if recover then
    returnhome()
  end
  
  mine5way()
  move()
  
  Is(1)
  if Ic() > 1 then
    pl(0)
  end

end
