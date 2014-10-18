require "class"
require "game"
require "variables"

function love.load()
    debug = false
    gamestate = "game"

    love.graphics.setDefaultFilter("nearest", "nearest")

    game = Game()
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