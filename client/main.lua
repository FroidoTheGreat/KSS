local net = require 'net'
local render = require 'render'
local v = require 'Vector'

local objects = require 'objects'
objects.load 'client'

local World = require 'World'
local controller = require 'controller'

local Player = objects.get 'player'

local world
local player

local client
local udp
local tcp

local CONNECTED = false
local REJECTED = false
local STARTED = false

function love.load()
	net.load()
	udp = net.udp
	tcp = net.tcp

	client = require 'client_network'

	client.load()

	world = World()
end

function love.update(dt)
	local cmds = client.receive_updates()
	for _, cmd in ipairs(cmds) do
		cmd:resolve(world)
	end
	CONNECTED = net.connected or false
	STARTED = world.started or false
	REJECTED = net.rejected

	if STARTED then
		if world then
			if world.me_id and not world.me then
				local player = world:find_by_id(world.me_id)

				if player and player.typ == 'player' then
					world.me = player
					player.controls = controller.actions
				else
					--print('no player object matching player id')
				end
			end

			world:update(dt)
		end
	elseif CONNECTED then

	elseif REJECTED then

	else
		client.request_connection(dt)
	end
end

function love.draw()
	if STARTED then
		if world then
			if world.me then
				controller.update(world.me)
			end
			render.draw(world)
		end
	elseif CONNECTED then
		love.graphics.print("waiting for players...", 10, 10)
	elseif REJECTED then
		love.graphics.print("server rejected connection because: " .. net.rejection_reason, 10, 10)
	else
		love.graphics.print("waiting for server connection...", 10, 10)
	end
end