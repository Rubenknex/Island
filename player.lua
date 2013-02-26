require "animation"
require "inventory"
require "map"
require "shapes"
require "utils"

Player = class()

function Player:init()
    self.position = Vec2()
    while map:tileAt(self.position.x, self.position.y).type == "water" do
        self.position = Vec2((math.random(map.width - 1) + 0.5) * tileDrawSize, (math.random(map.height - 1) + 0.5) * tileDrawSize)
    end
    self.offset = Vec2(8, 16)
    self.velocity = Vec2()
    self.collidable = true
    self.static = false

    self.inventory = Inventory()

    self.image = love.graphics.newImage("images/man.png")
    self.animation = Animation(self.image)
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
    love.graphics.drawq(self.animation.image, self.animation:getCurrentQuad(), self.position.x, self.position.y, 0, 3, 3, self.offset.x, self.offset.y)
    
    utils.debugDrawCircle(255, 0, 0, 255, self:getCircle())
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
        self.velocity = dir:normalized() * speed * dt
        self.position = self.position + self.velocity
    else
        self.animation:pauseSequence(1)
    end
end

function Player:collideWith(other)

end

function Player:getCircle()
    return Circle(self.position.x, self.position.y, 7)
end

function Player:getRect()
    return Rect(self.position.x - self.offset.x, self.position.y - self.offset.y, self.image:getWidth(), self.image:getHeight())
end