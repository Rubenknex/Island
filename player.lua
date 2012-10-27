require "animation"
require "map"
require "rect"
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

function Player.create(x, y)
    local self = {}
    setmetatable(self, Player)

    self.type = "player"
    self.pos = Vec2.create(0, 0)
    while not map:walkableAt(self.pos.x, self.pos.y) do
        self.pos = Vec2.create(math.random(map.width) * Map.DRAW_SIZE, math.random(map.height) * Map.DRAW_SIZE)
    end
    self.collidable = true

    self.circleOffset = Vec2.create(0, 18)
    self.circleRadius = 6

    self.animation = Animation.create(love.graphics.newImage("data/man.png"))
    self.animation:addSequence("down", 0, 0, 16, 16, 1)
    self.animation:addSequence("up", 16, 0, 16, 16, 1)
    self.animation:addSequence("left", 32, 0, 16, 16, 1)
    self.animation:addSequence("right", 48, 0, 16, 16, 1)
    self.animation:playSequence("down", "paused", 1)

    self.scale = 3

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
        self.pos = self.pos + self.dir:normalized() * speed * dt
    else
        self.animation:pauseSequence(1)
    end
end

function Player:handleCollision(dt)
    local circlePos = self.pos + self.circleOffset
    local left, top = circlePos.x - self.circleRadius, circlePos.y - self.circleRadius
    local right, bottom = circlePos.x + self.circleRadius, circlePos.y + self.circleRadius
    local tSize = Map.DRAW_SIZE
    local tLeft, tTop = math.floor(left / tSize), math.floor(top / tSize)
    local tRight, tBottom = math.floor(right / tSize), math.floor(bottom / tSize)
    
    local result, normal, length = false, 0, 0
    if not map:walkableAt(left, top) then
        result, normal, length = utils.collideRectCircle(Rect.create(tLeft * tSize, tTop * tSize, tSize, tSize), circlePos, self.circleRadius)
        if result then
            self.pos = self.pos + normal * length
        end
    end

    if not map:walkableAt(right, top) then
        result, normal, length = utils.collideRectCircle(Rect.create(tRight * tSize, tTop * tSize, tSize, tSize), circlePos, self.circleRadius)
        if result then
            self.pos = self.pos + normal * length
        end
    end

    if not map:walkableAt(right, bottom) then
        result, normal, length = utils.collideRectCircle(Rect.create(tRight * tSize, tBottom * tSize, tSize, tSize), circlePos, self.circleRadius)
        if result then
            self.pos = self.pos + normal * length
        end
    end

    if not map:walkableAt(left, bottom) then
        result, normal, length = utils.collideRectCircle(Rect.create(tLeft * tSize, tBottom * tSize, tSize, tSize), circlePos, self.circleRadius)
        if result then
            self.pos = self.pos + normal * length
        end
    end
end

function Player:getBoundingCircle()
    return self.pos.x, self.pos.y, self.circleRadius
end

function Player:update(dt)
    self:handleInput(dt)
    self:handleCollision(dt)
end

function Player:draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.drawq(self.animation.image, self.animation:getCurrentQuad(), self.pos.x, self.pos.y, 0, self.scale, self.scale, 8, 8)
    
    utils.debugDrawCircle(255, 0, 0, 255, self.pos.x + self.circleOffset.x, self.pos.y + self.circleOffset.y, self.circleRadius)
end