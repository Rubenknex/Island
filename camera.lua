require "shapes"

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
    love.graphics.translate(-math.floor(self.x + 0.5), -math.floor(self.y + 0.5))
end

function Camera:unset()
    love.graphics.pop()
end

function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Camera:moveTo(target)
    self.x = target.x
    self.y = target.y
end

function Camera:moveToSmooth(target, speed, dt)
    self.x = self.x - (self.x - target.x) * speed * dt
    self.y = self.y - (self.y - target.y) * speed * dt
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

function Camera:getRect()
    --return Rect(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    return {x = self.x - self.width / 2, y = self.y - self.height / 2, w = self.width, h = self.height}
end