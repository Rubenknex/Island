--[[
Background story:
You have become stranded on an island in the middle of the ocean, 
]]

require "game"

function love.load()
	debug = true
    gamestate = "game"

    love.graphics.setDefaultImageFilter("nearest", "nearest")

    game = Game.create()
end

function love.keypressed(key, unicode)
	if key == '`' then
		debug = not debug
	end
end

function love.update(dt)
    if gamestate == "game" then
        game:update(dt)
    end
end

function love.draw()
    if gamestate == "game" then
        game:draw()
    end
end