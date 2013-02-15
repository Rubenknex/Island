require "shapes"
require "utils"

-- Credit goes to: http://nova-fusion.com/2011/04/19/cameras-in-love2d-part-1-the-basics/

Camera = class()

function Camera:init(x, y, scale, rotation)
    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()

    self.x = x or 0
    self.y = y or 0
    self.scale = scale or 1
    self.rotation = rotation or 0
end

function Camera:set()
    love.graphics.push()
    
    love.graphics.translate(self.width / 2, self.height / 2)
    love.graphics.rotate(self.rotation)
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
    love.graphics.pop()
end

function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Camera:rotate(dr)
    self.rotation = self.rotation + dr
end

function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end

function Camera:setScale(scale)
    self.scale = scale
end

function Camera:setRotation(rotation)
    self.rotation = rotation
end

function Camera:getBounds()
    return Rect(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end