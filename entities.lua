require "map"

Crab = {}
Crab.__index = Crab

function Crab.create(x, y)
	self = {}
	setmetatable(self, Crab)

	return self
end

function Crab:update(dt)
	
end

function Crab:draw()
	
end