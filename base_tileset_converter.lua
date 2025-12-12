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
	:check{ id="chk_sprite", label="Sprite Mode", selected=false, 
	onclick=function()
		d:entry{
			id="filter_clr",
			label="Filter Colour (565)",
			text="0x6767"
		}
	end}
	:button{ id="confirm_btn", text="OKBUTT" }
 :show()
 

--backend 

local data = d.data
if(data.confirm_btn) then
	local tile_len = data.tile_len
	local filter_clr = data.filter_clr

	local tiles_w = img.width / tile_len
	local tiles_h = img.height / tile_len

	app.alert( tile_len + "''" + tiles_w + "''" + tiles_h )
end
