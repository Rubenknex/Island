Vec2 = class()

function Vec2:init(x, y)
    self.x, self.y = x or 0, y or 0
end

function Vec2:set(x, y)
    self.x, self.y = x, y
end

function Vec2:length()
    return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function Vec2:lengthSquared()
    return self.x ^ 2 + self.y ^ 2
end

function Vec2:normalized()
    local length = self:length()

    return Vec2(self.x / length, self.y / length)
end

function Vec2:distance(other)
    local difference = self - other

    return difference:length()
end

function Vec2.__add(a, b)
    return Vec2(a.x + b.x, a.y + b.y)
end

function Vec2.__sub(a, b)
    return Vec2(a.x - b.x, a.y - b.y)
end

function Vec2.__mul(a, b)
    if type(a) == "number" then
        return Vec2(b.x * a, b.y * a)
    elseif type(b) == "number" then
        return Vec2(a.x * b, a.y * b)
    else
        return Vec2(a.x * b.x, a.y * b.y)
    end
end

function Vec2.__div(a, b)
    if type(a) == "number" then
        return Vec2(b.x / a, b.y / a)
    elseif type(b) == "number" then
        return Vec2(a.x / b, a.y / b)
    else
        return Vec2(a.x / b.x, a.y / b.y)
    end
end

function Vec2.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vec2.__tostring(a)
    return "Vec2(" .. a.x .. ", " .. a.y .. ")"
end