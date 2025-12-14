-- Get the active sprite, cel, and image
local activeSprite = app.activeSprite
if not activeSprite then
    return app.alert("No active sprite.")
end

local activeCel = app.activeCel
if not activeCel then
    return app.alert("No active cel.")
end

local layer = activeCel.layer
if not layer.isTilemap then
    return app.alert("Active layer is not a tilemap.")
end

local activeImage = activeCel.image
local tileIndices = {}
local pc = app.pixelColor -- Helper object to decompose tile data

-- Iterate through all "pixels" (tile entries) in the tilemap image
for pixel in activeImage:pixels() do
    local tileEntry = pixel() -- The raw value including index and flags
    local tileIndex = pc.tileI(tileEntry) -- Extract just the tile index

    -- Add the index to our list
    table.insert(tileIndices, tileIndex)
end

-- Print the list of indices (for demonstration)
print("Tile indices list:")
for i, index in ipairs(tileIndices) do
    -- Format: [index_in_list] tile_index
    print(string.format("[%d] %d", i, index))
end

-- You can also return the tileIndices table for use in other scripts or functions
-- return tileIndices

