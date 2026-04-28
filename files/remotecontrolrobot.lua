tunnel = component.proxy(component.list("tunnel")())
modem = component.proxy(component.list("modem")())
robot = component.proxy(component.list("robot")())
tunneluuid = tunnel.getChannel()

while true do
  signame, siguuid, arg2, arg3, arg4, arg5, arg6, arg7, arg8 = computer.pullSignal()
  if signame == "modem_message" then
    if arg2 == tunneluuid then
      if arg6 == "shutdown" then
        computer.shutdown()
      end
      if type(robot[arg5]) == type(type) then
        robot[arg5](arg6, arg7)
      end
    end
  end
end