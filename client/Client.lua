local Object = require 'Object'
local serpent = require 'serpent'
local net = require 'net'
local Client = Object:extend()

function Client:new(address, tcp)
	self.tcp = tcp

	self.address = address

	self.controls = {
		LEFT = false,
		RIGHT = false,
		UP = false,
		DOWN = false
	}
end

function Client:assign_player(player)
	self.player = player
	self:send_udp({
		H = 'me',
		id = player.id
	})
end

function Client:send_udp(datagram)
	if type(datagram) == 'table' then
		datagram = serpent.dump(datagram)
	end
	net.sendto(datagram, self.address)
end

function Client:resolve_command(cmd)
	local d = cmd.data
	if d.H == 'act' then
		if d.k then
			self.controls[d.k] = true
		else
			print('received \'act\' command with no action ID')
		end
	elseif d.H == 'unact' then
		if d.k then
			self.controls[d.k] = false
		else
			print('received \'unact\' command with no action ID')
		end
	else
		return false, 'unrecognized cmd header: ' .. d.H
	end

	return true
end

return Client