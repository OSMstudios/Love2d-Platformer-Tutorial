bump = require 'libs.bump.bump'

local Entities = require 'entities.Entities'
local Entity = require 'entities.Entity'

local gameLevel1 = {}
local Player = require 'entities.player'
local Ground = require 'entities.ground'

player = nil
world = nil

function gameLevel1:enter()
  print('gameLevel1 enter')

  -- Game Levels do need collisions.
  world = bump.newWorld(16)
  Entities:enter(world, nil)

  player = Player(world, 16, 16)
  ground_0 = Ground(world, 120, 360, 640, 16)
  ground_1 = Ground(world, 0, 448, 640, 16)

  Entities:addMany({player, ground_0, ground_1})
end

function gameLevel1:update(dt)
  Entities:update(dt)

  --[[

  local prevX, prevY = player.x, player.y

  -- Apply Friction
  player.xVelocity = player.xVelocity * (1 - math.min(dt * player.friction, 1))
  player.yVelocity = player.yVelocity * (1 - math.min(dt * player.friction, 1))

  -- Apply gravity
  player.yVelocity = player.yVelocity + player.gravity * dt

	if love.keyboard.isDown("left", "a") and player.xVelocity > -player.maxSpeed then
		player.xVelocity = player.xVelocity - player.acc * dt
	elseif love.keyboard.isDown("right", "d") and player.xVelocity < player.maxSpeed then
		player.xVelocity = player.xVelocity + player.acc * dt
	end

  -- The Jump code gets a lttle bit crazy.  Bare with me.
  if love.keyboard.isDown("up", "w") then
    if -player.yVelocity < player.jumpMaxSpeed and not player.hasReachedMax then
      player.yVelocity = player.yVelocity - player.jumpAcc * dt
    elseif math.abs(player.yVelocity) > player.jumpMaxSpeed then
      player.hasReachedMax = true
    end

    player.isGrounded = false -- we are no longer in contact with the ground
  end

  -- these store the location the player will arrive at should
  local goalX = player.x + player.xVelocity
  local goalY = player.y + player.yVelocity

  -- This "filters" out certain types of collisions so we only process what we care about.
  player.filter = function(item, other)
    local x, y, w, h = world:getRect(other)
    local px, py, pw, ph = world:getRect(item)
    local playerBottom = py + ph
    local otherBottom = y + h

    if playerBottom <= y then -- bottom of player collides with top of platform.
      return 'slide'
    --[[elseif py >= otherBottom then
        return nil -- no collision. We pass through the bottom of this platform
      elseif math.max(playerBottom, otherBottom) - math.min(py, y) <= ph + h then
        -- http://stackoverflow.com/questions/3269434/whats-the-most-efficient-way-to-test-two-integer-ranges-for-overlap
        return 'bounce'
      end
    end
  end

  -- Move the player while testing for collisions
  player.x, player.y, collisions, len = world:move(player, goalX, goalY, player.filter)

  -- Loop through those collisions to see if anything important is happening
  for i, coll in ipairs(collisions) do
    if coll.touch.y > goalY then  -- We touched below (remember that higher locations have lower y values) our intended target.
      player.hasReachedMax = true -- this scenario does not occur in this demo
      player.isGrounded = false
    elseif coll.normal.y < 0 then
      player.hasReachedMax = false
      player.isGrounded = true
    end
  end]]
end

function gameLevel1:draw()
  Entities:draw()
end


return gameLevel1
