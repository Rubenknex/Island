require "utils"
require "noise"
require "tile"
require "vec2"

Map = {}
Map.__index = Map

Map.TILE_SIZE = 16
Map.DRAW_SIZE = 32
Map.COLUMNS = 640 / Map.DRAW_SIZE
Map.ROWS = 480 / Map.DRAW_SIZE
Map.WATER = 0
Map.SAND = 1
Map.GRASS = 2
Map.ROCK = 3
Map.WATER_LIMIT = 0.3
Map.SAND_LIMIT = 0.4
Map.GRASS_LIMIT = 0.65
Map.ROCK_LIMIT = 1.0

function Map.create(width, height)
    local self = {}
    setmetatable(self, Map)

    self:generate(width, height)

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
        self.decalQuads[x + 1] = love.graphics.newQuad(x * Map.TILE_SIZE, 0, Map.TILE_SIZE, Map.TILE_SIZE, self.decals:getWidth(), self.decals:getHeight())
    end

    return self
end

function Map:generate(width, height)
    self.width, self.height = width, height

    local data = noise.fractionalBrownianMotion(width, height, 1.0, 1.0, 0.7, 6, os.time())
    utils.arrayToImage(data, "1 - Noise")

    local islandMask = self:generateIslandMask(width, height, 30)
    utils.arrayToImage(islandMask, "2 - Mask")

    for x=1, width do
        for y=1, height do
            data[x][y] = data[x][y] * islandMask[x][y]
        end
    end
    utils.arrayToImage(data, "3 - Masked")

    data = utils.smoothenHeightMap(data, 5)
    utils.arrayToImage(data, "4 - Smoothened")

    local types = {}
    for x=1, width do
        types[x] = {}

        for y=1, height do
            local type = Map.WATER
            local value = data[x][y]

            if value < Map.WATER_LIMIT then type = Map.WATER
            elseif value < Map.SAND_LIMIT then type = Map.SAND
            elseif value < Map.GRASS_LIMIT then type = Map.GRASS
            elseif value < Map.ROCK_LIMIT then type = Map.ROCK
            end

            types[x][y] = type
        end
    end

    -- Calculate which transition tiles must be placed where using bitwise counting.
    -- http://www.saltgames.com/2010/a-bitwise-method-for-applying-tilemaps/
    self.tiles = {}
    for x=1, self.width do
        self.tiles[x] = {}

        for y=1, self.height do
            local top = (y > 1) and types[x][y - 1] or 0
            local right = (x < self.width) and types[x + 1][y] or 0
            local bottom = (y < self.height) and types[x][y + 1] or 0
            local left = (x > 1) and types[x - 1][y] or 0

            local transition = 0
            local currentType = types[x][y]
            if top > currentType then transition = transition + 1 end
            if right > currentType then transition = transition + 2 end
            if bottom > currentType then transition = transition + 4 end
            if left > currentType then transition = transition + 8 end

            self.tiles[x][y] = Tile.create(currentType, data[x][y], transition)
        end
    end

    self:generateMinimap()

    self:placeDecals()
end

