local Object = require 'Object'
local Player = require 'objects/Player'
local WorldState = require 'WorldState'
local v = require 'Vector'
local World = Object:extend()

local id = 1

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

	object.id = id
	id = id + 1
end

function World:update(dt)
	for _, object in ipairs(self.items) do
		if (object.update) then
			object:update(dt)
		end
	end
end

function World:new_state(...)
	return WorldState(self, ...)
end

return World