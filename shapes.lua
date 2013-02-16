Rect = class()

function Rect:init(left, top, width, height)
    self.left, self.top = left, top
    self.right, self.bottom = left + width, top + height
    self.width, self.height = width, height
end

function Rect:intersects(other)
    if self.right < other.left or self.left > other.right or
        self.bottom < other.top or self.top > other.bottom then
        return false
    end

    return true
end

function Rect:contains(x, y)
    return x >= self.left and x <= self.right and y >= self.top and y <= self.bottom
end

function Rect.__tostring(a)
    return "Rect(" .. a.left .. "," .. a.right .. "," .. a.width .. "," .. a.height .. ")"
end

Circle = class()

function Circle:init(x, y, radius)
    self.x, self.y = x, y
    self.radius = radius
end

function Circle:intersect(other)

end

function Circle.__tostring(a)
    return "Circle(" .. a.x .. "," .. a.y .. "," .. a.radius .. ")"
end