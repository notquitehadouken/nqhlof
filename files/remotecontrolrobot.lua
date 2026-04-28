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
      end
      if type(robot[arg5]) == type(type) then
        computer.beep(750, 0.15)
        robot[arg5](arg6, arg7)
      end
    end
  end
end