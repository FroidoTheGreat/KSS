local World = require 'World'
local objects = require 'objects'
local Player = objects.get 'player'
local clients = require 'client_manager'
local game = {}

function game.init()
	game.started = false
end

function game.load()
	game.started = true
	print('starting game...')

	game.world = World()
	for _, client in ipairs(clients.clients) do
		local player = Player({
			x = math.random(30, 400),
			y = math.random(30, 400),
			controls = client.controls
		})
		game.world:add(player)
		client:assign_player(player)
	end
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