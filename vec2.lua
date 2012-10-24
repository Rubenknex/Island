Vec2 = {}
Vec2.__index = Vec2

function Vec2.create(x, y)
    local self = {}
    setmetatable(self, Vec2)

    self.x, self.y = x or 0, y or 0

    return self
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

    return Vec2.create(self.x / length, self.y / length)
end

function Vec2:distance(other)
    local difference = self - other

    return difference.length()
end

function Vec2.__add(a, b)
    return Vec2.create(a.x + b.x, a.y + b.y)
end

function Vec2.__sub(a, b)
    return Vec2.create(a.x - b.x, a.y - b.y)
end

function Vec2.__mul(a, b)
    if type(a) == "number" then
        return Vec2.create(b.x * a, b.y * a)
    elseif type(b) == "number" then
        return Vec2.create(a.x * b, a.y * b)
    else
        return Vec2(a.x * b.x, a.y * b.y)
    end
end

function Vec2.__div(a, b)
    if type(a) == "number" then
        return Vec2.create(b.x / a, b.y / a)
    elseif type(b) == "number" then
        return Vec2.create(a.x / b, a.y / b)
    else
        return Vec2(a.x / b.x, a.y / b.y)
    end
end

function Vec2.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vec2.__tostring(a)
    return "(" .. a.x .. ", " .. a.y .. ")"
end