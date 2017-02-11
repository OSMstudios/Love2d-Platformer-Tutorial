local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local Ground = Class{
  __includes = Entity -- Ground class inherits our Entity class
}

function Ground:init(world, x, y, w, h)
  print('ground initialized')

  self.world = world
  self.x = x
  self.y = y
  self.w = w
  self.h = h

  self.world:add(self, self:getRect())
end

function Ground:draw()
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

return Ground
