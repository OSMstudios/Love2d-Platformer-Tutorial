local Class = require 'libs.middleclass.middleclass'
local Entity = require 'entities.Entity'

local Ground = Class('Ground', Entity)

function Ground:initialize(world, x, y, w, h)
  print('ground initialized')

  self.world = world
  self.x = x
  self.y = y
  self.w = w
  self.h = h

  print(self)
  self.world:add(self, self:getRect())
end

function Ground:draw()
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

return Ground
