SpatialHash = {}
SpatialHash.__index = SpatialHash

function SpatialHash.create(cellSize)
    local self = {}
    setmetatable(self, SpatialHash)

    self.cells = {}
    self.cellSize = cellSize

    return self
end

function SpatialHash:clear()
    for k1, v1 in pairs(self.cells) do
        for k2, v2 in pairs(v1) do
            for k, v in pairs(v2) do
                if v.collidable and not v.static then
                    table.remove(self.cells, k)
                end
            end
        end
    end
end

function SpatialHash:insert(entity)
    local circle = entity:getCollisionCircle()

    table.insert(self:getCellAt(circle.x, circle.y), entity)
end

function SpatialHash:getNearby(entity)
    local circle = entity:getCollisionCircle()

    return self:getCellAt(circle.x, circle.y)
end

function SpatialHash:cellCoords(x, y)
    return math.floor(x / self.cellSize), math.floor(y / self.cellSize)
end

function SpatialHash:getCell(i, j)
    if self.cells[i] == nil then 
        self.cells[i] = {}
    end

    if self.cells[i][j] == nil then
        self.cells[i][j] = {}
    end

    return self.cells[i][j]
end

function SpatialHash:getCellAt(x, y)
    return self:getCell(self:cellCoords(x, y))
end