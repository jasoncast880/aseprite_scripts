--all frames on the layer, each frame gets its own handle
--ASSUME: all frames have same tile dims: ie frame 1 and frame 5 both are 3x5 tiles

function ReadFrameIndices(pc, img)
	local tileIndices = {}

	for pixel in img:pixels() do
		local tileIndex = pc.tileI(pixel())
		table.insert(tileIndices, tileIndex)
	end

	return tileIndices
end

function AppendTilemap(file, tbl, p, w, h, filename)
	file:write("inline uint8_t " .. filename .. "Pos_" .. p .. "[]={")
	local idx=1
	for y=1, h do
		for x=1, w do
			file:write(tbl[idx] .. ", ")
			idx = idx + 1
		end
		file:write("\n")
	end
	file:write("};")
end

function AppendTileset(file, tbl, filename)
	file:write("inline uint8_t " .. filename .. "Tileset[] ={")
	for i=0, (#tbl/16) do
		for j=1,(16+1) do
			file:write(tbl[i*16+j] .. ", ")
		end
		file:write("\n")
	end
	file:write("};")
end

-- currently will output in some working directory of the aseprite app (tested on windows)
function GetFileHandle(filename) -- can be rewritten to accomodate diff os formats, download locations
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
	:number{ id="num_frames", label="# of Frames", text="1" }
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
	local num_frames = data.num_frames
	local filter_color = data.filter_color
	local filename = data.filename

	local file = GetFileHandle(filename) --will output in the working dir; aseprite/scripts (machine dependent)

	--assertion step end TODO : assert filepath validity, tileset existence.
	local sprite_img = Image(sprite.spec)
	local tiles_w = sprite_img.width / tile_len
	local tiles_h = sprite_img.height / tile_len

	--file manipulation here
	file:write("#ifndef " .. data.filename .. "\n#define " .. data.filename .. "\n") -- can be changed based on the context.
	file:write("#include <cstdint> \n")

	--get the tileset pixels, format as rgb 565
	local tileset = layer.tileset
	local tileset_pixels = {}
	local num_tiles = num_frames * tiles_w * tiles_h

	--tilset pixel extraction loops
	for i=0, tileset.tileCount-1 do --HOW TO GET NUM TILES
		local tile_image = tileset:tile(i).image -- @@@ problems staart here !!!
		local pc = app.pixelColor

		for it in tile_image:pixels() do
			local pixValue = it() --manipulate this value to become the rgb 565 pixel 
			if(pc.rgbaA(pixValue)==(0)) then
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

	AppendTileset(file, tileset_pixels, filename)
	print(string.format("Tileset Completed \n TOTAL PIXELS: %d \n TOTAL TILES: %d \n TOTAL DATA: ~%d(by) ", #tileset_pixels, num_tiles, (#tileset_pixels*2)))
	--tileset portion finished

	local indices = {}
	while(frame) do
		local pc = app.pixelColor
		local img = layer:cel(frame).image --!

		indices = ReadFrameIndices(pc, img)
		AppendTilemap(file, indices, frame.frameNumber, tiles_w, tiles_h, filename)

		frame = frame.next
	end

	file:write("\n#endif") -- can be changed based on the context. this for tactigachi
end


