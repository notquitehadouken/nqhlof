tunneluuid = component.list("tunnel")()
tunnel = component.proxy(tunneluuid)
modemuuid = component.list("modem")()
modem = component.proxy(modemuuid)
robot = component.proxy(component.list("robot")())
dronemodemuuid = ""

modem.open(0xA1)
robot.setLightColor(0x000000)

function signalFromModem()
  while true do
    local siginfo = {computer.pullSignal()}
    if siginfo[2] == modemuuid and siginfo[3] == dronemodemuuid then
      return siginfo
    end
    computer.pushSignal(table.unpack(siginfo))
  end
end

function signalFromTunnel()
  while true do
    local siginfo = {computer.pullSignal()}
    if siginfo[2] == tunneluuid then
      return siginfo
    end
    computer.pushSignal(table.unpack(siginfo))
  end
end

function read(key)
  tunnel.send("read", key)
  return signalFromTunnel()[6]
end

function write(key, value)
  tunnel.send("write", key, value)
end

dronemodemuuid = read("dronemodemuuid")

if dronemodemuuid == "" then
  robot.setLightColor(0xFF0000)
  modem.broadcast(0xA1, nil)
  while true do
    local sig = {computer.pullSignal()}
    if sig[2] == modemuuid and sig[6] == "link" then
      dronemodemuuid = sig[3]
      break
    end
  end
  write("dronemodemuuid", dronemodemuuid)
  computer.shutdown()
end

robot.setLightColor(0x0000FF)

modem.send(dronemodemuuid, 0xA1, modemuuid)
signalFromModem()
modem.send(dronemodemuuid, 0xA1)

posx = read("posx")
posy = read("posy")
posz = read("posz")
roty = read("roty")

while true do
  local siginfo = {computer.pullSignal()}
  signame = siginfo[1]
  siggenerator = siginfo[2]
  
  if siggenerator == modemuuid or siggenerator == tunneluuid then
    if signame == "modem_message" then
      messagesender = siginfo[3]
      port = siginfo[4]
      dist = siginfo[5]
      message1 = siginfo[6]
      message2 = siginfo[7]
      if siggenerator == tunneluuid then
        if message1 == "ping" then
          tunnel.send("ping_return")
        elseif message1 == "shutdown" then
          computer.shutdown()
        elseif message1 == "move" then
          robot.move(message2)
        elseif message1 == "turn" then
          robot.turn(message2)
        end
      elseif siggenerator == modemuuid then
        if message1 == "ping" then
          modem.send(messagesender, port, "ping_return")
        end
      end
    end
  end
end