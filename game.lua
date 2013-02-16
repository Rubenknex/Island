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

Game = class()

function Game:init()
    camera = Camera()
    map = Map(128, 128)
    player = Player()

    self.spatialhash = SpatialHash(10 * tileDrawSize)
    entities = {}
    table.insert(entities, player)
    self:placeEntities()

    self.mapButton = Button(640 - 35, 480 - 35, 30, 30)
    self.mapButton.color = Color(255, 255, 255)
    self.mapButton.text = "Map"
    self.mapButton.onHover = Game.drawMinimap
end

function Game:update(dt)
    map:update(dt)

    self.spatialhash:clear()

    for k, v in pairs(entities) do
        if v.update then v:update(dt) end

        if v.collidable and not v.static then
            self.spatialhash:insert(v)
        end
    end

    self:handleMapCollisions()
    self:handleEntityCollisions()

    camera.x = utils.lerp(camera.x, player.position.x, 0.05)
    camera.y = utils.lerp(camera.y, player.position.y, 0.05)
end

function Game:draw()
    camera.x = math.floor(camera.x + 0.5)
    camera.y = math.floor(camera.y + 0.5)

    camera:set()
    map:draw()

    table.sort(entities, function(a, b) return a.position.y < b.position.y end)
    for k, v in pairs(entities) do
        if camera:getBounds():contains(v.position.x, v.position.y) then
            if v.draw then v:draw() end
        end
    end
    camera:unset()

    self:drawUI()

    utils.debugPrint(255, 255, 255, 255, "FPS: " .. love.timer.getFPS(), 0, 0)
    utils.debugPrint(255, 255, 255, 255, "Player: " .. tostring(player.position), 0, 15)
end

function Game:placeEntities()
    for i=1, 10 do
        local position = Vec2(0, 0)
        repeat
            position = Vec2((math.random(map.width) + 0.5) * tileDrawSize, (math.random(map.height) + 0.5) * tileDrawSize)
        until map:tileTypeAt(position.x, position.y) == SAND

        table.insert(entities, Crab(position.x, position.y))
    end

    for x=1, map.width do
        for y=1, map.height do
            local s = 128
            local p = 0.4
            local point = Vec2(x * s + utils.random(-p, p) * s, y * s + utils.random(-p, p) * s)

            if map:tileTypeAt(point.x, point.y) == GRASS then
                table.insert(entities, Tree("palmtree", point.x, point.y))
            end
        end
    end
end

function Game:handleMapCollisions()
    for k, e in pairs(entities) do
        if e.collidable and not e.static then
            e.collided = false

            local circle = e:getCollisionCircle()
            left = circle.x - circle.radius
            middleX = circle.x
            right = circle.x + circle.radius
            top = circle.y - circle.radius
            middleY = circle.y
            bottom = circle.y + circle.radius

            self:resolveMapCollision(left,   middleY, e)
            self:resolveMapCollision(right,  middleY, e)
            self:resolveMapCollision(middleX, top,    e)
            self:resolveMapCollision(middleX, bottom, e)
        end
    end
end

function Game:resolveMapCollision(x, y, entity)
    if not map:walkableAt(x, y) then
        local result, resolve = utils.collideRectCircle(map:rectAt(x, y), entity:getCollisionCircle())

        if result then
            entity.collided = true
            entity.position = entity.position + resolve
        end
    end
end

function Game:handleEntityCollisions()
    for k1, a in pairs(entities) do
        local nearby = self.spatialhash:getNearby(a)

        for k2, b in pairs(nearby) do
            if k1 ~= k2 and not (a.static and b.static) then
                local collision, resolve = utils.collideCircleCircle(a:getCollisionCircle(), b:getCollisionCircle())

                if collision then
                    if a.static then
                        b.position = b.position + resolve
                    elseif b.static then
                        a.position = a.position - resolve
                    else
                        a.position = a.position - resolve / 2
                        b.position = b.position + resolve / 2
                    end

                    if a.collidedWith then a:collidedWith(b) end
                    if b.collidedWith then b:collidedWith(a) end
                end
            end
        end
    end
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