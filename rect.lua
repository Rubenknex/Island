Rect = {}
Rect.__index = Rect

function Rect.create(x, y, width, height)
    local self = {}
    setmetatable(self, Rect)

    self.x, self.y = x, y
    self.max_x, self.max_y = x + width, y + height
    self.width, self.height = width, height

    return self
end

function Rect:intersect(other)
    if self.max_x < other.min_x or self.min_x > other.max_x or
        self.max_y < other.min_y or self.min_y > other.max_y then
        return false
    end

    return true
end

function Rect:contains(x, y)
    return x >= self.x and x <= self.max_x and y >= self.y and y <= self.max_y
end