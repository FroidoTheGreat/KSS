-- io.stdout:setvbuf("no")

print('starting server...')

local net = require 'net'
local Command = require 'Command'

-- testing environment?
local ip
if net.settings.localhost then
	ip = 'localhost'
else
	ip = '0.0.0.0'
end

-- connect to the network
net.load()
local udp = net.udp
local tcp = net.tcp
udp:setsockname(ip, 12345)
udp:settimeout(0)

RUN = true
MAX_MESSAGES = 500

-- mainloop
while RUN do
	-- read messages
	local data, ip, port
	local cmds = {}
	repeat
		data, ip, port = udp:receivefrom()

		if data then
			local cmd = Command(data, ip, port)
			cmd:print()
			table.insert(cmds, cmd)
		elseif ip ~= 'timeout' then
			print('Network error: ' .. tostring(ip))
		end
	until not data
end