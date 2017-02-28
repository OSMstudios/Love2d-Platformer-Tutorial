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
end

function gameLevel1:draw()
  love.graphics.scale(3, 3) -- make this big! 3 times bigger

  self.map:draw() -- Remember that we inherited map from LevelBase
  Entities:draw() -- this executes the draw function for each individual Entity
end

--[[
-- Create our Gamestate
local gameLevel1 = Gamestate.new()

-- Declare a couple immportant variables
player = nil
world = nil

function gameLevel1:enter()
  -- Game Levels do need collisions.
  world = bump.newWorld(16) -- Create a world for bump to function in.

  -- Initialize our Entity System
  Entities:enter()
  --player = Player(world, 16, 16)
  --ground_0 = Ground(world, 120, 360, 640, 16)
  --ground_1 = Ground(world, 0, 448, 640, 16)

  -- Add instances of our entities to the Entity List
  Entities:addMany({player, ground_0, ground_1})
end

function gameLevel1:update(dt)
  Entities:update(dt) -- this executes the update function for each individual Entity
end

function gameLevel1:draw()
  Entities:draw() -- this executes the draw function for each individual Entity
end
]]

return gameLevel1
