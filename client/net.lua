--[[
this file is mostly useless.
it keeps track of the network variables
and network settings so that they
can be required whenever needed.
--]]

local net = {}

net.sock = require 'socket'
net.settings = require 'network_settings'
local serpent = require 'serpent'
local data = require 'data'

function net.load()
	net.udp = net.sock.udp()
	net.tcp = net.sock.tcp()
end

function net.send_udp(s)
	if type(s) == 'table' then
		s = data.pack(s)
	end
	if net.settings.p2p then
		net.input:push(s)
	else
		net.udp:send(s)
	end
end

function net.receive()
	if net.settings.p2p then
		return net.output:pop()
	else
		return net.udp:receive()
	end
end

function net.receive_from_udp()
	return net.udp:receivefrom()
end
function net.receive_from_thread()
	return net.input:pop()
end

function net.sendto(s, address)
	if type(s) == 'table' then
		s = data.pack(s)
	end
	--[[local prcnt = math.floor( 100 * 100 * ((#s)/8000) ) / 100
	if prcnt > 0.1 then
		print(prcnt)
	end]]
	if address.host then
		net.output:push(s)
	else
		net.udp:sendto(s, address.ip, address.port)
	end
end

function net.host(thread, input, output) -- input means server input
	net.thread = thread
	net.input = input
	net.output = output
end

return net