require "functions"

Perlin2D = {}
Perlin2D.__index = Perlin2D

function Perlin2D.create(width, height, persistance, octaves)
	local self = {}
	setmetatable(self, Perlin2D)

	self.width, self.height = width, height
	self.persistance = persistance
	self.octaves = octaves

	self.noise = {}
	for x=1, width do
		self.noise[x] = {}
		for y=1, height do
			self.noise[x][y] = math.random()
		end
	end

	arrayToImage(self.noise, "noise")

	return self
end

function Perlin2D:smoothNoise(octave)
	local smooth = {}
	local period = 2.0 ^ octave
	local frequency = 1.0 / period

	for x=0, self.width - 1 do
		smooth[x + 1] = {}

		local left = math.floor(x / period) * period
		local right = (left + period) % self.width
		local horBlend = (x - left) * frequency
		--print("Left: " .. left .. " x: " .. x .. " Frequency: " .. frequency)

		for y=0, self.height - 1 do
			local top = math.floor(y / period) * period
			local bottom = (top + period) % self.height
			local verBlend = (y - top) * frequency

			local above = math.cerp(self.noise[left + 1][top + 1], self.noise[right + 1][top + 1], horBlend)
			local below = math.cerp(self.noise[left + 1][bottom + 1], self.noise[right + 1][bottom + 1], horBlend)

			smooth[x + 1][y + 1] = math.cerp(above, below, verBlend)
			--smooth[x + 1][y + 1] = verBlend
		end
	end

	return smooth
end

function Perlin2D:perlinNoise()
	local smooth = {}

	for i=1, self.octaves do
		smooth[i] = self:smoothNoise(i - 1)

		arrayToImage(smooth[i], "octave" .. i)
	end

	local perlin = {}
	for x=1, self.width do
		perlin[x] = {}
		for y=1, self.height do
			perlin[x][y] = 0.0
		end
	end

	local amplitude = 1.0
	local totalAmplitude = 0.0

	for i=self.octaves, 1, -1 do
		amplitude = amplitude * self.persistance
		totalAmplitude = totalAmplitude + amplitude

		for x=1, self.width do
			for y=1, self.height do
				perlin[x][y] = perlin[x][y] + smooth[i][x][y] * amplitude
			end
		end
	end

	for x=1, self.width do
		for y=1, self.height do
			perlin[x][y] = perlin[x][y] / totalAmplitude
		end
	end

	arrayToImage(perlin, "perlin")
	print(perlin[1][1])

	return perlin
end