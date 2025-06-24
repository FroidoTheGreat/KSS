local Object = require 'Object'
local Player = require 'objects/Player'
local WorldState = require 'WorldState'
local v = require 'Vector'
local World = Object:extend()

function World:new()
	self.items = {}

	self.player = Player({
		x = 100,
		y = 100
	})
	self:add(player)
end

function World:add(object)
	table.insert(self.items, object)
end

function World:update(dt)
	for _, object in ipairs(self.items) do
		if (object.update) then
			object:update(dt)
		end
	end
end

function World:newWorldState()
	return WorldState(self)
end

return World