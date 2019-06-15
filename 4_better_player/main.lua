debug = true -- Add a quick flag to handle our development process.  Set to false before packaging

-- Pull in the Bump library
bump = require 'libs.bump.bump'

-- Pull in Gamestate from the HUMP library
Gamestate = require 'libs.hump.gamestate'

-- Pull in each of our game states
local mainMenu = require 'gamestates.mainMenu'
local gameLevel1 = require 'gamestates.gameLevel1'
local pause = require 'gamestates.pause'

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(gameLevel1)
end

function love.keypressed(key)
  if debug and key == "escape" then
		love.event.push("quit")
	end
end
