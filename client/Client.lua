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
		DOWN = false,
		AB1 = {
			p = false,
			x = 0,
			y = 0
		}
	}

	self.timeout = 5
end

function Client:assign_player(player)
	self.player = player
	player.controls = self.controls
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
	self.timeout = 3
	
	local d = cmd.data
	if d.H == 'act' then
		if d.k then
			if d.x then
				self.controls[d.k] = {
					p = true,
					x = d.x,
					y = d.y
				}
			else
				self.controls[d.k] = true
			end
		else
			print('received \'act\' command with no action ID')
		end
	elseif d.H == 'unact' then
		if d.k then
			if type(self.controls[d.k]) == 'table' then
				self.controls[d.k].p = false
			else
				self.controls[d.k] = false
			end
		else
			print('received \'unact\' command with no action ID')
		end
	elseif d.H == 'here' then

	else
		return false, 'unrecognized cmd header: ' .. d.H
	end

	return true
end

return Client