local client = {}

local net = require 'net'
local serpent = require 'serpent'
local Update = require 'Update'

local ip, port
if net.settings.localhost then
	ip, port = 'localhost', 12345
else
	ip, port = '165.232.141.132', 12345
end

function client.load()
	udp = net.udp
	udp:settimeout(0)
	udp:setpeername(ip, port)

	-- connection requests
	client.request_timer = 0
	client.request_timeout = 0.5

	-- udp:send('oh hi mark!')
end

function client.request_connection(dt)
	-- only periodically send requests
	if client.request_timer > 0 then
		client.request_timer = client.request_timer - dt
		return
	end
	client.request_timer = client.request_timer + client.request_timeout

	-- send the request to the server
	local data = {
		H = 'connect'
	}
	local datagram = serpent.dump(data)
	udp:send(datagram)
end

function client.receive_updates()
	local data, msg
	local cmds = {}

	repeat
		data, msg = net.udp:receive()
		if data then
			table.insert(cmds, Update(data))
		end
	until not data

	return cmds
end

return client