Inventory = class()

function Inventory:init()
    self.items = {}
    self:addItem({name="Sword", amount=1})
    self:addItem({name="Wood", amount=123})
    self:addItem({name="Flint", amount=1})
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
    local item = self.items[newItem.name]

    if item == nil then
        self.items[newItem.name] = newItem
    else
        item.amount = item.amount + 1
    end
end

function Inventory:removeItem(name, amount)
    local item = self.items[name]

    if item ~= nil then
        if item.amount - amount >= 1 then
            self.items[name] = nil
        else
            item.amount = item.amount - amount
        end
    end
end

function Inventory:hasItem(name)
    return self.items[name] ~= nil
end