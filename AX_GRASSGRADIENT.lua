-- Create a Gradiant Grass/Dirt/Stone based on Y Level
if not isSolid(getBlockState(x, y, z)) then
    return nil
end

-- Load custom arguments
local top = $blockState(Top, grass_block)$
local mid = $blockState(Middle, dirt)$
local below = $blockState(Bottom, stone)$

-- Calculate surface depth
local depth = 0
for i = 0, 6 do
    if i == 6 then
        return below
    end
    if not isSolid(getBlockState(x, y + i + 1, z)) then
        depth = i
        break
    end
end

-- Place grass on top
if depth == 0 then
    return top
end

-- Compute gradual dirt thickness based on Y height
-- 3 layers at y=68, 1 layer at y=90
-- Use linear interpolation + simplex noise for variation
local baseDirtDepth = 3 - ((y - 68) / (90 - 68)) * 2  -- linearly goes from 3 to 1
local noise = getSimplexNoise(x / 32, y / 32, z / 32)
local variation = (noise - 0.5) * 1.5 -- range: -0.75 to +0.75
local dirtDepth = math.max(1, math.floor(baseDirtDepth + variation + 0.5))

-- Place dirt if within calculated dirt depth
if depth < dirtDepth then
    return mid
end

-- Otherwise, place stone
return below
