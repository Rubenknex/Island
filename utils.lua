require "vec2"

utils = {}

function utils.gaussian(x, y, sigma)
    return math.exp(-(x * x + y * y) / (2 * sigma * sigma)) / (sigma * math.sqrt(2 * math.pi))
end

function utils.random(min, max)
    return math.random() * (max - min)
end

function utils.normalize(value, min, max)
    return (value - min) / (max - min)
end

function utils.clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    end

    return value
end

function utils.lerp(a, b, x)
    return a + (b - a) * x
end

function utils.cerp(a, b, x)
    local f = (1 - math.cos(x * math.pi)) * 0.5
    return a * (1 - f) + b * f
end

function utils.rectContains(rect, x, y)
    if not y then
        y = x.y
        x = x.x
    end

    return x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h
end

function utils.rectIntersects(a, b)
    if a.x + a.w < b.x or a.x > b.x + b.w or
        a.y + a.h < b.y or a.y > b.y + b.h then
        return false
    end

    return true
end

function utils.collideRectCircle(rect, circle)
    local closest = Vec2(utils.clamp(circle.x, rect.left, rect.right), 
                         utils.clamp(circle.y, rect.top, rect.bottom))

    local distanceVec = Vec2(circle.x, circle.y) - closest
    local distance = distanceVec:length()

    if distance < circle.radius and distance ~= 0 then
        local resolve = distanceVec:normalized() * (circle.radius - distance)

        return true, resolve
    else
        return false
    end
end

function utils.collideCircleCircle(a, b)
    local difference = Vec2(b.x - a.x, b.y - a.y)
    local totalRadius = a.radius + b.radius

    if difference:lengthSquared() < totalRadius ^ 2 then
        local overlap = totalRadius - difference:length()
        local resolve = difference:normalized() * overlap

        return true, resolve
    else
        return false
    end
end

function utils.noiseMap(width, height, frequency, amplitude, persistence, octaves, seed)
    local offsetX = love.math.random() * 20000
    local offsetY = love.math.random() * 20000

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
                total = total + love.math.noise(offsetX + (x * period) * frequency, offsetY + (y * period) * frequency) * amplitude

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

function utils.debugPrint(text, x, y)
    if debug then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(text, x + 1, y + 1)

        love.graphics.setColor(255, 255, 255)
        love.graphics.print(text, x, y)
    end
end

function utils.debugDrawLine(r, g, b, a, x1, y1, x2, y2)
    if debug then
        love.graphics.setColor(r, g, b, a)
        love.graphics.setLineWidth(1)
        love.graphics.setLineStyle("rough")
        love.graphics.line(x1, y1, x2, y2)
    end
end

function utils.debugDrawCircle(r, g, b, a, circle)
    if debug then
        love.graphics.setColor(r, g, b, a)
        love.graphics.setLineWidth(1)
        love.graphics.setLineStyle("rough")
        love.graphics.circle("line", circle.x, circle.y, circle.radius)
    end
end