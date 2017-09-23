-- Import our libraries.
local Gamestate = require 'libs.hump.gamestate'
local Class = require 'libs.hump.class'

-- Grab our base class
local LevelBase = require 'gamestates.LevelBase'

-- Import our Entity system.
local Entities = require 'entities.Entities'

-- Import the Entities we will build.
local Player = require 'entities.player'

-- Declare a couple immportant variables
player = nil

local gameLevel1 = Class{
  __includes = LevelBase
}

function gameLevel1:init()
  LevelBase.init(self, 'assets/levels/level_1.lua')
end

function gameLevel1:enter()
  Entities:enter()

  player = Player(self.world,  16, 16)
  Entities:add(player)
end

function gameLevel1:update(dt)
  self.map:update(dt) -- remember, we inherited map from LevelBase
  Entities:update(dt) -- this executes the update function for each individual Entity

  local mapWidth = self.map.width * self.map.tilewidth -- get width in pixels

  if player.x < (mapWidth - 240) then -- use this value until we're approaching the end.
    boundX = math.max(107, player.x) -- lock camera at the left side of the screen.
  else
    boundX = math.min(player.x, mapWidth - 107) -- lock camera at the right side of the screen
  end

  self.cam:lookAt(boundX, 80)
end

function gameLevel1:draw()
  self.cam:attach()
  self.map:draw() -- Remember that we inherited map from LevelBase
  Entities:draw() -- this executes the draw function for each individual Entity
  self.cam:detach()
end

-- All levels will have a pause menu
function gameLevel1:keypressed(key)
  Entities:keypressed(key)
end

function gameLevel1:keyreleased(key)
  Entities:keyreleased(key)
end

return gameLevel1
