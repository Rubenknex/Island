require "functions"
require "perlinnoise"
require "tile"

TILE_SIZE = 16
DRAW_SIZE = 8
SCREEN_COLUMNS = 640 / DRAW_SIZE
SCREEN_ROWS = 480 / DRAW_SIZE

WATER = 0
SAND = 1
GRASS = 2
ROCK = 3

WATER_LIMIT = 0.3
SAND_LIMIT = 0.4
GRASS_LIMIT = 0.7
ROCK_LIMIT = 1.

Map = {}
Map.__index = Map

function Map.create()
	local self = {}
	setmetatable(self, Map)

	self:generate(128, 128)

	self.tileset = love.graphics.newImage("data/tileset.png")
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
	local startX = math.floor(camera.x / DRAW_SIZE)
	local startY = math.floor(camera.y / DRAW_SIZE)
	local endX = startX + SCREEN_COLUMNS + 1
	local endY = startY + SCREEN_ROWS + 1

	for x=startX, endX do
		for y=startY, endY do
			if x >= 0 and y >= 0 and x < self.width and y < self.height then
				local posX = x * DRAW_SIZE - camera.x
				local posY = y * DRAW_SIZE - camera.y
				
				local currentTile = self.tiles[x + 1][y + 1]

				love.graphics.drawq(self.tileset, self.quads[currentTile.type + 1][1], posX, posY, 0, DRAW_SIZE / TILE_SIZE)
				
				if currentTile.transition > 0 then
					love.graphics.drawq(self.tileset, self.quads[currentTile.type + 1 + 1][currentTile.transition + 1], posX, posY, 0, DRAW_SIZE / TILE_SIZE)
				end

				if currentTile.decal ~= nil then
					love.graphics.drawq(self.decals, self.decalQuads[currentTile.decal], posX, posY, 0, DRAW_SIZE / TILE_SIZE)
				end
			end
		end
	end
end

function Map:generate(width, height)
	self.width, self.height = width, height

	local perlin = Perlin2D.create(width, height, 0.65, 6)
	local data = perlin:perlinNoise()
	
	local mask = self:generateIslandMask(width, height)

	for x=1, width do
		for y=1, height do
			data[x][y] = data[x][y] * mask[x][y]
		end
	end

	arrayToImage(data, "maskedPerlin")

	data = smoothenHeightMap(data, 10)

	local types = {}
	for x=1, self.width do
		types[x] = {}

		for y=1, self.height do
			local type = WATER
			local value = data[x][y]

			if value < WATER_LIMIT then type = WATER
			elseif value < SAND_LIMIT then type = SAND
			elseif value < GRASS_LIMIT then type = GRASS
			elseif value < ROCK_LIMIT then type = ROCK
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

	for x=1, self.width do
		for y=1, self.height do
			if self.tiles[x][y].type == SAND and math.random(100) < 3 then
				self.tiles[x][y].decal = math.random(1, 3)
			end
		end
	end
end

function Map:generateIslandMask(width, height)
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

	for i=1, math.floor(width * height * 0.85) do
		local x = math.random(30, width - 30)
		local y = math.random(30, height - 30)

		for j=1, math.floor(width * height * 0.05) do
			mask[x][y] = mask[x][y] + 4

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

	arrayToImage(mask, "islandMask")

	return mask
end

function Map:collisionAt(x, y)
	tileX = math.floor(x / DRAW_SIZE)
	tileY = math.floor(y / DRAW_SIZE)

	if tileX >= 0 and tileX < self.width and tileY >= 0 and tileY < self.height then
		local type = self.tiles[tileX + 1][tileY + 1].type
		
		if type == WATER then return true end
	end

	return false
end