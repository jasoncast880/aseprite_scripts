-- get the active sprite, cel, img
local activeSprite = app.sprite
local activeCel = app.cel
local layer = activeCel.layer
local activeImg = app.image

-- iterate through tile entries in the tilemap image
local tileIndices = {}
local pc = app.pixelColor

for pixel in activeImage:pixels() do
	local tileIndex = pc.tileI(pixel())
	table.insert(tileIndices, tileIndex)
end
-- local func:
-- print the list of indices and return a table of tileIndeces.

-- write a file with table, holding indeces list.
