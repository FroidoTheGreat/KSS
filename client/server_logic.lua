local World = require 'World'
local Map = require 'Map'
local V = require 'Vector'
local objects = require 'objects'
local Player = objects.get 'player'
local Boss = objects.get 'boss'
local clients = require 'client_manager'
local network_settings = require 'network_settings'
local game = {}

function game.init()
	game.started = false
end

function game.load()
	game.started = true
	print('starting game...')

	local r = 30 -- WHAT IS THIS?

	game.world = World()

	game.world.level_name = '1'
	game.world:load_level(game.world.level_name, #clients.clients)

	for _, client in ipairs(clients.clients) do
		client:assign_player(game.world.players[_])
	end

	local load_state = game.world:new_state({header='load'})
	game.last_state = game.world:new_state()


	for _, client in ipairs(clients.clients) do
		client:send_udp(load_state.data)
	end
end

function game.update(dt)
	game.world:update(dt)
end

return game