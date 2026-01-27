-- ChunkBotSource.lua
-- Final draft

-- One pickaxe must be equipped

k = component
c = computer
r = k.proxy(k.list("robot")())

function check()
  while r.count(16) > 0 do
    c.beep(300, 0.5)
  end
end

function swingmove(dir)
  r.swing(dir)
  check()
  r.move(dir)
end

while true do
  for i = 1, 4 do
    for i = 1, 7 do
      swingmove(3)
    end
    r.turn(true)
    swingmove(3)
    r.turn(true)
    for i = 1, 7 do
      swingmove(3)
    end
    r.turn(false)
    swingmove(3)
    r.turn(false)
  end
  r.turn(false)
  r.turn(false)
  swingmove(0)

end
