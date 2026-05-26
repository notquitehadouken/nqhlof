_tnu = component.list("tunnel")()
_tn = component.proxy(_tnu)
_tn.setWakeMessage("poweron")
_mu = component.list("modem")()
_m = component.proxy(_mu)
_r = component.proxy(component.list("robot")())
_i = component.proxy(component.list("inventory_controller")())
dmu = ""

_m.open(0xA1)
_r.setLightColor(0)

function signalFromDrone()
  while true do
    local siginfo = {computer.pullSignal()}
    if siginfo[2] == _mu and siginfo[3] == dmu then
      return siginfo
    end
    computer.pushSignal(table.unpack(siginfo))
  end
end

function signalFromHome()
  while true do
    local siginfo = {computer.pullSignal()}
    if siginfo[2] == _tnu then
      return siginfo
    end
    computer.pushSignal(table.unpack(siginfo))
  end
end

function sendDrone(...)
  _m.send(dmu, 0xA1, ...)
end

function sendHome(...)
  _tn.send(...)
end

function read(key)
  _tn.send("read", key)
  return signalFromTunnel()[6]
end

function write(key, value)
  _tn.send("write", key, value)
end

dmu = read("dronemodemuuid")

if dmu == "" then
  _r.setLightColor(0xFF0000)
  _m.broadcast(0xA1, nil)
  while true do
    local sig = {computer.pullSignal()}
    if sig[2] == _mu and sig[6] == "link" then
      dmu = sig[3]
      break
    end
  end
  write("dronemodemuuid", dmu)
  computer.shutdown()
end

sendDrone(_mu)
signalFromDrone()
sendDrone()

_r.setLightColor(0x0000FF)

posx = read("posx")
posy = read("posy")
posz = read("posz")
rot = 0

function crappysincos(degree)
  local rotto = degree % 4
  if rotto == 0 then
    return 0, 1
  elseif rotto == 1 then
    return 1, 0
  elseif rotto == 2 then
    return 0, -1
  elseif rotto == 3 then
    return -1, 0
  end
end

function dirtorot(dir)
  if dir <= 1 then
    return false
  elseif dir == 3 or dir == 4 then
    return dir - 3
  elseif dir == 2 then
    return 2
  else
    return 3
  end
end

function getxyzdir(dir)
  if dir == 1 then
    return 0, 1, 0
  elseif dir == 0 then
    return 0, -1, 0
  end
  local ForwardX, ForwardZ = crappysincos(rot + dirtorot(dir))
  return ForwardX, 0, ForwardZ
end

function move(dir)
  if not _r.move(dir) then
    return
  end
  local dx, dy, dz = getxyzdir(dir)
  posx = posx + dx
  posy = posy + dy
  posz = posz + dz
  write("posx", posx)
  write("posy", posy)
  write("posz", posz)
end

function turn(dir)
  if dir then
    rot = (rot + 1) % 4
  else
    rot = (rot - 1) % 4
  end
  _r.turn(dir)
end

sendDrone("hone", posx, posy, posz)
signalFromDrone()
sendDrone("move", 0, -1, 1)
signalFromDrone()

for i = 1, 4 do
  if _i.getInventorySize() == 8 then
    break
  end
  _r.turn(true)
end

sendHome("power")

while true do
  local siginfo = {computer.pullSignal()}
  signame = siginfo[1]
  siggenerator = siginfo[2]
  
  if siggenerator == _mu or siggenerator == _tnu then
    if signame == "modem_message" then
      messagesender = siginfo[3]
      port = siginfo[4]
      dist = siginfo[5]
      message1 = siginfo[6]
      message2 = siginfo[7]
      if siggenerator == _tnu then
        if message1 == "ping" then
          _tn.send("ping_return")
        elseif message1 == "shutdown" then
          sendDrone("hone", 0, 0, 0)
          sendDrone("shutdown")
          for i = 1, rot do
            _r.turn()
          end
          computer.shutdown()
        elseif message1 == "move" then
          _r.move(message2)
        elseif message1 == "turn" then
          turn(message2)
        elseif message1 == "query" then
          
        end
      elseif siggenerator == _mu then
        if message1 == "help" then
          tunnel.send("help", "drone: " .. message2)
        elseif message1 == "reading" then
          tunnel.send("reading", "drone", message2)
        elseif message1 == "ping" then
          _m.send(messagesender, port, "ping_return")
        end
      end
    end
  end
end