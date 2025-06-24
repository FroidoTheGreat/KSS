local Object = require 'Object'
local Address = Object:extend()

function Address:new(ip, port)
	self.ip = ip
	self.port = port

	self.player = -1
end

return Address