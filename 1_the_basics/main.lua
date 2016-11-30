-- Pull in the Bump library
bump = require 'libs.bump.bump'
world = nil -- storage place for bump


ground_0 = {
  isGround = true
}

ground_1 = {
  isGround = true
}

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

function love.load()
  -- Setup bump
  world = bump.newWorld(16)  -- 16 is our tile size

  -- Create our player.
  player.img = love.graphics.newImage('assets/character_block.png')

  world:add(player, player.x, player.y, player.img:getWidth(), player.img:getHeight())

  -- Draw a level
  world:add(ground_0, 120, 360, 640, 16)
  world:add(ground_1, 0, 448, 640, 32)
end

function love.update(dt)

  --[[
  -- movement without any collision checks
  player.x = player.x + player.xVelocity
  player.y = player.y + player.yVelocity
  ]]
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

  player.filter = function(item, other)
    local x, y, w, h = world:getRect(other)
    if player.y + player.img:getHeight() <= y then
      return 'slide'
    end
  end

  player.x, player.y, collisions, len = world:move(player, goalX, goalY, player.filter)
  for i=1, len do
    if collisions[i].touch.y > goalY then
      player.hasReachedMax = true
      player.isGrounded = false
    elseif collisions[i].normal.y < 0 then
      player.hasReachedMax = false
      player.isGrounded = true
    end
  end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
end

function love.draw(dt)
  love.graphics.draw(player.img, player.x, player.y)
  love.graphics.rectangle('fill', 0, 448, 640, 32)
  love.graphics.rectangle('fill', 120, 360, 640, 16)
end
