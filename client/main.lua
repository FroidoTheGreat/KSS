local net = require 'net'
local render = require 'render'
local v = require 'Vector'

local World = require 'World'
local Player = require 'objects/Player'
local controller = require 'controller'

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
		controller.update()
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
end