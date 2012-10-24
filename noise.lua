require "perlin"

noise = {}

-- Generates a 2D perlin noise map with values within the range 0-1
-- width, height: The dimensions of the noise map
-- frequency: The initial frequency of the noise
-- amplitude: The initial amplitude of the noise
-- persistence: Multiplied with the amplitude every octave
-- octaves: The amount of layers of noise to add to each other
-- seed: A seed for the noise, the same seed will produce the same noise maps
function noise.fractionalBrownianMotion(width, height, frequency, amplitude, persistence, octaves, seed)
	perlin.seed(seed)

	local data = {}
	local min, max = math.huge, -math.huge

	local startFrequency = frequency
	local startAmplitude = amplitude

	for x=1, width do
		data[x] = {}
		for y=1, height do
			local total = 0

			local period = 1.0 / width
			local frequency = startFrequency
			local amplitude = startAmplitude

			for octave=1, octaves do
				value = perlin.noise((x * period) * frequency, (y * period) * frequency)
				total = total + value * amplitude

				frequency = frequency * 2
				amplitude = amplitude * persistence
			end

			if total < min then min = total end
			if total > max then max = total end

			data[x][y] = total
		end
	end

	for x=1, width do
		for y=1, height do
			data[x][y] = (data[x][y] - min) / (max - min)
		end
	end

	return data
end

function noise.perturb(data, noise)
	local width, height = #data, #data[1]
	local out = {}

	for x=1, width do
		out[x] = {}
		for y=1, height do
			
		end
	end


end