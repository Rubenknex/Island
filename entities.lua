require "animation"
require "map"

Crab = {}
Crab.__index = Crab

function Crab.create(x, y)
	self = {}
	setmetatable(self, Crab)

    self.type = "crab"
	self.position = Vec2.create(x, y)
    self.collidable = true

    self.boundingCircle = Circle.create(x, y, 6)

	self.speed = 50
	self.direction = Vec2.create()
    self.degrees = 0
	self.target = Vec2.create()
	self.minRange = 20
	self.maxRange = 40
	self.collided = false
	self.walking = false
	self.walkTime = 0.0
	self.idleTime = 0.0

    self.animation = Animation.create(love.graphics.newImage("data/crab.png"))
    self.animation:addSequence("down", 0, 0, 16, 16, 2)
    self.animation:addSequence("up", 0, 16, 16, 16, 2)
    self.animation:addSequence("left", 0, 32, 16, 16, 2)
    self.animation:addSequence("right", 0, 48, 16, 16, 2)

	return self
end

function Crab:update(dt)
	if self.walking then
		local movement = self.direction * self.speed * dt

		if self.walkTime <= 0.0 or self.collided or map:tileTypeAt(self.position.x, self.position.y) ~= Map.SAND then
			self.position = self.position - movement
			self.walking = false
			self.collided = false
			self.idleTime = 1.0 + math.random() * 2.0

            self.animation:pauseSequence(1)
		else
			self.position = self.position + movement
			self.walkTime = self.walkTime - dt
		end
	else
		self.idleTime = self.idleTime - dt

		if self.idleTime <= 0.0 then
			self.walking = true
			self:chooseTarget()
		end
	end

    self.animation:update(dt)
end

function Crab:draw()
	love.graphics.setColor(255, 255, 255, 255)

    love.graphics.drawq(self.animation.image, self.animation:getCurrentQuad(), self.position.x, self.position.y, 0, 2, 2, 8, 8)

    utils.debugDrawCircle(255, 0, 0, 255, self:getBoundingCircle())
end

function Crab:chooseTarget()
    local degrees = math.random(0, 359)
	local angle = math.rad(degrees)

    -- Set the correct quad facing the target
    if degrees >= 315 or degrees <= 45 then self.animation:playSequence("up", "loop", 0.2)
    elseif degrees >= 45 and degrees <= 135 then self.animation:playSequence("right", "loop", 0.2)
    elseif degrees >= 135 and degrees <= 225 then self.animation:playSequence("down", "loop", 0.2)
    elseif degrees >= 225 and degrees <= 315 then self.animation:playSequence("left", "loop", 0.2) end

	self.direction = Vec2.create(math.cos(angle), math.sin(angle))
	local distance = math.random(self.minRange, self.maxRange)
	self.target = self.position + self.direction * distance
	self.walkTime = distance / self.speed
end

function Crab:getBoundingCircle()
    self.boundingCircle.x = self.position.x
    self.boundingCircle.y = self.position.y

    return self.boundingCircle
end