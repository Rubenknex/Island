require "functions"

Camera = {}
Camera.__index = Camera

function Camera.create(x, y, width, height)
	self = {}
	setmetatable(self, Camera)

	self.x, self.y = x, y
	self.width, self.height = width, height

	return self
end

function Camera:setPosition(pos)
	self.x, self.y = pos.x, pos.y
end

function Camera:interpolate(pos, var)
	self.x = math.lerp(self.x, pos.x, var)
	self.y = math.lerp(self.y, pos.y, var)
end

function Camera:move(offset)
	self.x = self.x + offset.x
	self.y = self.y + offset.y
end