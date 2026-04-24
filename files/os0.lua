clist = component.list
screenaddr = clist("screen")()
gpu = component.proxy(clist("gpu")())
gpu.bind(screenaddr)
gpu.setViewport(32, 16)
gpu.setResolution(32, 16)

idx = 0
max = 256 * 256 * 256
while os.sleep(10) do
	for x = 0, 31 do
		for y = 0, 15 do
			gpu.set(x + 1, y + 1, "#")
      idx += 1
      gpu.setForeground(idx)
		end
	end
  if idx >= max then
    idx = 0
  end
end