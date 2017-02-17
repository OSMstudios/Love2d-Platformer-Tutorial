bump = require 'libs.bump.bump'
Gamestate = require 'libs.hump.gamestate'

local Entities = require 'entities.Entities'
local Entity = require 'entities.Entity'

local gameLevel1 = Gamestate.new()
local Player = require 'entities.player'
local Ground = require 'entities.ground'

player = nil
world = nil

function gameLevel1:enter()
  print('gameLevel1 enter')

  -- Game Levels do need collisions.
  world = bump.newWorld(16)
  Entities:enter(world, nil)

  player = Player(world, 16, 16)
  ground_0 = Ground(world, 120, 360, 640, 16)
  ground_1 = Ground(world, 0, 448, 640, 16)

  Entities:addMany({player, ground_0, ground_1})
end

function gameLevel1:update(dt)
  Entities:update(dt)
end

function gameLevel1:draw()
  Entities:draw()
end


return gameLevel1
