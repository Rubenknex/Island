require "camera"
require "entities"
require "map"
require "player"
require "rect"
require "vec2"

--[[
IDEAS:
-   A crafting/construction system similar to that of Minecraft. You don't
    have to place the items in a specific order, just place them there. The idea
    is that a lot of the combinations are possible so the player can keep trying
    new things.

-   A final objective of the game could be to keep constructing items until you
    have enough to make an attempted escape to search for a boat.
    An example of the final items would be: A wooden raft.

-   Different activities to do on the island:
    -   Gathering raw materials such as wood, food and rock.
    -   Fishing, hunting animals, picking fruit.

]]

Game = {}
Game.__index = Game

function Game.create()
    local self = {}
    setmetatable(self, Game)

    map = Map.create(128, 128)
    camera = Camera.create(0, 0, 640, 480)
    player = Player.create(320, 240)

    entities = {}
    for i=1, 10 do
        local pos = Vec2.create(0, 0)
        while map:tileTypeAt(pos.x, pos.y) ~= Map.SAND do
            pos = Vec2.create(math.random(map.width) * Map.DRAW_SIZE, math.random(map.height) * Map.DRAW_SIZE)
        end

        table.insert(entities, Crab.create(pos.x, pos.y))
    end

    self.mapButtonRect = Rect.create(640 - 35, 480 - 35, 30, 30)
    self.inventoryButtonRect = Rect.create(640 - 35 - 35, 480 - 35, 30, 30)
    self.showMap = false
    self.showInventory = false

    return self
end

function Game:update(dt)
    map:update(dt)
    player:update(dt)

    for k, v in pairs(entities) do
        v:update(dt)
    end

    self:updateUI(dt)

    local screenPos = Vec2.create(player.pos.x - camera.width / 2, player.pos.y - camera.height / 2)
    camera:interpolate(screenPos, 0.1)
end

function Game:draw()
    map:draw()
    player:draw()

    for k, v in pairs(entities) do
        v:draw()
    end

    self:drawUI()

    love.graphics.setColor(255, 255, 255)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 0, 0)
end

function Game:updateUI(dt)
    local mX, mY = love.mouse.getPosition()
    
    self.showInventory = self.inventoryButtonRect:contains(mX, mY)
    self.showMap = self.mapButtonRect:contains(mX, mY)
end

function Game:drawUI()
    -- Bottom bar
    love.graphics.setColor(135, 72, 0)
    love.graphics.rectangle("fill", 0, 480 - 40, 640, 40)

    -- Health bar
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", 5, 480 - 35, 100, 10)

    -- Energy bar
    love.graphics.setColor(224, 27, 106)
    love.graphics.rectangle("fill", 5, 480 - 15, 100, 10)

    -- Map button
    love.graphics.setColor(200, 161, 123)
    love.graphics.rectangle("fill", 640 - 35, 480 - 35, 30, 30)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("M", 640 - 35, 480 - 35)

    -- Inventory button
    love.graphics.setColor(200, 161, 123)
    love.graphics.rectangle("fill", 640 - 35 - 35, 480 - 35, 30, 30)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("I", 640 - 35 - 35, 480 - 35)

    if self.showMap then 
        love.graphics.setColor(200, 161, 123)
        love.graphics.draw(map.minimap, 640 - 256 - 5, 480 - 256 - 40 - 5, 0, 2)
    end

    if self.showInventory then
        love.graphics.setColor(200, 161, 123)
        love.graphics.rectangle("fill", 640 - 200 - 5, 480 - 300 - 40 - 5, 200, 300)

        love.graphics.setColor(0, 0, 0)
        for i=1, #player.inventory do
            love.graphics.print(player.inventory[i].name, 640 - 200 - 5, 480 - 300 - 40 - 5 + i * 12)
        end
    end
end