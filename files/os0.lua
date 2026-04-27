clist = component.list
screenaddr = clist("screen")()
gpu = component.proxy(clist("gpu")())
gpu.bind(screenaddr)
gpu.setViewport(32, 16)
gpu.setResolution(32, 16)

blueshades = {0x00, 0x40, 0x80, 0xC0, 0xFF}
redshades = {0x000000, 0x330000, 0x660000, 0x990000, 0xCC0000, 0xFF0000}
greenshades = {0x0000, 0x2400, 0x4900, 0x6D00, 0x9200, 0xB600, 0xDB00, 0xFF00}
bwshades = {0x0F, 0x1E, 0x2D, 0x3C, 0x4B, 0x5A, 0x69, 0x78, 0x87, 0x96, 0xA5, 0xB4, 0xC3, 0xD2, 0xE1, 0xF0}

colorof = function(index)
  if index >= 240 then
    index = index - 240
    local shade = bwshades[index]
    local color = shade + shade * 256 + shade * 65536
    return color
  end
  local blue = index % 5 + 1
  local green = math.floor(index / 5) % 8 + 1
  local red = math.floor(index / 40) + 1
  return redshades[red] + greenshades[green] + blueshades[blue]
end

while 1 do
  for x = 0, 15 do
    for y = 0, 15 do
      idx = y * 16 + x
      local color = colorof(idx)
      gpu.setForeground(color)
      gpu.setBackground(color)
      gpu.set(x * 2 + 1, y + 1, "##")
    end
  end
end