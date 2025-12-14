local layer = app.activeLayer
if layer.isTilemap then
    local w, h = 3, 2
    local data = layer.data -- 1D array of tileset indices

    for y = 0, h-1 do
        for x = 0, w-1 do
            local idx = x + y * w + 1 -- Lua is 1-based
            local tileIndex = data[idx]
            print("Tile at", x, y, "=", tileIndex)
        end
    end
end

local s = app.cel.image.bytes
print(s)


