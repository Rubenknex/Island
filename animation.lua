Animation = {}
Animation.__index = Animation

--[[
Usage:
    Animation.addSequence("walk", 0, 0, 16, 16, 5) Add a sequence of 5 frames
    Animation.playSequence("walk", "single", 0.5)
]]--

function Animation.create(image)
    local self = {}
    setmetatable(self, Animation)

    self.image = image
    self.sequences = {}
    self.currentSequence = nil
    self.currentFrame = 0

    -- nil: No animation is being played and no frame will be shown
    -- 'paused': Show a single frame
    -- 'once': Complete the animation one time
    -- 'loop': Loop the animation until stopped
    self.mode = nil
    self.interval = 0
    self.timer = 0

    return self
end

function Animation:addSequence(name, x, y, frameWidth, frameHeight, length)
    local sequence = {}

    for i=1, length do
        sequence[i] = love.graphics.newQuad(x + frameWidth * (i - 1), 
                                            y, 
                                            frameWidth, frameHeight, 
                                            self.image:getWidth(), self.image:getHeight())
    end

    self.sequences[name] = sequence
end

function Animation:playSequence(name, mode, interval)
    if self.sequences[name] == nil then
        do return end
    end

    self.currentSequence = name
    self.currentFrame = 1
    self.mode = mode
    self.interval = interval
    self.timer = 0
end

function Animation:pauseSequence(frame)
    if self.mode ~= nil then
        self.mode = "paused"
        self.currentFrame = frame
    end
end

function Animation:stopSequence()
    self.mode = nil
end

function Animation:getCurrentQuad()
    if self.mode ~= nil then
        return self.sequences[self.currentSequence][self.currentFrame]
    end

    return nil
end

function Animation:update(dt)
    if self.mode ~= nil then
        if self.mode == "paused" then

        elseif self.mode == "once" then
            self.timer = self.timer + dt

            if self.timer > self.interval then
                self.timer = 0
                self.currentFrame = self.currentFrame + 1

                if self.currentFrame > #self.sequences[self.currentSequence] then
                    self.mode = nil
                end
            end
        elseif self.mode == "loop" then
            self.timer = self.timer + dt

            if self.timer > self.interval then
                self.timer = 0
                self.currentFrame = self.currentFrame + 1

                if self.currentFrame > #self.sequences[self.currentSequence] then
                    self.currentFrame = 1
                end
            end
        end
    end
end