invoke = component.invoke

local drives = {}
driveiter = component.list("drive")
for driveaddr in driveiter do
  table.insert(drives, driveaddr)
  invoke(driveaddr, "setLabel", "Drive " .. tostring(#drives))
end

modemaddr = component.list("modem")
invoke(modemaddr, "open", 0xA1)

sectorsize = invoke(drives[1], "getSectorSize")
sectorcount = invoke(drives[1], "getCapacity") / sectorsize

while true do
  local sig = {computer.pullSignal()}
  if sig[6] == "read" then
    local sector = sig[7]
    local drive = drives[math.floor(sector / sectorcount) + 1]
    local offset = sector % sectorcount
    invoke(modemaddr, "send", sig[3], 0xA1, invoke(drive, "readSector", offset + 1))
  elseif sig[6] == "write" then
    local sector = sig[7]
    local drive = drives[math.floor(sector / sectorcount) + 1]
    local offset = sector % sectorcount
    invoke(drive, "writeSector", offset + 1, sig[8])
  elseif sig[6] == "querystats" then
    invoke(modemaddr, "send", sig[3], 0xA1, invoke(drives[1], "getCapacity"), invoke(drives[1], "getSectorSize"), #drives)
  end
end