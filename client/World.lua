local Object = require 'Object'
local objects = require 'objects'
local Player = objects.get 'player'
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

	return object
end

function World:update(dt)
	for _, object in ipairs(self.items) do
		if (object.update) then
			object:update(dt, self)
		end
		if (object.post_update) then
			object:post_update(dt, self)
		end
	end

	for _, object in ipairs(self.items) do
		if object.purge then
			table.remove(self.items, _) -- FIXME: I can never remember how to do this properly
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