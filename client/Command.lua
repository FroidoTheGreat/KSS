local Object = require 'Object'
local serpent = require 'serpent'
local Command = Object:extend()

function Command:new(datagram, address)
	self.address = address

	ok, self.data = serpent.load(datagram)
	self.err = not ok

	if self.err then
		self.header = 'ERROR'
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