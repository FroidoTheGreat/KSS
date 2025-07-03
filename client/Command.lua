local Object = require 'Object'
local serpent = require 'serpent'
local data = require 'data'
local Command = Object:extend()

function Command:new(datagram, address)
	self.address = address

	self.data = data.unpack(datagram)

	if self.header == 'ERROR' then
		self.data = {}
		return
	end

	self.header = self.data.H or 'BLANK'
end

function Command:print()
	print('received command from ' .. self.address.ip .. ':' .. self.address.port)
	print('- ' .. self.header .. ' -')
end

return Command