require "color"
require "shapes"

--[[
GUI elements:

- Label
- Button
- TextBox
]]--

Button = {}
Button.__index = Button

function Button.create(x, y, width, height)
    local self = {}
    setmetatable(self, Button)

    self.rect = Rect.create(x, y, width, height)
    self.color = nil
    self.text = nil
    self.image = nil

    self.onHover = nil
    self.onClick = nil

    return self
end

function Button:update(dt)
    if self.onHover ~= nil and self.rect:contains(love.mouse.getX(), love.mouse.getY()) then
        self.onHover()
    end
end

function Button:draw()
    if self.color ~= nil then
        love.graphics.setColor(self.color:toRGB())
        love.graphics.rectangle("fill", self.rect.left, self.rect.top, self.rect.width, self.rect.height)
    end

    if self.text ~= nil then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self.text, self.rect.left, self.rect.top)
    end
end