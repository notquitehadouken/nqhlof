clist = component.list
screenaddr = clist("screen")()
gpu = component.proxy(clist("gpu")())
gpu.bind(screenaddr)
gpu.setViewport(32, 16)
gpu.setResolution(32, 16)

while os.sleep(10) do
	for x = 0, 15 do
		for y = 0, 15 do
			str = string.char(y * 16 + x)
			gpu.set(x + 1, y + 1, str)
		end
	end
end