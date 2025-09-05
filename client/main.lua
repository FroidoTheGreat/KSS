love.graphics.setDefaultFilter('nearest', 'nearest')

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

	client = require 'client_network'

	client.load()

	world = World()

	render.load()
end

function love.update(dt)
	client.ping_timer = client.ping_timer - dt
	if client.ping_timer < 0 then
		client.send_ping()
	end

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
					player.controller = controller
				else
					--print('no player object matching player id')
				end
			end

			if world.me then
				controller.update(world.me, render.getOffset())
			end

			world:update(dt)

			render.update(dt, world)
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
			render.draw(world)
		end
	elseif CONNECTED then
		love.graphics.print("waiting for players...", 10, 10)
	elseif REJECTED then
		love.graphics.print("server rejected connection because: " .. net.rejection_reason, 10, 10)
	else
		love.graphics.print("waiting for server connection...", 10, 10)
	end
	love.graphics.print(love.timer.getFPS(), 10, 10)
end

function love.quit()
	print('STOPPING GAME...')
	print('\n\n\n')
end