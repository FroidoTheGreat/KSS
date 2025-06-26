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
	local d = self.data
	print(serpent.block(d))
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
				-- FIXME: make this smooth
				local new_pos = v(datum.x or object.pos.x, datum.y or object.pos.y)
				local old_pos = object.pos
				local distance = (new_pos - old_pos):magnitude()
				object.pos = new_pos
			end
			for k, v in pairs(object) do
				if k ~= 'x' and k ~= 'y' and k ~= 'id' then
					object[k] = v
				end
			end
		end
	end
end

return Update