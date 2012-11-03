require "shapes"
require "utils"

-- Credit goes to: http://nova-fusion.com/2011/04/19/cameras-in-love2d-part-1-the-basics/

camera = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
    x = 0,
    y = 0,
    scale = 1,
    rotation = 0,
}

function camera:set()
    love.graphics.push()
    
    love.graphics.translate(self.width / 2, self.height / 2)
    love.graphics.rotate(self.rotation)
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
    love.graphics.pop()
end

function camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function camera:lerp(x, y, a)
    self.x = self.x + (x - self.x) * a
    self.y = self.y + (y - self.y) * a
end

function camera:rotate(dr)
    self.rotation = self.rotation + dr
end

function camera:setPosition(x, y)
    self.x = x
    self.y = y
end

function camera:setScale(scale)
    self.scale = scale
end

function camera:setRotation(rotation)
    self.rotation = rotation
end

function camera:getBounds()
    return Rect.create(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end