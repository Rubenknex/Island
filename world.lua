require "color"
require "grid"
require "utils"
require "vec2"

World = class()

function World:init(width, height)
    self.tileset = love.graphics.newImage("images/terrain.png")

    self.width = width
    self.height = height

    self.tiles = {}
    self.quads = {}
    for y=0, #tileTypes - 1 do
        self.quads[y + 1] = {}
        for x=0, 15 do
            self.quads[y + 1][x + 1] = love.graphics.newQuad(x * tileSize, y * tileSize, tileSize, tileSize, self.tileset:getWidth(), self.tileset:getHeight())
        end
    end

    self.entities = {}

    self.grid = Grid(width * tileDrawSize, height * tileDrawSize, gridSize)
    
    self:generate(width, height)
end

function World:update(dt)
    self.grid:clear()

    for k, v in pairs(self.entities) do
        if v.update then v:update(dt) end

        if v.collidable and not v.static then
            self.grid:insert(v)
        end
    end

    self:handleMapCollisions()
    self:handleEntityCollisions()
end

function World:draw()
    local bounds = camera:getRect()
    local startX = math.floor(bounds.x / tileDrawSize)
    local startY = math.floor(bounds.y / tileDrawSize)
    local endX = math.ceil((bounds.x + bounds.w) / tileDrawSize)
    local endY = math.ceil((bounds.y + bounds.h) / tileDrawSize)

    for x=startX, endX do
        local posX = x * tileDrawSize
        --utils.debugDrawLine(255, 0, 0, 128, posX, startY * tileDrawSize, posX, endY * tileDrawSize)

        for y=startY, endY do
            local posY = y * tileDrawSize
            --utils.debugDrawLine(255, 0, 0, 128, startX * tileDrawSize, posY, endX * tileDrawSize, posY)

            if x >= 0 and y >= 0 and x < self.width and y < self.height then
                local tile = self.tiles[x + 1][y + 1]

                love.graphics.setColor(tile.color:toRGB())
                love.graphics.draw(self.tileset, self.quads[tile.index][1], posX, posY, 0, tileDrawSize / tileSize)

                if tile.transition > 0 then
                    love.graphics.setColor(tileTypes[tile.index + 1].startColor:toRGB())
                    love.graphics.draw(self.tileset, self.quads[tile.index + 1][tile.transition + 1], posX, posY, 0, 2)
                end
            end
        end
    end

    table.sort(self.entities, function(a, b) return a.position.y < b.position.y end)
    for k, v in pairs(self.entities) do
        if utils.rectIntersects(v:getRect(), camera:getRect()) then
            if v.draw then v:draw() end
        end
    end
end

function World:generate(width, height)
    local data = utils.noiseMap(width, height, mapFrequency, mapAmplitude, mapPersistence, mapOctaves, os.time())
    --utils.arrayToImage(data, "1 - Noise")

    local islandMask = self:generateIslandMask(width, height)
    --utils.arrayToImage(islandMask, "2 - Mask")

    for x=1, width do
        for y=1, height do
            data[x][y] = data[x][y] * islandMask[x][y]
        end
    end
    --utils.arrayToImage(data, "3 - Masked")

    data = utils.smoothenHeightMap(data, mapSmoothingPasses)
    --utils.arrayToImage(data, "4 - Smoothened")

    for x=1, width do
        self.tiles[x] = {}

        for y=1, height do
            local value = data[x][y]

            for key, tile in pairs(tileTypes) do
                if value < tile.limit then
                    local lowerLimit = 0
                    if tileTypes[key - 1] then lowerLimit = tileTypes[key - 1].limit end
                    local interpolation = utils.normalize(value, lowerLimit, tile.limit)

                    self.tiles[x][y] = {
                        type = tile.type,
                        index = key,
                        value = value,
                        interpolation = interpolation,
                        color = Color.interpolate(tile.startColor, tile.endColor, interpolation)
                    }

                    break
                end
            end
        end
    end

    self:generateTileTransitions()
    self.minimap = self:generateMinimap()
