require "color"
require "utils"
require "noise"
require "vec2"

WATER = 1
SAND = 2
GRASS = 3
ROCK = 4

Map = class()

function Map:init(width, height)
    self.tileset = love.graphics.newImage("data/terrain.png")
    self.quads = {}
    for y=0, 3 do
        self.quads[y + 1] = {}
        for x=0, 15 do
            self.quads[y + 1][x + 1] = love.graphics.newQuad(x * 16, y * 16, 16, 16, self.tileset:getWidth(), self.tileset:getHeight())
        end
    end

    self.decals = love.graphics.newImage("data/decals.png")
    self.decalQuads = {}
    for x=0, 2 do
        self.decalQuads[x + 1] = love.graphics.newQuad(x * tileSize, 0, tileSize, tileSize, self.decals:getWidth(), self.decals:getHeight())
    end

    self:generate(width, height)
end

function Map:update(dt)
    
end

function Map:draw()
    local bounds = camera:getBounds()
    local startX = math.floor(bounds.left / tileDrawSize)
    local startY = math.floor(bounds.top / tileDrawSize)
    local endX = math.ceil(bounds.right / tileDrawSize)
    local endY = math.ceil(bounds.bottom / tileDrawSize)

    for x=startX, endX do
        local posX = x * tileDrawSize
        utils.debugDrawLine(255, 0, 0, 255, posX, startY * tileDrawSize, posX, endY * tileDrawSize)

        for y=startY, endY do
            local posY = y * tileDrawSize
            utils.debugDrawLine(255, 0, 0, 255, startX * tileDrawSize, posY, endX * tileDrawSize, posY)

            if x >= 0 and y >= 0 and x < self.width and y < self.height then
                local tile = self.tiles[x + 1][y + 1]

                love.graphics.setColor(tile.color:toRGB())
                love.graphics.drawq(self.tileset, self.quads[tile.type][1], posX, posY, 0, 2)
                
                if tile.transition > 0 then
                    love.graphics.setColor(tileColorTransitions[tile.type + 1][1]:toRGB())
                    love.graphics.drawq(self.tileset, self.quads[tile.type + 1][tile.transition + 1], posX, posY, 0, 2)
                end

                love.graphics.setColor(255, 255, 255)
                if tile.decal ~= nil then
                    love.graphics.drawq(self.decals, self.decalQuads[tile.decal], posX, posY, 0, 2)
                end
            end
        end
    end
end

function Map:generate(width, height)
    self.width, self.height = width, height

    local data = noise.fractionalBrownianMotion(width, height, mapFrequency, mapAmplitude, mapPersistence, mapOctaves, os.time())
    --utils.arrayToImage(data, "1 - Noise")

    local islandMask = self:generateIslandMask(width, height, mapPadding)
    --utils.arrayToImage(islandMask, "2 - Mask")

    for x=1, width do
        for y=1, height do
            data[x][y] = data[x][y] * islandMask[x][y]
        end
    end
    --utils.arrayToImage(data, "3 - Masked")

    data = utils.smoothenHeightMap(data, mapSmoothingPasses)
    --utils.arrayToImage(data, "4 - Smoothened")

    self.tiles = {}
    for x=1, width do
        self.tiles[x] = {}

        for y=1, height do
            local type = WATER
            local value = data[x][y]
            local interpolation = 0

            if value < waterLimit then 
                type = WATER
                interpolation = utils.normalize(value, 0, waterLimit)
            elseif value < sandLimit then 
                type = SAND
                interpolation = utils.normalize(value, waterLimit, sandLimit)
            elseif value < grassLimit then 
                type = GRASS
                interpolation = utils.normalize(value, sandLimit, grassLimit)
            elseif value < rockLimit then 
                type = ROCK
                interpolation = utils.normalize(value, grassLimit, 1)
            end

            self.tiles[x][y] = {
                value = value,
                type = type,
                interpolation = interpolation,
                color = Color.interpolate(tileColorTransitions[type][1], tileColorTransitions[type][2], interpolation)
            }
        end
    end

    -- Calculate which transition tiles must be placed where using bitwise counting.
    -- http://www.saltgames.com/2010/a-bitwise-method-for-applying-tilemaps/
    for x=1, self.width do
        for y=1, self.height do
            local top = (y > 1) and self.tiles[x][y - 1].type or 0
            local right = (x < self.width) and self.tiles[x + 1][y].type or 0
            local bottom = (y < self.height) and self.tiles[x][y + 1].type or 0
            local left = (x > 1) and self.tiles[x - 1][y].type or 0

            local transition = 0
            local currentType = self.tiles[x][y].type
            if top > currentType then transition = transition + 1 end
            if right > currentType then transition = transition + 2 end
            if bottom > currentType then transition = transition + 4 end
            if left > currentType then transition = transition + 8 end

            self.tiles[x][y].transition = transition
        end
    end

    self.minimap = self:generateMinimap()

    self:placeDecals()
end

function Map:generateIslandMask(width, height, size)
    local mask = {}
    for x=1, width do
        mask[x] = {}
        for y=1, height do
            local distanceToCenter = math.sqrt((width / 2 - x) ^ 2 + (height / 2 - y) ^ 2) - size
            local normalized = utils.normalize(distanceToCenter, width / 2, 0)
            mask[x][y] = utils.smootherstep(utils.clamp(normalized, 0, 1))
        end
    end

    return mask
end

function Map:generateMinimap()
    local minimapData = love.image.newImageData(self.width, self.height)
    for x=0, self.width - 1 do
        for y=0, self.height - 1 do
            minimapData:setPixel(x, y, self.tiles[x + 1][y + 1].color:toRGBA())
        end
    end

    return love.graphics.newImage(minimapData)
end

function Map:placeDecals()
    for x=1, self.width do
        for y=1, self.height do
            if self.tiles[x][y].type == SAND and math.random(100) < 3 then
                self.tiles[x][y].decal = math.random(1, 3)
            end
        end
    end
end

function Map:walkableAt(x, y)
    local type = self:tileTypeAt(x, y)

    return type ~= nil and type ~= WATER
end

function Map:tileTypeAt(x, y)
    tileX = math.floor(x / tileDrawSize)
    tileY = math.floor(y / tileDrawSize)

    if tileX >= 0 and tileX < self.width and tileY >= 0 and tileY < self.height then
        return self.tiles[tileX + 1][tileY + 1].type
    else
        return nil
    end
end

function Map:rectAt(x, y)
    tileX = math.floor(x / tileDrawSize)
    tileY = math.floor(y / tileDrawSize)

    return Rect(tileX * tileDrawSize, tileY * tileDrawSize, tileDrawSize, tileDrawSize)
end