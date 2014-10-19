GUI = {}
GUI.mouseDown = false

function GUI.button(type, rect, text)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(text, rect.x, rect.y, rect.w, "center")

    if utils.rectContains(rect, love.mouse.getX(), love.mouse.getY()) then
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