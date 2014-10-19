require "class"
require "game"
require "variables"

function love.load()
    debug = false
    gamestate = "game"

    love.graphics.setDefaultFilter("nearest", "nearest")

    images = {}
    local files = love.filesystem.getDirectoryItems("images")
    for k, file in pairs(files) do
        local name, extension = string.match(file, "(.+)%.(.+)")
        if extension == "png" then
            images[name] = love.graphics.newImage("images/" .. file)
        end
    end

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