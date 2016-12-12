-- Pull in the Bump library
bump = require 'libs.bump.bump'

-- Pull in Gamestate from the HUMP library
Gamestate = require 'libs.hump.gamestate'

-- Let's add some awesome debugging tools
require 'libs.tableutils' -- some table management functions
                     -- one of which allows us to print tables
lovebird = require 'libs.lovebird.lovebird'

-- Pull in each of our game states
--local mainMenu = require 'gamestates.mainmenu'
local gameLevel1 = require 'gamestates.gameLevel1'


function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(gameLevel1)
end

function love.update(dt)
  lovebird.update()
end

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

  player.filter = function(item, other)
    local x, y, w, h = world:getRect(other)
    local px, py, pw, ph = world:getRect(item)
    local playerBottom = py + ph
    local otherBottom = y + h

    if playerBottom <= y then -- collide with top
      return 'slide'
    --[[elseif py >= otherBottom then
      return nil -- no collision. We pass through the bottom of this platform
    elseif math.max(playerBottom, otherBottom) - math.min(py, y) <= ph + h then
      -- http://stackoverflow.com/questions/3269434/whats-the-most-efficient-way-to-test-two-integer-ranges-for-overlap
      return 'bounce'
    end
  end

  player.x, player.y, collisions, len = world:move(player, goalX, goalY, player.filter)
  for i=1, len do
    if collisions[i].touch.y > goalY and collisions[i].type == 'bounce' then
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
]]
