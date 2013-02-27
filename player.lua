require "animation"
require "inventory"
require "shapes"
require "utils"
require "world"

Player = class()

function Player:init()
    self.position = Vec2()
    while world:tileAt(self.position.x, self.position.y).type == "water" do
        self.position = Vec2((math.random(world.width - 1) + 0.5) * tileDrawSize, (math.random(world.height - 1) + 0.5) * tileDrawSize)
    end
    self.offset = Vec2(8, 16)
    self.velocity = Vec2()
    self.collidable = true
    self.static = false

    self.inventory = Inventory()

    self.image = love.graphics.newImage("images/man.png")
    self.animation = Animation(self.image)
    self.animation:add("down", 0, 0, 16, 16, 1)
    self.animation:add("up", 16, 0, 16, 16, 1)
    self.animation:add("left", 32, 0, 16, 16, 1)
    self.animation:add("right", 48, 0, 16, 16, 1)
    self.animation:play("down", "paused", 1)
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
        self.animation:play("left", "paused", 1)
    end
    if love.keyboard.isDown("d") then
        dir.x = dir.x + 1
        self.animation:play("right", "paused", 1)
    end
    if love.keyboard.isDown("w") then
        dir.y = -1
        self.animation:play("up", "paused", 1)
    end
    if love.keyboard.isDown("s") then
        dir.y = dir.y + 1
        self.animation:play("down", "paused", 1)
    end

    if dir:length() > 0 then
        local speed = love.keyboard.isDown("lshift") and playerSprintSpeed or playerSpeed
        self.velocity = dir:normalized() * speed * dt
        self.position = self.position + self.velocity
    else
        self.animation:pause(1)
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