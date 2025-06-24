local Object = require 'Object'
local serpent = require 'serpent'
local Command = Object:extend()

function Command:new(datagram, ip, port)
	self.ip = ip or 0
	self.port = port or 0

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
	print('received command from ' .. self.ip .. ':' .. self.port)
	print('- ' .. self.header .. ' -')
end

return Command