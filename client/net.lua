--[[
this file is mostly useless.
it keeps track of the network variables
and network settings so that they
can be required whenever needed.
--]]

local net = {}

net.sock = require 'socket'
net.settings = require 'network_settings'

function net.load()
	net.udp = net.sock.udp()
	net.tcp = net.sock.tcp()
end

function net.send_udp(s, address)
	net.udp:send(s, address)
end

function net.send_udp(s, address)
	net.tcp:send(s, address)
end

return net