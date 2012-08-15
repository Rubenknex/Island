require "vec2"

function math.cerp(a, b, x)
	local f = (1 - math.cos(x * math.pi)) * 0.5
	return a * (1 - f) + b * f
end

function math.clamp(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	end

	return value
end

function math.dist(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function math.lerp(a, b, x)
	return a + (b - a) * x
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