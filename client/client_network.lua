local client = {}

local net = require 'net'
local serpent = require 'serpent'
local Update = require 'Update'

local udp

local ip, port
if net.settings.p2p then

elseif net.settings.localhost then
	ip, port = 'localhost', 12345
else
	ip, port = '165.232.141.132', 12345
end

function client.load()
	if net.settings.p2p then
		local thread = love.thread.newThread('server.lua')
		local input = love.thread.getChannel('input')
		local output = love.thread.getChannel('output')

		net.host(thread, input, output)
		net.send_udp('host')

		thread:start()
	else
		udp = net.udp
		udp:settimeout(0)
		udp:setpeername(ip, port)
	end

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
	net.send_udp(datagram)
end

function client.receive_updates()
	local data, msg
	local cmds = {}

	repeat
		data, msg = net.receive()
		if data then
			table.insert(cmds, Update(data))
		else

		end
	until not data

	return cmds
end

return client