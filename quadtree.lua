require "shapes"

QuadTree = class()

function QuadTree:init(bounds, level)
    self.bounds = bounds
    self.level = level or 0
    self.nodes = nil
    self.objects = {}
    self.count = 0
end

function QuadTree:clear(func)
    for k, v in pairs(self.objects) do
        self.objects[k] = nil
    end

    if self.nodes ~= nil then
        for k, v in pairs(self.nodes) do
            v:clear(func)
            self.nodes[k] = nil
        end

        self.nodes = nil
    end
end

function QuadTree:split()
    local x = self.bounds.left
    local y = self.bounds.top
    local halfWidth = self.bounds.width / 2
    local halfHeight = self.bounds.height / 2

    self.nodes = {
        QuadTree(Rect(x,             y,              halfWidth, halfHeight), self.level + 1),
        QuadTree(Rect(x + halfWidth, y,              halfWidth, halfHeight), self.level + 1),
        QuadTree(Rect(x,             y + halfHeight, halfWidth, halfHeight), self.level + 1),
        QuadTree(Rect(x + halfWidth, y + halfHeight, halfWidth, halfHeight), self.level + 1)
    }
end

function QuadTree:getIndex(rect)
    local xMidpoint = self.bounds.left + self.bounds.width / 2
    local yMidpoint = self.bounds.top + self.bounds.height / 2

    local index = 0
    local left = rect.right < xMidpoint
    local right = rect.left > xMidpoint

    if rect.bottom < yMidpoint then
        if left then 
            index = 1 
        elseif right then
            index = 2 
        end
    elseif rect.top > yMidpoint then
        if left then 
            index = 3 
        elseif right then
            index = 4 
        end
    end

    return index
end

function QuadTree:insert(object, func)
    local rect = func(object)

    if self.nodes == nil then
        table.insert(self.objects, object)
        self.count = self.count + 1

        if self.count >= 5 then
            self:split()

            for k, v in pairs(self.objects) do
                local index = self:getIndex(func(v))

                if index ~= 0 then
                    self.nodes[index]:insert(v, func)
                    self.objects[k] = nil
                    self.count = self.count - 1
                end
            end
        end
    else
        local index = self:getIndex(rect)

        if index ~= 0 then
            self.nodes[index]:insert(object, func)
        else
            table.insert(self.objects, object)
        end
    end
end

function QuadTree:retrieve(rect, nearby)
    if nearby == nil then nearby = {} end

    local index = self:getIndex(rect)

    if index ~= 0 and self.nodes ~= nil then
        self.nodes[index]:retrieve(rect, nearby)
    end

    for k, v in pairs(self.objects) do
        table.insert(nearby, v)
    end

    return nearby
end

function QuadTree:draw()
    if debug then 
        love.graphics.setColor(0, 0, 255)
        love.graphics.rectangle("line", self.bounds:getValues())

        if self.nodes ~= nil then
            for k, v in pairs(self.nodes) do
                v:draw()
            end
        end
    end
end