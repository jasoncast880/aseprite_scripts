-- Takes an aseprite sheet, extracts the local tileset 
-- and convert into a c++ assets file.
--
-- For programmers' reference, use the aseprite tool, the numbering/
-- indexing on the tilesets tool should be the same...
--
-- PIXEL ORDER: Left-To-Right, Top Row to Bottom Row.

-- get the tileset handle
local d = Dialog("Convert to .cpp Asset File")
d:number{ id="tile_len", label="Tile Size", text="16", focus=true }
	:check{ id="check_sprite", label="Sprite Mode", selected=false, 
	onclick=function()
		d:modify{
			id="filter_clr",
			visible=d.data.check_sprite,
		}
	end}
	:entry{
				id="filter_clr",
				label="Filter Colour (565)",
				text="0x6767",
				visible=false
			}
	:button{ id="confirm_btn", text="CONFIRM" }
 :show()



 --backend

 --[[
function convertSprite(data, filter_clr)
	-- run through the tiles and turn alpha colors into filter color;
	-- return a array
	local tuple_thing

	for i=1, data.poop do
		aiwjoaijdoaiwjdoiawjd
	end
	
	return tuple_thing
end
]]--

--assume you have a sprite, it will have one pure tileset layer, and multiple tilemap 'configuration' layers, each perhaps will have multiple frames.
--assume layer 1 is the layer with the tileset, other layers are pure configuration.

local data = d.data
if(data.confirm_btn) then
	local tile_len = data.tile_len
	local filter_clr = data.filter_clr

	local s = app.sprite

	local image = Image(s.spec)
	local tiles_w = img.width / tile_len
	local tiles_h = img.height / tile_len
	app.alert( tile_len .. " | " ..  tiles_w .. " | " .. tiles_h )

	for i=1,#s.cels do 
		local cel_bytes = s.cels[i].image:pixels()
		
	end 


end
