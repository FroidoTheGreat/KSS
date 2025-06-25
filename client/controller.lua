local C = {}
local net = require 'net'

C.actions = {
	LEFT = false,
	RIGHT = false,
	UP = false,
	DOWN = false
}

C.keyboard = {
	a = 'LEFT',
	d = 'RIGHT',
	w = 'UP',
	s = 'DOWN',
}

function C.update()
	for k, v in pairs(C.keyboard) do
		local isDown = love.keyboard.isDown(k)
		if isDown ~= C.actions[v] then
			C.actions[v] = isDown
			local H = 'act'
			if not isDown then H = 'unact' end
			net.send_udp({
				H = H,
				k = v
			})
		end
	end
end

return C