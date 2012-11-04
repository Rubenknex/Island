require "camera"
require "entities"
require "map"
require "player"
require "shapes"
require "utils"
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

    camera = Camera.create()
    map = Map.create(128, 128)
    player = Player.create()

    entities = {}
    table.insert(entities, player)
    self:placeEntities()

    self.mapButtonRect = Rect.create(640 - 35, 480 - 35, 30, 30)
    self.showMap = false

    return self
end

function Game:update(dt)
    map:update(dt)

    for k, v in pairs(entities) do
        v:update(dt)
    end

    self:handleCollisions()

    self:updateUI(dt)

    camera.x = utils.lerp(camera.x, player.position.x, 0.05)
    camera.y = utils.lerp(camera.y, player.position.y, 0.05)
end

function Game:draw()
    camera.x = math.floor(camera.x + 0.5)
    camera.y = math.floor(camera.y + 0.5)

    camera:set()
    map:draw()

    table.sort(entities, function(a, b) return a.layer < b.layer end)
    for k, v in pairs(entities) do
        v:draw()
    end
    camera:unset()

    self:drawUI()

    utils.debugPrint(255, 255, 255, 255, "FPS: " .. love.timer.getFPS(), 0, 0)
    utils.debugPrint(255, 255, 255, 255, "Player: " .. tostring(player.position), 0, 15)
end

function Game:placeEntities()
    for i=1, 10 do
        local position = Vec2.create(0, 0)
        while map:tileTypeAt(position.x, position.y) ~= SAND do
            position = Vec2.create((math.random(map.width) + 0.5) * TILE_DRAW_SIZE, (math.random(map.height) + 0.5) * TILE_DRAW_SIZE)
        end

        table.insert(entities, Crab.create(position.x, position.y))
    end
end

function Game:resolveCollision(x, y, entity)
    local result, resolveX, resolveY = false, 0, 0
    if not map:walkableAt(x, y) then
        result, resolveX, resolveY = utils.collideRectCircle(map:rectAt(x, y), entity:getBoundingCircle())

        if result then
            entity.collided = true
            entity.position.x = entity.position.x + resolveX
            entity.position.y = entity.position.y + resolveY
        end
    end
end

function Game:handleCollisions()
    for k, v in pairs(entities) do
        if v.collidable then
            v.collided = false

            local circle = v:getBoundingCircle()
            leftX = circle.x - circle.radius
            middleX = circle.x
            rightX = circle.x + circle.radius
            topY = circle.y - circle.radius
            middleY = circle.y
            bottomY = circle.y + circle.radius

            self:resolveCollision(leftX, middleY, v)
            self:resolveCollision(rightX, middleY, v)
            self:resolveCollision(middleX, topY, v)
            self:resolveCollision(middleX, bottomY, v)

            self:resolveCollision(leftX, topY, v)
            self:resolveCollision(leftX, bottomY, v)
            self:resolveCollision(rightX, topY, v)
            self:resolveCollision(rightX, bottomY, v)
        end
    end
end

function Game:updateUI(dt)
    local mX, mY = love.mouse.getPosition()
    
    self.showMap = self.mapButtonRect:contains(mX, mY)
end

function Game:drawUI()
    -- Bottom bar
    love.graphics.setColor(135, 72, 0)
    love.graphics.rectangle("fill", 0, 480 - 40, 640, 40)

    -- Map button
    love.graphics.setColor(200, 161, 123)
    love.graphics.rectangle("fill", 640 - 35, 480 - 35, 30, 30)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("M", 640 - 35, 480 - 35)

    if self.showMap then 
        love.graphics.setColor(200, 161, 123)
        love.graphics.draw(map.minimap, 640 - 256 - 5, 480 - 256 - 40 - 5, 0, 2)
    end
end