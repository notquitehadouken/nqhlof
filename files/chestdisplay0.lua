gpu = component.proxy(component.list("gpu")())
screenaddress = component.list("screen")()
gpu.bind(screenaddress)
gpu.setResolution(50, 16)

modem = component.proxy(component.list("modem")())
modem.open(0x0101)

function onmodemrecieve(name, localaddr, remoteaddr, port, dist, message)
  if message ~= "R_OPEN" then
    return
  end
  modem.send(remoteaddr, 0x0101, "C_LINK")
  
  messageindex = 0
  gpu.fill(1, 1, 50, 16, " ")
  while true do
    local success, _, _, _, msg, msg2, item, count = event.pull(30, "modem_message", nil, remoteaddr, nil, "R_TRANSMIT")
    if msg2 ~= "R_ENTRY" then
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
    event.send(remoteaddr, 0x0101, "C_QUERY")
  end
end

event.listen("modem_message", onmodemrecieve)