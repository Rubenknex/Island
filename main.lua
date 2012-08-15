--[[
Background story:
You have become stranded on an island in the middle of the ocean, 
]]

require "game"

function love.load()
	gamestate = "game"

	love.graphics.setDefaultImageFilter("nearest", "nearest")

	load_game()
end

function love.update(dt)
	if gamestate == "game" then
		update_game(dt)
	end
end

function love.draw()
	if gamestate == "game" then
		draw_game()
	end
end