local Object = require 'Object'
local Player = require 'objects/Player'
local WorldState = require 'WorldState'
local controller = require 'controller'
local v = require 'Vector'
local World = Object:extend()

local next_id = 1

function World:new()
	self.items = {}
end

function World:add(object, id)
	table.insert(self.items, object)

	if id then
		object.id = id
	else
		object.id = next_id
		next_id = next_id + 1
	end
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

function World:find_by_id(id)
	for _, o in ipairs(self.items) do
		if o.id == id then
			return o
		end
	end
end

return World