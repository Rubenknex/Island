require "color"
require "utils"
require "vec2"

Map = class()

function Map:init(width, height)
    self.width = width
    self.height = height
    self.tileset = love.graphics.newImage("images/terrain.png")
    self.quads = {}
    for y=0, 3 do
        self.quads[y + 1] = {}
        for x=0, 15 do
            self.quads[y + 1][x + 1] = love.graphics.newQuad(x * 16, y * 16, 16, 16, self.tileset:getWidth(), self.tileset:getHeight())
        end
    end

    self.decals = love.graphics.newImage("images/decals.png")
    self.decalQuads = {}
    for x=0, 2 do
        self.decalQuads[x + 1] = love.graphics.newQuad(x * tileSize, 0, tileSize, tileSize, self.decals:getWidth(), self.decals:getHeight())
    end

    self:generate(width, height)
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
                love.graphics.drawq(self.tileset, self.quads[tile.index][1], posX, posY, 0, tileDrawSize / tileSize)

                if tile.transition > 0 then
                    love.graphics.setColor(tileTypes[tile.index + 1].startColor:toRGB())
                    love.graphics.drawq(self.tileset, self.quads[tile.index + 1][tile.transition + 1], posX, posY, 0, 2)
                end

                if tile.decal ~= nil then
                    love.graphics.setColor(255, 255, 255)
                    love.graphics.drawq(self.decals, self.decalQuads[tile.decal], posX, posY, 0, 2)
                end
            end
        end
    end
end

function Map:generate(width, height)
    local data = utils.noiseMap(width, height, mapFrequency, mapAmplitude, mapPersistence, mapOctaves, os.time())
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

function Map:generateTileTransitions()
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
            if self.tiles[x][y].type == "sand" and math.random(100) < 3 then
                self.tiles[x][y].decal = math.random(1, 3)
            end
        end
    end
end

function Map:tileAt(x, y)
    tileX = math.floor(x / tileDrawSize)
    tileY = math.floor(y / tileDrawSize)

    if tileX >= 0 and tileX < self.width and tileY >= 0 and tileY < self.height then
        return self.tiles[tileX + 1][tileY + 1]
    else
        return nil
    end
end

function Map:rectAt(x, y)
    tileX = math.floor(x / tileDrawSize)
    tileY = math.floor(y / tileDrawSize)

    return Rect(tileX * tileDrawSize, tileY * tileDrawSize, tileDrawSize, tileDrawSize)
end