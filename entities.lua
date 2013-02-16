require "animation"
require "map"

--[[
Entities

Properties:
- position
- collidable
- static

Methods:
- init
- update
- draw
]]

Tree = class()

function Tree:init(treeType, x, y)
    self.position = Vec2(x, y)
    self.collidable = true
    self.static = true

    self.treeType = treeType
    self.image = love.graphics.newImage("data/" .. treeType .. ".png")
    self.visibility = Rect(0, 0, self.image:getWidth(), self.image:getHeight())
end

function Tree:draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.image, self.position.x, self.position.y, 0, 2, 2, self.image:getWidth() / 2, self.image:getHeight())

    utils.debugDrawCircle(255, 0, 0, 255, self:getCollisionCircle())
end

function Tree:getCollisionCircle()
    return Circle(self.position.x, self.position.y, 8)
end

function Tree:getVisibilityRect()
    self.visibility.left = self.position.x
    self.visibility.top = self.position.y

    return self.visibility
end

Crab = class()

function Crab:init(x, y)
    self.position = Vec2(x, y)
    self.collidable = true
    self.static = false

    self.collided = false

    self.boundingCircle = Circle(x, y, 6)

    self.direction = Vec2()
    self.degrees = 0
    self.target = Vec2()
    self.walking = false
    self.walkTime = 0.0
    self.idleTime = 0.0

    self.animation = Animation(love.graphics.newImage("data/crab.png"))
    self.animation:addSequence("down", 0, 0, 16, 16, 2)
    self.animation:addSequence("up", 0, 16, 16, 16, 2)
    self.animation:addSequence("left", 0, 32, 16, 16, 2)
    self.animation:addSequence("right", 0, 48, 16, 16, 2)
end

function Crab:update(dt)
    if self.walking then
        local movement = self.direction * crabSpeed * dt

        if self.walkTime <= 0.0 or self.collided or map:tileTypeAt(self.position.x, self.position.y) ~= SAND then
            self.position = self.position - movement
            self.walking = false
            self.collided = false
            self.idleTime = crabMinIdle + math.random() * (crabMaxIdle - crabMinIdle)

            self.animation:pauseSequence(1)
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

    utils.debugDrawCircle(255, 0, 0, 255, self:getCollisionCircle())
end

function Crab:chooseTarget()
    local degrees = math.random(0, 359)
    local angle = math.rad(degrees)

    -- Set the correct quad facing the target
    if degrees >= 315 or degrees <= 45 then self.animation:playSequence("up", "loop", 0.2)
    elseif degrees >= 45 and degrees <= 135 then self.animation:playSequence("right", "loop", 0.2)
    elseif degrees >= 135 and degrees <= 225 then self.animation:playSequence("down", "loop", 0.2)
    elseif degrees >= 225 and degrees <= 315 then self.animation:playSequence("left", "loop", 0.2) end

    self.direction = Vec2(math.cos(angle), math.sin(angle))
    local distance = math.random(crabMinRange, crabMaxRange)
    self.target = self.position + self.direction * distance
    self.walkTime = distance / crabSpeed
end

function Crab:getCollisionCircle()
    self.boundingCircle.x = self.position.x
    self.boundingCircle.y = self.position.y

    return self.boundingCircle
end