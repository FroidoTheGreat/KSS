local net = require 'net'
local render = require 'render'
local v = require 'Vector'

local World = require 'World'
local Player = require 'objects/Player'

local world
local player

local client
local udp
local tcp

local CONNECTED = false
local STARTED = false

function love.load()
	net.load()
	udp = net.udp
	tcp = net.tcp

	client = require 'client_network'

	client.load()
end

function love.update(dt)
	if STARTED then
		if world then
			world:update(dt)
		end
	elseif CONNECTED then

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
	else
		love.graphics.print("waiting for server connection...", 10, 10)
	end
end