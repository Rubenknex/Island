require "camera"
require "map"
require "player"
require "functions"

--[[
IDEAS:
- 	A crafting/construction system similar to that of Minecraft. You don't
	have to place the items in a specific order, just place them there. The idea
	is that a lot of the combinations are possible so the player can keep trying
	new things.

-	A final objective of the game could be to keep constructing items until you
	have enough to make an attempted escape to search for a boat.
	An example of the final items would be: A wooden raft.

-	Different activities to do on the island:
	- 	Gathering raw materials such as wood, food and rock.
	- 	Fishing, hunting animals, picking fruit.

]]

function load_game()
	map = Map.create()
	camera = Camera.create(0, 0, 640, 480)
	player = Player.create(320, 240)
end

function update_game(dt)
	player:update(dt)

	local screenPos = Vec2.create(player.pos.x - camera.width / 2, player.pos.y - camera.height / 2)
	camera:interpolate(screenPos, 0.1)
end

function draw_game()
	map:draw()
	player:draw()

	love.graphics.setColor(255, 255, 255)
	love.graphics.print("FPS: " .. love.timer.getFPS(), 0, 0)
end