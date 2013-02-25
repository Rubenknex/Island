require "shapes"

GUI = {}
GUI.mouseDown = false

function GUI.button(type, rect, text)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", rect:getValues())
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(text, rect.left, rect.top, rect.width, "center")

    if rect:contains(love.mouse.getX(), love.mouse.getY()) then
        if type == "click" then
            if love.mouse.isDown("l") then
                GUI.mouseDown = true
            elseif GUI.mouseDown then
                GUI.mouseDown = false

                return true
            end
        elseif type == "hover" then
            return true
        end
    end

    return false
end