Rect = {}
Rect.__index = Rect

function Rect.create(x, y, width, height)
    local self = {}
    setmetatable(self, Rect)

    self.left, self.top = x, y
    self.right, self.bottom = x + width, y + height
    self.width, self.height = width, height

    return self
end

function Rect:intersect(other)
    if self.right < other.left or self.left > other.right or
        self.bottom < other.top or self.top > other.bottom then
        return false
    end

    return true
end

function Rect:contains(x, y)
    return x >= self.left and x <= self.right and y >= self.top and y <= self.bottom
end