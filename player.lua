require "animation"
require "map"
require "shapes"
require "utils"

Item = {}
Item.__index = Item

function Item.create(name)
    local self = {}
    setmetatable(self, Item)

    self.name = name

    return self
end

Player = {}
Player.__index = Player

function Player.create()
    local self = {}
    setmetatable(self, Player)

    self.type = "player"
    self.position = Vec2.create(0, 0)
    while not map:walkableAt(self.position.x, self.position.y) do
        self.position = Vec2.create((math.random(map.width) + 0.5) * TILE_DRAW_SIZE, (math.random(map.height) + 0.5) * TILE_DRAW_SIZE)
    end
    self.collidable = true

    self.boundingCircle = Circle.create(self.position.x, self.position.y + 18, 6)

    self.animation = Animation.create(love.graphics.newImage("data/man.png"))
    self.animation:addSequence("down", 0, 0, 16, 16, 1)
    self.animation:addSequence("up", 16, 0, 16, 16, 1)
    self.animation:addSequence("left", 32, 0, 16, 16, 1)
    self.animation:addSequence("right", 48, 0, 16, 16, 1)
    self.animation:playSequence("down", "paused", 1)

    self.normalSpeed = 150
    self.sprintSpeed = 250

    self.dir = Vec2.create()

    self.health = 100
    self.energy = 100

    self.inventory = {}
    table.insert(self.inventory, Item.create("Rope"))
    table.insert(self.inventory, Item.create("Spade"))
    table.insert(self.inventory, Item.create("Knife"))

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
        local speed = love.keyboard.isDown("lshift") and self.sprintSpeed or self.normalSpeed
        self.position = self.position + self.dir:normalized() * speed * dt
    else
        self.animation:pauseSequence(1)
    end
end

function Player:getBoundingCircle()
    self.boundingCircle.x = self.position.x
    self.boundingCircle.y = self.position.y  + 18

    return self.boundingCircle
end

function Player:update(dt)
    self:handleInput(dt)
end

function Player:draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.drawq(self.animation.image, self.animation:getCurrentQuad(), self.position.x, self.position.y, 0, 3, 3, 8, 8)
    
    utils.debugDrawCircle(255, 0, 0, 255, self:getBoundingCircle())
end