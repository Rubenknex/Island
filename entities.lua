require "map"

Crab = {}
Crab.__index = Crab

function Crab.create(x, y)
	self = {}
	setmetatable(self, Crab)

	self.pos = Vec2.create(x, y)

	self.circleOffset = Vec2.create(0, 0)
    self.circleRadius = 6

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

	self.image = love.graphics.newImage("data/crab.png")
    self.qDown = love.graphics.newQuad(0, 0, 16, 16, self.image:getWidth(), self.image:getHeight())
    self.qUp = love.graphics.newQuad(16, 0, 16, 16, self.image:getWidth(), self.image:getHeight())
    self.qLeft = love.graphics.newQuad(32, 0, 16, 16, self.image:getWidth(), self.image:getHeight())
    self.qRight = love.graphics.newQuad(48, 0, 16, 16, self.image:getWidth(), self.image:getHeight())
    self.currentQuad = self.qDown

    self.scale = 2

	return self
end

function Crab:handleCollision(dt)
    local circlePos = self.pos + self.circleOffset
    local left, top = circlePos.x - self.circleRadius, circlePos.y - self.circleRadius
    local right, bottom = circlePos.x + self.circleRadius, circlePos.y + self.circleRadius
    local tSize = Map.DRAW_SIZE
    local tLeft, tTop = math.floor(left / tSize), math.floor(top / tSize)
    local tRight, tBottom = math.floor(right / tSize), math.floor(bottom / tSize)
    
    local result, normal, length = false, 0, 0
    if not map:walkableAt(left, top) then
        result, normal, length = utils.collideRectCircle(Rect.create(tLeft * tSize, tTop * tSize, tSize, tSize), circlePos, self.circleRadius)
        if result then
        	self.collided = true
            self.pos = self.pos + normal * length
        end
    end

    if not map:walkableAt(right, top) then
        result, normal, length = utils.collideRectCircle(Rect.create(tRight * tSize, tTop * tSize, tSize, tSize), circlePos, self.circleRadius)
        if result then
        	self.collided = true
            self.pos = self.pos + normal * length
        end
    end

    if not map:walkableAt(right, bottom) then
        result, normal, length = utils.collideRectCircle(Rect.create(tRight * tSize, tBottom * tSize, tSize, tSize), circlePos, self.circleRadius)
        if result then
        	self.collided = true
            self.pos = self.pos + normal * length
        end
    end

    if not map:walkableAt(left, bottom) then
        result, normal, length = utils.collideRectCircle(Rect.create(tLeft * tSize, tBottom * tSize, tSize, tSize), circlePos, self.circleRadius)
        if result then
        	self.collided = true
            self.pos = self.pos + normal * length
        end
    end
end

function Crab:chooseTarget()
    local degrees = math.random(0, 359)
	local angle = math.rad(degrees)

    -- Set the correct quad facing the target
    if degrees >= 315 or degrees <= 45 then self.currentQuad = self.qRight
    elseif degrees >= 45 and degrees <= 135 then self.currentQuad = self.qDown
    elseif degrees >= 135 and degrees <= 225 then self.currentQuad = self.qLeft
    elseif degrees >= 225 and degrees <= 315 then self.currentQuad = self.qUp end

	self.direction = Vec2.create(math.cos(angle), math.sin(angle))
	local distance = math.random(self.minRange, self.maxRange)
	self.target = self.pos + self.direction * distance
	self.walkTime = distance / self.speed
end

function Crab:update(dt)
	if self.walking then
		local movement = self.direction * self.speed * dt

		if self.walkTime <= 0.0 or self.collided or map:tileTypeAt(self.pos.x, self.pos.y) ~= Map.SAND then
			self.pos = self.pos - movement
			self.walking = false
			self.collided = false
			self.idleTime = 1.0 + math.random() * 2.0
		else
			self.pos = self.pos + movement
			self.walkTime = self.walkTime - dt
		end
	else
		self.idleTime = self.idleTime - dt

		if self.idleTime <= 0.0 then
			self.walking = true
			self:chooseTarget()
		end
	end

	self:handleCollision()
end

function Crab:draw()
	love.graphics.setColor(255, 255, 255, 255)

    love.graphics.drawq(self.image, self.currentQuad, self.pos.x - camera.x, self.pos.y - camera.y, 0, self.scale, self.scale, 8, 8)

    --love.graphics.setColor(255, 0, 0)
    --love.graphics.circle("line", self.pos.x + self.circleOffset.x - camera.x, self.pos.y + self.circleOffset.y - camera.y, self.circleRadius)
end