end

function World:generateIslandMask(width, height)
    local mask = {}
    for x=1, width do
        mask[x] = {}
        for y=1, height do
            local value = utils.gaussian((x - width / 2) / (width / 1.3), (y - height / 2) / (height / 1.3), 0.3)
            mask[x][y] = utils.clamp(value, 0.0, 1.0)
        end
    end

    return mask
end

function World:generateTileTransitions()
    -- http://www.saltgames.com/2010/a-bitwise-method-for-applying-tilemaps/
    for x=1, self.width do
        for y=1, self.height do
            local top = (y > 1) and self.tiles[x][y - 1].index or 0
            local right = (x < self.width) and self.tiles[x + 1][y].index or 0
            local bottom = (y < self.height) and self.tiles[x][y + 1].index or 0
            local left = (x > 1) and self.tiles[x - 1][y].index or 0

            local transition = 0
            local currentType = self.tiles[x][y].index
            if top > currentType then transition = transition + 1 end
            if right > currentType then transition = transition + 2 end
            if bottom > currentType then transition = transition + 4 end
            if left > currentType then transition = transition + 8 end

            self.tiles[x][y].transition = transition
        end
    end
end

function World:generateMinimap()
    local minimapData = love.image.newImageData(self.width, self.height)
    for x=1, self.width do
        for y=1, self.height do
            minimapData:setPixel(x - 1, y - 1, self.tiles[x][y].color:toRGBA())
        end
    end

    return love.graphics.newImage(minimapData)
end

function World:handleMapCollisions()
    for k, e in pairs(self.entities) do
        if e.collidable and not e.static then
            e.collided = false

            local circle = e:getCircle()
            local left = circle.x - circle.radius
            local middleX = circle.x
            local right = circle.x + circle.radius
            local top = circle.y - circle.radius
            local middleY = circle.y
            local bottom = circle.y + circle.radius

            self:resolveMapCollision(left,   middleY, e)
            self:resolveMapCollision(right,  middleY, e)
            self:resolveMapCollision(middleX, top,    e)
            self:resolveMapCollision(middleX, bottom, e)
        end
    end
end

function World:resolveMapCollision(x, y, entity)
    if self:tileAt(x, y).type == "water" then
        local result, resolve = utils.collideRectCircle(world:rectAt(x, y), entity:getCircle())

        if result then
            entity.position = entity.position + resolve
        end
    end
end

function World:handleEntityCollisions()
    self.checks = 0
    self.solves = 0

    for k1, a in pairs(self.entities) do
        if a.collidable then
            local nearby = self.grid:getNearby(a)

            for k2, b in pairs(nearby) do
                if a ~= b then
                    local collision, resolve = utils.collideCircleCircle(a:getCircle(), b:getCircle())

                    if collision then
                        if a.static then
                            b.position = b.position + resolve
                        else
                            a.position = a.position - resolve / 2
                            b.position = b.position + resolve / 2
                        end

                        if a.collidedWith then a:collidedWith(b) end
                        if b.collidedWith then b:collidedWith(a) end

                        self.solves = self.solves + 1
                    end

                    self.checks = self.checks + 1
                end
            end
        end
    end
end

function World:addEntity(entity)
    table.insert(self.entities, entity)
end

function World:tileAtIndex(x, y)
    if x >= 0 and x < self.width and y >= 0 and y < self.height then
        return self.tiles[x + 1][y + 1]
    else
        return nil
    end
end

function World:tileAt(x, y)
    tileX = math.floor(x / tileDrawSize)
    tileY = math.floor(y / tileDrawSize)

    return self:tileAtIndex(tileX, tileY)
end

function World:rectAt(x, y)
    tileX = math.floor(x / tileDrawSize)
    tileY = math.floor(y / tileDrawSize)

    return Rect(tileX * tileDrawSize, tileY * tileDrawSize, tileDrawSize, tileDrawSize)
end