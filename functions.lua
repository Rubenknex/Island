require "vec2"

function math.cerp(a, b, x)
	-- Returns the cosine interpolated value between a and b.
	local f = (1 - math.cos(x * math.pi)) * 0.5
	return a * (1 - f) + b * f
end

function math.clamp(value, min, max)
	-- Returns the value clamped between min and max.
	if value < min then
		return min
	elseif value > max then
		return max
	end

	return value
end

function math.lerp(a, b, x)
	-- Returns the linear interpolated value between a and b.
	return a + (b - a) * x
end

function HSL(h, s, l, a)
	-- Converts from HSL color space to RGB color space
	-- h: Hue, where in the spectrum the color is.
	-- s: Saturation, how vibrant the color is.
	-- l: Lightness, how light or dark a color is.
	if s <= 0 then return 1, 1, 1, a end

	h, s, l = h / 256 * 6, s / 255, l / 255

	local c = (1 - math.abs(2 * l - 1)) * s
	local x = (1 - math.abs(h % 2 - 1)) * c
	local m, r, g, b = (1 - 0.5 * c), 0, 0, 0

	if h < 1 then r, g, b = c, x, 0
	elseif h < 2 then r, g, b = x, c, 0
	elseif h < 3 then r, g, b = 0, c, x
	elseif h < 4 then r, g, b = 0, x, c
	elseif h < 5 then r, g, b = x, 0, c
	else r, g, b = c, 0, x end

	return (r + m) * 255, (g + m) * 255, (b + m) * 255, a
end

function collideRectCircle(rect, pos, radius)
	local closestX = math.clamp(pos.x, rect.x, rect.max_x)
	local closestY = math.clamp(pos.y, rect.y, rect.max_y)

	local diff = Vec2.create(pos.x - closestX, pos.y - closestY)

	if diff:lengthSquared() > radius ^ 2 then
		return false, 0, 0
	end

	local length = diff:length()

	if length == 0 then
		return false, 0, 0
	end

	local normal = diff:normalized()

	return true, normal, radius - length
end

function smoothenHeightMap(data, passes)
	local newData = nil
	local width, height = #data, #data[1]

	for i=1, passes do
		newData = {}

		for x=1, width do
			newData[x] = {}

			for y=1, height do
				local adjacent = 0
				local total = 0

				if x - 1 >= 1 then
					total = total + data[x - 1][y]
					adjacent = adjacent + 1

					if y - 1 >= 1 then
						total = total + data[x - 1][y - 1]
						adjacent = adjacent + 1
					end
					if y + 1 <= height then
						total = total + data[x - 1][y + 1]
						adjacent = adjacent + 1
					end
				end

				if x + 1 <= width then
					total = total + data[x + 1][y]
					adjacent = adjacent + 1

					if y - 1 >= 1 then
						total = total + data[x + 1][y - 1]
						adjacent = adjacent + 1
					end
					if y + 1 <= height then
						total = total + data[x + 1][y + 1]
						adjacent = adjacent + 1
					end
				end

				if y - 1 >= 1 then
					total = total + data[x][y - 1]
					adjacent = adjacent + 1
				end
				if y + 1 <= height then
					total = total + data[x][y + 1]
					adjacent = adjacent + 1
				end

				newData[x][y] = (data[x][y] + (total / adjacent)) * 0.5
			end
		end

		for x=1, width do
			for y=1, height do
				data[x][y] = newData[x][y]
			end
		end
	end

	return newData
end

function arrayToImage(array, name)
	local width, height = #array, #array[1]
	local imgData = love.image.newImageData(width, height)
	for y=1, height do
		for x=1, width do
			local value = array[x][y] * 255
			imgData:setPixel(x - 1, y - 1, value, value, value, 255)
		end
	end
	imgData:encode(name .. ".png")
end