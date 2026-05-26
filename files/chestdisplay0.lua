_g = component.proxy(component.list("gpu")())
screenaddress = component.list("screen")()
_g.bind(screenaddress)
_g.setResolution(50, 16)

_m = component.proxy(component.list("modem")())
_m.open(0x0101)

function onmodemrecieve(localaddr, remoteaddr, port, dist, message)
  if message ~= "R_OPEN" then
    return
  end
  
  _m.send(remoteaddr, 0x0101, "C_LINK")
  
  messageindex = 0
  _g.fill(1, 1, 50, 16, " ")
  while true do
    computer.beep(250, 0.5)
    local name, laddr, raddr, port, dist, msg, msg2, item, count = computer.pullSignal()
    if raddr == remoteaddr and name == "modem_message" and msg == "R_TRANSMIT" then
      if msg2 == "R_END" then
        break
      end
      messageindex = messageindex + 1
      y = messageindex
      x = 1
      if y > 16 then
        y = y - 16
        x = 26
      end
      _g.set(x, y, item .. ": " .. tostring(count))
      _m.send(remoteaddr, 0x0101, "C_QUERY")
    end
  end
  computer.beep(750, 0.5)
end

local saywait = false
function waittext(force)
  if force ~= nil then
    saywait = force
  else
    saywait = not saywait
  end
  local towrite = "Waiting..."
  if not saywait then
    towrite = "          "
  end
  _g.set(26, 16, towrite)
end
while true do
  local name, localaddr, remoteaddr, port, dist, msg = computer.pullSignal(1)
  if name == "modem_message" then
    waittext(false)
    onmodemrecieve(localaddr, remoteaddr, port, dist, msg)
  elseif name == nil then
    waittext()
  end
end