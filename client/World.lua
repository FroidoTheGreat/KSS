local Object = require 'Object'
local Map = require 'Map'
local objects = require 'objects'
local Player = objects.get 'player'
local WorldState = require 'WorldState'
local controller = require 'controller'
local v = require 'Vector'
local World = Object:extend()

local next_id = 1

function World:new()
	self.items = {}
	self.players = {}
end

function World:add(object, id)
	if id then
		object.id = id
	else
		object.id = next_id
		next_id = next_id + 1
	end

	self.items[object.id] = object
	if object.post_load then
		object:post_load()
	end

	if object.typ == 'player' then
		table.insert(self.players, object)
	end

	return object
end

function World:update(dt)
	for _, object in pairs(self.items) do
		if (object.update) then
			object:update(dt, self)
		end
		if (object.post_update) then
			object:post_update(dt, self)
		end

		if object.purge then
			self.items[_] = nil
		end
	end
end

function World:load_level(name, num_players)
	self.map = Map(name)
	local data = self.map.data

	for i=1, num_players or 0 do
		local spawn = data.spawns[i]
		self:add(objects.get('player')({
			x = spawn.x,
			y = spawn.y,
			name = spawn.name
		}))
	end

	for _, datum in ipairs(data.objects) do
		self:add(objects.get(datum.typ)(datum.t))
	end
end

function World:new_state(...)
	return WorldState(self, ...)
end

function World:find_by_id(id)
	return self.items[id]
end

return World