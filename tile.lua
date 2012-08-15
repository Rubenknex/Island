Tile = {}
Tile.__index = Tile

function Tile.create(type, value, transition)
	-- type: The type of the tile (water, grass etc).
	-- value: The value from the noise map, the type is derived from this.
	-- transition: Stores the combination of neighbouring tiles, used as offset in the tileset.
	local self = {}
	setmetatable(self, Tile)

	self.type = type
	self.value = value
	self.transition = transition
	self.decal = nil

	return self
end