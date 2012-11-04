require "color"
require "utils"
require "noise"
require "vec2"

WATER = 1
SAND = 2
GRASS = 3
ROCK = 4

TILE_COLORS = {
    {Color.fromHSL(218, 100, 35), Color.fromHSL(218, 100, 60)},
    {Color.fromHSL(59, 55, 67), Color.fromHSL(59, 55, 80)},
    {Color.fromHSL(103, 50, 32), Color.fromHSL(103, 50, 23)},
    {Color.fromHSL(0, 0, 40), Color.fromHSL(0, 0, 32)}
}

Tile = {}
Tile.__index = Tile

function Tile.create(type, value, transition, interpolation)
    -- type: The type of the tile (water, grass etc).
    -- value: The value from the noise map, the type is derived from this.
    -- transition: Stores the combination of neighbouring tiles, used as offset in the tileset.
    local self = {}
    setmetatable(self, Tile)

    self.type = type
    self.value = value
    self.transition = transition
    self.tileColor = TILE_COLORS[self.type][1]:interpolate(TILE_COLORS[self.type][2], interpolation)
    if self.type ~= ROCK then
        self.transitionColor = TILE_COLORS[self.type + 1][1]
    end
    self.decal = nil

    return self
end

TILE_SIZE = 16
TILE_DRAW_SIZE = 32
WATER_LIMIT = 0.3
SAND_LIMIT = 0.4
GRASS_LIMIT = 0.65
ROCK_LIMIT = 1.0

Map = {}
Map.__index = Map

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
        self.decalQuads[x + 1] = love.graphics.newQuad(x * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, self.decals:getWidth(), self.decals:getHeight())
    end

    return self
end

function Map:update(dt)
    
end

function Map:draw()
    local bounds = camera:getBounds()
    local startX = math.floor(bounds.left / TILE_DRAW_SIZE)
    local startY = math.floor(bounds.top / TILE_DRAW_SIZE)
    local endX = math.ceil(bounds.right / TILE_DRAW_SIZE)
    local endY = math.ceil(bounds.bottom / TILE_DRAW_SIZE)

    for x=startX, endX do
        local posX = x * TILE_DRAW_SIZE
        utils.debugDrawLine(255, 0, 0, 255, posX, startY * TILE_DRAW_SIZE, posX, endY * TILE_DRAW_SIZE)

        for y=startY, endY do
            local posY = y * TILE_DRAW_SIZE
            utils.debugDrawLine(255, 0, 0, 255, startX * TILE_DRAW_SIZE, posY, endX * TILE_DRAW_SIZE, posY)

            if x >= 0 and y >= 0 and x < self.width and y < self.height then
                local currentTile = self.tiles[x + 1][y + 1]

                love.graphics.setColor(currentTile.tileColor:toRGB())
                love.graphics.drawq(self.tileset, self.quads[currentTile.type][1], posX, posY, 0, 2)
                
                if currentTile.transition > 0 then
                    love.graphics.setColor(currentTile.transitionColor:toRGB())
                    love.graphics.drawq(self.tileset, self.quads[currentTile.type + 1][currentTile.transition + 1], posX, posY, 0, 2)
                end

                love.graphics.setColor(255, 255, 255)
                if currentTile.decal ~= nil then
                    love.graphics.drawq(self.decals, self.decalQuads[currentTile.decal], posX, posY, 0, 2)
                end
            end
        end
    end
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
    local interpolations = {}
    for x=1, width do
        types[x] = {}
        interpolations[x] = {}

        for y=1, height do
            local type = WATER
            local value = data[x][y]
            local interpolation = 0

            if value < WATER_LIMIT then 
                type = WATER
                interpolation = utils.normalize(value, 0, WATER_LIMIT)
            elseif value < SAND_LIMIT then 
                type = SAND
                interpolation = utils.normalize(value, WATER_LIMIT, SAND_LIMIT)
            elseif value < GRASS_LIMIT then 
                type = GRASS
                interpolation = utils.normalize(value, SAND_LIMIT, GRASS_LIMIT)
            elseif value < ROCK_LIMIT then 
                type = ROCK
                interpolation = utils.normalize(value, GRASS_LIMIT, 1)
            end

            types[x][y] = type
            interpolations[x][y] = interpolation
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

            self.tiles[x][y] = Tile.create(currentType, data[x][y], transition, interpolations[x][y])
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

function Map:generateMinimap()
    local minimapData = love.image.newImageData(self.width, self.height)
    for x=1, self.width do
        for y=1, self.height do
            local type = self.tiles[x][y].type

            if type == WATER then minimapData:setPixel(x - 1, y - 1, 31, 34, 222, 255)
            elseif type == SAND then minimapData:setPixel(x - 1, y - 1, 252, 227, 58, 255)
            elseif type == GRASS then minimapData:setPixel(x - 1, y - 1, 0, 128, 30, 255)
            elseif type == ROCK then minimapData:setPixel(x - 1, y - 1, 82, 82, 82, 255)
            end
        end
    end

    self.minimap = love.graphics.newImage(minimapData)
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

function Map:placePlants()

end

function Map:walkableAt(x, y)
    local type = self:tileTypeAt(x, y)

    return type ~= nil and type ~= WATER
end

function Map:tileTypeAt(x, y)
    tileX = math.floor(x / TILE_DRAW_SIZE)
    tileY = math.floor(y / TILE_DRAW_SIZE)

    if tileX >= 0 and tileX < self.width and tileY >= 0 and tileY < self.height then
        return self.tiles[tileX + 1][tileY + 1].type
    else
        return nil
    end
end

function Map:rectAt(x, y)
    tileX = math.floor(x / TILE_DRAW_SIZE)
    tileY = math.floor(y / TILE_DRAW_SIZE)

    return Rect.create(tileX * TILE_DRAW_SIZE, tileY * TILE_DRAW_SIZE, TILE_DRAW_SIZE, TILE_DRAW_SIZE)
end