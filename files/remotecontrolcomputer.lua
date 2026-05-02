modemuuid = component.list("modem")() -- The computer has one card, which it uses to communicate with the server
modem = component.proxy(modemuuid)
tunneluuid = component.list("tunnel")()
tunnel = component.proxy(tunneluuid)
screenuuid = component.list("screen")()
component.invoke(screenuuid, "turnOn")
gpu = component.proxy(component.list("gpu")())
gpu.bind(screenuuid)
drive = component.proxy(component.list("drive")())

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

driveoffsets = { -- 1 is added for r/w operations
  posx = 0,
  posy = 4,
  posz = 8,
  roty = 12,
  dronemodemuuid = 64,
  chunkdata = 4096,
}

drivesizes = {
  posx = 4,
  posy = 4,
  posz = 4,
  roty = 4,
  dronemodemuuid = 36,
}

drivestart = {}
driveend = {}

for k, v in pairs(driveoffsets) do
  drivestart[k] = v + 1
  driveend[k] = v + (drivesizes[k] or 0)
end

drivetypes = { -- Numbers are stored little-endian (0x0a0b0c0d -> 0d 0c 0b 0a) for r/w operations
  posx = "number",
  posy = "number",
  posz = "number",
  roty = "number",
  dronemodemuuid = "string",
}

function readnumoff(offset, size)
  num = 0
  for i = offset, offset + size do
    num = num * 256 + drive.readByte(i)
  end
  return num
end

function read(key)
  if drivetypes[key] == "number" then
    return readnumoff(driveoffsets[key], drivesizes[key])
  elseif drivetypes[key] == "string" then
    str = ""
    for i = drivestart[key], driveend[key] do
      local rd = drive.readByte(i)
      if rd == 0 then
        break
      end
      str = str .. string.char(rd)
    end
    return str
  end
end

function write(key, value)
  if drivetypes[key] == "number" then
    for i = drivestart[key], driveend[key] do
      drive.writeByte(i, value % 256)
      value = value / 256
    end
  elseif drivetypes[key] == "string" then
    for i = drivestart[key], driveend[key] do
      drive.writeByte(i, string.byte(value))
      value = value:sub(2)
    end
  end
end

function gpwritenew(line1, line2)
  local xres, yres = gpu.getResolution()
  
  for i = yres, 3, -2 do
    gpu.copy(1, i, xres, 2, 0, 2)
  end
  
  gpu.set(1, 1, line1)
  gpu.set(1, 2, line2)
end

while true do
  local siginfo = {computer.pullSignal()}
  signame = siginfo[1]
  
  if signame == "modem_message" then -- No other network cards are present.
    message1 = siginfo[6]
    
    if message1 == "ping" then
      tunnel.send("ping_return")
    elseif message1 == "read" then
      local red = read(siginfo[7])
      gpwritenew("robot read " .. siginfo[7], "\"" .. tostring(red) .. "\"")
      tunnel.send(red)
    elseif message1 == "write" then
      gpwritenew("robot write " .. siginfo[7], "\"" .. tostring(siginfo[8]) .. "\"")
      write(siginfo[7], siginfo[8])
    end
  elseif signame == "key_down" then
    keyname = string.char(siginfo[3]):lower()
    keybyte = string.byte(keyname)
    scan = siginfo[4]
    tosend = signalmapkey[keyname] or signalmapkey[keybyte] or signalmapscan[scan]
    if tosend ~= nil then
      tunnel.send(table.unpack(tosend))
    else
      if keyname == "q" then
        tunnel.send("shutdown")
        computer.shutdown()
      end
    end
  end
end