local Object = require 'Object'
local net = require 'net'
local serp = require 'serpent'
local WorldState = Object:extend()

function WorldState:new(world, settings)
	self.settings = settings
	self.data = {H = 'update' or settings.header}
	local items = world.items
	self.data.items = {}

	for _, object in ipairs(items) do
		local datum = {}

		datum.id = object.id
		if self.settings.header == 'load' then
			datum.typ = object.typ
		end
		if object.pos then
			datum.x = object.x
			datum.y = object.y
		end
	end
end

function WorldState:send(address)
	local datagram = serpent.dump(self.data)

	if (self.data.H == 'load') then
		net.send_tcp(datagram, address)
	else
		net.send_udp(datagram, address)
	end
end

return WorldState