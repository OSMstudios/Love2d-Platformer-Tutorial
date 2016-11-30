-- Pull in the Bump library
bump = require 'libs.bump.bump'
-- Load up our levels using Simple Tiled Loader
sti = require 'libs.sti.sti'


world = nil -- storage place for bump

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
  jumpMaxSpeed = 9.5, -- our speed limit while jumping

  -- Here are some incidental storage areas
  img = nil -- store the sprite we'll be drawing
}

function love.load()
  -- Setup bump
  world = bump.newWorld(16)  -- 16 is our tile size
  map = sti("assets/levels/level_1.lua", { "bump" })

  -- Create our player.
  player.img = love.graphics.newImage('assets/character_block.png')

  world:add(player, player.x, player.y, player.img:getWidth(), player.img:getHeight())

  -- Draw a level
  map:bump_init(world)
  -- world:add(ground, 0, 448, 640, 32)
end

function love.update(dt)
  player.x, player.y, collisions, len = world:move(player, player.x + player.xVelocity, player.y + player.yVelocity)

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

  for i=1, len do
    --if collisions[i].other.isGround then
      player.hasReachedMax = false
      player.isGrounded = true
    --end
  end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
end

function love.draw(dt)
  love.graphics.scale(3)
  love.graphics.translate(-player.x, 0)

  map:setDrawRange(player.x, 0, love.graphics.getWidth(), love.graphics.getHeight()) -- TODO: Store width, height so we don't call these functions over and over again

  -- Draw the map and all objects within
  map:draw()

  -- Draw Collision Map (useful for debugging)
  --love.graphics.setColor(255, 0, 0, 255)
  --map:bump_draw()


  love.graphics.draw(player.img, player.x, player.y)

end
