gpu = component.proxy(component.list("gpu")())
screenaddress = component.list("screen")()
gpu.bind(screenaddress)
gpu.setResolution(50, 16)

modem = component.proxy(component.list("modem")())
modem.open(0x0101)

function onmodemrecieve(localaddr, remoteaddr, port, dist, message)
  if message ~= "R_OPEN" then
    return
  end
  
  modem.send(remoteaddr, 0x0101, "C_LINK")
  
  messageindex = 0
  gpu.fill(1, 1, 50, 16, " ")
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
      gpu.set(x, y, item .. ": " .. tostring(count))
      modem.send(remoteaddr, 0x0101, "C_QUERY")
    end
  end
  computer.beep(750, 0.5)
end

while true do
  local name, localaddr, remoteaddr, port, dist, msg = computer.pullSignal()
  if name == "modem_message" then
    onmodemrecieve(localaddr, remoteaddr, port, dist, msg)
  end
end