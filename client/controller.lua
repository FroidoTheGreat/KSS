local C = {}
local net = require 'net'
local V = require 'Vector'

C.actions = {
	LEFT = false,
	RIGHT = false,
	UP = false,
	DOWN = false,
	AB1 = {
		p = false,
		x = 0,
		y = 0
	}
}

C.keyboard = {
	a = 'LEFT',
	d = 'RIGHT',
	w = 'UP',
	s = 'DOWN'
}

C.mouse = {
	'AB1',
}

C.mouse_p = V(0, 0)

function C.update(me, offx, offy, scale)
	-- can't do anything if we don't know who we are
	if not me then return end

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
	C.mouse_p = V(love.mouse.getPosition())
	C.mouse_p = ((C.mouse_p - V(offx, offy)) / scale)

	for button, v in pairs(C.mouse) do
		local isDown = love.mouse.isDown(button)
		local action = C.actions[v]

		if isDown or (action.p ~= isDown) then
			action.p = isDown

			local msg = me:mouse_event(button, action)
			if msg then
				net.send_udp(msg)
			end
		end
	end
end

--[[
local dir = (C.mouse_p - me.pos):normal()
action.x, action.y = dir.x, dir.y
local msg = {
	H = 'act',
	k = v,
	x = action.x,
	y = action.y
}
]]

return C