function Map:generateIslandMask(width, height, maskDistance)
    -- Generates a mask with values ranging from 0 to 1 with which to multiply
    -- the height map.
    -- Credit goes to http://breinygames.blogspot.nl/2012/06/generating-terrain-using-perlin-noise.html
    local mask = {}
    for x=1, width do
        mask[x] = {}
        for y=1, height do
            mask[x][y] = 0
        end
    end

    for i=1, math.floor(width * height * 0.60) do
        local x = math.random(maskDistance, width - maskDistance)
        local y = math.random(maskDistance, height - maskDistance)

        for j=1, math.floor(width * height * 0.1) do
            mask[x][y] = mask[x][y] + 5

            if mask[x][y] > 255 then mask[x][y] = 255 end
            local value = mask[x][y]

            local directions = {}
            if x - 1 >= 1 then
                if mask[x - 1][y] <= value then table.insert(directions, "left") end
            end
            if x + 1 <= width then
                if mask[x + 1][y] <= value then table.insert(directions, "right") end
            end
            if y - 1 >= 1 then
                if mask[x][y - 1] <= value then table.insert(directions, "up") end
            end
            if y + 1 <= height then
                if mask[x][y + 1] <= value then table.insert(directions, "down") end
            end

            if #directions == 0 then break end

            local direction = directions[math.random(#directions)]
            if direction == "left" then x = x - 1 end
            if direction == "right" then x = x + 1 end
            if direction == "up" then y = y - 1 end
            if direction == "down" then y = y + 1 end
        end
    end
    
    for x=1, width do
        for y=1, height do
            mask[x][y] = mask[x][y] / 255
        end
    end

    return mask
end

function Map:placeDecals()
    for x=1, self.width do
        for y=1, self.height do
            if self.tiles[x][y].type == Map.SAND and math.random(100) < 3 then
                self.tiles[x][y].decal = math.random(1, 3)
            end
        end
    end
end

function Map:placePlants()

end

function Map:generateMinimap()
    local minimapData = love.image.newImageData(self.width, self.height)
    for x=1, self.width do
        for y=1, self.height do
            local type = self.tiles[x][y].type

            if type == Map.WATER then minimapData:setPixel(x - 1, y - 1, 31, 34, 222, 255)
            elseif type == Map.SAND then minimapData:setPixel(x - 1, y - 1, 252, 227, 58, 255)
            elseif type == Map.GRASS then minimapData:setPixel(x - 1, y - 1, 0, 128, 30, 255)
            elseif type == Map.ROCK then minimapData:setPixel(x - 1, y - 1, 82, 82, 82, 255)
            end
        end
    end

    self.minimap = love.graphics.newImage(minimapData)
end

function Map:walkableAt(x, y)
    local type = self:tileTypeAt(x, y)

    return type ~= nil and type ~= Map.WATER
end

function Map:tileTypeAt(x, y)
    tileX = math.floor(x / Map.DRAW_SIZE)
    tileY = math.floor(y / Map.DRAW_SIZE)

    if tileX >= 0 and tileX < self.width and tileY >= 0 and tileY < self.height then
        return self.tiles[tileX + 1][tileY + 1].type
    else
        return nil
    end
end

function Map:update(dt)
    
end

function Map:draw()
    local startX = math.floor(camera.x / Map.DRAW_SIZE)
    local startY = math.floor(camera.y / Map.DRAW_SIZE)
    local endX = startX + Map.COLUMNS + 1
    local endY = startY + Map.ROWS + 1

    for x=startX, endX do
        local posX = x * Map.DRAW_SIZE - camera.x
        utils.debugDrawLine(255, 0, 0, 255, posX, startY * Map.DRAW_SIZE - camera.y, posX, endY * Map.DRAW_SIZE - camera.y)

        for y=startY, endY do
            local posY = y * Map.DRAW_SIZE - camera.y
            utils.debugDrawLine(255, 0, 0, 255, startX * Map.DRAW_SIZE - camera.x, posY, endX * Map.DRAW_SIZE - camera.x, posY)

            if x >= 0 and y >= 0 and x < self.width and y < self.height then
                local currentTile = self.tiles[x + 1][y + 1]

                love.graphics.setColor(255, 255, 255, 255)
                love.graphics.drawq(self.tileset, self.quads[currentTile.type + 1][1], posX, posY, 0, Map.DRAW_SIZE / Map.TILE_SIZE)
                
                if currentTile.transition > 0 then
                    love.graphics.drawq(self.tileset, self.quads[currentTile.type + 1 + 1][currentTile.transition + 1], posX, posY, 0, Map.DRAW_SIZE / Map.TILE_SIZE)
                end

                if currentTile.decal ~= nil then
                    love.graphics.drawq(self.decals, self.decalQuads[currentTile.decal], posX, posY, 0, Map.DRAW_SIZE / Map.TILE_SIZE)
                end
            end
        end
    end
end