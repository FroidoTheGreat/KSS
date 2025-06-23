local sock = require 'socket'

local udp = sock.udp()

local data, msg_or_ip, port_or_nil

RUN = true

while RUN do
	data, msg_or_ip, port_or_nil = udp:receivefrom()

	if data then
		print(data)
		RUN = false
	end
end