require "vec2"

utils = {}

function utils.normalize(value, min, max)
    return (value - min) / (max - min)
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

function utils.cerp(a, b, x)
    -- Returns the cosine interpolated value between a and b.
    local f = (1 - math.cos(x * math.pi)) * 0.5
    return a * (1 - f) + b * f
end

function utils.smoothstep(x)
    return x * x * (3 - 2 * x)
end

function utils.smootherstep(x)
    return x * x * x * (x * (x * 6 - 15) + 10)
end

function utils.collideRectCircle(rect, circle)
    local closestX = utils.clamp(circle.x, rect.left, rect.right)
    local closestY = utils.clamp(circle.y, rect.top, rect.bottom)

    local distX = circle.x - closestX
    local distY = circle.y - closestY
    local distLength = math.sqrt(distX ^ 2 + distY ^ 2)

    if distLength < circle.radius and distLength ~= 0 then
        local resolveX = (distX / distLength) * (circle.radius - distLength)
        local resolveY = (distY / distLength) * (circle.radius - distLength)

        return true, resolveX, resolveY
    else
        return false, 0, 0
    end
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

function utils.debugPrint(r, g, b, a, text, x, y)
    if debug then
        love.graphics.setColor(r, g, b, a)
        love.graphics.print(text, x, y)
    end
end

function utils.debugDrawLine(r, g, b, a, x1, y1, x2, y2)
    if debug then
        love.graphics.setColor(r, g, b, a)
        love.graphics.setLine(1, "rough")
        love.graphics.line(x1, y1, x2, y2)
    end
end

function utils.debugDrawCircle(r, g, b, a, circle)
    if debug then
        love.graphics.setColor(r, g, b, a)
        love.graphics.setLine(1, "rough")
        love.graphics.circle("line", circle.x, circle.y, circle.radius)
    end
end