Rect = class()

function Rect:init(left, top, width, height)
    self.left = left
    self.top = top
    self.right = left + width
    self.bottom = top + height
    self.width = width
    self.height = height
end

function Rect:set(left, top)
    if not top then
        top = left.x
        left = left.y
    end

    self.left = left or self.left
    self.top = top or self.top
end

function Rect:intersects(other)
    if self.right < other.left or self.left > other.right or
        self.bottom < other.top or self.top > other.bottom then
        return false
    end

    return true
end

function Rect:contains(x, y)
    if not y then
        y = x.y
        x = x.x
    end

    return x >= self.left and x <= self.right and y >= self.top and y <= self.bottom
end

function Rect:getValues()
    return self.left, self.top, self.width, self.height
end

function Rect.__tostring(a)
    return "Rect(" .. a.left .. "," .. a.right .. "," .. a.width .. "," .. a.height .. ")"
end

Circle = class()

function Circle:init(x, y, radius)
    self.x, self.y = x, y
    self.radius = radius
end

function Circle:set(x, y)
    if not y then
        y = x.y
        x = x.x
    end
    
    self.x = x or self.x
    self.y = y or self.y
end

function Circle:intersect(other)

end

function Circle.__tostring(a)
    return "Circle(" .. a.x .. "," .. a.y .. "," .. a.radius .. ")"
end