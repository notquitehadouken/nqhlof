-- I have too many files for this.
-- This one is basically just a 4-hard drive API that only supports reading entire sectors.

invoke = component.invoke

local drives = {}
driveiter = component.list("drive")
while true do
  local driveaddr = driveiter()
  if driveaddr == nil then
    break
  end
  table.insert(drives, driveaddr)
  invoke(driveaddr, "setLabel", "Drive " .. tostring(#drives))
end
modemaddr = component.list("modem")
invoke(modemaddr, "open", 0xA1)

while true do
  local sig = {computer.pullSignal()}
  if sig[6] == "read" then
    local sector = sig[7] -- 0-indexed
    local sectorcount = invoke(drives[1], "getCapacity") / invoke(drives[1], "getSectorSize")
    local drive = drives[math.floor(sector / sectorcount) + 1]
    local offset = sector % sectorcount
    invoke(modemaddr, "send", sig[3], 0xA1, invoke(drive, "readSector", offset))
  elseif sig[6] == "write" then
    local sector = sig[7]
    local sectorcount = invoke(drives[1], "getCapacity") / invoke(drives[1], "getSectorSize")
    local drive = drives[math.floor(sector / sectorcount) + 1]
    local offset = sector % sectorcount
    invoke(drive, "writeSector", offset, sig[8])
  elseif sig[6] == "querystats" then
    invoke(modemaddr, "send", sig[3], 0xA1, invoke(drives[1], "getCapacity"), invoke(drives[1], "getSectorSize"), #drives)
  end
end