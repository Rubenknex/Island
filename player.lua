require "animation"
require "map"
require "shapes"
require "utils"

Player = class()

function Player:init()
    self.position = Vec2(0, 0)
    while not map:walkableAt(self.position.x, self.position.y) do
        self.position = Vec2((math.random(map.width) + 0.5) * tileDrawSize, (math.random(map.height) + 0.5) * tileDrawSize)
    end
    self.collidable = true
    self.static = false
    self.radius = 7

    self.animation = Animation(love.graphics.newImage("data/man.png"))
    self.animation:addSequence("down", 0, 0, 16, 16, 1)
    self.animation:addSequence("up", 16, 0, 16, 16, 1)
    self.animation:addSequence("left", 32, 0, 16, 16, 1)
    self.animation:addSequence("right", 48, 0, 16, 16, 1)
    self.animation:playSequence("down", "paused", 1)
end

function Player:update(dt)
    self:handleInput(dt)
end

function Player:draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.drawq(self.animation.image, self.animation:getCurrentQuad(), self.position.x, self.position.y, 0, 3, 3, 8, 16)
    
    utils.debugDrawCircle(255, 0, 0, 255, self:getCollisionCircle())
end

function Player:handleInput(dt)
    local dir = Vec2()

    if love.keyboard.isDown("a") then
        dir.x = -1
        self.animation:playSequence("left", "paused", 1)
    end
    if love.keyboard.isDown("d") then
        dir.x = dir.x + 1
        self.animation:playSequence("right", "paused", 1)
    end
    if love.keyboard.isDown("w") then
        dir.y = -1
        self.animation:playSequence("up", "paused", 1)
    end
    if love.keyboard.isDown("s") then
        dir.y = dir.y + 1
        self.animation:playSequence("down", "paused", 1)
    end

    if dir:length() > 0 then
        local speed = love.keyboard.isDown("lshift") and playerSprintSpeed or playerSpeed
        self.position = self.position + dir:normalized() * speed * dt
    else
        self.animation:pauseSequence(1)
    end
end

function Player:getCollisionCircle()
    return Circle(self.position.x, self.position.y - 6, self.radius)
end