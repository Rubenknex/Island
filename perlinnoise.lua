require "utils"

Perlin2D = {}
Perlin2D.__index = Perlin2D

function Perlin2D.create(width, height, persistance, octaves)
	local self = {}
	setmetatable(self, Perlin2D)

	self.width, self.height = width, height
	self.persistance = persistance
	self.octaves = octaves

	-- Create a map filled with random noise.
	self.noise = {}
	for x=1, width do
		self.noise[x] = {}
		for y=1, height do
			self.noise[x][y] = math.random()
		end
	end

	return self
end

function Perlin2D:generateOctave(octave)
	local period = 2.0 ^ octave
	local frequency = 1.0 / period

	-- Retrieve the surrounding values for each value in the noise map and calculate
	-- an interpolated value using cosine interpolation.
	local smooth = {}
	for x=0, self.width - 1 do
		smooth[x + 1] = {}

		local left = math.floor(x / period) * period
		local right = (left + period) % self.width
		local horBlend = (x - left) * frequency

		for y=0, self.height - 1 do
			local top = math.floor(y / period) * period
			local bottom = (top + period) % self.height
			local verBlend = (y - top) * frequency

			local above = utils.cerp(self.noise[left + 1][top + 1], self.noise[right + 1][top + 1], horBlend)
			local below = utils.cerp(self.noise[left + 1][bottom + 1], self.noise[right + 1][bottom + 1], horBlend)

			smooth[x + 1][y + 1] = utils.cerp(above, below, verBlend)
		end
	end

	return smooth
end

function Perlin2D:generate()
	local layers = {}

	-- Generate a smooth noise map for each octave.
	for i=1, self.octaves do
		layers[i] = self:generateOctave(i - 1)
	end

	-- Fill the perlin noise map with zeroes.
	local perlin = {}
	for x=1, self.width do
		perlin[x] = {}
		for y=1, self.height do
			perlin[x][y] = 0
		end
	end

	local amplitude = 1.0
	local totalAmplitude = 0.0

	-- Add all the values from the octaves multiplied by the amplitude together.
	for i=self.octaves, 1, -1 do
		amplitude = amplitude * self.persistance
		totalAmplitude = totalAmplitude + amplitude

		for x=1, self.width do
			for y=1, self.height do
				perlin[x][y] = perlin[x][y] + layers[i][x][y] * amplitude
			end
		end
	end

	-- Devide all the values by the total amplitude to put it in range [0-1].
	for x=1, self.width do
		for y=1, self.height do
			perlin[x][y] = perlin[x][y] / totalAmplitude
		end
	end

	return perlin
end