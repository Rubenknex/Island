require "animation"
require "map"

Entity = class()

function Entity:init(type, x ,y)
    local data = objectTypes[type]

    self.type = type
    self.image = love.graphics.newImage("images/" .. type .. ".png")
    self.position = Vec2(x, y)
    self.origin = Vec2(data.origin_x, data.origin_y)
    self.static = true
    if data.static ~= nil then self.static = data.static end
    self.collidable = true
    if data.collidable ~= nil then self.collidable = data.collidable end
    self.radius = data.radius or 0
end

function Entity:draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.image, self.position.x, self.position.y, 0, 2, 2, self.origin.x, self.origin.y)

    utils.debugDrawCircle(0, 255, 0, 255, self:getCircle())
end

function Entity:getCircle()
    return Circle(self.position.x, self.position.y, self.radius)
end

function Entity:getRect()
    return Rect(self.position.x, self.position.y, self.image:getWidth(), self.image:getHeight())
end

Crab = class()

function Crab:init(x, y)
    self.position = Vec2(x, y)
    self.collidable = true
    self.static = false

    self.collided = false

    self.circle = Circle(x, y, 6)
    self.rect = Rect(x, y, 16, 16)

    self.direction = Vec2()
    self.degrees = 0
    self.target = Vec2()
    self.walking = false
    self.walkTime = 0.0
    self.idleTime = 0.0

    self.image = love.graphics.newImage("images/crab.png")
    self.animation = Animation(self.image)
    self.animation:add("down", 0, 0, 16, 16, 2)
    self.animation:add("up", 0, 16, 16, 16, 2)
    self.animation:add("left", 0, 32, 16, 16, 2)
    self.animation:add("right", 0, 48, 16, 16, 2)
end

function Crab:update(dt)
    if self.walking then
        local movement = self.direction * crabSpeed * dt

        if self.walkTime <= 0.0 or self.collided or map:tileAt(self.position.x, self.position.y).type ~= "sand" then
            self.position = self.position - movement
            self.walking = false
            self.collided = false
            self.idleTime = crabMinIdle + math.random() * (crabMaxIdle - crabMinIdle)

            self.animation:pause(1)
        else
            self.position = self.position + movement
            self.walkTime = self.walkTime - dt
        end
    else
        self.idleTime = self.idleTime - dt

        if self.idleTime <= 0.0 then
            self.walking = true
            self:chooseTarget()
        end
    end

    self.animation:update(dt)
end

function Crab:draw()
    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.drawq(self.animation.image, self.animation:getCurrentQuad(), self.position.x, self.position.y, 0, 2, 2, 8, 8)

    utils.debugDrawCircle(255, 0, 0, 255, self:getCircle())
end

function Crab:chooseTarget()
    local degrees = math.random(0, 359)
    local angle = math.rad(degrees)

    if degrees >= 315 or degrees <= 45 then self.animation:play("up", "loop", 0.2)
    elseif degrees >= 45 and degrees <= 135 then self.animation:play("right", "loop", 0.2)
    elseif degrees >= 135 and degrees <= 225 then self.animation:play("down", "loop", 0.2)
    elseif degrees >= 225 and degrees <= 315 then self.animation:play("left", "loop", 0.2) end

    self.direction = Vec2(math.cos(angle), math.sin(angle))
    local distance = math.random(crabMinRange, crabMaxRange)
    self.target = self.position + self.direction * distance
    self.walkTime = distance / crabSpeed
end

function Crab:collidedWith(other)
    self.collided = true
end

function Crab:getCircle()
    self.circle:set(self.position)

    return self.circle
end

function Crab:getRect()
    return Rect(self.position.x - 8, self.position.y - 8, self.image:getWidth(), self.image:getHeight())
end