local client = {}

local net = require 'net'
local serpent = require 'serpent'
local data = require 'data'
local Update = require 'Update'

local udp


local awaiting_ping
local ping_timestamp

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

	client.send_ping()
end

function client.send_ping()
	-- print('sent ping!')
	awaiting_ping = true
	ping_timestamp = net.sock.gettime()
	client.ping_timer = 1
	net.send_udp({
		H='ping'
	})
end

function client.request_connection(dt)
	-- only periodically send requests
	if client.request_timer > 0 then
		client.request_timer = client.request_timer - dt
		return
	end
	client.request_timer = client.request_timer + client.request_timeout

	-- send the request to the server
	net.send_udp({
		H = 'connect'
	})
end

function client.receive_updates()
	local d, msg
	local cmds = {}

	repeat
		d, msg = net.receive()
		if d then
			local u = Update(d)

			if u.header == 'ping' then
				client.ping = net.sock.gettime() - ping_timestamp
				awaiting_ping = false
				-- print(client.ping)
			else
				table.insert(cmds, u)
			end
		else

		end
	until not d

	return cmds
end

return client