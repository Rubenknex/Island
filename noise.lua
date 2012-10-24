require "perlin"

noise = {}

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