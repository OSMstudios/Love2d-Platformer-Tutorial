-- Pull in the Bump library
bump = require 'libs.bump.bump'

-- Pull in Gamestate from the HUMP library
Gamestate = require 'libs.hump.gamestate'

-- Let's add some awesome debugging tools
require 'libs.tableutils' -- some table management functions
                     -- one of which allows us to print tables
lovebird = require 'libs.lovebird.lovebird'

-- Pull in each of our game states
local mainMenu = require 'gamestates.mainmenu'
local gameLevel1 = require 'gamestates.gameLevel1'
local pause = require 'gamestates.pause'

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(gameLevel1)
end

function love.update(dt)
  lovebird.update()
end

function love.keypressed(key)
  if key == "escape" then
		love.event.push("quit")
	end

  if Gamestate.current() ~= mainMenu and Gamestate.current() ~= pause and key == 'p' then
    Gamestate.push(pause)
  end
end
