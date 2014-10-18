require "camera"
require "color"
require "entities"
require "gui"
require "player"
require "shapes"
require "utils"
require "vec2"
require "world"

Game = class()

function Game:init()
    world = World(128, 128)
    player = Player()
    camera = Camera()

    world:addEntity(player)
    camera:moveTo(player.position)

    self:placeEntities()

    self.showInventory = false
end

function Game:update(dt)
    world:update(dt)

    camera:moveToSmooth(player.position, 3, dt)
end

function Game:draw()
    camera:set()
    world:draw()
    camera:unset()

    self:onGUI()

    utils.debugPrint("FPS: " .. love.timer.getFPS(), 0, 0)
    utils.debugPrint("Player: " .. tostring(player.position), 0, 15)
    utils.debugPrint(string.format("Collision: %d checks, %d solves", world.checks, world.solves), 0, 45)
end

function Game:placeEntities()
    for i=1, 10 do
        local position = Vec2()
        while world:tileAt(position.x, position.y).type ~= "sand" do
            position = Vec2((math.random(world.width - 1) + 0.5) * tileDrawSize, (math.random(world.height - 1) + 0.5) * tileDrawSize)
        end

        world:addEntity(Crab(position.x, position.y))
    end

    for x=1, world.width do
        for y=1, world.height do
            local s = 128
            local p = 0.4
            local point = Vec2(x * s + utils.random(-p, p) * s, y * s + utils.random(-p, p) * s)

            local tile = world:tileAt(point.x, point.y)

            if tile and tile.type == "grass" then
                world:addEntity(Entity("palm", point.x, point.y))
            end
        end
    end

    for x=1, world.width do
        for y=1, world.height do
            local s = 128
            local p = 0.4
            local point = Vec2(x * s + utils.random(-p, p) * s, y * s + utils.random(-p, p) * s)

            local tile = world:tileAt(point.x, point.y)

            if tile and tile.type == "sand" then
                local choices = {"starfish", "stone", "shell"}
                world:addEntity(Entity(choices[math.random(1, 3)], point.x, point.y))
            end
        end
    end
end

function Game:onGUI()
    love.graphics.setColor(135, 72, 0)
    love.graphics.rectangle("fill", 0, 480 - 40, 640, 40)

    if GUI.button("click", Rect(640 - 65, 480 - 35, 60, 30), "Inventory") then
        self.showInventory = not self.showInventory
    end

    if self.showInventory then
        player.inventory:draw(640 - 155, 480 - 295)
    end

    if GUI.button("hover", Rect(640 - 130, 480 - 35, 60, 30), "Map") then
        self:drawMinimap()
    end
end

function Game:drawMinimap()
    love.graphics.setColor(200, 161, 123)
    love.graphics.draw(world.minimap, 640 - 256 - 5, 480 - 256 - 40 - 5, 0, 2)
end