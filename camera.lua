require "utils"

Camera = {}
Camera.__index = Camera

function Camera.create(x, y, width, height)
    self = {}
    setmetatable(self, Camera)

    self.x, self.y = x, y
    self.width, self.height = width, height
    self:roundPosition()

    return self
end

function Camera:setPosition(pos)
    self.x, self.y = pos.x, pos.y
    self:roundPosition()
end

function Camera:interpolate(pos, var)
    self.x = utils.lerp(self.x, pos.x, var)
    self.y = utils.lerp(self.y, pos.y, var)
    self:roundPosition()
end

function Camera:move(offset)
    self.x = self.x + offset.x
    self.y = self.y + offset.y
    self:roundPosition()
end

function Camera:roundPosition()
    self.x = math.floor(self.x + 0.5)
    self.y = math.floor(self.y + 0.5)
end