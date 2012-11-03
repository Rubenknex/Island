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
    love.graphics.rotate(self.rotation)
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x + self.width / 2, -self.y + self.height / 2)
end

function camera:unset()
    love.graphics.pop()
end

function camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function camera:lerp(x, y, x)
    self.x = self.x + (x - self.x) * x
    self.y = self.y + (y - self.y) * x
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

function camera:getBounds()
    local halfWidth = self.width / 2
    local halfHeight = self.height / 2

    return self.x - halfWidth, self.y - halfHeight, self.x + halfWidth, self.y + halfHeight
end