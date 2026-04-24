function proxy(name)
  return component.proxy(component.list(name)())
end

robot = proxy("robot")
icont = proxy("inventory_controller")
compu = proxy("computer")

path = {}
pathReverse = {}
forwardvalue = 0
rightvalue = 1
leftvalue = 2

-- trace path

while 1 do
  if robot.move(3) then
    table.insert(path, forwardvalue)
    table.insert(pathReverse, 1, forwardvalue)
  else
    robot.turn(true)
    if robot.move(3) then
      table.insert(path, rightvalue)
      table.insert(path, forwardvalue)
      table.insert(pathReverse, 1, leftvalue)
      table.insert(pathReverse, 1, forwardvalue)
    else
      robot.turn(true)
      robot.turn(true)
      if robot.move(3) then
        table.insert(path, leftvalue)
        table.insert(path, forwardvalue)
        table.insert(pathReverse, 1, rightvalue)
        table.insert(pathReverse, 1, forwardvalue)
      else
        break
      end
    end
  end
end

robot.turn(false)

function follow(path, callback)
  for _, move in ipairs(path) do
    if move == forwardvalue then
      if callback ~= nil then
        callback()
      end
      robot.move(3)
    elseif move == rightvalue then
      robot.turn(true)
    else
      robot.turn(false)
    end
  end
  if callback ~= nil then
    callback()
  end
end

follow(pathReverse)

compu.beep(750, 0.5)