SpatialHash = class()

function SpatialHash:init(cellSize)
    self.cells = {}
    self.cellSize = cellSize
end

function SpatialHash:clear()
    for k1, cell in pairs(self.cells) do
        for k2, e in pairs(cell) do
            cell[k2] = nil
        end
    end
end

function SpatialHash:insert(entity)
    local circle = entity:getCollisionCircle()

    table.insert(self:getCell(circle.x, circle.y), entity)
end

function SpatialHash:getNearby(entity)
    local circle = entity:getCollisionCircle()

    return self:getCell(circle.x, circle.y)
end

function SpatialHash:getKey(x, y)
    return math.floor(x / self.cellSize) + math.floor(y / self.cellSize) * self.cellSize
end

function SpatialHash:getCell(x, y)
    local key = self:getKey(x, y)

    if self.cells[key] == nil then 
        self.cells[key] = {}
    end

    return self.cells[key]
end

function SpatialHash.__tostring(a)
    local cellAmount = 0
    local dynamic = 0
    local static = 0

    for k1, cell in pairs(a.cells) do
        cellAmount = cellAmount + 1

        for k2, entity in pairs(cell) do
            if entity.static then 
                static = static + 1 
            else
                dynamic = dynamic + 1
            end
        end
    end

    return string.format("SpatialHash: %d cells, %d static, %d dynamic", cellAmount, static, dynamic)
end