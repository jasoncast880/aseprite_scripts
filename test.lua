local spr = app.activeSprite
if not spr then return app.alert("No active sprite") end

local img = spr.cels[1].image  -- or get the cel for the layer/frame you want

local tile_size = 16  -- tile width/height
local tiles_w = math.floor(img.width / tile_size)
local tiles_h = math.floor(img.height / tile_size)

jj
