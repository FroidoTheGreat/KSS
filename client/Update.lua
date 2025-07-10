local Object = require 'Object'
local v = require 'Vector'
local serpent = require 'serpent'
local data = require 'data'
local Update = Object:extend()
local render = require 'render'
local net = require 'net'

local objects = require('objects')

function Update:new(datagram)
	self.data = data.unpack(datagram)
	-- print(serpent.block(self.data))

	if (self.data.H == 'ERROR') or type(self.data) ~= 'table' then
		self.data = {}
		return
	end

	self.header = self.data.H or 'BLANK'
end

function Update:resolve(world)
	local d = self.data
	if self.header == 'update' then
		self:update(world)
	elseif self.header == 'load' then
		self:load(world)
	elseif self.header == 'connected' then
		net.connected = true
	elseif self.header == 'rejected' then
		net.rejected = true
		net.rejection_reason = tostring(d.reason)
	elseif self.header == 'me' then
		if type(d.id) == 'number' then
			world.me_id = d.id
		end
	else
		print('unrecognized header: ' .. tostring(self.header))
	end
end

function Update:load(world)
	-- map
	if not self.data.level_name then
		print('did not receive level name from server... loading example level')
		self.data.level_name = '1'
	end
	world.level_name = self.data.level_name
	world:load_level(self.data.level_name, self.data.num_players)
	render.load_level(world.map.data.sprite)

	world.started = true
end

function Update:update(world)
	for _, datum in ipairs(self.data.items) do
		local object = world:find_by_id(datum.id)
		if object then
			for k, value in pairs(datum) do
				if k ~= 'id' then
					if type(value) ~= 'table' then
						object[k] = value
					else
						object[k] = v(value.x or 0, value.y or 0)
					end
				end
			end
		elseif datum.id then
			local class = objects.get(datum.typ)
			if class then
				object = world:add(class(datum), datum.id)
			else
				print('WARNING: should have created object but type was blank')
				-- at this point the client should probably request a fix from the server
				-- this would simply amount to asking the details of the object with this ID
			end
		else
			print('no id for some reason')
		end
	end
end

return Update