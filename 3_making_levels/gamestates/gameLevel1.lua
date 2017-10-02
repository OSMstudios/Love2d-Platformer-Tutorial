-- Import our libraries.
local Gamestate = require 'libs.hump.gamestate'
local Class = require 'libs.hump.class'

-- Grab our base class
local LevelBase = require 'gamestates.LevelBase'

-- Import our Entity system.
local Entities = require 'entities.Entities'

-- Import the Entities we will build.
local Player = require 'entities.player'
local camera = require 'libs.camera'

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

  player = Player(self.world,  32, 64)
  Entities:add(player)
end

function gameLevel1:update(dt)
  self.map:update(dt) -- remember, we inherited map from LevelBase
  Entities:update(dt) -- this executes the update function for each individual Entity

  LevelBase.positionCamera(self, player, camera)
end

function gameLevel1:draw()
  -- Attach the camera before drawing the entities
  camera:set()

  self.map:draw() -- Remember that we inherited map from LevelBase
  Entities:draw() -- this executes the draw function for each individual Entity

  camera:unset()
  -- Be sure to detach after running to avoid weirdness
end

-- All levels will have a pause menu
function gameLevel1:keypressed(key)
  Entities:keypressed(key)
end

function gameLevel1:keyreleased(key)
  Entities:keyreleased(key)
end

return gameLevel1
