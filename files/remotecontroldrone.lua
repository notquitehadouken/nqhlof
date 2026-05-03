robotuuid = "%s"
unsafe = robotuuid:len() == 2

modemuuid = component.list("modem")()
modem = component.proxy(modemuuid)
drone = component.proxy(component.list("drone")())
eeprom = component.proxy(component.list("eeprom")())

modem.open(0xA1)
drone.setLightColor(0x000000)

if unsafe then -- This is most likely a first boot, as the target modem address was unset.
  drone.setLightColor(0xFF0000)
  while true do
    local signext = {computer.pullSignal(5)}
    if signext[1] == nil then
      break -- No secondary signal was recieved after wakeup.
    end
    if signext[1] == "modem_message" and signext[5] <= 2.25 then -- Next to robot
      computer.beep(1250)
      eeprom.set(eeprom.get():format(signext[3]))
      eeprom.setLabel(eeprom.getLabel() .. " (set)")
      modem.send(signext[3], 0xA1, "link")
      modem.setWakeMessage(signext[3])
      break
    end
  end
  computer.shutdown()
end

modem.send(robotuuid, 0xA1)
while true do
  local sig = {computer.pullSignal(3)}
  if sig[1] == nil then
    computer.shutdown()
  end
  if sig[3] == robotuuid then
    break
  end
end

drone.setLightColor(0x0000FF)

function send(...)
  modem.send(robotuuid, 0xA1, ...)
end

function recieve()
  while true do
    local sig = {computer.pullSignal()}
    if sig[1] == "modem_message" and sig[3] == robotuuid then
      return sig
    end
  end
end

function ping()
  send("ping")
  return recieve()
end

x = 0
y = 0
z = 0

function dmo(dx, dy, dz)
  x = x + dx
  y = y + dy
  z = z + dz
  drone.move(dx, dy, dz)
end

function waitstatic() -- returns distance from destination once stopped
  local s = os.clock()
  local waiting = false
  while true do
    local vel = drone.getVelocity()
    local off = drone.getOffset()
    drone.setStatusText(tostring(vel) .. "!\n" .. tostring(off) .. "!")
    if vel < 0.001 and off < 0.001 then
      return 0
    end
    local dt = os.clock() - s
    if dt >= 0.25 and vel < 0.001 then -- we have stopped early
      if not waiting then
        waiting = true
      else
        return off
      end
    else
      waiting = false
    end
  end
end

function dmos(dx, dy, dz)
  dmo(dx, dy, dz)
  return waitstatic()
end

function hone() -- Center above the robot, with 0, 0, 0 as directly above
  local m1 = ping()[5]
  local d = 1
  local dx = d - dmos(d, 0, 0)
  local m2x = ping()[5]
  dmos(-d, 0, 0)
  local dy = d - dmos(0, d, 0)
  local m2y = ping()[5]
  dmos(0, -d, 0)
  local dz = d - dmos(0, 0, d)
  local m2z = ping()[5]
  dmo(0, 0, -d)
  
  x = math.floor((m2x * m2x - m1 * m1 - dx * dx) / (2 * dx) + 0.5)
  y = math.floor((m2y * m2y - m1 * m1 - dy * dy) / (2 * dy) + 0.5) - 1
  z = math.floor((m2z * m2z - m1 * m1 - dz * dz) / (2 * dz) + 0.5)
  
  dmo(-x, -y, -z)
end

hone()

while true do
  computer.pullSignal(5)
end