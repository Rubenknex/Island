require "camera"
require "color"
require "entities"
require "gui"
require "map"
require "player"
require "shapes"
require "spatialhash"
require "utils"
require "vec2"

Game = {}
Game.__index = Game

function Game.create()
    local self = {}
    setmetatable(self, Game)

    camera = Camera.create()
    map = Map.create(128, 128)
    player = Player.create()

    self.spatialhash = SpatialHash.create(10 * tileDrawSize)
    entities = {}
    table.insert(entities, player)
    self:placeEntities()

    self.mapButton = Button.create(640 - 35, 480 - 35, 30, 30)
    self.mapButton.color = Color.fromRGB(255, 255, 255)
    self.mapButton.text = "Map"
    self.mapButton.onHover = Game.drawMinimap

    return self
end

function Game:update(dt)
    map:update(dt)

    self.spatialhash:clear()

    for k, v in pairs(entities) do
        v:update(dt)

        if v.collidable and not v.static then
            self.spatialhash:insert(v)
        end
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

    table.sort(entities, function(a, b) return a.position.y < b.position.y end)
    local bounds = camera:getBounds()
    for k, v in pairs(entities) do
        if bounds:contains(v.position.x, v.position.y) then
            v:draw()
        end
    end
    camera:unset()

    self:drawUI()

    utils.debugPrint(255, 255, 255, 255, "FPS: " .. love.timer.getFPS(), 0, 0)
    utils.debugPrint(255, 255, 255, 255, "Player: " .. tostring(player.position), 0, 15)
end

function Game:placeEntities()
    for i=1, 10 do
        local position = Vec2.create(0, 0)
        repeat
            position = Vec2.create((math.random(map.width) + 0.5) * tileDrawSize, (math.random(map.height) + 0.5) * tileDrawSize)
        until map:tileTypeAt(position.x, position.y) == SAND

        table.insert(entities, Crab.create(position.x, position.y))
    end

    for x=1, map.width do
        for y=1, map.height do
            local s = 128
            local p = 0.4
            local point = Vec2.create(x * s + utils.random(-p, p) * s, y * s + utils.random(-p, p) * s)

            if map:tileTypeAt(point.x, point.y) == GRASS then
                table.insert(entities, Tree.create("palmtree", point.x, point.y))
            end
        end
    end
end

function Game:resolveCollision(x, y, entity)
    if not map:walkableAt(x, y) then
        local result, resolve = utils.collideRectCircle(map:rectAt(x, y), entity:getCollisionCircle())

        if result then
            entity.collided = true
            entity.position = entity.position + resolve
        end
    end
end

function Game:handleCollisions()
    for k, v in pairs(entities) do
        if v.collidable and not v.static then
            v.collided = false

            local circle = v:getCollisionCircle()
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

    for k1, v1 in pairs(entities) do
        local nearby = self.spatialhash:getNearby(v1)

        for k2, v2 in pairs(nearby) do
            if k1 ~= k2 and not (v1.static and v2.static) then
                local result, resolve = utils.collideCircleCircle(v1:getCollisionCircle(), v2:getCollisionCircle())

                if result then
                    if v1.static then
                        v2.position = v2.position + resolve
                    elseif v2.static then
                        v1.position = v1.position - resolve
                    else
                        v1.position = v1.position - resolve / 2
                        v2.position = v2.position + resolve / 2
                    end
                end
            end
        end
    end
end

function Game:updateUI(dt)
    
end

function Game:drawUI()
    -- Bottom bar
    love.graphics.setColor(135, 72, 0)
    love.graphics.rectangle("fill", 0, 480 - 40, 640, 40)

    -- Map button
    self.mapButton:update()
    self.mapButton:draw()
end

function Game:drawMinimap()
    love.graphics.setColor(200, 161, 123)
    love.graphics.draw(map.minimap, 640 - 256 - 5, 480 - 256 - 40 - 5, 0, 2)
end