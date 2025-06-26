local Address = {}

function Address:__eq(other)
	return (self.host and other.host) or (self.ip == other.ip and self.port == other.port)
end

function Address:__tostring()
	if self.host then
		return 'host'
	else
		return self.ip .. ':' .. self.port
	end
end

function Address.__concat(a, b)
	return tostring(a) .. tostring(b)
end

Address.__index = Address

function Address:new(ip, port)
	if type(ip) == 'boolean' then
		self.host = true
		return
	end
	self.host = false
	self.ip = ip
	self.port = port

	self.player = -1

	return self
end

setmetatable(Address, {
	__call = function(self, ...)
		local address = setmetatable({}, Address)
		address:new(...)
		return address
	end
})

return Address