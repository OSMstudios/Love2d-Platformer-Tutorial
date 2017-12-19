local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local player = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function player:init(world, x, y)
  self.img = love.graphics.newImage('/assets/character_block.png')
  self.x, self.y = x, y

  Entity.init(self, world, x, y, self.img:getWidth(), self.img:getHeight())
  self.world:add(self, self:getRect())

  -- Add our unique player values
  self.xRelativeVelocity = 0
  self.yRelativeVelocity = 0
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
end

function player:update(dt)
  local prevX, prevY = self.x, self.y

  -- Process inputs from the player.
  -- self:playerInput(dt)

  if not self.ground then
    self.yVelocity = self.yVelocity + self.gravity * dt -- Apply gravity
  end

  self.ground = nil
  self:move(dt)
end

function player:draw()
  love.graphics.draw(self.img, self.x, self.y)
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
  self.ground = other
  self.y      = self.ground.y - self.h
  self.world:update(self, self.x, self.y)
end

function player:checkIfOnGround(ny, other)
  if ny < 0 then
    self.ground = other
  end
end

function player:keypressed(key)

end

function player:keyreleased(key)

end

return player
