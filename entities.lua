require "animation"
require "world"

--[[
Types of entities:
-   Simple static objects:
    These are objects like stones, shells, coconuts, sticks etc.
    They do not perform any action by themselves, but can be interacted
    with by the player.

-   Static objects:
    These are a bit more complex than simple static objects, in the sense
    that they have unique logic. Like a palm tree of which the coconuts
    can be taken, and can grow new coconuts. Or can be cut down and gradually
    dissapear.

-   Dynamic entities:
    These are the various entities that live on the island, like crabs,
    seagulls, snakes etc. They perform various actions and 
]]--

--[[
Object properties:
- origin_x, origin_y:   set the center of the object                (0, 0)
- limit_min, limit_max: object can only occur in this range         (0, 1)
- density:              occurrance                                  (1)
- static:               is the object non-moving?                   (true)
- collidable:           can the object be collided with?            (false)
- radius:               radius of the collision circle              (0)
- rotation:             can the object be randomly rotated?         (false)
- can_flip:             can the object be flipped in the x-axis?    (false)
- flat:                 is the object flat on the ground?           (true)
]]--

Entity = class()

function Entity:init(type, x, y, origin, static, collidable, radius, rotation)
    self.type = type
    self.image = images[type]
    self.position = Vec2(x, y)
    self.origin = origin or Vec2(0, 0)
    self.static = static
    self.collidable = collidable or false
    self.radius = radius or 0
    self.rotation = rotation or 0
    self.scale = Vec2(2, 2)
end

function Entity:getCircle()
    return {x = self.position.x, 
            y = self.position.y, 
            radius = self.radius}
end

function Entity:getRect()
    local scaleX, scaleY = math.abs(self.scale.x), math.abs(self.scale.y)
    return {x = self.position.x - self.origin.x  * scaleX, 
            y = self.position.y - self.origin.y * scaleY, 
            w = self.image:getWidth() * scaleX, 
            h = self.image:getHeight() * scaleY}
end

Object = class(Entity)

function Object:init(type, x ,y)
    local data = objectTypes[type]
    Entity.init(self, type, x, y, data.origin, true, data.collidable, data.radius)

    self.limit_min, self.limit_max = 0, 1
    self.density = data.density or 1
    self.can_flip = data.can_flip or false
    self.flat = true
    if data.flat ~= nil then self.flat = data.flat end

    if data.rotation ~= nil then self.rotation = math.random() * 2 * math.pi end

    if data.can_flip and math.random(0, 1) == 0 then self.scale.x = self.scale.x * -1 end
end

function Object:draw()
    love.graphics.setColor(255, 255, 255, 255)
    local scale = 2
    love.graphics.draw(self.image, self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y, self.origin.x, self.origin.y)

    utils.debugDrawCircle(0, 255, 0, 255, self:getCircle())
end

Crab = class(Entity)

function Crab:init(x, y)
    Entity.init(self, "crab", x, y, Vec2(8, 8), false, true, 7)

    self.collided = false

    self.direction = Vec2()
    self.degrees = 0
    self.target = Vec2()
    self.walking = false
    self.walkTime = 0.0
    self.idleTime = 0.0

    self.image = images["crab"]
    self.animation = Animation(self.image)
    self.animation:add("down", 0, 0, 16, 16, 2)
    self.animation:add("up", 0, 16, 16, 16, 2)
    self.animation:add("left", 0, 32, 16, 16, 2)
    self.animation:add("right", 0, 48, 16, 16, 2)
end

function Crab:update(dt)
    if self.walking then
        local movement = self.direction * crabSpeed * dt

        if self.walkTime <= 0.0 or self.collided or world:tileAt(self.position.x, self.position.y).type ~= "sand" then
            self.position = self.position - movement
            self.walking = false
            self.collided = false
            self.idleTime = crabMinIdle + math.random() * (crabMaxIdle - crabMinIdle)

            self.animation:pause(1)
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

    love.graphics.draw(self.animation.image, self.animation:getCurrentQuad(), self.position.x, self.position.y, 0, self.scale.x, self.scale.y, self.origin.x, self.origin.y)

    utils.debugDrawCircle(255, 0, 0, 255, self:getCircle())
end

function Crab:chooseTarget()
    local degrees = math.random(0, 359)
    local angle = math.rad(degrees)

    if degrees >= 315 or degrees <= 45 then self.animation:play("up", "loop", 0.2)
    elseif degrees >= 45 and degrees <= 135 then self.animation:play("right", "loop", 0.2)
    elseif degrees >= 135 and degrees <= 225 then self.animation:play("down", "loop", 0.2)
    elseif degrees >= 225 and degrees <= 315 then self.animation:play("left", "loop", 0.2) end

    self.direction = Vec2(math.cos(angle), math.sin(angle))
    local distance = math.random(crabMinRange, crabMaxRange)
    self.target = self.position + self.direction * distance
    self.walkTime = distance / crabSpeed
end

function Crab:collidedWith(other)
    self.collided = true
end