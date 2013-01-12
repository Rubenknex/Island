require "animation"
require "map"
require "shapes"
require "utils"

Player = {}
Player.__index = Player

function Player.create()
    local self = {}
    setmetatable(self, Player)

    self.type = "player"
    self.layer = 0
    self.position = Vec2.create(0, 0)
    while not map:walkableAt(self.position.x, self.position.y) do
        self.position = Vec2.create((math.random(map.width) + 0.5) * tileDrawSize, (math.random(map.height) + 0.5) * tileDrawSize)
    end
    self.collidable = true
    self.static = false

    self.radius = 7

    self.animation = Animation.create(love.graphics.newImage("data/man.png"))
    self.animation:addSequence("down", 0, 0, 16, 16, 1)
    self.animation:addSequence("up", 16, 0, 16, 16, 1)
    self.animation:addSequence("left", 32, 0, 16, 16, 1)
    self.animation:addSequence("right", 48, 0, 16, 16, 1)
    self.animation:playSequence("down", "paused", 1)

    self.dir = Vec2.create()

    return self
end

function Player:handleInput(dt)
    self.dir:set(0, 0)

    if love.keyboard.isDown("a") then
        self.dir.x = -1
        self.animation:playSequence("left", "paused", 1)
    end
    if love.keyboard.isDown("d") then
        self.dir.x = self.dir.x + 1
        self.animation:playSequence("right", "paused", 1)
    end
    if love.keyboard.isDown("w") then
        self.dir.y = -1
        self.animation:playSequence("up", "paused", 1)
    end
    if love.keyboard.isDown("s") then
        self.dir.y = self.dir.y + 1
        self.animation:playSequence("down", "paused", 1)
    end

    if self.dir:length() > 0 then
        local speed = love.keyboard.isDown("lshift") and playerSprintSpeed or playerSpeed
        self.position = self.position + self.dir:normalized() * speed * dt
    else
        self.animation:pauseSequence(1)
    end
end

function Player:getCollisionCircle()
    return Circle.create(self.position.x, self.position.y - 6, self.radius)
end

function Player:update(dt)
    self:handleInput(dt)
end

function Player:draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.drawq(self.animation.image, self.animation:getCurrentQuad(), self.position.x, self.position.y, 0, 3, 3, 8, 16)
    
    utils.debugDrawCircle(255, 0, 0, 255, self:getCollisionCircle())
end