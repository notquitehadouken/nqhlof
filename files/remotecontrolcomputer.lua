tunneluuid = component.list("tunnel")()
tunnel = component.proxy(tunneluuid)

signalmapkey = {
  w = {"move", 3},
  s = {"move", 2},
  a = {"turn", false},
  d = {"turn", true}
}

signalmapscan = {
  [29] = {"move", 0},
  [57] = {"move", 1},
}

while true do
  signame, siggenuuid, arg2, arg3, arg4, arg5 = computer.pullSignal()
  
  computer.beep(200, 0.15)
  if signame == "key_down" then
    computer.beep(350, 0.15)
    mod = arg2
    keyname = string.char(arg2):lower()
    keybyte = string.byte(keyname)
    scan = arg3
    tosend = signalmapkey[keyname] or signalmapkey[keybyte] or signalmapscan[scan]
    if tosend ~= nil then
      computer.beep(500, 0.15)
      tunnel.send(table.unpack(tosend))
    else
      if keyname == "q" then
        tunnel.send("shutdown")
        computer.shutdown()
      end
    end
  end
end