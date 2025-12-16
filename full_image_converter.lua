-- take an image and convert it into a c++ array assets file.
-- PIXEL ORDER: Left-To-Right, Top Row to Bottom Row.
--assume one layer, no frames, no general trickery

local sprite = app.sprite
local layer = app.layer
local img = Image(sprite.spec)

local pixels_w = img.width
local pixels_h = img.height

local pc = app.pixelColor

local file, err = io.open(layer.name..".h", "a")
assert(file, err)

file:write("inline uint16_t " .. layer.name .. "_img[] = {")

for i = 0, pixels_h do
	for j = 0, pixels_w do
		local pixValue = img:getPixel(j,i)

		local r = pc.rgbaR(pixValue)
		local g = pc.rgbaG(pixValue)
		local b = pc.rgbaB(pixValue)

		--bit shift and concat
		local r5 = r>>3
		local g6 = g>>2
		local b5 = b>>3
		local byte_565 = (r5<<11) | (g6<<5) | b5

		file:write(string.format("0x%04X",byte_565))

	end
	file:write("\n")
end

file:write("};")
