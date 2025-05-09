-- Axiom Script To Clear The Terrain And Replace Blocks By Stone
local block = getBlock(x, y, z)

-- Ignore air and water blocks
if block == blocks.air or block == blocks.water then
	return nil
end

-- Calculate replacement block (air or water)
local replaceWith = getFluidBlockStateOrAir(block)

-- Remove all non-solid blocks
if not isSolid(block) then
	return replaceWith
end

-- Remove all logs
if isBlockTagged(block, "logs") then
	return replaceWith
end

-- Remove all leaves
if isBlockTagged(block, "leaves") then
	return replaceWith
end

if block == blocks.mushroom_stem or 
   block == blocks.red_mushroom_block or 
   block == blocks.brown_mushroom_block then
    return replaceWith
end

-- Replace grass and dirt variants with stone
if block == blocks.grass_block or
   block == blocks.dirt or
   block == blocks.rooted_dirt or
   block == blocks.coarse_dirt or
   block == blocks.podzol then
    return blocks.stone
end

-- Replace stone variants, ores and natural blocks with stone
if block == blocks.moss_block or
   block == blocks.andesite or
   block == blocks.granite or
   block == blocks.diorite or
   block == blocks.clay or
   block == blocks.sand or
   block == blocks.red_sand or
   block == blocks.gravel or
   isBlockTagged(block, "ores") then  -- Tag pour tous les minerais
    return blocks.stone
end

-- Suppression explicite de l'eau et lave stagnante/flowing
if block == blocks.water or 
   block == blocks.lava or
   block == blocks.flowing_water or 
   block == blocks.flowing_lava then
    return replaceWith -- Serait remplacé par air via getFluidBlockStateOrAir
end
