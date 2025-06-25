local Object = require 'Object'
local v = require 'Vector'
local serpent = require 'serpent'
local Update = Object:extend()
local Player = require 'objects/Player'
local net = require 'net'

function Update:new(datagram)
	ok, self.data = serpent.load(datagram)

	if (not ok) or type(self.data) ~= 'table' then
		self.header = 'ERROR'
		self.data = {}
		return
	end

	self.header = self.data.H or 'BLANK'
end

function Update:resolve(world)
	if self.header == 'update' then
		self:update(world)
	elseif self.header == 'load' then
		self:load(world)
	elseif self.header == 'connected' then
		net.connected = true
	elseif self.header == 'rejected' then
		net.rejected = true
		net.rejection_reason = self.data.reason
	else
		print('unrecognized header: ' .. self.header)
	end
end

function Update:load(world)
	for _, datum in ipairs(self.data.items) do
		local class
		if datum.typ == 'player' then
			class = Player
		else end
		if class then
			world:add(class(datum), datum.id)
		end
	end

	world.started = true
end

function Update:update(world)
	for _, datum in ipairs(self.data.items) do
		local object = world:find_by_id(datum.id)
		if object then
			if datum.x or datum.y then
				object.pos = v(datum.x, datum.y or object.pos.y)
			end
		end
	end
end

return Update