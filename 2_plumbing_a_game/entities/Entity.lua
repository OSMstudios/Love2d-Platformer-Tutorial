-- Represents a single drawable object
local Class = require 'libs.middleclass.middleclass'

local Entity = Class('Entity')

-- Entities must have a :initialize, :draw, :update
function Entity:initialize(x, y)
  self.x = x
  self.y = y
end

function Entity:getRect()
  return self.x, self.y, self.w, self.h
end

function Entity:draw()
  -- Do nothing by default
end

function Entity:update(dt)

end

return Entity
