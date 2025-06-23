local sock = require 'socket'

local udp

local address, port = '165.232.141.132', 12345

function love.load()
	udp = sock.udp()

	udp:settimeout(0)

	udp:setpeername(address, port)

	udp:send('oh hi mark!')
end

function love.update(dt)

end

function love.draw()
	
end