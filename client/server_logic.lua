local World = require 'World'
local V = require 'Vector'
local objects = require 'objects'
local Player = objects.get 'player'
local Boss = objects.get 'boss'
local clients = require 'client_manager'
local game = {}

function game.init()
	game.started = false
end

function game.load()
	game.started = true
	print('starting game...')

	local r = 30
	local corners = {
		V(r, r),
		V(400 - r, 400 - r),
		V(400 - r, r),
		V(r, 400 - r)
	}
	local names = {
		'blue',
		'gold',
		'green',
		'green'
	}

	game.world = World()
	for _, client in ipairs(clients.clients) do
		local player = Player({
			x = corners[_].x,
			y = corners[_].y,
			name = names[_],
			controls = client.controls
		})
		game.world:add(player)
		client:assign_player(player)
	end

	local boss = Boss({
		pos = {
			x = 200,
			y = 200,
		}
	})
	game.world:add(boss)

	local load_state = game.world:new_state({header='load'})
	game.last_state = load_state


	for _, client in ipairs(clients.clients) do
		client:send_udp(load_state.data)
	end
end

function game.update(dt)
	game.world:update(dt)
end

return game