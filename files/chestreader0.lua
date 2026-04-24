function proxy(name)
  return component.proxy(component.list(name)())
end

robot = proxy("robot")
rm = robot.move
rt = robot.turn

icont = proxy("inventory_controller")
compu = proxy("computer")
modem = proxy("modem")

val_f = 0
val_r = 1
val_l = 2
path = {}
pathr = {val_r, val_r}
ti = table.insert

-- trace path

while true do
  if rm(3) then
    ti(path, val_f)
    ti(pathr, 1, val_f)
  else
    rt(true)
    if rm(3) then
      ti(path, val_r)
      ti(path, val_f)
      ti(pathr, 1, val_l)
      ti(pathr, 1, val_f)
    else
      rt(true)
      rt(true)
      if rm(3) then
        ti(path, val_l)
        ti(path, val_f)
        ti(pathr, 1, val_r)
        ti(pathr, 1, val_f)
      else
        ti(path, val_r)
        ti(path, val_r)
        rt(false)
        break
      end
    end
  end
end

function follow(path, callback)
  if callback ~= nil then
    callback()
  end
  for _, move in ipairs(path) do
    if move == val_f then
      rm(3)
      if callback ~= nil then
        callback()
      end
    elseif move == val_r then
      rt(true)
    else
      rt(false)
    end
  end
end

follow(pathr)

compu.beep(500, 0.5)

total = {}
last = {}

targetreduced = {"Iron", "Gold", "Silver", "Tin", "Lead", "Copper",
"Cobalt", "Ardite", "Invar", "Electrum", "Steel", "Nickel",
"Platinum", "Bronze"}
targetother = {"Nether Quartz", "Redstone", "Diamond", "Glowstone Dust"}
targetblock = {"Block of Quartz", "Block of Redstone", "Block of Diamond", "Glowstone"}

function tryadd(name, count)
  for i, blockname in ipairs(targetblock) do
    if blockname == name then
      total[targetother[i]] = (total[targetother[i]] or 0) + 9
      return
    end
  end
  for _, itemname in ipairs(targetother) do
    if itemname == name then
      total[itemname] = (total[itemname] or 0) + 1
      return
    end
  end
  for _, itemname in ipairs(targetreduced) do
    if (itemname .. " Ingot") == name then
      total[itemname] = (total[itemname] or 0) + 1
      return
    elseif ("Block of " .. itemname) == name then
      total[itemname] = (total[itemname] or 0) + 9
      return
    end
  end
end

function check()
  local size = icont.getInventorySize(3)
  if size == nil then
    return -- nothing lol
  end
  local rolling = false
  for i = 1, size do
    local info = icont.getStackInSlot(3, i)
    if info ~= nil then
      local entry = last[i]
      if last[i] == nil then
        rolling = true
        break
      end
      if entry[0] ~= info.label or entry[1] ~= info.size then
        rolling = true
        break
      end
    end
  end
  if not rolling then
    return -- this is the same chest as last time
  end
  last = {}
  for i = 1, size do
    local info = icont.getStackInSlot(3, i)
    if info ~= nil then
      last[i] = {info.label, info.size}
      tryadd(info.label, info.size)
    end
  end
end

function checksurrounding()
  rt(true)
  check()
  rt(false)
  check()
end

function transmit()
  modem.open(0x0101)
  modem.broadcast(0x0101, "R_OPEN")
  local remote
  while true do
    local name, localaddress, raddr, _, _, msg = computer.pullSignal()
    if name == "modem_message" and msg == "C_LINK" then
      remote = raddr
      break
    end
  end
  for item, amount in pairs(total) do
    compu.beep(300, 0.5)
    modem.send(remote, 0x0101, "R_TRANSMIT", "R_ENTRY", item, amount)
    while true do
      local name, laddr, raddr, port, dist, msg = computer.pullSignal()
      if raddr == remote and msg == "C_QUERY" then
        break
      end
    end
  end
  compu.beep(800, 0.5)
  modem.send(remote, 0x0101, "R_TRANSMIT", "R_END")
  modem.close(0x0101)
end

while true do
  total = {}
  last = {}
  follow(path, checksurrounding)
  follow(pathr)
  rm(1)
  follow(path, checksurrounding)
  follow(pathr)
  rm(0)
  transmit()
end