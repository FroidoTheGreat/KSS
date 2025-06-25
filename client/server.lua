-- io.stdout:setvbuf("no")

print('starting server...')

local net = require 'net'
local serpent = require 'serpent'
local Command = require 'Command'
local Address = require 'Address'
local Client = require 'Client'
local World = require 'World'
local Player = require 'objects/Player'

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

local RUN = true
local STARTED = false

local NUM_PLAYERS = net.settings.num_players
local clients = {}
function clients:get(address)
	for _, client in ipairs(self) do
		if client.address.ip == address.ip and client.address.port == address.port then
			return client
		end
	end
end

local game = {}

local world

local tic_timer = 0
local tic_rate = 1/60
local tic_last_time = net.sock.gettime()

local update_timer = 0
local update_rate = 1/60
local update_last_time = net.sock.gettime()

-- mainloop
function game.load()
	STARTED = true

	world = World()
	for _, client in ipairs(clients) do
		local player = Player({
			x = math.random(30, 400),
			y = math.random(30, 400),
			controls = client.controls
		})
		world:add(player)
		client:assign_player(player)
	end
	local load_state = world:new_state({header='load'}).data

	for _, client in ipairs(clients) do
		client:send_udp(load_state)
	end
end

function game.update(dt)
	world:update(dt)
end

while RUN do
	-- collect messages
	local data, ip, port
	local cmds = {}
	repeat
		data, ip, port = udp:receivefrom()

		if data then
			local cmd = Command(data, Address(ip, port))
			table.insert(cmds, cmd)
		elseif ip ~= 'timeout' then
			print('Network error: ' .. tostring(ip))
		end
	until not data

	-- resolve commands
	for _, cmd in ipairs(cmds) do
		local client
		if cmd.header == 'connect' then
			if STARTED then
				udp:sendto(serpent.dump({H='rejected', reason='game started'}), cmd.address.ip, cmd.address.port)
			else
				client = Client(cmd.address)
				table.insert(clients, client)
				udp:sendto(serpent.dump({H='connected'}), cmd.address.ip, cmd.address.port)
				-- FIXME: don't let just anyone in
			end
		else
			client = clients:get(cmd.address)
			client:resolve_command(cmd)
		end
	end

	-- control time and updates
	local time = net.sock.gettime()
	local dt = time - tic_last_time
	tic_timer = tic_timer + dt
	tic_last_time = time

	update_timer = update_timer + (time - update_last_time)
	update_last_time = time

	if STARTED then
		if (tic_timer > tic_rate) then
			tic_timer = tic_timer - tic_rate

			local update_state = world:new_state().data
			for _, client in ipairs(clients) do
				client:send_udp(update_state)
			end
		end

		if (update_timer > update_rate) then
			update_timer = update_timer - update_rate

			game.update(dt)
		end
	elseif #clients >= NUM_PLAYERS then
		game.load()
	end

	net.sock.sleep(0.01)
end