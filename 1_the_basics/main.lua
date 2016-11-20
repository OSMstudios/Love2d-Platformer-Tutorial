-- Pull in the HardonCollider library
HC = require 'libs.HC'

ground = nil
-- Setup a player object to hold an image and attach a physics object
player = {
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
  hasReachedMax = false,
  jumpAcc = 500, -- how fast do we accelerate towards the top
  jumpMaxSpeed = 8, -- our speed limit while jumping

  -- Here are some incidental storage areas
  img = nil, -- store the sprite we'll be drawing
  body = nil -- this will hold the Hardon Collider
}

function player:getCorner()
  local x, y = self.body:center()
  return x - self.img:getWidth()/2, y - self.img:getHeight()/2
end

function love.load()
  -- Create our player.
  player.img = love.graphics.newImage('assets/character_block.png')
  player.body = HC.rectangle(10, 10, player.img:getWidth(), player.img:getHeight())

  -- Draw a level
  ground = love.graphics.newImage('assets/ground_block.png')
  HC.rectangle(0, 448, 640, 32)
end

function love.update(dt)
  local x, y = player:getCorner()
	player.body:move(player.xVelocity, player.yVelocity)

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
    elseif math.abs(-player.yVelocity) > player.jumpMaxSpeed then
      player.hasReachedMax = true
    end

    player.isGrounded = false -- we are no longer in contact with the ground
  end

  -- handle our collisions
  local collisions = HC.collisions(player.body)
  for shape, delta in pairs(collisions) do
    -- reset all of our jumping variables
    player.isGrounded = true -- we're on the ground. let the system know
    player.hasReachedMax = false -- reset our jump max
    player.body:move(delta.x, delta.y) -- resolve our collision by moving the player away
  end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
end

function love.draw(dt)
  love.graphics.draw(player.img, player:getCorner())
  love.graphics.rectangle('fill', 0, 448, 640, 32)
end
