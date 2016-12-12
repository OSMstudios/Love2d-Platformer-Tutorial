bump = require 'libs.bump.bump'

local gameLevel1 = {}

function gameLevel1:enter()
  ground_0 = {}
  ground_1 = {}

  -- Setup a player object to hold an image and attach a physics object
  player = {
    x = 16,
    y = 16,
    -- The first set of values are for our rudimentary physics system
    xVelocity = 0, -- current velocity on x, y axes
    yVelocity = 0,
    acc = 100, -- the acceleration of our player
    maxSpeed = 600, -- the top speed
    friction = 20, -- slow our player down - we could toggle this situationally to create icy or slick platforms
    gravity = 80, -- we will accelerate towards the bottom

    -- These are values applying specifically to jumping
    isJumping = false, -- are we in the process of jumping?
    isGrounded = false, -- are we on the ground?
    hasReachedMax = false,  -- is this as high as we can go?
    jumpAcc = 500, -- how fast do we accelerate towards the top
    jumpMaxSpeed = 11, -- our speed limit while jumping

    -- Here are some incidental storage areas
    img = nil -- store the sprite we'll be drawing
  }

  world = bump.newWorld(16)
  -- Create our player.
  player.img = love.graphics.newImage('assets/character_block.png')

  world:add(player, player.x, player.y, player.img:getWidth(), player.img:getHeight())

  -- Draw a level
  world:add(ground_0, 120, 360, 640, 16)
  world:add(ground_1, 0, 448, 640, 32)
end

function gameLevel1:update(dt)
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
      end]]
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
  end
end

function gameLevel1:draw()
  love.graphics.draw(player.img, player.x, player.y)
  love.graphics.rectangle('fill', world:getRect(ground_0))
  love.graphics.rectangle('fill', world:getRect(ground_1))
end


return gameLevel1
