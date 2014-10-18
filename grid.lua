Grid = class()

function Grid:init(worldWidth, worldHeight, nodeSize)
	self.nodeSize = nodeSize
	self.nodes = {}
    for x=1, worldWidth / nodeSize do
        table.insert(self.nodes, {})
        for y=1, worldHeight / nodeSize do
            table.insert(self.nodes[x], {})
        end
    end
end

function Grid:clear()
	for k, row in pairs(self.nodes) do
		for k2, node in pairs(row) do
			for k3, entity in pairs(node) do
				node[k3] = nil
			end
		end
	end
end

function Grid:getIndices(entity)
	local rect = entity:getRect()

	local x1 = math.floor(rect.x / self.nodeSize)
	local y1 = math.floor(rect.y / self.nodeSize)
	local x2 = math.floor((rect.x + rect.w) / self.nodeSize)
	local y2 = math.floor((rect.y + rect.h) / self.nodeSize)


	return x1, y1, x2, y2
end

function Grid:insert(entity)
	local x1, y1, x2, y2 = self:getIndices(entity)

	table.insert(self.nodes[x1][y1], entity)
	if x2 ~= x1 then table.insert(self.nodes[x2][y1], entity) end
	if y2 ~= y1 then table.insert(self.nodes[x1][y2], entity) end
	if x2 ~= x1 and y2 ~= y1 then table.insert(self.nodes[x2][y2], entity) end
end

function Grid:getNearby(entity)
	local nearby = {}

	x1, y1, x2, y2 = self:getIndices(entity)

	for k, v in pairs(self.nodes[x1][y1]) do table.insert(nearby, v) end
	if x2 ~= x1 then
		for k, v in pairs(self.nodes[x2][y1]) do table.insert(nearby, v) end
	end
	if y2 ~= y1 then
		for k, v in pairs(self.nodes[x1][y2]) do table.insert(nearby, v) end
	end
	if x2 ~= x1 then
		for k, v in pairs(self.nodes[x2][y2]) do table.insert(nearby, v) end
	end

	return nearby
end

function Grid:draw()
	if debug then
		love.graphics.setColor(0, 0, 255)

		for k, v in pairs(self.nodes) do
			for k2, v2 in pairs(v) do
				love.graphics.rectangle("fill", k * 32, k2 * 32, self.nodeSize, self.nodeSize)
			end
		end
	end
end

function Grid:status()
	for k, v in pairs(self.nodes) do
		for k2, v2 in pairs(v) do
			io.write(#v2)
		end
		io.write("\n")
	end
	io.write("\n")
end