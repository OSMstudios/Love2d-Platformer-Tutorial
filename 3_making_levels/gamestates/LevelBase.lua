-- Each level will inherit from this class which itself inherits from Gamestate.
-- This class is Gamestate but with function for loading up Tiled maps.

local Gamestate = require 'libs.hump.gamestate'
local Class = require 'libs.hump.class'

local sti = require 'libs.sti.sti'

local LevelBase = Class{
  __includes = Gamestate
}

function LevelBase:init(mapFile)
  print('LevelBase init')

  self.map = sti(mapFile, { "bump" })
end

function LevelBase:draw()
  self.map:draw()
end

function LevelBase:update(dt)
  self.map:update(dt)
end

-- All levels will have a pause menu
function LevelBase:keypressed(key)
  if Gamestate.current() ~= pause and key == 'p' then
    Gamestate.push(pause)
  end
end

return LevelBase
