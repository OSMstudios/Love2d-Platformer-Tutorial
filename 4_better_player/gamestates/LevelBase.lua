-- Each level will inherit from this class which itself inherits from Gamestate.
-- This class is Gamestate but with function for loading up Tiled maps.

local bump = require 'libs.bump.bump'
local Gamestate = require 'libs.hump.gamestate'
local Class = require 'libs.hump.class'
local sti = require 'libs.sti.sti' -- New addition here
local Entities = require 'entities.Entities'
local camera = require 'libs.camera' -- New addition here

local LevelBase = Class{
  __includes = Gamestate,
  init = function(self, mapFile)
    self.map = sti(mapFile, { 'bump' })
    self.world = bump.newWorld(32)
    self.map:resize(love.graphics.getWidth(), love.graphics.getHeight())

    self.map:bump_init(self.world)

    Entities:enter()
  end;
  Entities = Entities;
  camera = camera
}

function LevelBase:keypressed(key)
  -- All levels will have a pause menu
  if Gamestate.current() ~= pause and key == 'p' then
    Gamestate.push(pause)
  end
end

function LevelBase:positionCamera(player, camera)
  local mapWidth = self.map.width * self.map.tilewidth -- get width in pixels
  local halfScreen =  love.graphics.getWidth() / 2

  if player.x < (mapWidth - halfScreen) then -- use this value until we're approaching the end.
    boundX = math.max(0, player.x - halfScreen) -- lock camera at the left side of the screen.
  else
    boundX = math.min(player.x - halfScreen, mapWidth - love.graphics.getWidth()) -- lock camera at the right side of the screen
  end

  camera:setPosition(boundX, 0)
end

return LevelBase
