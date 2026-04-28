tunnel = component.proxy(component.list("tunnel")())
tunneluuid = tunnel.getChannel()

signalmapkey = {
  w = {"move", 3},
  [29] = {"move", 0},
  s = {"move", 2},
  [57] = {"move", 1},
  a = {"turn", false},
  d = {"turn", true}
}

signalmapscan = {
  
}

while true do
  signame, siguuid, arg2, arg3, arg4, arg5 = computer.pullSignal()
  
  if signame == "key_down" then
    mod = arg2
    keyname = string.char(arg2):lower()
    scan = arg3
    tosend = signalmapkey[keyname] or signalmapscan[scan]
    if tosend ~= nil then
      tunnel.send(table.unpack(tosend))
    else
      if keyname == "q" then
        computer.shutdown()
      end
    end
  end
end