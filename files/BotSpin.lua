local robot = component.proxy(component.list("robot")())

while true do
  robot.turn(true)
end
