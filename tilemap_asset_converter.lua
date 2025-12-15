--all frames on the layer, each frame gets its own handle
--ASSUME: all frames have same tile dims: ie frame 1 and frame 5 both are 3x5 tiles

function ReadFrameIndices(f, pc, img)
	local tileIndices = {}

	for pixel in img:pixels() do
		local tileIndex = pc.tileI(pixel())
		table.insert(tileIndices, tileIndex)
	end

	return tileIndices
end

function AppendHeaderTilemap(file, table, p, w, h, filename)
	file:write("inline uint8_t " .. filename .. "Pos_" .. p .. "[]={")
	for i=0, h do
		for j=1, w+1 do
			file:write(table[i*w+j] .. ", ")
		end
		file:write("\n")
	end
	file:write("};")
end

function AppendHeaderTileset(file, table, filename)
	file:write("inline uint8_t " .. filename .. "Tileset[] ={")
	for i=0, (#table/16) do
		for j=0,16 do
			file:write(table[i*16+j] .. ", ")
		end
		file:write("\n")
	end
	file:write("};")
end

function GetFileHandle(filename)
	local file, err = io.open(filename..".h", "a")
	assert(file, err)
	return file
end

local sprite = app.sprite
local frame = app.frame
local layer = app.layer

--form/fe construct
local d = Dialog("Convert Tilemap to Asset File") --SEPERATE FILE for tileset layer
d:number{ id="tile_len", label="Tile Size", text="16", focus=true, }
	:entry{ id="filter_color",label="Filter Color", text="0x6767", visible=false }
	:check{ id="check_sprite", label="Sprite Mode", selected=false,
	onclick=function()
		d:modify{
			id="filter_color",
			visible=d.data.check_sprite
		}
	end   }
	:entry{ id="filename",label="filename", text=layer.name }
	:button{ id="confirm_button", text="CONFIRM" }
:show()

--globs and assertions
local data = d.data

assert((frame.frameNumber == 1 ), "GO TO THE FIRST FRAME TO RUN THIS SCRIPT") --has to be first layer because of loops
assert(layer.tileset, "NON-VALID FORMAT (not tilemap)")

--button handler
if(data.confirm_button) then
	local tile_len = data.tile_len
	local filter_color = data.filter_color
	local filename = data.filename

	local file = GetFileHandle(filename) --will output in the working dir; aseprite/scripts (machine dependent)

	--assertion step end TODO : assert filepath validity, tileset existence.
	local sprite_img = Image(sprite.spec)
	local tiles_w = sprite_img.width / tile_len
	local tiles_h = sprite_img.height / tile_len

	--file manipulation here
	file:write("#ifndef " .. data.filename .. "\n#define " .. data.filename .. "\n") -- can be changed based on the context. this for tactigachi
	file:write("#include <cstdint> \n")

	--get the tileset pixels, format as rgb 565
	local tileset = layer.tileset
	local size = tileset.grid.tileSize

	local tileset_pixels = {}

	for i=1, tileset_size+1 do
		local tile_image = tileset:getTile(i)
		for it in tile_image:pixels() do
			local pc = app.pixelColor
			local pixValue = it() --manipulat this value to become the rgb 565 pixel 
		
			if(pc.rgbaA(pixValue)==(nil or 0)) then
				table.insert(tileset_pixels, filter_color)
			else
				local r = pc.rgbaR(pixValue)
				local g = pc.rgbaG(pixValue)
				local b = pc.rgbaB(pixValue)
				
				--bit shift and concat
				local r5 = r>>3
				local g6 = g>>2 
				local b5 = b>>3
				local byte_565 = (r5<<11) | (g6<<5) | b5

				table.insert(tileset_pixels, string.format( "0x%04X", byte_565))
			end
		end
	end

	AppendHeaderTileset(file, tileset_pixels, filename)

	local indices = {}
	local tilemap_pos = 0 -- 0-based indexing for C++ 
	while(frame) do
		local pc = app.pixelColor
		local img = layer:cel(frame).image --!

		indices = ReadFrameIndices(frame, pc, img)
		AppendHeaderTilemap(file, indices, tilemap_pos, tiles_w, tiles_h, filename)

		frame = frame.next
		tilemap_pos = tilemap_pos+1
	end

	file:write("#endif") -- can be changed based on the context. this for tactigachi
end
--EOF
