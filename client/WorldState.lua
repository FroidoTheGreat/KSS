local Object = require 'Object'
local net = require 'net'
local serp = require 'serpent'
local WorldState = Object:extend()

function WorldState:new(world)
	self.data = {}
	local items = world.items
	self.data.items = {}

	for _, object in ipairs(items) do
		local datum = {}

		datum.id = object.id
	end
end

function WorldState:send(address)
	local datagram = serpent.dump(self.data)

	net.send_udp(datagram, address)
end

return WorldState