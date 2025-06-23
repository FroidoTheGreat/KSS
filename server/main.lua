print('starting server') 

io.stdout:setvbuf("no")

local sock = require 'socket'

local address
if true then
	address = 'localhost'
else
	address = '0.0.0.0'
end

local udp = sock.udp()
print(udp:setsockname(address, 12345))

local data, msg_or_ip, port_or_nil

RUN = true

while RUN do
	data, msg_or_ip, port_or_nil = udp:receivefrom()

	if data then
		print(data)
		RUN = false
	end
end