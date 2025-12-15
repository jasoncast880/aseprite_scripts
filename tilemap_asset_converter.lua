--all frames on the layer, each frame gets its own handle
--ASSUME: all frames have same tile dims: ie frame 1 and frame 5 both are 3x5 tiles

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
	:entry{ id="filename",label="filename", text=sprite.filename }
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

	local file = GetFileHandle() --will output in the working dir; aseprite/scripts (machine dependent)

	--assertion step end TODO : assert filepath validity, tileset existence.
	local img = Image(sprite.spec)
	local tiles_w = img.width / tile_len
	local tiles_h = img.height / tile_len

	--file manipulation here
	file:write("#ifndef " .. data.filename .. "\n#define " .. data.filename .. "\n") -- can be changed based on the context. this for tactigachi
	file:write("#include <cstdint> \n")

	local tileset_size = layer.tileset.grid.tileSize
	local tileset_pixels = {}

	for i=1, tileset_size+1 do
		local tile_image = layer.tileset:getTile(i)
		for it in tile_image:pixels() do
			table.insert(tileset_pixels, it())
		end
	end

	AppendHeaderTileset(file, tileset_pixels, filter_color)

	local indices = {}
	local tilemap_pos = 0 -- 0-based indexing for C++ 
	while(frame) do
		indices = ReadFrameIndices(frame)
		AppendHeaderTilemap(file, indices, tilemap_pos, tiles_w, tiles_h)

		frame = frame.next
		tilemap_pos = tilemap_pos+1
	end

	file:write("#endif") -- can be changed based on the context. this for tactigachi
end
--EOF

function ReadFrameIndices(f)
	local tileIndices = {}

	local pc = app.pixelColor
	local img = layer:cel(f).image --!

	for pixel in img:pixels() do
		local tileIndex = pc.tileI(pixel())
		table.insert(tileIndices, tileIndex)
	end

	return tileIndices
end

--assuming global, asserted file handle in 'append mode' named file
function AppendHeaderTilemap(file, table, p, w, h)
	file:write("inline uint8_t " .. data.filename .. "Pos_" .. p .. "[]={")
	for i=1, h+1 do
		for j=1, w+1 do
			file:write(table[i*w+j] .. ", ")
		end
		file:write("\n")
	end
	file:write("};")
end

function AppendHeaderTileset(file, table, filter_color)
	file:write("inline uint8_t " .. data.filename .. "Tileset[] ={")
	for i=0, #table do
		for j=0,16 do
			if (table[i*16+j] == {ALPHA_COLOR}) then -- TODO: establish how the pixels are stored, and write method to conver them to rgb 565
				file:write(filter_color .. ",")
			else file:write(table[i*16+j] .. ",") end
		end
		file:write("\n")
	end
	file:write("};")
end

function GetFileHandle()
	local file, err = io.open("output.h", "a")
	assert(file, err)
	return file
end
