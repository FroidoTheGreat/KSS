-- io.stdout:setvbuf("no")

print('starting server...')

local net = require 'net'
local Command = require 'Command'
local Address = require 'Address'
local World = require 'World'

-- testing environment?
local ip
if net.settings.localhost then
	ip = 'localhost'
else
	ip = '0.0.0.0'
end

-- connect to the network
net.load()
local udp = net.udp
local tcp = net.tcp
udp:setsockname(ip, 12345)
udp:settimeout(0)
tcp:setsockname(ip, 12345)
tcp:settimeout(0)

local RUN = true
local STARTED = false

local clients = {}

local game = {}

local world

local timer = 0
local rate = 1/30
local last_time = net.sock.getttime()

-- mainloop
while RUN do
	-- collect messages
	local data, ip, port
	local cmds = {}
	repeat
		data, ip, port = udp:receivefrom()
		if not data then
			data, ip, port = tcp:receivefrom()
		end

		if data then
			local cmd = Command(data, Address(ip, port))
			cmd:print()
			table.insert(cmds, cmd)
		elseif ip ~= 'timeout' then
			print('Network error: ' .. tostring(ip))
		end
	until not data

	-- resolve commands
	for _, cmd in ipairs(cmds) do
		world:resolve_command(cmd)
	end

	-- control time and updates
	local dt = net.sock.getttime() - last_time
	timer = timer + dt
	last_time = net.sock.getttime()

	if (timer > rate) then
		timer = timer - rate
		if STARTED then
			game.update(dt)
		end
	end

	net.sock.sleep(0.01)
end

function game.load()
	world = World()
	local load_state = world:new_state({header = 'load'})
end

function game.update(dt)

end