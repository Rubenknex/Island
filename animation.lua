Animation = class()

function Animation:init(image)
    self.image = image
    self.sequences = {}
    self.currentSequence = nil
    self.currentFrame = 0
    self.mode = nil
    self.interval = 0
    self.timer = 0
end

function Animation:update(dt)
    if self.mode == "once" or self.mode == "loop" then
        self.timer = self.timer + dt

        if self.timer > self.interval then
            self.timer = 0
            self.currentFrame = self.currentFrame + 1

            if self.currentFrame > #self.sequences[self.currentSequence] then
                if self.mode == "once" then self.mode = nil end
                if self.mode == "loop" then self.currentFrame = 1 end
            end
        end
    end
end

function Animation:add(name, x, y, frameWidth, frameHeight, length)
    local sequence = {}

    for i=1, length do
        sequence[i] = love.graphics.newQuad(x + frameWidth * (i - 1), y, frameWidth, frameHeight, self.image:getWidth(), self.image:getHeight())
    end

    self.sequences[name] = sequence
end

function Animation:play(name, mode, interval)
    if self.sequences[name] == nil then
        do return end
    end

    self.currentSequence = name
    self.currentFrame = 1
    self.mode = mode
    self.interval = interval
    self.timer = 0
end

function Animation:pause(frame)
    if self.mode ~= nil then
        self.mode = "paused"
        self.currentFrame = frame
    end
end

function Animation:stop()
    self.mode = nil
end

function Animation:getCurrentQuad()
    if self.mode ~= nil then
        return self.sequences[self.currentSequence][self.currentFrame]
    end

    return nil
end