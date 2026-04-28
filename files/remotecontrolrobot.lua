tunneluuid = component.list("tunnel")()
tunnel = component.proxy(tunneluuid)
modem = component.proxy(component.list("modem")())
robot = component.proxy(component.list("robot")())

while true do
  signame, siggenuuid, arg2, arg3, arg4, arg5, arg6, arg7, arg8 = computer.pullSignal()
  
  computer.beep(200, 0.15)
  if signame == "modem_message" then
    computer.beep(350, 0.15)
    if siggenuuid == tunneluuid then
      computer.beep(500, 0.15)
      if arg5 == "shutdown" then
        computer.shutdown()
      elseif arg5 == "move" then
        robot.move(arg6)
      elseif arg5 == "turn" then
        robot.turn(arg6)
      end
    end
  end
end