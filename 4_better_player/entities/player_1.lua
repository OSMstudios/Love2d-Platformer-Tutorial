local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local player = Class{
  __includes = Entity -- Player class inherits our Entity class
}

-- Enumeration isn't technically supported in lua, but this approach
-- has a similar outcome.
local PlayerStates = {
  Idle = 0,
  Walking = 1,
  Running = 2,
  Jumping = 3,
  Dead = 4
}

function player:init(world, x, y)
  self.state = PlayerStates.Idle
  self.img = love.graphics.newImage('/assets/character_block.png')

  Entity.init(self, world, x, y, self.img:getWidth(), self.img:getHeight())

  -- Add our unique player values
  self.xRelativeVelocity = 0
  self.xVelocity = 0 -- current velocity on x, y axes
  self.yVelocity = 0
  self.acc = 500 -- the acceleration of our player
  self.brakeAccel = 500
  self.maxSpeed = 600 -- the top speed
  self.gravity = 650 -- we will accelerate towards the bottom

  -- These are values applying specifically to jumping
  self.jumpStartY = y
  self.jumpImpulse = 250
  self.jumpMaxHeight = 64 -- pixels
  self.jumpCurrentImpulse = 0

  self.world:add(self, self:getRect())
end

function player:collisionFilter(other)
  local x, y, w, h = self.world:getRect(other)
  local playerBottom = self.y + self.h
  local otherBottom = y + h

  --if playerBottom <= y then -- bottom of player collides with top of platform.
    return 'slide'
  --end
end

function player:changeVelocityByCollisionNormal(col)
  local other, normal = col.other, col.normal
  local nx, ny        = normal.x, normal.y
  local vx, vy        = self.xVelocity, self.yVelocity

  if other.xVelocity and ((nx < 0 and vx > 0) or (nx > 0 and vx < 0)) then
    self.xVelocity = other.xVelocity
    self.xRelativeVelocity  = other.xVelocity
  end

  if other.yVelocity and ((ny < 0 and vy > 0) or (ny > 0 and vy < 0)) then
    self.yVelocity = math.max(0, other.yVelocity)
  end
end

function player:setGround(other)
  self.state = PlayerStates.Idle
  self.ground = other
  self.y      = self.ground.y - self.h
  self.world:update(self, self.x, self.y)
end

function player:checkIfOnGround(ny, other)
  if ny < 0 then
    self.ground = other
  end
end

function player:playerInput(dt)
  -- Do xVelocity logic
  local vx = self.xRelativeVelocity

  if love.keyboard.isDown("left", "a") and self.xVelocity > -self.maxSpeed then
		vx = self.xVelocity - self.acc * dt
	elseif love.keyboard.isDown("right", "d") and self.xVelocity < self.maxSpeed then
		vx = self.xVelocity + self.acc * dt
  else
    local brake = dt * (vx < 0 and self.brakeAccel or -self.brakeAccel)
    if math.abs(brake) > math.abs(vx) then
      vx = 0
    else
      vx = vx + brake
    end
	end

  self.xRelativeVelocity = vx

  -- if we're grounded on a moving platform we need to move with that platform.
  if self.ground then
    groundAdjust = 0
    if self.ground.xVelocity then
      groundAdjust = self.ground.xVelocity
    end

    self.xVelocity = self.xRelativeVelocity + groundAdjust
  else
    self.xVelocity = self.xRelativeVelocity
  end

  -- Do yVelocity logic
  if love.keyboard.isDown("up", "space") then


  elseif not self.ground and self.state == PlayerStates.Jumping then
    self.yVelocity = 0
    self.state = PlayerStates.Idle
  end
end

function player:keypressed(key)
  if key ~= "up" and key ~= "space" then
    return
  end

  if self.ground then
    self.state = PlayerStates.Jumping
    self.jumpStartY = self.y
  end

  if (self.jumpStartY - self.y) < self.jumpMaxHeight then
    self.yVelocity = -self.jumpImpulse -- no need to multiply by dt because this is instantaneous
  else
    self.yVelocity = 0
  end
end

function player:keyreleased(key)
  if key ~= "up" and key ~= "space" then
    return
  end


end

function player:move(dt)
  local world = self.world

  local goalX = self.x + self.xVelocity * dt
  local goalY = self.y + self.yVelocity * dt

  local actualX, actualY, collisions, len = world:check(self, goalX, goalY, self.filter)

  for i, col in ipairs(collisions) do
    self:changeVelocityByCollisionNormal(col)
    self:checkIfOnGround(col.normal.y, col.other)
  end

  self.x, self.y = actualX, actualY
  world:update(self, actualX, actualY)
end

function player:update(dt, index)
  local prevX, prevY = self.x, self.y

  -- Process inputs from the player.
  self:playerInput(dt)

  if not self.ground and self.state ~= PlayerStates.Jumping then
    self.yVelocity = self.yVelocity + self.gravity * dt -- Apply gravity
  end

  self.ground = nil
  self:move(dt)
end

function player:draw()
  love.graphics.draw(self.img, self.x, self.y)
end

return player
