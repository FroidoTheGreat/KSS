print('starting server...')

math.randomseed(os.time())

local objects = require 'objects'
objects.load 'server'

local net = require 'net'
local serpent = require 'serpent'
local Command = require 'Command'
local Address = require 'Address'
local Client = require 'Client'
local World = require 'World'
local Player = objects.get 'player'
local clients = require 'client_manager'
local game = require 'server_logic'

-- game initiation
game.init()

-- when run in a thread
local channel
if love then
	channel = {}
	channel.input = love.thread.getChannel('input')
	channel.output = love.thread.getChannel('output')
	channel.connected = false
	net.host(nil, channel.input, channel.output)
end

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

-- clients
local NUM_PLAYERS = net.settings.num_players
clients.load()

-- timers
local time
local last_time = net.sock.gettime()
local dt

local tic_timer = 0
local update_timer = 0
local tic_rate = 1/60
local update_rate = 1/60

-- mainloop
local RUN = true
while RUN do
	-- collect messages
	local data, ip, port
	local cmds = {}

	-- first from main thread (if applicable)
	if channel then
		if not channel.connected then
			local msg = net.receive_from_thread()
			if msg == 'host' then
				channel.connected = true
			end
		end
		if channel.connected then
			local num_messages = channel.input:getCount()
			for i=1, num_messages do
				data = net.receive_from_thread()

				local cmd = Command(data, Address(true))
				table.insert(cmds, cmd)
			end
		end
	end
	-- then from udp
	repeat
		data, ip, port = net.receive_from_udp()

		if data then
			local cmd = Command(data, Address(ip, port))
			table.insert(cmds, cmd)
		elseif ip ~= 'timeout' then
			print('Network error: ' .. tostring(ip))
		end
	until not data
	-- then from tcp (eventually)

	-- resolve commands
	for _, cmd in ipairs(cmds) do
		local client
		if cmd.header == 'connect' then
			if game.started then
				net.sendto({H='rejected', reason='game started'}, cmd.address)
			else
				client = Client(cmd.address)
				clients.add(client)
				client:send_udp({H='connected'})
				-- FIXME: don't let just anyone in
			end
		else
			client = clients.get(cmd.address)
			if client then
				client:resolve_command(cmd)
			end
		end
	end

	-- control time and updates
	time = net.sock.gettime()
	dt = time - last_time
	last_time = time
	update_timer = update_timer + dt
	tic_timer = tic_timer + dt

	if game.started then
		while update_timer > update_rate do
			update_timer = update_timer - update_rate
			game.update(update_rate)
		end

		if tic_timer > tic_rate then
			tic_timer = tic_timer - tic_rate
			local update_state = game.world:new_state({
				last = game.last_state
			})
			game.last_state = update_state
			for _, client in ipairs(clients.clients) do
				client:send_udp(update_state.data)
			end
		end
	elseif #clients.clients >= NUM_PLAYERS then
		game.load()
	end

	net.sock.sleep(0.001)
end
