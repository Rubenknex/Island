Inventory = class()

function Inventory:init()
    self.items = {}
end

function Inventory:draw(x, y)
    love.graphics.setColor(200, 161, 123)
    love.graphics.rectangle("fill", x, y, 150, 250)

    local i = 0
    love.graphics.setColor(255, 255, 255)
    for k, v in pairs(self.items) do
        love.graphics.print(v.name, x + 5, y + i * 15 + 5)
        love.graphics.printf(v.amount, x + 5, y + i * 15 + 5, 140, "right")
        i = i + 1
    end
end

function Inventory:addItem(newItem)
    for k, v in pairs(self.items) do
        if v.name == newItem.name then
            v.amount = v.amount + newItem.amount

            return
        end
    end

    table.insert(self.items, newItem)
end

function Inventory:removeItem(name, amount)
    for k, v in pairs(self.items) do
        if v.name == name then
            if v.amount - amount <= 0 then
                self.items[k] = nil
            else
                v.amount = v.amount - amount
            end
        end
    end
end

function Inventory:hasItem(name)
    for k, v in pairs(self.items) do
        if v.name == name then return true end
    end

    return false
end