require "vec2"

utils = {}

function utils.cerp(a, b, x)
    -- Returns the cosine interpolated value between a and b.
    local f = (1 - math.cos(x * math.pi)) * 0.5
    return a * (1 - f) + b * f
end

function utils.clamp(value, min, max)
    -- Returns the value clamped between min and max.
    if value < min then
        return min
    elseif value > max then
        return max
    end

    return value
end

function utils.lerp(a, b, x)
    -- Returns the linear interpolated value between a and b.
    return a + (b - a) * x
end

function utils.collideRectCircle(rect, pos, radius)
    local closestX = utils.clamp(pos.x, rect.left, rect.right)
    local closestY = utils.clamp(pos.y, rect.top, rect.bottom)

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

function utils.smoothenHeightMap(data, passes)
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

function utils.arrayToImage(array, name)
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